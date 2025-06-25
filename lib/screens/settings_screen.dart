import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Mode Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Mode',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildThemeModeSelector(context),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Primary Color Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Primary Color',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildPrimaryColorSelector(context),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Preview Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeSelector(BuildContext context) {
    final themeService = context.themeService;

    return Column(
      children: AppThemeMode.values.map((mode) {
        return RadioListTile<AppThemeMode>(
          title: Text(_getThemeModeName(mode)),
          subtitle: Text(_getThemeModeDescription(mode)),
          value: mode,
          groupValue: themeService.themeMode,
          onChanged: (value) {
            if (value != null) {
              themeService.setThemeMode(value);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildPrimaryColorSelector(BuildContext context) {
    final themeService = context.themeService;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: PrimaryColorTheme.values.map((colorTheme) {
        final isSelected = themeService.primaryColorTheme == colorTheme;

        return GestureDetector(
          onTap: () => themeService.setPrimaryColorTheme(colorTheme),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colorTheme.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: colorTheme.color.withValues(alpha: 0.3),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    const Icon(Icons.check, color: Colors.white, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    colorTheme.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewSection(BuildContext context) {
    return Column(
      children: [
        // Chat bubble preview
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Hello! This is a preview message.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: context.primaryGradient),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.assistant, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.chatBubbleAssistantColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: Text(
                'Hi there! How can I help you today?',
                style: TextStyle(color: context.onSurfaceColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getThemeModeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  String _getThemeModeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Always use light theme';
      case AppThemeMode.dark:
        return 'Always use dark theme';
      case AppThemeMode.system:
        return 'Follow system settings';
    }
  }
}
