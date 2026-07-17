import 'package:equatable/equatable.dart';

enum OrganizationRole { owner, admin, member }

/// A company workspace. FloodStore's Business accounts belong to one or
/// more of these — Individual and Guest accounts never touch this type.
class Organization extends Equatable {
  const Organization({
    required this.id,
    required this.name,
    required this.domain,
    this.workspaceUrl,
    this.logoUrl,
    required this.ownerId,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// Verified company email domain (e.g. `acme.com`) — see
  /// [OrganizationRepository.emailMatchesDomain]. Employees signing up with
  /// an `@acme.com` address auto-join instead of needing an invite code.
  final String domain;

  /// e.g. `acme` → `floodstore.app/acme`. Optional, purely cosmetic today.
  final String? workspaceUrl;

  final String? logoUrl;
  final String ownerId;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, name, domain, workspaceUrl, logoUrl, ownerId, createdAt];
}

/// A user's membership in one [Organization] — this is what makes the
/// Organization Switcher possible: a user can hold several of these at
/// once.
class OrganizationMembership extends Equatable {
  const OrganizationMembership({
    required this.organization,
    required this.role,
    required this.joinedAt,
  });

  final Organization organization;
  final OrganizationRole role;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [organization, role, joinedAt];
}

/// A single-use (or capped-use) code that lets someone join an
/// [Organization] without a matching email domain.
class InvitationCode extends Equatable {
  const InvitationCode({
    required this.code,
    required this.organizationId,
    required this.role,
    required this.expiresAt,
    this.maxUses = 1,
    this.usedCount = 0,
  });

  final String code;
  final String organizationId;
  final OrganizationRole role;
  final DateTime expiresAt;
  final int maxUses;
  final int usedCount;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isExhausted => usedCount >= maxUses;
  bool get isValid => !isExpired && !isExhausted;

  @override
  List<Object?> get props => [code, organizationId, role, expiresAt, maxUses, usedCount];
}
