import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Enhanced with vibrant, dramatic colors
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep royal blue
  static const Color primaryPurple = Color(0xFF7C3AED); // Vivid purple
  static const Color accentGreen = Color(0xFF10B981); // Emerald green
  static const Color accentCyan = Color(0xFF06B6D4); // Bright cyan
  static const Color accentOrange = Color(0xFFF59E0B); // Amber orange
  static const Color accentPink = Color(0xFFEC4899); // Hot pink
  static const Color accentRed = Color(0xFFEF4444); // Bright red

  // New dramatic accent colors
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonBlue = Color(0xFF0099FF);
  static const Color neonPurple = Color(0xFF8844FF);
  static const Color neonPink = Color(0xFFFF0088);

  // Background Colors
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color overlayBackground = Color(0x80000000);

  // Text Colors
  static const Color primaryText = Color(0xFF2C3E50);
  static const Color secondaryText = Color(0xFF7F8C8D);
  static const Color lightText = Colors.white;
  static const Color mutedText = Color(0xFFBDC3C7);

  // Gradient Sets - Enhanced with more dramatic combinations
  static const List<Color> primaryGradient = [primaryBlue, primaryPurple];
  static const List<Color> successGradient = [accentGreen, neonGreen];
  static const List<Color> warningGradient = [accentOrange, Color(0xFFFF6B35)];
  static const List<Color> dangerGradient = [accentRed, neonPink];
  static const List<Color> infoGradient = [neonBlue, accentCyan];
  static const List<Color> secondaryGradient = [neonPurple, accentPink];

  // New dramatic gradient combinations
  static const List<Color> sunsetGradient = [
    Color(0xFFFF6B35),
    Color(0xFFF7931E),
  ];
  static const List<Color> oceanGradient = [
    Color(0xFF0077BE),
    Color(0xFF00A8CC),
  ];
  static const List<Color> forestGradient = [
    Color(0xFF134E5E),
    Color(0xFF71B280),
  ];
  static const List<Color> galaxyGradient = [
    Color(0xFF2C1810),
    Color(0xFF8E44AD),
  ];
  static const List<Color> fireGradient = [
    Color(0xFFFF4E50),
    Color(0xFFF9D423),
  ];
  static const List<Color> iceGradient = [Color(0xFF74B9FF), Color(0xFF0984E3)];

  // Component Specific Gradients - Updated for more impact
  static const List<Color> workoutGradient = fireGradient;
  static const List<Color> progressGradient = successGradient;
  static const List<Color> goalGradient = sunsetGradient;
  static const List<Color> achievementGradient = galaxyGradient;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusRound = 50.0;

  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Typography
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryText,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: primaryText,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: primaryText,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: primaryText,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: primaryText,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: secondaryText,
    height: 1.3,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: primaryText,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: secondaryText,
  );

  // Component Builders
  static BoxDecoration cardDecoration({
    List<Color>? gradient,
    Color? backgroundColor,
    double? borderRadius,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      gradient: gradient != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            )
          : null,
      color: backgroundColor ?? cardBackground,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
      boxShadow:
          boxShadow ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
    );
  }

  static BoxDecoration overlayDecoration({
    List<Color>? gradient,
    double? borderRadius,
  }) {
    return BoxDecoration(
      gradient: gradient != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [gradient[0].withValues(alpha: 0.1), Colors.transparent],
            )
          : null,
      borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
    );
  }

  static Widget buildGradientButton({
    required String text,
    required VoidCallback onPressed,
    List<Color> gradient = primaryGradient,
    IconData? icon,
    double? width,
    double? height,
    double? borderRadius,
  }) {
    return Container(
      width: width,
      height: height ?? 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: spacingM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: lightText, size: 20),
                  const SizedBox(width: spacingS),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    color: lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildAnimatedCard({
    required Widget child,
    List<Color>? gradient,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsets? padding,
    VoidCallback? onTap,
    Duration animationDuration = const Duration(milliseconds: 200),
  }) {
    return TweenAnimationBuilder<double>(
      duration: animationDuration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOut, // Added curve to prevent overshoot
      builder: (context, value, child) {
        // Ensure value is always within valid bounds
        final clampedValue = value.clamp(0.0, 1.0);

        return Transform.scale(
          scale: 0.8 + (0.2 * clampedValue),
          child: Opacity(
            opacity: clampedValue,
            child: Container(
              decoration: cardDecoration(
                gradient: gradient,
                backgroundColor: backgroundColor,
                borderRadius: borderRadius,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(borderRadius ?? radiusM),
                  child: Padding(
                    padding: padding ?? const EdgeInsets.all(spacingM),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }

  static Widget buildHeaderSection({
    required String title,
    required String subtitle,
    List<Color> gradient = primaryGradient,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(spacingL),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: headingMedium.copyWith(color: lightText),
                    ),
                    const SizedBox(height: spacingXS),
                    Text(
                      subtitle,
                      style: bodyMedium.copyWith(
                        color: lightText.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
    List<Color> gradient = primaryGradient,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(spacingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: lightText),
            ),
            const SizedBox(height: spacingL),
            Text(title, style: headingSmall, textAlign: TextAlign.center),
            const SizedBox(height: spacingS),
            Text(
              message,
              style: bodyMedium.copyWith(color: secondaryText),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: spacingL), action],
          ],
        ),
      ),
    );
  }
}
