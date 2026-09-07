/// App-wide design constants — spacing, radii, durations.
/// Use these tokens everywhere instead of hardcoded numbers.
class AppConstants {
  AppConstants._();

  // ── Spacing ──────────────────────────────────────────────────────────────
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;
  static const double spaceXxl = 48.0;

  // ── Border radius ────────────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusPill = 100.0;

  // ── Animation durations ──────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationNormal = Duration(milliseconds: 350);
  static const Duration durationSlow = Duration(milliseconds: 600);

  // ── Splash ────────────────────────────────────────────────────────────────
  static const Duration splashDelay = Duration(seconds: 2);

  // ── OTP ───────────────────────────────────────────────────────────────────
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;
}
