#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:mcp_dart/mcp_dart.dart';
import 'package:http/http.dart' as http;

/// Standalone MCP Weather Server
/// This server provides weather tools through the MCP protocol
/// Usage: dart run bin/weather_server.dart
void main() async {
  // Get API key from environment variable
  final apiKey = Platform.environment['OPENWEATHER_API_KEY'] ?? '';

  final server = McpServer(
    Implementation(name: "weather-mcp-server", version: "1.0.0"),
    options: ServerOptions(
      capabilities: ServerCapabilities(tools: ServerCapabilitiesTools()),
    ),
  );

  // Register weather tools
  await _setupWeatherTools(server, apiKey);

  // Connect to stdio transport
  final transport = StdioServerTransport();
  await server.connect(transport);

  stderr.writeln("Weather MCP Server running on stdio");
}

Future<void> _setupWeatherTools(McpServer server, String apiKey) async {
  // Current weather tool
  server.tool(
    "get-current-weather",
    description: 'Get current weather conditions for a city',
    inputSchemaProperties: {
      'city': {
        'type': 'string',
        'description': 'City name (e.g., "London", "New York")',
      },
      'country': {
        'type': 'string',
        'description': 'Country code (optional, e.g., "US", "UK")',
      },
    },
    callback: ({args, extra}) async {
      final city = args?['city'] as String?;
      final country = args?['country'] as String?;

      if (city == null || city.isEmpty) {
        return CallToolResult.fromContent(
          content: [TextContent(text: "City name is required")],
          isError: true,
        );
      }

      try {
        final weather = await _getCurrentWeather(city, country, apiKey);
        return CallToolResult.fromContent(
          content: [TextContent(text: weather)],
        );
      } catch (e) {
        return CallToolResult.fromContent(
          content: [TextContent(text: "Error fetching weather: $e")],
          isError: true,
        );
      }
    },
  );

  // Weather forecast tool
  server.tool(
    "get-weather-forecast",
    description: 'Get 5-day weather forecast for a city',
    inputSchemaProperties: {
      'city': {
        'type': 'string',
        'description': 'City name (e.g., "London", "New York")',
      },
      'country': {
        'type': 'string',
        'description': 'Country code (optional, e.g., "US", "UK")',
      },
    },
    callback: ({args, extra}) async {
      final city = args?['city'] as String?;
      final country = args?['country'] as String?;

      if (city == null || city.isEmpty) {
        return CallToolResult.fromContent(
          content: [TextContent(text: "City name is required")],
          isError: true,
        );
      }

      try {
        final forecast = await _getWeatherForecast(city, country, apiKey);
        return CallToolResult.fromContent(
          content: [TextContent(text: forecast)],
        );
      } catch (e) {
        return CallToolResult.fromContent(
          content: [TextContent(text: "Error fetching forecast: $e")],
          isError: true,
        );
      }
    },
  );
}

Future<String> _getCurrentWeather(
  String city,
  String? country,
  String apiKey,
) async {
  if (apiKey.isEmpty) {
    return '''Demo Weather for $city:
🌡️ Temperature: 22°C (feels like 24°C)
🌤️ Condition: Partly Cloudy
💧 Humidity: 65%
🌬️ Wind: 3.2 m/s
🔽 Pressure: 1013 hPa

📝 Note: This is demo data. To get real weather data, please:
1. Get a free API key from https://openweathermap.org/api
2. Set OPENWEATHER_API_KEY environment variable''';
  }

  final query = country != null ? "$city,$country" : city;
  final url =
      "https://api.openweathermap.org/data/2.5/weather?q=$query&appid=$apiKey&units=metric";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final main = data['main'];
      final weather = data['weather'][0];
      final wind = data['wind'] ?? {};

      return '''Current Weather in ${data['name']}, ${data['sys']['country']}:
🌡️ Temperature: ${main['temp']}°C (feels like ${main['feels_like']}°C)
🌤️ Condition: ${weather['main']} - ${weather['description']}
💧 Humidity: ${main['humidity']}%
🌬️ Wind: ${wind['speed'] ?? 'N/A'} m/s
🔽 Pressure: ${main['pressure']} hPa''';
    } else if (response.statusCode == 401) {
      return "Invalid API key. Please check your OpenWeather API key.";
    } else if (response.statusCode == 404) {
      return "City not found. Please check the city name.";
    } else {
      return "Failed to fetch weather data. HTTP ${response.statusCode}";
    }
  } catch (e) {
    return "Network error: $e";
  }
}

Future<String> _getWeatherForecast(
  String city,
  String? country,
  String apiKey,
) async {
  if (apiKey.isEmpty) {
    return '''5-Day Demo Forecast for $city:

📅 Today: 22°C, Partly Cloudy
📅 Tomorrow: 24°C, Sunny
📅 Day 3: 19°C, Light Rain
📅 Day 4: 21°C, Cloudy
📅 Day 5: 23°C, Sunny

📝 Note: This is demo data. To get real forecast data, please:
1. Get a free API key from https://openweathermap.org/api
2. Set OPENWEATHER_API_KEY environment variable''';
  }

  final query = country != null ? "$city,$country" : city;
  final url =
      "https://api.openweathermap.org/data/2.5/forecast?q=$query&appid=$apiKey&units=metric";

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
        final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        if (!dailyForecasts.containsKey(dateKey)) {
          dailyForecasts[dateKey] = forecast;
        }
      }

      int day = 0;
      for (final forecast in dailyForecasts.values.take(5)) {
        final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
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
      return "Invalid API key. Please check your OpenWeather API key.";
    } else if (response.statusCode == 404) {
      return "City not found. Please check the city name.";
    } else {
      return "Failed to fetch forecast data. HTTP ${response.statusCode}";
    }
  } catch (e) {
    return "Network error: $e";
  }
}
