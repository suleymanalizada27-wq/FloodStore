import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';

/// Firestore layout this repository assumes (created lazily, no manual
/// setup required beyond enabling Firestore in the console):
///
/// ```
/// organizations/{orgId}          — Organization fields
/// organizations/{orgId}/members/{uid} — { role, joinedAt }
/// invitationCodes/{code}         — InvitationCode fields
/// users/{uid}                    — { activeOrganizationId }
/// ```
class FirestoreOrganizationRepository implements OrganizationRepository {
  FirestoreOrganizationRepository({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final fb.FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const OrganizationFailure('No signed-in user.', code: 'no-user');
    }
    return uid;
  }

  Organization _mapOrg(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Organization(
      id: doc.id,
      name: d['name'] as String,
      domain: d['domain'] as String,
      workspaceUrl: d['workspaceUrl'] as String?,
      logoUrl: d['logoUrl'] as String?,
      ownerId: d['ownerId'] as String,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  bool emailMatchesDomain(String email, Organization organization) {
    final at = email.indexOf('@');
    if (at == -1) return false;
    final domain = email.substring(at + 1).trim().toLowerCase();
    return domain == organization.domain.trim().toLowerCase();
  }

  @override
  Future<List<OrganizationMembership>> listMyOrganizations() async {
    final memberships = await _db
        .collectionGroup('members')
        .where('uid', isEqualTo: _uid)
        .get();

    final result = <OrganizationMembership>[];
    for (final m in memberships.docs) {
      final orgRef = m.reference.parent.parent;
      if (orgRef == null) continue;
      final orgDoc = await orgRef.get();
      if (!orgDoc.exists) continue;
      result.add(OrganizationMembership(
        organization: _mapOrg(orgDoc),
        role: OrganizationRole.values.byName(m.data()['role'] as String? ?? 'member'),
        joinedAt: (m.data()['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      ));
    }
    return result;
  }

  @override
  Future<Organization?> getActiveOrganization() async {
    final userDoc = await _db.collection('users').doc(_uid).get();
    final activeId = userDoc.data()?['activeOrganizationId'] as String?;
    if (activeId == null) return null;
    final orgDoc = await _db.collection('organizations').doc(activeId).get();
    return orgDoc.exists ? _mapOrg(orgDoc) : null;
  }

  @override
  Future<void> setActiveOrganization(String organizationId) async {
    await _db.collection('users').doc(_uid).set(
      {'activeOrganizationId': organizationId},
      SetOptions(merge: true),
    );
  }

  @override
  Future<Organization> createOrganization({
    required String name,
    required String domain,
    String? workspaceUrl,
  }) async {
    final normalizedDomain = domain.trim().toLowerCase();
    final existing = await _db
        .collection('organizations')
        .where('domain', isEqualTo: normalizedDomain)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      throw const OrganizationFailure(
        'An organization for this domain already exists — ask your admin for an invite code.',
        code: 'domain-taken',
      );
    }

    final ref = _db.collection('organizations').doc();
    final org = Organization(
      id: ref.id,
      name: name.trim(),
      domain: normalizedDomain,
      workspaceUrl: workspaceUrl?.trim(),
      ownerId: _uid,
      createdAt: DateTime.now(),
    );

    await ref.set({
      'name': org.name,
      'domain': org.domain,
      'workspaceUrl': org.workspaceUrl,
      'logoUrl': org.logoUrl,
      'ownerId': org.ownerId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await ref.collection('members').doc(_uid).set({
      'uid': _uid,
      'role': OrganizationRole.owner.name,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    await setActiveOrganization(ref.id);
    return org;
  }

  @override
  Future<Organization> joinByDomain(String companyEmail) async {
    final at = companyEmail.indexOf('@');
    if (at == -1) {
      throw const OrganizationFailure('Enter a valid company email.', code: 'invalid-email');
    }
    final domain = companyEmail.substring(at + 1).trim().toLowerCase();

    final matches = await _db
        .collection('organizations')
        .where('domain', isEqualTo: domain)
        .limit(1)
        .get();
    if (matches.docs.isEmpty) {
      throw const OrganizationFailure(
        'No organization is registered for this domain yet. Create one, or ask for an invite code.',
        code: 'no-org-for-domain',
      );
    }

    final orgDoc = matches.docs.first;
    await orgDoc.reference.collection('members').doc(_uid).set({
      'uid': _uid,
      'role': OrganizationRole.member.name,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    await setActiveOrganization(orgDoc.id);
    return _mapOrg(orgDoc);
  }

  @override
  Future<Organization> joinWithInvitationCode(String code) async {
    final normalized = code.trim().toUpperCase();
    final codeDoc = await _db.collection('invitationCodes').doc(normalized).get();
    if (!codeDoc.exists) {
      throw const OrganizationFailure('Invalid invitation code.', code: 'invalid-code');
    }
    final d = codeDoc.data()!;
    final invite = InvitationCode(
      code: normalized,
      organizationId: d['organizationId'] as String,
      role: OrganizationRole.values.byName(d['role'] as String? ?? 'member'),
      expiresAt: (d['expiresAt'] as Timestamp).toDate(),
      maxUses: d['maxUses'] as int? ?? 1,
      usedCount: d['usedCount'] as int? ?? 0,
    );
    if (!invite.isValid) {
      throw const OrganizationFailure(
        'This invitation code has expired or already been used.',
        code: 'code-exhausted',
      );
    }

    final orgDoc = await _db.collection('organizations').doc(invite.organizationId).get();
    if (!orgDoc.exists) {
      throw const OrganizationFailure('This organization no longer exists.', code: 'org-missing');
    }

    await orgDoc.reference.collection('members').doc(_uid).set({
      'uid': _uid,
      'role': invite.role.name,
      'joinedAt': FieldValue.serverTimestamp(),
    });
    await codeDoc.reference.update({'usedCount': FieldValue.increment(1)});
    await setActiveOrganization(orgDoc.id);
    return _mapOrg(orgDoc);
  }

  @override
  Future<InvitationCode> generateInvitationCode({
    required String organizationId,
    OrganizationRole role = OrganizationRole.member,
    Duration validFor = const Duration(days: 7),
    int maxUses = 1,
  }) async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0/O/1/I ambiguity
    final rand = Random.secure();
    final code = List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
    final expiresAt = DateTime.now().add(validFor);

    await _db.collection('invitationCodes').doc(code).set({
      'organizationId': organizationId,
      'role': role.name,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'maxUses': maxUses,
      'usedCount': 0,
    });

    return InvitationCode(
      code: code,
      organizationId: organizationId,
      role: role,
      expiresAt: expiresAt,
      maxUses: maxUses,
    );
  }
}
