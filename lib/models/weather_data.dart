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

      // Extract condition and description
      final conditionMatch = RegExp(r'Condition: (.+?) - (.+?)\\n', multiLine: true).firstMatch(response);
      String condition = 'Unknown';
      String description = 'Unknown';
      
      if (conditionMatch != null) {
        condition = conditionMatch.group(1)!;
        description = conditionMatch.group(2)!;
      } else {
        // Try alternative pattern
        final altMatch = RegExp(r'Condition: (.+?)\\n', multiLine: true).firstMatch(response);
        if (altMatch != null) {
          condition = altMatch.group(1)!;
          description = condition;
        }
      }

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
