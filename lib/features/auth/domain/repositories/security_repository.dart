import '../entities/device_session.dart';

/// Everything Security Center and the session-management UI need. Kept
/// separate from [AuthRepository] because none of this is authentication
/// itself — it's bookkeeping *about* authentication that Firebase Auth
/// doesn't retain (Firebase keeps no session history beyond "who's signed
/// in right now").
abstract interface class SecurityRepository {
  /// Call once per app start / sign-in — writes or refreshes a
  /// [DeviceSession] row for the current device so it shows up in the list
  /// and `lastActiveAt` stays current.
  Future<void> recordSession();

  Future<List<DeviceSession>> listSessions();

  Future<void> terminateSession(String sessionId);

  /// Terminates every session except the current device's.
  Future<void> terminateAllOtherSessions();

  Future<void> markDeviceTrusted(String sessionId, bool trusted);

  Future<List<LoginHistoryEntry>> listLoginHistory({int limit = 20});

  Future<void> recordLoginHistory(LoginHistoryEntry entry);
}
