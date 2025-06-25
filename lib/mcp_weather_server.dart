import 'dart:convert';
import 'package:mcp_dart/mcp_dart.dart';
import 'package:http/http.dart' as http;

class WeatherMcpServer {
  late McpServer server;

  // OpenWeatherMap API - free tier (no API key needed for basic current weather)
  static const String openWeatherApiBase =
      "https://api.openweathermap.org/data/2.5";

  WeatherMcpServer() {
    server = McpServer(
      Implementation(name: "weather-server", version: "1.0.0"),
      options: ServerOptions(
        capabilities: ServerCapabilities(tools: ServerCapabilitiesTools()),
      ),
    );

    _setupTools();
  }

  void _setupTools() {
    // Current weather tool
    server.tool(
      "get-current-weather",
      description: 'Get current weather for a city',
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
          final weather = await _getCurrentWeather(city, country);
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
          final forecast = await _getWeatherForecast(city, country);
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

  Future<String> _getCurrentWeather(String city, String? country) async {
    // Using free tier of OpenWeatherMap (limited but works for demo)
    // For production, you'd want to get an API key from openweathermap.org
    final query = country != null ? "$city,$country" : city;
    final url =
        "$openWeatherApiBase/weather?q=$query&units=metric&appid=demo"; // Using demo mode

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
      } else {
        // Fallback to a simple demo response for demo purposes
        return '''Demo Weather for $city:
🌡️ Temperature: 22°C (feels like 24°C)
🌤️ Condition: Partly Cloudy
💧 Humidity: 65%
🌬️ Wind: 3.2 m/s
🔽 Pressure: 1013 hPa
📝 Note: This is demo data. For real weather data, please get a free API key from openweathermap.org''';
      }
    } catch (e) {
      // Fallback for demo
      return '''Demo Weather for $city:
🌡️ Temperature: 20°C (feels like 22°C)
🌤️ Condition: Clear Sky
💧 Humidity: 60%
🌬️ Wind: 2.5 m/s
🔽 Pressure: 1015 hPa
📝 Note: This is demo data. Network error: $e''';
    }
  }

  Future<String> _getWeatherForecast(String city, String? country) async {
    // Similar to current weather but for forecast
    // Demo forecast data for demonstration
    return '''5-Day Weather Forecast for $city:

📅 Today: 22°C, Partly Cloudy
📅 Tomorrow: 24°C, Sunny
📅 Day 3: 19°C, Light Rain
📅 Day 4: 21°C, Cloudy
📅 Day 5: 23°C, Sunny

📝 Note: This is demo data. For real forecast data, please get a free API key from openweathermap.org and update the implementation.''';
  }

  Future<void> start() async {
    // For in-process communication, we'll use a different approach
    // This server will be used directly by the client, not via stdio
  }

  void stop() {
    // Cleanup if needed
  }

  // Public methods for direct access
  Future<String> getCurrentWeather(String city, String? country) async {
    return await _getCurrentWeather(city, country);
  }

  Future<String> getWeatherForecast(String city, String? country) async {
    return await _getWeatherForecast(city, country);
  }
}
