/// Layout tokens for FloodStore: a 4pt spacing scale and a matching
/// corner-radius scale.
///
/// Nothing in the UI layer should hardcode a raw `EdgeInsets`/`double`
/// spacing or radius value — every gap, padding, and rounded corner should
/// trace back to a token here. This is what keeps rhythm consistent across
/// hundreds of future screens without a design review on every PR.
abstract final class AppSpacing {
  static const double none = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;
}

/// Corner-radius scale. `md` (16) matches the radius already used across
/// the existing input/button theme, so adopting these tokens is a
/// zero-visual-diff change for anything currently hardcoding `16`.
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double xxl = 36;

  /// Fully rounded — pills, circular avatars-in-a-box, OTP digit cells.
  static const double pill = 999;
}
