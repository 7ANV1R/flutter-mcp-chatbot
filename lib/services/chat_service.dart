// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';
import '../models/weather_data.dart';
import 'llm_service.dart';
import 'mcp_client.dart';

class ChatService {
  late LlmService _llmService;
  final McpChatClient _mcpClient;
  final List<ChatMessage> _messages = [];

  // Conversation context
  String? _lastAskedCity;
  String? _lastWeatherType; // 'current' or 'forecast'
  DateTime? _lastWeatherRequest;

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
        ? """Hello! I'm your AI weather assistant.

I can help you get current weather conditions and forecasts for any city around the world. Just ask me about the weather! 🌤️"""
        : """Hello! I'm your weather assistant powered by MCP.

Currently running in demo mode. To enable full AI features, add your Gemini API key to the .env file.

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
      // Check if this is a contextual query and enhance it
      String processedMessage = userMessage;
      final isContextual = _llmService.isContextualWeatherQuery(
        userMessage,
        lastCity: _lastAskedCity,
        lastWeatherType: _lastWeatherType,
        lastWeatherRequest: _lastWeatherRequest,
      );

      if (isContextual) {
        processedMessage = _llmService.enhanceMessageWithContext(
          userMessage,
          lastCity: _lastAskedCity,
          lastWeatherType: _lastWeatherType,
        );
        print(
          '🧠 DEBUG: Enhanced contextual message: "$userMessage" → "$processedMessage"',
        );
      }

      // Check if the LLM service thinks we should use weather tools
      List<String> toolResults = [];
      WeatherData? weatherData; // Move weather data outside try block

      print('🔍 DEBUG: Processing user message: "$processedMessage"');

      if (_llmService.shouldUseWeatherTool(processedMessage)) {
        print('🛠️ DEBUG: LLM service detected weather tool should be used');

        // Extract parameters for weather tool
        final params = _llmService.extractWeatherToolParams(processedMessage);
        print('🔧 DEBUG: Extracted tool params: $params');

        if (params.containsKey('city')) {
          try {
            // Determine which tool to use based on the message
            final toolName = _llmService.getToolName(processedMessage);
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
              print(
                '🌤️ DEBUG: Parsed weather data: ${weatherData?.cityName ?? "null"}',
              );
            }

            // Update conversation context
            _lastAskedCity = params['city'] as String?;
            _lastWeatherType = toolName == 'get-weather-forecast'
                ? 'forecast'
                : 'current';
            _lastWeatherRequest = DateTime.now();
            print(
              '🧠 DEBUG: Updated context - city: $_lastAskedCity, type: $_lastWeatherType',
            );
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

      // Generate LLM response with conversation context
      print(
        '🤖 DEBUG: Generating LLM response with ${toolResults.length} tool results',
      );

      // Build context for LLM
      String contextualPrompt = processedMessage;
      if (isContextual && _lastAskedCity != null) {
        contextualPrompt +=
            "\n\nContext: User previously asked about weather in $_lastAskedCity. This is a follow-up question.";
      }

      final response = await _llmService.generateResponse(
        contextualPrompt,
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
