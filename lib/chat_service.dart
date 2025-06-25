// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/chat_message.dart';
import 'models/weather_data.dart';
import 'llm_service.dart';
import 'mcp_client.dart';

class ChatService {
  late LlmService _llmService;
  final McpChatClient _mcpClient;
  final List<ChatMessage> _messages = [];

  ChatService() : _mcpClient = McpChatClient();

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  Future<void> initialize() async {
    // Load environment variables
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print('Warning: Could not load .env file: $e');
    }

    // Initialize LLM service with API key
    final geminiApiKey = dotenv.env['GEMINI_API_KEY'];
    _llmService = LlmService(apiKey: geminiApiKey);

    // Initialize MCP client
    await _mcpClient.initialize();

    // Add welcome message
    final hasApiKey = geminiApiKey != null && geminiApiKey.isNotEmpty;
    final welcomeMessage = hasApiKey
        ? """Hello! I'm your AI weather assistant powered by MCP (Model Context Protocol) and Google Gemini AI.

I can help you get:
🌤️ Current weather conditions
📅 5-day weather forecasts
🌡️ Temperature, humidity, wind speed and more

Just ask me about the weather in any city! For example:
• "What's the weather in London?"
• "Show me the forecast for New York"
• "How's the weather today in Tokyo?"

🚀 Running in mobile-compatible mode with real AI and weather APIs!"""
        : """Hello! I'm your weather assistant powered by MCP (Model Context Protocol).

I can help you get weather information for any city. Currently running in demo mode.

📱 Mobile-compatible mode: No external processes needed!

To enable full AI features:
1. Get a free API key from https://aistudio.google.com/app/apikey
2. Add it to the .env file as GEMINI_API_KEY=your_key_here
3. Hot reload the app

For real weather data:
1. Get a free API key from https://openweathermap.org/api
2. Add it to the .env file as OPENWEATHER_API_KEY=your_key_here

Try asking me about the weather in any city!""";

    _addMessage(
      ChatMessage(
        id: _generateId(),
        content: welcomeMessage,
        type: MessageType.assistant,
      ),
    );
  }

  Future<ChatMessage> sendMessage(String userMessage) async {
    // Add user message
    final userMsg = ChatMessage(
      id: _generateId(),
      content: userMessage,
      type: MessageType.user,
    );
    _addMessage(userMsg);

    try {
      // Check if the LLM service thinks we should use weather tools
      List<String> toolResults = [];
      WeatherData? weatherData; // Move weather data outside try block

      print('🔍 DEBUG: Processing user message: "$userMessage"');

      if (_llmService.shouldUseWeatherTool(userMessage)) {
        print('🛠️ DEBUG: LLM service detected weather tool should be used');

        // Extract parameters for weather tool
        final params = _llmService.extractWeatherToolParams(userMessage);
        print('🔧 DEBUG: Extracted tool params: $params');

        if (params.containsKey('city')) {
          try {
            // Determine which tool to use based on the message
            final toolName = _llmService.getToolName(userMessage);
            print('🎯 DEBUG: Selected tool: $toolName');

            // Call the appropriate MCP tool
            print('📞 DEBUG: Calling MCP tool...');
            final result = await _mcpClient.callTool(toolName, params);
            print(
              '✅ DEBUG: Tool call successful, result: ${result.length > 100 ? "${result.substring(0, 100)}..." : result}',
            );
            toolResults.add(result);
            
            // Parse weather data if it's a current weather response
            if (toolName == 'get-current-weather') {
              weatherData = WeatherData.fromWeatherResponse(result);
              print('🌤️ DEBUG: Parsed weather data: ${weatherData?.cityName ?? "null"}');
            }
          } catch (e) {
            // If tool call fails, we'll still generate a response
            print('❌ DEBUG: Tool call failed: $e');
            toolResults.add(
              "Sorry, I couldn't fetch weather data right now: $e",
            );
          }
        } else {
          print('⚠️ DEBUG: No city found in message');
        }
      } else {
        print('💭 DEBUG: LLM service determined no weather tool needed');
      }

      // Generate LLM response
      print(
        '🤖 DEBUG: Generating LLM response with ${toolResults.length} tool results',
      );
      final response = await _llmService.generateResponse(
        userMessage,
        toolResults: toolResults.isNotEmpty ? toolResults : null,
      );
      print(
        '📝 DEBUG: LLM response generated: ${response.length > 100 ? "${response.substring(0, 100)}..." : response}',
      );

      // Add assistant response with weather data if available
      final assistantMsg = ChatMessage(
        id: _generateId(),
        content: weatherData != null 
            ? "Here's the current weather information:" 
            : response,
        type: MessageType.assistant,
        weatherData: weatherData,
      );
      _addMessage(assistantMsg);

      return assistantMsg;
    } catch (e) {
      // Add error message
      final errorMsg = ChatMessage(
        id: _generateId(),
        content: "Sorry, I encountered an error: $e",
        type: MessageType.assistant,
        isError: true,
      );
      _addMessage(errorMsg);

      return errorMsg;
    }
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
  }

  void clearMessages() {
    _messages.clear();
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  void dispose() {
    _mcpClient.dispose();
  }
}
