// ignore_for_file: avoid_print

import 'dart:math';
import 'package:flutter/foundation.dart';
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

  // Callback for UI updates
  VoidCallback? onMessagesChanged;

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
      print('🔍 DEBUG: Processing user message: "$userMessage"');

      // Fast analysis for weather intent detection
      final analysis = await _llmService.analyzeWeatherQueryComplete(
        userMessage,
        lastCity: _lastAskedCity,
        lastWeatherType: _lastWeatherType,
        conversationHistory: _getRecentConversationContext(),
      );

      print('📋 DEBUG: Complete analysis result: $analysis');

      if (analysis['should_use_tool'] == true && analysis['city'] != null) {
        print(
          '🌦️ DEBUG: Weather intent detected - starting streaming response',
        );

        final city = analysis['city'] as String;
        final toolName =
            analysis['tool_name'] as String? ?? 'get-current-weather';

        print('🔧 DEBUG: Using city: "$city", tool: "$toolName"');

        // Create placeholder message immediately for streaming UI
        final streamingMsg = ChatMessage(
          id: _generateId(),
          content: "Analyzing your weather request...",
          type: MessageType.assistant,
          state: MessageState.analyzing,
          isWeatherQuery: true,
        );
        _addMessage(streamingMsg);

        // Update to fetching state
        _updateMessageState(
          streamingMsg.id,
          MessageState.fetchingWeather,
          "Getting weather data for $city...",
        );

        List<String> toolResults = [];
        WeatherData? weatherData;

        try {
          // Call the appropriate MCP tool
          print('📞 DEBUG: Calling MCP tool...');
          final result = await _mcpClient.callTool(toolName, {'city': city});
          print(
            '✅ DEBUG: Tool call successful, result: ${result.length > 100 ? "${result.substring(0, 100)}..." : result}',
          );
          toolResults.add(result);

          // Parse weather data if it's a current weather response and city was found
          if (toolName == 'get-current-weather' &&
              !result.contains('not found') &&
              !result.contains('❌')) {
            weatherData = WeatherData.fromWeatherResponse(result);
            print(
              '🌤️ DEBUG: Parsed weather data: ${weatherData?.cityName ?? "null"}',
            );
          } else if (toolName == 'get-current-weather') {
            print('❌ DEBUG: City not found, skipping weather widget creation');
          }

          // Update conversation context
          _lastAskedCity = city;
          _lastWeatherType = toolName == 'get-weather-forecast'
              ? 'forecast'
              : 'current';
          print(
            '🧠 DEBUG: Updated context - city: $_lastAskedCity, type: $_lastWeatherType',
          );
        } catch (e) {
          // If tool call fails, we'll still generate a response
          print('❌ DEBUG: Tool call failed: $e');
          toolResults.add("Sorry, I couldn't fetch weather data right now: $e");
        }

        // Update to streaming final response
        _updateMessageState(
          streamingMsg.id,
          MessageState.streaming,
          "Preparing your weather report...",
        );

        // Generate LLM response with conversation context
        print(
          '🤖 DEBUG: Generating LLM response with ${toolResults.length} tool results',
        );

        // Use enhanced message from analysis if available, otherwise original
        final messageToProcess =
            analysis['enhanced_message'] as String? ?? userMessage;

        final response = await _llmService.generateResponse(
          messageToProcess,
          toolResults: toolResults.isNotEmpty ? toolResults : null,
        );
        print(
          '📝 DEBUG: LLM response generated: ${response.length > 100 ? "${response.substring(0, 100)}..." : response}',
        );

        // Update final message with complete content
        final finalContent = weatherData != null
            ? "Here's the current weather information:"
            : response;

        _updateMessageState(
          streamingMsg.id,
          MessageState.complete,
          finalContent,
          weatherData,
        );

        return _messages.firstWhere((msg) => msg.id == streamingMsg.id);
      } else {
        print('💭 DEBUG: Analysis determined no weather tool needed');

        // For non-weather queries, generate direct response
        final response = await _llmService.generateResponse(userMessage);

        final assistantMsg = ChatMessage(
          id: _generateId(),
          content: response,
          type: MessageType.assistant,
        );
        _addMessage(assistantMsg);

        return assistantMsg;
      }
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

  // Update message state for streaming UI
  void _updateMessageState(
    String messageId,
    MessageState newState,
    String newContent, [
    WeatherData? weatherData,
  ]) {
    final messageIndex = _messages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex != -1) {
      _messages[messageIndex] = _messages[messageIndex].copyWith(
        state: newState,
        content: newContent,
        weatherData: weatherData,
      );
      onMessagesChanged?.call();
    }
  }

  // Get recent conversation context for LLM enhancement
  String _getRecentConversationContext() {
    if (_messages.isEmpty) return '';

    // Get last 3 messages for context
    final recentMessages = _messages
        .take(3)
        .map((msg) {
          final type = msg.type == MessageType.user ? 'User' : 'Assistant';
          return '$type: ${msg.content}';
        })
        .join('\n');

    return recentMessages;
  }

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    onMessagesChanged?.call();
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
