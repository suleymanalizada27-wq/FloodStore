import 'package:equatable/equatable.dart';

/// One signed-in device/browser, as shown in Security Center's session
/// list. IP and country are placeholders — resolving a real IP to a
/// location requires a server-side call (Firebase Auth doesn't expose the
/// client IP to the app), so these stay `null` until a Cloud Function
/// fills them in.
class DeviceSession extends Equatable {
  const DeviceSession({
    required this.id,
    required this.deviceName,
    required this.platform,
    this.browserName,
    this.ipPlaceholder,
    this.countryPlaceholder,
    required this.createdAt,
    required this.lastActiveAt,
    this.isCurrent = false,
    this.isTrusted = false,
  });

  final String id;
  final String deviceName;
  final String platform;
  final String? browserName;
  final String? ipPlaceholder;
  final String? countryPlaceholder;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final bool isCurrent;
  final bool isTrusted;

  @override
  List<Object?> get props => [
        id,
        deviceName,
        platform,
        browserName,
        ipPlaceholder,
        countryPlaceholder,
        createdAt,
        lastActiveAt,
        isCurrent,
        isTrusted,
      ];
}

/// A completed sign-in attempt, successful or not — the raw material for
/// "Login History" and "Unknown Device Detection".
class LoginHistoryEntry extends Equatable {
  const LoginHistoryEntry({
    required this.id,
    required this.method,
    required this.deviceName,
    required this.occurredAt,
    required this.wasSuccessful,
    this.wasNewDevice = false,
  });

  final String id;

  /// e.g. "Email", "Google", "GitHub", "Phone".
  final String method;
  final String deviceName;
  final DateTime occurredAt;
  final bool wasSuccessful;
  final bool wasNewDevice;

  @override
  List<Object?> get props =>
      [id, method, deviceName, occurredAt, wasSuccessful, wasNewDevice];
}

/// A 0–100 rollup of account hygiene signals, computed client-side from
/// data this app already has — no separate "score" is stored anywhere.
class SecurityScore extends Equatable {
  const SecurityScore({
    required this.score,
    required this.factors,
  });

  final int score;

  /// Human-readable contributing factors, e.g. "Email not verified (-20)".
  final List<String> factors;

  String get label {
    if (score >= 85) return 'Excellent';
    if (score >= 65) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs attention';
  }

  @override
  List<Object?> get props => [score, factors];
}
