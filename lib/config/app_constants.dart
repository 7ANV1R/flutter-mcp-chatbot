import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appTitle = 'MCP Weather Chat';

  // Colors
  static const Color primaryBlue = Color(0xFF6366F1);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color darkGreen = Color(0xFF059669);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color hintGray = Color(0xFF9CA3AF);

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

  // Messages
  static const String initializingMessage =
      'Initializing MCP Weather Server...';
  static const String inputHint = 'Ask about weather in any city...';
  static const String copySuccessMessage = 'Message copied to clipboard';
}
