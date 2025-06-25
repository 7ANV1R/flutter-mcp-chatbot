import 'package:flutter/material.dart';

class WeatherData {
  final String cityName;
  final String country;
  final double temperature;
  final double feelsLike;
  final String condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final String iconCode;
  final bool isDemo;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.feelsLike,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    this.iconCode = '',
    this.isDemo = false,
  });

  // Parse weather data from the text response
  static WeatherData? fromWeatherResponse(String response) {
    try {
      print('🔍 DEBUG: Parsing weather response: "${response.length > 300 ? '${response.substring(0, 300)}...' : response}"');
      
      // Check if it's demo data
      final isDemo = response.contains('Demo Weather') || response.contains('📝 Note: This is demo data');
      
      // Extract city and country
      final cityMatch = RegExp(r'Weather (?:in|for) (.+?):').firstMatch(response);
      String cityName = 'Unknown';
      String country = '';
      
      if (cityMatch != null) {
        final cityCountry = cityMatch.group(1)!;
        if (cityCountry.contains(', ')) {
          final parts = cityCountry.split(', ');
          cityName = parts[0];
          country = parts.length > 1 ? parts[1] : '';
        } else {
          cityName = cityCountry;
        }
      }

      // Extract temperature
      final tempMatch = RegExp(r'Temperature: (\d+(?:\.\d+)?)°C').firstMatch(response);
      final temperature = tempMatch != null ? double.tryParse(tempMatch.group(1)!) ?? 0.0 : 0.0;

      // Extract feels like
      final feelsMatch = RegExp(r'feels like (\d+(?:\.\d+)?)°C').firstMatch(response);
      final feelsLike = feelsMatch != null ? double.tryParse(feelsMatch.group(1)!) ?? temperature : temperature;

      // Extract condition and description with better regex patterns
      String condition = 'Unknown';
      String description = 'Unknown';
      
      // Try multiple patterns to match different formats
      final patterns = [
        RegExp(r'🌤️ Condition: (.+?) - (.+?)(?:\n|$)', multiLine: true),
        RegExp(r'Condition: (.+?) - (.+?)(?:\n|$)', multiLine: true),
        RegExp(r'🌤️ Condition: (.+?)(?:\n|$)', multiLine: true),
        RegExp(r'Condition: (.+?)(?:\n|$)', multiLine: true),
        // Handle cases where description comes after main condition
        RegExp(r'Weather: (.+?) - (.+?)(?:\n|$)', multiLine: true),
        RegExp(r'Weather: (.+?)(?:\n|$)', multiLine: true),
      ];
      
      for (final pattern in patterns) {
        final match = pattern.firstMatch(response);
        if (match != null) {
          condition = match.group(1)!.trim();
          if (match.groupCount >= 2 && match.group(2) != null) {
            description = match.group(2)!.trim();
          } else {
            description = condition;
          }
          break;
        }
      }
      
      // If still unknown, try to extract from any line with weather description
      if (description == 'Unknown') {
        final fallbackPattern = RegExp(r'(Partly Cloudy|Sunny|Clear Sky|Cloudy|Rain|Snow|Storm|Fog|Mist|Overcast|Fair)', caseSensitive: false);
        final fallbackMatch = fallbackPattern.firstMatch(response);
        if (fallbackMatch != null) {
          description = fallbackMatch.group(1)!;
          condition = description;
        } else {
          // Last resort: use a generic description based on temperature
          if (temperature > 25) {
            description = "Warm weather";
          } else if (temperature < 10) {
            description = "Cool weather";
          } else {
            description = "Pleasant weather";
          }
        }
      }
      
      print('🔍 DEBUG: Final parsed - condition: "$condition", description: "$description", temp: $temperature°C');

      // Extract humidity
      final humidityMatch = RegExp(r'Humidity: (\d+)%').firstMatch(response);
      final humidity = humidityMatch != null ? int.tryParse(humidityMatch.group(1)!) ?? 0 : 0;

      // Extract wind speed
      final windMatch = RegExp(r'Wind: (\d+(?:\.\d+)?) m/s').firstMatch(response);
      final windSpeed = windMatch != null ? double.tryParse(windMatch.group(1)!) ?? 0.0 : 0.0;

      // Extract pressure
      final pressureMatch = RegExp(r'Pressure: (\d+) hPa').firstMatch(response);
      final pressure = pressureMatch != null ? int.tryParse(pressureMatch.group(1)!) ?? 0 : 0;

      return WeatherData(
        cityName: cityName,
        country: country,
        temperature: temperature,
        feelsLike: feelsLike,
        condition: condition,
        description: description,
        humidity: humidity,
        windSpeed: windSpeed,
        pressure: pressure,
        isDemo: isDemo,
      );
    } catch (e) {
      print('Error parsing weather data: $e');
      return null;
    }
  }

  // Get weather icon based on condition
  String get weatherIcon {
    final conditionLower = condition.toLowerCase();
    if (conditionLower.contains('sun') || conditionLower.contains('clear')) {
      return '☀️';
    } else if (conditionLower.contains('cloud')) {
      return '☁️';
    } else if (conditionLower.contains('rain')) {
      return '🌧️';
    } else if (conditionLower.contains('snow')) {
      return '❄️';
    } else if (conditionLower.contains('storm')) {
      return '⛈️';
    } else if (conditionLower.contains('fog') || conditionLower.contains('mist')) {
      return '🌫️';
    } else if (conditionLower.contains('wind')) {
      return '💨';
    } else {
      return '🌤️'; // Partly cloudy as default
    }
  }

  // Get temperature color based on value
  Color get temperatureColor {
    if (temperature < 0) return const Color(0xFF2196F3); // Blue for freezing
    if (temperature < 10) return const Color(0xFF03DAC6); // Cyan for cold
    if (temperature < 20) return const Color(0xFF4CAF50); // Green for cool
    if (temperature < 30) return const Color(0xFFFF9800); // Orange for warm
    return const Color(0xFFF44336); // Red for hot
  }
}
