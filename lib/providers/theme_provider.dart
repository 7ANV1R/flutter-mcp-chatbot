import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../config/app_colors.dart';

class ThemeProvider extends InheritedNotifier<ThemeService> {
  const ThemeProvider({
    super.key,
    required ThemeService themeService,
    required super.child,
  }) : super(notifier: themeService);

  static ThemeService of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(provider != null, 'No ThemeProvider found in context');
    return provider!.notifier!;
  }

  static ThemeService? maybeOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>();
    return provider?.notifier;
  }
}

extension ThemeExtension on BuildContext {
  ThemeService get themeService => ThemeProvider.of(this);
  PrimaryColorTheme get primaryColorTheme =>
      ThemeProvider.of(this).primaryColorTheme;

  Color get primaryColor => primaryColorTheme.color;
  Color get primaryLightColor => primaryColorTheme.lightColor;
  Color get primaryDarkColor => primaryColorTheme.darkColor;

  List<Color> get primaryGradient => primaryColorTheme.gradientColors;
  List<Color> get primaryLightGradient => primaryColorTheme.lightGradientColors;

  // Dynamic colors based on theme
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get surfaceContainerColor =>
      Theme.of(this).colorScheme.surfaceContainer;
  Color get onSurfaceColor => Theme.of(this).colorScheme.onSurface;
  Color get onSurfaceVariantColor =>
      Theme.of(this).colorScheme.onSurfaceVariant;

  // Chat specific colors
  Color get chatBubbleUserColor => primaryColor;
  Color get chatBubbleAssistantColor =>
      Theme.of(this).brightness == Brightness.light
      ? Colors.white
      : Colors.grey.shade800;

  Color get chatInputBackgroundColor =>
      Theme.of(this).brightness == Brightness.light
      ? Colors.grey.shade100
      : Colors.grey.shade800;
}
