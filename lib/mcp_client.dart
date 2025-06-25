import 'weather_service.dart';

class ToolInfo {
  final String name;
  final String description;

  ToolInfo({required this.name, required this.description});
}

/// Mobile-compatible MCP client that uses in-process tools
/// This version doesn't require external processes and works on iOS/Android
class McpChatClient {
  late WeatherService _weatherService;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔧 Initializing mobile-compatible MCP client...');

      // Initialize the weather service
      _weatherService = WeatherService();

      print('✅ MCP client initialized successfully (mobile mode)');
      _isInitialized = true;
    } catch (e) {
      print('❌ Failed to initialize MCP client: $e');
      throw Exception('Failed to initialize MCP client: $e');
    }
  }

  Future<List<ToolInfo>> getAvailableTools() async {
    if (!_isInitialized) await initialize();

    return [
      ToolInfo(
        name: 'get-current-weather',
        description: 'Get current weather conditions for a city',
      ),
      ToolInfo(
        name: 'get-weather-forecast',
        description: 'Get 5-day weather forecast for a city',
      ),
    ];
  }

  Future<String> callTool(String toolName, Map<String, dynamic> arguments) async {
    if (!_isInitialized) await initialize();

    try {
      print('🔧 DEBUG: MCP calling tool: $toolName with args: $arguments');

      final city = arguments['city'] as String?;
      final country = arguments['country'] as String?;

      if (city == null || city.isEmpty) {
        print('❌ DEBUG: MCP tool call failed - no city provided');
        throw Exception('City name is required');
      }

      String result;

      switch (toolName) {
        case 'get-current-weather':
          print('🌤️ DEBUG: MCP calling getCurrentWeather for $city');
          result = await _weatherService.getCurrentWeather(city, country: country);
          break;
        case 'get-weather-forecast':
          print('📅 DEBUG: MCP calling getWeatherForecast for $city');
          result = await _weatherService.getWeatherForecast(city, country: country);
          break;
        default:
          print('❌ DEBUG: MCP unknown tool: $toolName');
          throw Exception('Unknown tool: $toolName');
      }

      print('✅ DEBUG: MCP tool call successful, result length: ${result.length}');
      return result;
    } catch (e) {
      print('❌ DEBUG: MCP tool call failed: $e');
      throw Exception('Failed to call tool $toolName: $e');
    }
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      print('🧹 Disposing MCP client...');
      _isInitialized = false;
    }
  }
}
