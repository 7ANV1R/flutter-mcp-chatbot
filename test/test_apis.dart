#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Simple script to test API keys
/// Usage: dart run test/test_apis.dart
void main() async {
  print('🧪 Testing API Keys...\n');

  // Load environment variables
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env file not found!');
    print('Create a .env file with your API keys.');
    exit(1);
  }

  final envContent = await envFile.readAsString();
  final envVars = <String, String>{};

  for (final line in envContent.split('\n')) {
    if (line.contains('=') && !line.startsWith('#')) {
      final parts = line.split('=');
      if (parts.length >= 2) {
        envVars[parts[0].trim()] = parts.sublist(1).join('=').trim();
      }
    }
  }

  // Test OpenWeather API
  await testOpenWeatherAPI(envVars['OPENWEATHER_API_KEY']);
  print('');

  // Test Gemini API
  await testGeminiAPI(envVars['GEMINI_API_KEY']);
}

Future<void> testOpenWeatherAPI(String? apiKey) async {
  print('🌤️ Testing OpenWeather API...');

  if (apiKey == null ||
      apiKey.isEmpty ||
      apiKey == 'your_openweather_api_key_here') {
    print('⚠️ OpenWeather API key not set in .env file');
    return;
  }

  try {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=London&appid=$apiKey&units=metric';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(
        '✅ OpenWeather API working! Current temp in London: ${data['main']['temp']}°C',
      );
    } else if (response.statusCode == 401) {
      print('❌ OpenWeather API key is invalid');
    } else {
      print('⚠️ OpenWeather API returned status: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Error testing OpenWeather API: $e');
  }
}

Future<void> testGeminiAPI(String? apiKey) async {
  print('🤖 Testing Gemini API...');

  if (apiKey == null ||
      apiKey.isEmpty ||
      apiKey == 'your_gemini_api_key_here') {
    print('⚠️ Gemini API key not set in .env file');
    return;
  }

  try {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'Say hello in one word'},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text =
          data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
          'No response';
      print('✅ Gemini API working! Response: $text');
    } else if (response.statusCode == 400) {
      print('❌ Gemini API request error - check your API key');
    } else if (response.statusCode == 403) {
      print('❌ Gemini API access denied - check your API key permissions');
    } else {
      print('⚠️ Gemini API returned status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Error testing Gemini API: $e');
  }
}
