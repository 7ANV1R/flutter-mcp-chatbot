# Theming System

## Overview

The Flutter MCP Chat app now includes a comprehensive theming system that supports:

- Light and Dark mode themes
- Customizable primary colors with 6 built-in color schemes
- System theme detection
- Persistent theme preferences using SharedPreferences

## Features

### Theme Modes

- **Light Mode**: Clean, bright interface optimized for daylight use
- **Dark Mode**: Dark interface optimized for low-light environments
- **System Mode**: Automatically follows the system's light/dark mode setting

### Primary Color Themes

Choose from 6 beautiful color schemes:

- **Blue** (Default): Modern blue gradient
- **Purple**: Rich purple tones
- **Green**: Fresh green palette
- **Orange**: Warm orange accent
- **Pink**: Vibrant pink theme
- **Red**: Bold red styling

### Settings Screen

Access theme customization through the settings button in the app bar:

- Switch between light, dark, and system themes
- Preview color themes with live chat bubble previews
- Changes are saved automatically and persist between app sessions

## Technical Implementation

### Key Components

#### ThemeService

- Manages theme state using `ChangeNotifier`
- Persists preferences with `SharedPreferences`
- Provides methods to update theme settings

#### ThemeProvider

- `InheritedNotifier` widget that provides theme access throughout the app
- Extension methods on `BuildContext` for easy theme access
- Dynamic color helpers for consistent theming

#### AppTheme

- Generates Material3 `ThemeData` for light and dark modes
- Uses primary color themes to create dynamic color schemes
- Maintains consistent design language across all components

### Usage

```dart
// Access theme colors anywhere in the app
context.primaryColor          // Current primary color
context.primaryGradient       // Primary gradient colors
context.chatBubbleUserColor   // Dynamic user chat bubble color
context.chatBubbleAssistantColor // Dynamic assistant chat bubble color

// Change theme programmatically
context.themeService.setThemeMode(AppThemeMode.dark);
context.themeService.setPrimaryColorTheme(PrimaryColorTheme.purple);
```

### File Structure

```
lib/
├── config/
│   ├── app_colors.dart       # Color definitions and theme enums
│   ├── app_theme.dart        # Theme generation logic
│   └── app_constants.dart    # App constants (cleaned up)
├── services/
│   └── theme_service.dart    # Theme management service
├── providers/
│   └── theme_provider.dart   # Theme provider and extensions
├── screens/
│   └── settings_screen.dart  # Theme customization UI
└── ...
```

## Design Principles

- **No hardcoded colors**: All colors are dynamic and theme-aware
- **Consistent experience**: UI adapts seamlessly to theme changes
- **Material Design 3**: Follows latest Material Design guidelines
- **Accessibility**: Proper contrast ratios maintained across all themes
- **Performance**: Efficient theme switching with minimal rebuilds

## Future Enhancements

- Custom color picker for unlimited color options
- Theme scheduling (automatic day/night switching)
- Additional color scheme variations
- Theme import/export functionality
