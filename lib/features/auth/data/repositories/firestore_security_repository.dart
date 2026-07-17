import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

import '../../domain/entities/device_session.dart';
import '../../domain/repositories/security_repository.dart';

/// Firestore layout:
/// `users/{uid}/sessions/{sessionId}` and `users/{uid}/loginHistory/{id}`.
///
/// Device/platform naming is derived from [defaultTargetPlatform] rather
/// than a `device_info_plus` dependency — good enough for "Windows PC" /
/// "iPhone" / "Android device" style labels without pulling in a package
/// whose native platform channels this sandbox can't verify.
class FirestoreSecurityRepository implements SecurityRepository {
  FirestoreSecurityRepository({
    FirebaseFirestore? firestore,
    fb.FirebaseAuth? auth,
    String? sessionIdOverride,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? fb.FirebaseAuth.instance,
        _sessionId = sessionIdOverride ?? _deriveStableSessionId();

  final FirebaseFirestore _db;
  final fb.FirebaseAuth _auth;

  /// Stable for the lifetime of the app process — good enough to identify
  /// "this device" without a persisted install-id package. A real
  /// production build would persist this in [SecureTokenService] so it
  /// survives restarts; deferred here to avoid another storage read on
  /// every cold start for a nice-to-have identifier.
  final String _sessionId;

  static String _deriveStableSessionId() =>
      'sess_${DateTime.now().millisecondsSinceEpoch}';

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('No signed-in user.');
    return uid;
  }

  String get _platformLabel {
    if (kIsWeb) return 'Web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'Unknown';
    }
  }

  String get _deviceNameLabel {
    if (kIsWeb) return 'Web Browser';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'Android Device',
      TargetPlatform.iOS => 'iPhone / iPad',
      TargetPlatform.macOS => 'Mac',
      TargetPlatform.windows => 'Windows PC',
      TargetPlatform.linux => 'Linux Device',
      _ => 'Unknown Device',
    };
  }

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('users').doc(_uid).collection('sessions');

  CollectionReference<Map<String, dynamic>> get _history =>
      _db.collection('users').doc(_uid).collection('loginHistory');

  @override
  Future<void> recordSession() async {
    await _sessions.doc(_sessionId).set({
      'deviceName': _deviceNameLabel,
      'platform': _platformLabel,
      'browserName': kIsWeb ? 'Browser' : null,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActiveAt': FieldValue.serverTimestamp(),
      'isTrusted': false,
    }, SetOptions(merge: true));
  }

  @override
  Future<List<DeviceSession>> listSessions() async {
    final snapshot = await _sessions.orderBy('lastActiveAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final d = doc.data();
      return DeviceSession(
        id: doc.id,
        deviceName: d['deviceName'] as String? ?? 'Unknown Device',
        platform: d['platform'] as String? ?? 'Unknown',
        browserName: d['browserName'] as String?,
        ipPlaceholder: null,
        countryPlaceholder: null,
        createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        lastActiveAt: (d['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isCurrent: doc.id == _sessionId,
        isTrusted: d['isTrusted'] as bool? ?? false,
      );
    }).toList();
  }

  @override
  Future<void> terminateSession(String sessionId) async {
    await _sessions.doc(sessionId).delete();
    // A real implementation also revokes the corresponding refresh token
    // server-side (Firebase Admin SDK's `revokeRefreshTokens`), which
    // requires a Cloud Function this client can't invoke directly. Until
    // that Function exists, this removes the session from the *list* but
    // — if `sessionId` is the current device — does not itself force a
    // client-side sign-out; call `AuthRepository.signOut()` separately for
    // that case.
  }

  @override
  Future<void> terminateAllOtherSessions() async {
    final snapshot = await _sessions.get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      if (doc.id != _sessionId) batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> markDeviceTrusted(String sessionId, bool trusted) async {
    await _sessions.doc(sessionId).set({'isTrusted': trusted}, SetOptions(merge: true));
  }

  @override
  Future<List<LoginHistoryEntry>> listLoginHistory({int limit = 20}) async {
    final snapshot =
        await _history.orderBy('occurredAt', descending: true).limit(limit).get();
    return snapshot.docs.map((doc) {
      final d = doc.data();
      return LoginHistoryEntry(
        id: doc.id,
        method: d['method'] as String? ?? 'Unknown',
        deviceName: d['deviceName'] as String? ?? 'Unknown Device',
        occurredAt: (d['occurredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        wasSuccessful: d['wasSuccessful'] as bool? ?? true,
        wasNewDevice: d['wasNewDevice'] as bool? ?? false,
      );
    }).toList();
  }

  @override
  Future<void> recordLoginHistory(LoginHistoryEntry entry) async {
    await _history.add({
      'method': entry.method,
      'deviceName': entry.deviceName,
      'occurredAt': FieldValue.serverTimestamp(),
      'wasSuccessful': entry.wasSuccessful,
      'wasNewDevice': entry.wasNewDevice,
    });
  }
}
