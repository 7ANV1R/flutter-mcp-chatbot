import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// In-process weather service that simulates MCP tools
/// This version works on mobile platforms without requiring external processes
class WeatherService {
  static const String openWeatherApiBase =
      "https://api.openweathermap.org/data/2.5";

  String? get apiKey => dotenv.env['OPENWEATHER_API_KEY'];

  Future<void> initialize() async {
    // Weather service is ready to use immediately
    print('🌤️ Weather service initialized');
  }

  void dispose() {
    // Nothing to dispose for this service
    print('🧹 Weather service disposed');
  }

  Future<String> getCurrentWeather(String city, {String? country}) async {
    print(
      '🌤️ DEBUG: WeatherService.getCurrentWeather called for $city${country != null ? ', $country' : ''}',
    );

    if (apiKey == null ||
        apiKey!.isEmpty ||
        apiKey == 'your_openweather_api_key_here') {
      print('📝 DEBUG: Using demo weather data (no API key)');
      return _getDemoWeather(city);
    }

    final query = country != null ? "$city,$country" : city;
    final url =
        "$openWeatherApiBase/weather?q=$query&appid=$apiKey&units=metric";
    print('🌐 DEBUG: Making API request to: $url');

    try {
      final response = await http.get(Uri.parse(url));
      print('📡 DEBUG: API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final main = data['main'];
        final weather = data['weather'][0];
        final wind = data['wind'] ?? {};

        final result =
            '''Current Weather in ${data['name']}, ${data['sys']['country']}:
🌡️ Temperature: ${main['temp']}°C (feels like ${main['feels_like']}°C)
🌤️ Condition: ${weather['main']} - ${weather['description']}
💧 Humidity: ${main['humidity']}%
🌬️ Wind: ${wind['speed'] ?? 'N/A'} m/s
🔽 Pressure: ${main['pressure']} hPa''';

        print('✅ DEBUG: Real weather data retrieved successfully');
        return result;
      } else if (response.statusCode == 401) {
        print('❌ DEBUG: Invalid API key');
        return "❌ Invalid OpenWeather API key. Please check your API key in the .env file.";
      } else if (response.statusCode == 404) {
        print('❌ DEBUG: City not found');
        return "❌ City '$city' not found. Please check the city name spelling.";
      } else {
        print('❌ DEBUG: API error ${response.statusCode}');
        return "❌ Failed to fetch weather data. HTTP ${response.statusCode}";
      }
    } catch (e) {
      print('❌ DEBUG: Network error: $e');
      return _getDemoWeather(city, error: "Network error: $e");
    }
  }

  Future<String> getWeatherForecast(String city, {String? country}) async {
    if (apiKey == null ||
        apiKey!.isEmpty ||
        apiKey == 'your_openweather_api_key_here') {
      return _getDemoForecast(city);
    }

    final query = country != null ? "$city,$country" : city;
    final url =
        "$openWeatherApiBase/forecast?q=$query&appid=$apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final forecasts = data['list'] as List;

        final buffer = StringBuffer();
        buffer.writeln(
          '5-Day Weather Forecast for ${data['city']['name']}, ${data['city']['country']}:\n',
        );

        // Group forecasts by day (take one forecast per day)
        final Map<String, dynamic> dailyForecasts = {};
        for (final forecast in forecasts) {
          final date = DateTime.fromMillisecondsSinceEpoch(
            forecast['dt'] * 1000,
          );
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

          if (!dailyForecasts.containsKey(dateKey)) {
            dailyForecasts[dateKey] = forecast;
          }
        }

        int day = 0;
        for (final forecast in dailyForecasts.values.take(5)) {
          final date = DateTime.fromMillisecondsSinceEpoch(
            forecast['dt'] * 1000,
          );
          final weather = forecast['weather'][0];
          final main = forecast['main'];

          final dayName = day == 0
              ? 'Today'
              : day == 1
              ? 'Tomorrow'
              : 'Day ${day + 1}';

          buffer.writeln(
            '📅 $dayName (${date.month}/${date.day}): ${main['temp']}°C, ${weather['description']}',
          );
          day++;
        }

        return buffer.toString();
      } else if (response.statusCode == 401) {
        return "❌ Invalid OpenWeather API key. Please check your API key in the .env file.";
      } else if (response.statusCode == 404) {
        return "❌ City '$city' not found. Please check the city name spelling.";
      } else {
        return "❌ Failed to fetch forecast data. HTTP ${response.statusCode}";
      }
    } catch (e) {
      return _getDemoForecast(city, error: "Network error: $e");
    }
  }

  String _getDemoWeather(String city, {String? error}) {
    return '''Current Weather in $city (Demo):
🌡️ Temperature: 22°C (feels like 24°C)
🌤️ Condition: Partly Cloudy - partly cloudy
💧 Humidity: 65%
🌬️ Wind: 3.2 m/s
🔽 Pressure: 1013 hPa

📝 Note: This is demo data. ${error ?? 'To get real weather data, add your OpenWeather API key to the .env file.'}''';
  }

  String _getDemoForecast(String city, {String? error}) {
    return '''5-Day Weather Forecast for $city (Demo):

📅 Today: 22°C, Partly Cloudy
📅 Tomorrow: 24°C, Sunny
📅 Day 3: 19°C, Light Rain
📅 Day 4: 21°C, Cloudy
📅 Day 5: 23°C, Sunny

📝 Note: This is demo data. ${error ?? 'To get real forecast data, add your OpenWeather API key to the .env file.'}''';
  }
}
