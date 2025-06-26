/// Environment configuration class for secure API key management
/// Uses --dart-define-from-file instead of .env files for better security
class Env {
  // OpenWeather API key for weather data
  static const String openWeatherApiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: '',
  );

  // Gemini API key for AI chat functionality
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Validates that all required API keys are provided
  /// Throws an exception if any required key is missing
  static void validateKeys() {
    final missingKeys = <String>[];

    if (openWeatherApiKey.isEmpty || openWeatherApiKey == 'your_openweather_api_key_here') {
      missingKeys.add('OPENWEATHER_API_KEY');
    }

    if (geminiApiKey.isEmpty || geminiApiKey == 'your_gemini_api_key_here') {
      missingKeys.add('GEMINI_API_KEY');
    }

    if (missingKeys.isNotEmpty) {
      throw Exception(
        'Missing required API keys: ${missingKeys.join(', ')}. '
        'Please ensure you have configured .env.json with your API keys and '
        'are running with --dart-define-from-file=.env.json',
      );
    }
  }

  /// Check if API keys are configured (non-empty and not placeholder values)
  static bool get hasValidOpenWeatherKey =>
      openWeatherApiKey.isNotEmpty && openWeatherApiKey != 'your_openweather_api_key_here';

  static bool get hasValidGeminiKey =>
      geminiApiKey.isNotEmpty && geminiApiKey != 'your_gemini_api_key_here';

  static bool get hasAllKeys => hasValidOpenWeatherKey && hasValidGeminiKey;
}
