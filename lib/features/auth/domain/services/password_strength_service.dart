import 'dart:math';

/// A single password rule and whether the current input satisfies it —
/// backs [PasswordRequirementsChecklist]'s live checkmarks.
class PasswordRequirement {
  const PasswordRequirement(this.label, this.isMet);
  final String label;
  final bool isMet;
}

/// Five-band password strength, cheap enough to recompute on every
/// keystroke (`PasswordStrengthMeter` calls [PasswordStrengthService.score]
/// directly from `onChanged`).
enum PasswordStrength {
  empty,
  weak,
  fair,
  good,
  strong;

  String get label => switch (this) {
        PasswordStrength.empty => '',
        PasswordStrength.weak => 'Weak',
        PasswordStrength.fair => 'Fair',
        PasswordStrength.good => 'Good',
        PasswordStrength.strong => 'Strong',
      };

  /// 0..1 fill fraction for the meter bar.
  double get fraction => switch (this) {
        PasswordStrength.empty => 0,
        PasswordStrength.weak => 0.25,
        PasswordStrength.fair => 0.5,
        PasswordStrength.good => 0.75,
        PasswordStrength.strong => 1.0,
      };
}

/// Heuristic, offline password scoring — no dependency pulled in for this,
/// deliberately, per the project's "no unnecessary packages" preference.
///
/// This is a UX signal only. The hard floor ("at least 8 characters") stays
/// enforced by [RegisterScreen]'s existing `validator`; this service never
/// blocks submission on its own.
abstract final class PasswordStrengthService {
  static PasswordStrength score(String password) {
    if (password.isEmpty) return PasswordStrength.empty;

    var points = 0;
    if (password.length >= 8) points++;
    if (password.length >= 12) points++;
    if (RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password)) {
      points++;
    }
    if (RegExp(r'[0-9]').hasMatch(password)) points++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) points++;

    if (points <= 1) return PasswordStrength.weak;
    if (points == 2) return PasswordStrength.fair;
    if (points == 3 || points == 4) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  /// Short, specific hint for whichever rule the password fails first —
  /// used as the meter's caption so the user knows exactly what to add
  /// next instead of guessing at a generic "weak" label.
  static String? nextHint(String password) {
    if (password.isEmpty) return null;
    if (password.length < 8) return 'Use at least 8 characters';
    if (!(RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[A-Z]').hasMatch(password))) {
      return 'Mix uppercase and lowercase letters';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Add a number';
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) {
      return 'Add a symbol for extra strength';
    }
    return null;
  }

  /// The individual rules [PasswordRequirementsChecklist] renders as live
  /// checkmarks. Kept separate from [nextHint] — the hint is "what to fix
  /// next", this is "everything, all at once", which is what a checklist
  /// needs.
  static List<PasswordRequirement> requirements(String password) => [
        PasswordRequirement('At least 8 characters', password.length >= 8),
        PasswordRequirement(
          'Upper and lowercase letters',
          RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password),
        ),
        PasswordRequirement('At least one number', RegExp(r'[0-9]').hasMatch(password)),
        PasswordRequirement(
          'At least one symbol',
          RegExp(r'[^a-zA-Z0-9]').hasMatch(password),
        ),
      ];

  /// A rough Shannon-entropy-style estimate in bits, based on the size of
  /// the character classes actually used — enough to back an "Entropy: ~52
  /// bits" caption, not a cryptographic guarantee.
  static double entropyBits(String password) {
    if (password.isEmpty) return 0;
    var poolSize = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) poolSize += 26;
    if (RegExp(r'[A-Z]').hasMatch(password)) poolSize += 26;
    if (RegExp(r'[0-9]').hasMatch(password)) poolSize += 10;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) poolSize += 32;
    if (poolSize == 0) return 0;
    return password.length * (log(poolSize) / ln2);
  }

  /// Checks whether [password] is one of a small set of famously common
  /// passwords — a real breach check (e.g. HaveIBeenPwned's k-anonymity
  /// range API) needs a network call this app doesn't make silently
  /// without an explicit opt-in; this local list catches the most
  /// egregious cases offline in the meantime.
  static bool isObviouslyCommon(String password) {
    const common = {
      'password', 'password1', '12345678', '123456789', 'qwerty123',
      'letmein', 'welcome1', 'admin123', 'iloveyou', 'monkey123',
    };
    return common.contains(password.toLowerCase());
  }

  /// Generates a 16-character password guaranteed to satisfy every rule in
  /// [requirements] — used by the "Generate Password" action on Register
  /// and the recovery flow's new-password step.
  static String generateStrongPassword({int length = 16}) {
    const lower = 'abcdefghijkmnpqrstuvwxyz';
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const digits = '23456789';
    const symbols = '!@#\$%^&*-_=+?';
    final random = Random.secure();

    final required = [
      lower[random.nextInt(lower.length)],
      upper[random.nextInt(upper.length)],
      digits[random.nextInt(digits.length)],
      symbols[random.nextInt(symbols.length)],
    ];

    const all = lower + upper + digits + symbols;
    final rest = List.generate(
      length - required.length,
      (_) => all[random.nextInt(all.length)],
    );

    final chars = [...required, ...rest]..shuffle(random);
    return chars.join();
  }
}
