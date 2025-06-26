import 'package:flutter/material.dart';

// Design System - All styling decisions in one place
class AppDesign {
  // Colors - Minimal palette with light gray background
  static const Color background = Color(0xFFF5F5F5);  // Light gray background everywhere
  static const Color surface = Color(0xFFFFFFFF);     // White for buttons only
  static const Color surfaceSelected = Color(0xFFE5E5E5); // Darker gray for selected state
  static const Color surfaceHover = Color(0xFFF2F2F2);    // Medium gray for hover (between white and selected)
  static const Color border = Color(0xFFE0E0E0);      // Light gray border
  static const Color text = Color(0xFF212529);        // Dark text
  static const Color textSecondary = Color(0xFF6C757D); // Secondary text
  static const Color textMuted = Color(0xFF9CA3AF);   // Muted text
  static const Color primary = Color(0xFF000000);     // Black for primary actions
  static const Color success = Color(0xFF22C55E);     // Green for completed
  static const Color warning = Color(0xFFF59E0B);     // Amber for medium priority
  static const Color error = Color(0xFFEF4444);       // Red for high priority
  static const Color accent = Color(0xFF6366F1);      // Indigo accent
  static const Color addButton = Color(0xFFFF4444);   // Nothing-style red for add buttons

  // Typography - Monospace font family
  static const String fontFamily = 'Courier New';
  
  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,  // Standardized section title size
    fontWeight: FontWeight.w600,
    color: text,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,  // Same as heading1 for consistency
    fontWeight: FontWeight.w600,
    color: text,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: text,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Spacing
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  // Component dimensions
  static const double buttonHeight = 48.0;  // Standard button height
  static const double iconSize = 24.0;      // Standard icon size

  // Border radius - Consistent across all elements
  static const double radiusSm = 4.0;
  static const double radiusMd = 12.0;  // Main radius for all pills/buttons
  static const double radiusLg = 12.0;  // Same as medium for consistency

  // Shadows - Minimal
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // Input decoration
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      hintStyle: bodySmall.copyWith(color: textMuted),
      labelStyle: bodySmall.copyWith(color: textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg), // More rounded for pill shape
        borderSide: const BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg), // More rounded for pill shape
        borderSide: const BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusLg), // More rounded for pill shape
        borderSide: const BorderSide(color: text, width: 2),
      ),
      filled: true,
      fillColor: surface, // White background for input fields
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spaceMd,
        vertical: spaceMd,
      ),
    );
  }

  // Button styles - White pills
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: surface, // White background
    foregroundColor: text,    // Black text
    textStyle: button,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd), // Consistent radius
    ),
    side: BorderSide(color: border, width: 1),
    padding: const EdgeInsets.symmetric(
      horizontal: spaceMd,
      vertical: spaceSm,
    ),
    minimumSize: Size(0, buttonHeight), // Standard height
    elevation: 0,
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    backgroundColor: surface, // White background
    foregroundColor: text,    // Black text
    textStyle: button,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd), // Consistent radius
    ),
    side: const BorderSide(color: border, width: 1),
    padding: const EdgeInsets.symmetric(
      horizontal: spaceMd,
      vertical: spaceSm,
    ),
    minimumSize: Size(0, buttonHeight), // Standard height
  );

  // Add button style - Nothing-inspired red button
  static ButtonStyle addButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: addButton, // Nothing-style red
    foregroundColor: Colors.white, // White icon
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    padding: EdgeInsets.zero,
    elevation: 0,
    animationDuration: Duration.zero, // No animations
    splashFactory: NoSplash.splashFactory, // No splash
  );

  // Tab button style - Consistent pill buttons
  static BoxDecoration tabButtonDecoration({required bool isSelected}) {
    return BoxDecoration(
      color: isSelected ? surfaceSelected : surface,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: border),
    );
  }

  // Category colors - subtle variations
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return const Color(0xFF3B82F6);
      case 'personal':
        return const Color(0xFF8B5CF6);
      case 'shopping':
        return const Color(0xFF10B981);
      case 'health':
        return const Color(0xFFF59E0B);
      default:
        return textSecondary;
    }
  }

  // App theme
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        surface: surface,
        background: background,
        error: error,
      ),
      scaffoldBackgroundColor: background,
      fontFamily: fontFamily,
      splashColor: Colors.transparent, // Remove ripple effect
      highlightColor: Colors.transparent, // Remove highlight effect
      splashFactory: NoSplash.splashFactory, // Completely disable splash
      textTheme: const TextTheme(
        headlineLarge: heading1,
        headlineMedium: heading2,
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: bodySmall,
        labelLarge: button,
        labelMedium: label,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        titleTextStyle: heading2,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 56.0, // Standard AppBar height for consistent title positioning
        centerTitle: true, // Ensure all titles are centered
      ),
      tabBarTheme: TabBarTheme(
        labelColor: text,        // Black text on selected
        unselectedLabelColor: text, // Black text on unselected too
        indicatorColor: Colors.transparent, // Hide default line indicator
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: button,
        unselectedLabelStyle: button,
        indicator: BoxDecoration(
          color: surfaceSelected, // Darker gray for selected tab
          borderRadius: BorderRadius.circular(radiusLg), // Pill shape
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceXs),
        tabAlignment: TabAlignment.center,
      ),
      cardTheme: CardTheme(
        color: background, // Gray background for cards
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
    );
  }
}
