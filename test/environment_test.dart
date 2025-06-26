import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_mcp_chat/config/environment.dart';

void main() {
  group('Environment Configuration Tests', () {
    test('should load API keys from dart-define', () {
      // These should be loaded from --dart-define-from-file=.env.json
      expect(Env.openWeatherApiKey, isNotEmpty);
      expect(Env.geminiApiKey, isNotEmpty);
      
      // Should not be placeholder values
      expect(Env.openWeatherApiKey, isNot('your_openweather_api_key_here'));
      expect(Env.geminiApiKey, isNot('your_gemini_api_key_here'));
    });

    test('should validate API keys correctly', () {
      expect(Env.hasValidOpenWeatherKey, isTrue);
      expect(Env.hasValidGeminiKey, isTrue);
      expect(Env.hasAllKeys, isTrue);
    });

    test('should handle validation logic correctly', () {
      // This test verifies the validation logic without requiring actual keys
      expect(() => Env.validateKeys(), returnsNormally);
    });
  });
}
