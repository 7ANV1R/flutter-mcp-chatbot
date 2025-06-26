import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'app.dart';
import 'config/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate environment configuration in debug mode
  if (kDebugMode) {
    try {
      Env.validateKeys();
      print('✅ All API keys are properly configured');
    } catch (e) {
      print('⚠️ Warning: $e');
    }
  }

  runApp(const MyApp());
}
