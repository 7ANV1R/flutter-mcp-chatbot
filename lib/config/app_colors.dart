import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

class AppColors {
  // Blue Theme
  static const Color primaryBlue = Color(0xFF6366F1);
  static const Color primaryBlueLight = Color(0xFF818CF8);
  static const Color primaryBlueDark = Color(0xFF4F46E5);

  // Purple Theme
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryPurpleLight = Color(0xFFA78BFA);
  static const Color primaryPurpleDark = Color(0xFF7C3AED);

  // Green Theme
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryGreenLight = Color(0xFF34D399);
  static const Color primaryGreenDark = Color(0xFF059669);

  // Orange Theme
  static const Color primaryOrange = Color(0xFFF59E0B);
  static const Color primaryOrangeLight = Color(0xFFFBBF24);
  static const Color primaryOrangeDark = Color(0xFFD97706);

  // Pink Theme
  static const Color primaryPink = Color(0xFFEC4899);
  static const Color primaryPinkLight = Color(0xFFF472B6);
  static const Color primaryPinkDark = Color(0xFFDB2777);

  // Red Theme
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color primaryRedLight = Color(0xFFF87171);
  static const Color primaryRedDark = Color(0xFFDC2626);
}

enum PrimaryColorTheme {
  blue(
    'Blue',
    AppColors.primaryBlue,
    AppColors.primaryBlueLight,
    AppColors.primaryBlueDark,
  ),
  purple(
    'Purple',
    AppColors.primaryPurple,
    AppColors.primaryPurpleLight,
    AppColors.primaryPurpleDark,
  ),
  green(
    'Green',
    AppColors.primaryGreen,
    AppColors.primaryGreenLight,
    AppColors.primaryGreenDark,
  ),
  orange(
    'Orange',
    AppColors.primaryOrange,
    AppColors.primaryOrangeLight,
    AppColors.primaryOrangeDark,
  ),
  pink(
    'Pink',
    AppColors.primaryPink,
    AppColors.primaryPinkLight,
    AppColors.primaryPinkDark,
  ),
  red(
    'Red',
    AppColors.primaryRed,
    AppColors.primaryRedLight,
    AppColors.primaryRedDark,
  );

  const PrimaryColorTheme(
    this.name,
    this.color,
    this.lightColor,
    this.darkColor,
  );

  final String name;
  final Color color;
  final Color lightColor;
  final Color darkColor;

  List<Color> get gradientColors => [color, darkColor];
  List<Color> get lightGradientColors => [lightColor, color];

  static PrimaryColorTheme fromString(String name) {
    return PrimaryColorTheme.values.firstWhere(
      (theme) => theme.name.toLowerCase() == name.toLowerCase(),
      orElse: () => PrimaryColorTheme.blue,
    );
  }
}
