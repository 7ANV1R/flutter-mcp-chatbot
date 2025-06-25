import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appTitle = 'MCP Weather Chat';

  // Dimensions
  static const double borderRadius = 24.0;
  static const double cardBorderRadius = 28.0;
  static const double iconSize = 20.0;
  static const double buttonSize = 48.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 400);

  // Spacing
  static const EdgeInsets defaultPadding = EdgeInsets.all(20);
  static const EdgeInsets smallPadding = EdgeInsets.all(8);
  static const EdgeInsets mediumPadding = EdgeInsets.all(16);
  static const EdgeInsets largePadding = EdgeInsets.all(24);

  // Chat constants
  static const double chatBubbleRadius = 16.0;
  static const double avatarSize = 40.0;

  // Messages
  static const String initializingMessage =
      'Initializing MCP Weather Server...';
  static const String inputHint = 'Ask about weather in any city...';
  static const String copySuccessMessage = 'Message copied to clipboard';
}
