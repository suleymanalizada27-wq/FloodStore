import 'dart:math' as math;

import 'package:flutter/animation.dart';

/// Motion tokens for FloodStore.
///
/// "Premium" is felt more than it is seen — and it's felt almost entirely
/// through motion consistency. Every animated widget in this app (button
/// press, input focus, page transition, success check, error shake) should
/// pull its [Duration] and [Curve] from here rather than inventing its own,
/// so the whole product moves with one unmistakable signature instead of a
/// dozen slightly-different tweens.
///
/// Duration scale is deliberately tight — luxury software reacts *fast*.
/// Nothing a user directly triggers (tap, focus, keystroke) should ever
/// clear ~300ms; only ambient/ownerless motion (particles, logo breathing)
/// is allowed to run slow.
abstract final class AppMotion {
  // Durations ----------------------------------------------------------

  /// Icon/checkbox toggles, ripple start — motion that must feel instant.
  static const Duration instant = Duration(milliseconds: 100);

  /// Button press/scale, focus ring, hover state.
  static const Duration fast = Duration(milliseconds: 160);

  /// Default for most micro-interactions: field validation, card hover,
  /// shake, success pulse.
  static const Duration base = Duration(milliseconds: 240);

  /// Page-level content transitions, dialogs, bottom sheets.
  static const Duration moderate = Duration(milliseconds: 360);

  /// Hero transitions, splash → login handoff.
  static const Duration slow = Duration(milliseconds: 520);

  /// Full-screen route transitions.
  static const Duration slower = Duration(milliseconds: 680);

  /// One cycle of a continuous, ambient loop (logo breathing glow).
  static const Duration ambient = Duration(milliseconds: 3600);

  /// One drift cycle for background particles — intentionally slow so the
  /// motion reads as "alive" rather than "animated".
  static const Duration ambientSlow = Duration(milliseconds: 9000);

  // Curves ---------------------------------------------------------------

  /// Default entrance for anything appearing on screen (fields, cards,
  /// staggered list items). A soft, confident deceleration.
  static const Curve entrance = Curves.easeOutCubic;

  /// Default exit — slightly sharper than [entrance] so dismissals never
  /// feel sluggish.
  static const Curve exit = Curves.easeInCubic;

  /// Symmetric, general-purpose — page transitions, dialog scale.
  static const Curve standard = Curves.easeInOutCubic;

  /// Material 3 emphasized easing — larger, more theatrical transitions
  /// (hero logo, route changes).
  static const Curve emphasized = Curves.easeInOutCubicEmphasized;

  /// A gentle overshoot used for "arrival" moments that should feel alive:
  /// success checkmarks, the logo settling after its hero transition.
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1);

  /// Sharp deceleration with no overshoot — button press-in, ripple.
  static const Curve pressIn = Curves.easeOutQuart;

  /// Snappy return — button release.
  static const Curve pressOut = Curves.easeOutCubic;

  /// Oscillation envelope for the error shake — see [evaluateShake].
  static const Curve shake = Curves.easeInOut;

  /// Samples a decaying horizontal error-shake wave at normalized progress
  /// [t] (0..1). Consumers multiply the result by their desired pixel
  /// amplitude (typically 8-10px) and drive [t] from a single
  /// [AnimationController]:
  ///
  /// ```dart
  /// final dx = 8.0 * AppMotion.evaluateShake(controller.value);
  /// ```
  ///
  /// Four oscillations, decaying to zero — front-loaded so the "no" reads
  /// instantly rather than winding up first.
  static double evaluateShake(double t) {
    final decay = (1 - t) * (1 - t);
    return decay * math.sin(t * 4 * math.pi);
  }
}
