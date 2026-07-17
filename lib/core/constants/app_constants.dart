/// Cross-cutting constants shared by multiple features. Keep this file
/// small and stable — it's imported widely, so churn here ripples across
/// the whole app.
abstract final class AppConstants {
  static const splashDuration = Duration(milliseconds: 2500);

  // Responsive breakpoints (logical pixels), used when a screen needs to
  // branch layout beyond what a max-width constraint can express.
  static const double phoneBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
}
