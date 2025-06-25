// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class LlmService {
  static const String geminiBaseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";
  final String? apiKey;

  LlmService({this.apiKey});

  Future<String> generateResponse(
    String userMessage, {
    List<String>? toolResults,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      // Fallback to intelligent pattern matching if no API key
      return _generateLocalResponse(userMessage, toolResults: toolResults);
    }

    try {
      String systemPrompt =
          '''You are a helpful weather assistant. You can provide weather information for any city using the available tools.

When a user asks about weather:
1. Extract the city name from their message
2. Determine if they want current weather or forecast
3. Use the appropriate tool to get weather data
4. Present the information in a friendly, conversational way

If tool results are provided, use them to answer the user's question. If no tools are available, provide helpful guidance.''';

      String fullPrompt = systemPrompt;

      // Add tool results as context if available
      if (toolResults != null && toolResults.isNotEmpty) {
        fullPrompt += '\n\nWeather Information Retrieved:\n';
        for (final result in toolResults) {
          fullPrompt += '$result\n';
        }
      }

      fullPrompt += '\n\nUser: $userMessage\n\nAssistant:';

      final response = await http.post(
        Uri.parse('$geminiBaseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': fullPrompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 1000},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content =
            data['candidates']?[0]?['content']?['parts']?[0]?['text']
                as String?;

        if (content != null) {
          return content.trim();
        } else {
          return _generateLocalResponse(userMessage, toolResults: toolResults);
        }
      } else if (response.statusCode == 400) {
        return "❌ Invalid request to Gemini API. Please check your API key.";
      } else if (response.statusCode == 403) {
        return "❌ Access denied. Please check your Gemini API key permissions.";
      } else {
        // Fallback to local response
        return _generateLocalResponse(userMessage, toolResults: toolResults);
      }
    } catch (e) {
      // Fallback to local response on any error
      return _generateLocalResponse(userMessage, toolResults: toolResults);
    }
  }

  String _generateLocalResponse(
    String userMessage, {
    List<String>? toolResults,
  }) {
    final lowerMessage = userMessage.toLowerCase();

    if (toolResults != null && toolResults.isNotEmpty) {
      // If we have tool results, incorporate them into the response
      return _generateResponseWithToolResults(userMessage, toolResults);
    }

    if (lowerMessage.contains('weather') ||
        lowerMessage.contains('temperature') ||
        lowerMessage.contains('forecast')) {
      final city = _extractCityFromMessage(userMessage);
      if (city != null) {
        return "I'll check the weather in $city for you. Let me fetch the current conditions...";
      }
      return "I can help you get weather information! Please let me know which city you'd like to check the weather for.";
    }

    if (lowerMessage.contains('hello') ||
        lowerMessage.contains('hi') ||
        lowerMessage.contains('hey')) {
      return "Hello! I'm your weather assistant powered by MCP (Model Context Protocol). I can help you get current weather information and forecasts for any city around the world. Just ask me about the weather in a specific location!";
    }

    if (lowerMessage.contains('help')) {
      return """I'm a weather assistant that can help you with:

🌤️ Current weather conditions for any city
📅 5-day weather forecasts
🌡️ Temperature, humidity, wind speed and more

Just ask me something like:
• "What's the weather in London?"
• "Show me the forecast for New York"
• "How's the weather today in Tokyo?"

I use MCP (Model Context Protocol) to fetch real weather data from APIs!""";
    }

    if (lowerMessage.contains('thank')) {
      return "You're welcome! Feel free to ask me about the weather in any other cities.";
    }

    return "I'm a weather assistant! Ask me about the weather in any city, and I'll help you get current conditions or forecasts. For example, try asking 'What's the weather in Paris?'";
  }

  String _generateResponseWithToolResults(
    String userMessage,
    List<String> toolResults,
  ) {
    final result = toolResults.first;

    // Handle city not found errors with helpful suggestions
    if (result.contains('not found') || result.contains('❌')) {
      final cityMatch = RegExp(r"'([^']+)'").firstMatch(result);
      if (cityMatch != null) {
        final failedCity = cityMatch.group(1)!;
        // Check if it might be a common misspelling or variant
        final suggestions = _getSimilarCityNames(failedCity);
        if (suggestions.isNotEmpty) {
          return "I couldn't find weather information for \"$failedCity\". Did you perhaps mean ${suggestions.join(' or ')}? Please check the spelling and try again.";
        }
      }
      return "I couldn't find that city. Please check the spelling and try again with a valid city name.";
    }

    if (result.contains('Demo Weather') || result.contains('Current Weather')) {
      return "Here's the current weather information I found:\n\n$result\n\nIs there anything else you'd like to know about the weather?";
    }

    if (result.contains('Forecast') || result.contains('forecast')) {
      return "Here's the weather forecast I found:\n\n$result\n\nWould you like the weather for any other location?";
    }

    if (result.contains('Error') || result.contains('error')) {
      return "I encountered an issue getting the weather data:\n\n$result\n\nPlease try asking about a different city or check the city name spelling.";
    }

    return "Here's what I found:\n\n$result\n\nFeel free to ask me about weather in other cities!";
  }

  // Helper method to suggest similar city names for common misspellings
  List<String> _getSimilarCityNames(String city) {
    final suggestions = <String>[];
    final lowerCity = city.toLowerCase();

    // Common city name corrections
    final corrections = {
      'londons': 'London',
      'newyork': 'New York',
      'losangeles': 'Los Angeles',
      'sanfrancisco': 'San Francisco',
      'tokio': 'Tokyo',
      'moskow': 'Moscow',
      'mumbay': 'Mumbai',
      'bejing': 'Beijing',
      'shangai': 'Shanghai',
      'sydney': 'Sydney',
      'melborne': 'Melbourne',
      'barcelon': 'Barcelona',
      'madrit': 'Madrid',
      'rom': 'Rome',
      'pari': 'Paris',
      'berli': 'Berlin',
      'vien': 'Vienna',
      'zuric': 'Zurich',
      'amsteram': 'Amsterdam',
      'brussel': 'Brussels',
      'stockhol': 'Stockholm',
    };

    // Check for exact matches
    if (corrections.containsKey(lowerCity)) {
      suggestions.add(corrections[lowerCity]!);
    } else {
      // Check for partial matches (common prefixes)
      for (final entry in corrections.entries) {
        if (lowerCity.startsWith(entry.key.substring(0, (entry.key.length * 0.7).round())) ||
            entry.key.startsWith(lowerCity.substring(0, (lowerCity.length * 0.7).round()))) {
          suggestions.add(entry.value);
        }
      }
    }

    return suggestions.take(2).toList(); // Limit to 2 suggestions
  }

  // Single optimized LLM call that handles all weather analysis at once
  Future<Map<String, dynamic>> analyzeWeatherQueryComplete(
    String message, {
    String? lastCity,
    String? lastWeatherType,
    String? conversationHistory,
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      return _analyzeWeatherQueryFallback(message, lastCity: lastCity, lastWeatherType: lastWeatherType);
    }

    try {
      final analysisPrompt = '''
Analyze this weather query and provide a complete analysis in one response.

Message: "$message"
Context: Last city: ${lastCity ?? 'none'}, Last type: ${lastWeatherType ?? 'none'}
Recent conversation: ${conversationHistory ?? 'none'}

Respond with ONLY a JSON object:
{
  "should_use_tool": true/false,
  "city": "extracted city name (English preferred)",
  "tool_name": "get-current-weather" or "get-weather-forecast",
  "enhanced_message": "clarified message if context was needed",
  "confidence": 0.0-1.0,
  "language": "detected language"
}

Rules:
- Extract cities from ANY language (京都→Kyoto, München→Munich)
- Handle possessive forms (London's→London)
- Use context to resolve ambiguous queries
- Set should_use_tool=false for greetings/non-weather queries
- Enhanced_message should be the original if no enhancement needed
- Use forecast tool if "forecast" is mentioned, otherwise current weather

Examples:
"How's the weather in London?" → {"should_use_tool": true, "city": "London", "tool_name": "get-current-weather", "enhanced_message": "How's the weather in London?", "confidence": 0.9, "language": "en"}
"What about Tokyo?" (after asking about weather) → {"should_use_tool": true, "city": "Tokyo", "tool_name": "get-current-weather", "enhanced_message": "What's the weather in Tokyo?", "confidence": 0.8, "language": "en"}
"Hello" → {"should_use_tool": false, "city": null, "tool_name": null, "enhanced_message": "Hello", "confidence": 1.0, "language": "en"}
''';

      final response = await http.post(
        Uri.parse('$geminiBaseUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': analysisPrompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 300,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        
        if (content != null) {
          try {
            final cleanContent = content.trim();
            final jsonStr = cleanContent.replaceAll(RegExp(r'```json\s*|\s*```'), '').trim();
            final result = jsonDecode(jsonStr) as Map<String, dynamic>;
            
            print('🚀 DEBUG: Complete LLM analysis: $result');
            return result;
          } catch (e) {
            print('❌ DEBUG: Failed to parse complete analysis: $content');
            return _analyzeWeatherQueryFallback(message, lastCity: lastCity, lastWeatherType: lastWeatherType);
          }
        }
      }
    } catch (e) {
      print('❌ DEBUG: Complete LLM analysis failed: $e');
    }

    return _analyzeWeatherQueryFallback(message, lastCity: lastCity, lastWeatherType: lastWeatherType);
  }

  // Fast fallback analysis without LLM
  Map<String, dynamic> _analyzeWeatherQueryFallback(
    String message, {
    String? lastCity,
    String? lastWeatherType,
  }) {
    print('🔄 DEBUG: Using fast fallback analysis');
    
    final lowerMessage = message.toLowerCase();
    
    // Quick greeting check
    final greetingWords = ['hello', 'hi', 'hey', 'good', 'thanks', 'bye'];
    final isGreeting = greetingWords.any((word) => lowerMessage.contains(word)) && 
                      message.split(' ').length <= 3;
    
    if (isGreeting) {
      return {
        "should_use_tool": false,
        "city": null,
        "tool_name": null,
        "enhanced_message": message,
        "confidence": 1.0,
        "language": _detectLanguageBasic(message),
      };
    }

    // Enhanced message with context
    String enhancedMessage = message;
    if (lastCity != null) {
      if (lowerMessage.contains('what about') || lowerMessage.contains('how about')) {
        final city = _extractCityFromMessage(message);
        if (city != null) {
          enhancedMessage = "What's the weather in $city?";
        }
      } else if ((lowerMessage.contains('today') || lowerMessage.contains('now')) && 
                 !lowerMessage.contains('weather') && message.split(' ').length <= 2) {
        enhancedMessage = "What's the weather in $lastCity today?";
      }
    }

    // Determine tool usage
    final hasWeatherIntent = _containsWeatherQuery(enhancedMessage) || 
                            _containsInternationalWeatherQuery(enhancedMessage);
    final city = _extractCityFromMessage(enhancedMessage);
    final shouldUse = hasWeatherIntent && city != null;

    // Determine tool name
    String? toolName;
    if (shouldUse) {
      toolName = (lowerMessage.contains('forecast') || 
                  lowerMessage.contains('预报') || 
                  lowerMessage.contains('pronóstico')) 
          ? 'get-weather-forecast' 
          : 'get-current-weather';
    }

    return {
      "should_use_tool": shouldUse,
      "city": city,
      "tool_name": toolName,
      "enhanced_message": enhancedMessage,
      "confidence": shouldUse ? 0.7 : 0.3,
      "language": _detectLanguageBasic(message),
    };
  }

  // Basic language detection
  String _detectLanguageBasic(String message) {
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(message)) return 'zh'; // Chinese
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(message)) return 'ja'; // Japanese
    if (RegExp(r'[àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿ]').hasMatch(message.toLowerCase())) return 'es'; // Spanish/French
    if (RegExp(r'[äöüß]').hasMatch(message.toLowerCase())) return 'de'; // German
    return 'en'; // Default to English
  }

  // Check for weather queries in other languages
  bool _containsInternationalWeatherQuery(String message) {
    final internationalWeatherKeywords = [
      // Chinese
      '天气', '气温', '温度', '预报',
      // Japanese  
      '天気', '気温', '予報',
      // Spanish
      'tiempo', 'temperatura', 'pronóstico', 'clima',
      // French
      'météo', 'température', 'prévision', 'climat',
      // German
      'wetter', 'temperatur', 'vorhersage', 'klima',
      // Portuguese
      'tempo', 'temperatura', 'previsão', 'clima',
      // Italian
      'tempo', 'temperatura', 'previsione', 'clima',
      // Russian
      'погода', 'температура', 'прогноз',
    ];

    return internationalWeatherKeywords.any((keyword) => message.toLowerCase().contains(keyword));
  }

  bool _containsWeatherQuery(String message) {
    final weatherKeywords = [
      'weather',
      'temperature',
      'forecast',
      'rain',
      'sunny',
      'cloudy',
      'hot',
      'cold',
      'humid',
      'wind',
      'storm',
      'snow',
      'climate',
    ];

    return weatherKeywords.any((keyword) => message.contains(keyword));
  }

  String? _extractCityFromMessage(String message) {
    print('🔍 DEBUG: Extracting city from: "$message"');

    // Words to filter out (time-related, common words, weather terms, greetings)
    final filterWords = {
      'weather',
      'today',
      'tomorrow',
      'now',
      'there',
      'like',
      'the',
      'is',
      'it',
      'forecast',
      'temperature',
      'hot',
      'cold',
      'rain',
      'sunny',
      'cloudy',
      'what',
      'how',
      'whats',
      "what's",
      'hows',
      "how's",
      'show',
      'me',
      'get',
      'give', // Added "give" to filter words
      'tell',
      'check',
      'current',
      'todays',
      "today's",
      'this',
      'morning',
      'afternoon',
      'evening',
      'night',
      'day',
      'week',
      'time',
      'right',
      'please',
      'can',
      'you',
      'will',
      'information',
      'info',
      // Common greetings
      'hello',
      'hi',
      'hey',
      'good',
      'thanks',
      'thank',
      'bye',
      'goodbye',
    };

    // Helper function to clean city name (remove possessive forms and punctuation)
    String cleanCityName(String city) {
      // Remove possessive forms (London's -> London)
      String cleaned = city.replaceAll(RegExp(r"'s$"), '');
      // Remove other punctuation
      cleaned = cleaned.replaceAll(RegExp(r'[^\w\s]'), '');
      return cleaned.trim();
    }

    // Enhanced patterns to match city names more accurately
    final patterns = [
      RegExp(
        r'weather\s+(?:in|for|at)\s+([a-zA-Z]+(?:' "'" r's|[a-zA-Z\s]+)*?)(?:\s+(?:today|tomorrow|now|this|right|please|\?|$))',
        caseSensitive: false,
      ),
      RegExp(
        r'forecast\s+(?:in|for|at)\s+([a-zA-Z]+(?:' "'" r's|[a-zA-Z\s]+)*?)(?:\s+(?:today|tomorrow|now|this|right|please|\?|$))',
        caseSensitive: false,
      ),
      RegExp(
        r'temperature\s+(?:in|for|at)\s+([a-zA-Z]+(?:' "'" r's|[a-zA-Z\s]+)*?)(?:\s+(?:today|tomorrow|now|this|right|please|\?|$))',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:in|at)\s+([a-zA-Z]+(?:' "'" r's|[a-zA-Z\s]+)*?)(?:\s+(?:today|tomorrow|now|weather|forecast|temperature|\?|$))',
        caseSensitive: false,
      ),
      RegExp(
        r"(?:how'?s|what'?s)\s+the\s+weather\s+in\s+([a-zA-Z]+(?:" "'" r"s|[a-zA-Z\s]+)*?)(?:\s*\?|$)",
        caseSensitive: false,
      ),
      RegExp(
        r"(?:how'?s|what'?s)\s+the\s+forecast\s+(?:for|in)\s+([a-zA-Z]+(?:" "'" r"s|[a-zA-Z\s]+)*?)(?:\s*\?|$)",
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(message);
      if (match != null) {
        final city = match.group(1)?.trim();
        if (city != null && city.isNotEmpty) {
          // Clean the city name and remove filter words
          final cleanedCity = cleanCityName(city);
          final cityWords = cleanedCity
              .split(' ')
              .where((word) => !filterWords.contains(word.toLowerCase()))
              .where((word) => word.length > 1)
              .toList();

          if (cityWords.isNotEmpty) {
            final finalCity = cityWords.join(' ');
            print(
              '🏙️ DEBUG: Extracted city: "$finalCity" from captured: "$city" (cleaned: "$cleanedCity")',
            );
            return finalCity;
          }
        }
      }
    }

    // Fallback: try to find potential city names (proper nouns)
    final words = message.split(' ');
    for (int i = 0; i < words.length; i++) {
      final word = words[i].replaceAll(
        RegExp(r'[^\w' "'" r']'),
        '',
      ); // Keep apostrophes for possessive forms

      // Check if it's a potential city name (capitalized, not a filter word)
      if (word.length > 2 &&
          word[0].toUpperCase() == word[0] &&
          !filterWords.contains(word.toLowerCase().replaceAll("'s", ""))) {
        // Check if next word is also capitalized (for multi-word cities)
        String cityName = cleanCityName(word);
        if (i + 1 < words.length) {
          final nextWord = words[i + 1].replaceAll(RegExp(r'[^\w' "'" r']'), '');
          if (nextWord.length > 1 &&
              nextWord[0].toUpperCase() == nextWord[0] &&
              !filterWords.contains(nextWord.toLowerCase().replaceAll("'s", ""))) {
            cityName = cleanCityName('$word $nextWord');
          }
        }

        if (cityName.isNotEmpty) {
          print('🏙️ DEBUG: Fallback extracted city: "$cityName"');
          return cityName;
        }
      }
    }

    print('❌ DEBUG: No city found in message');
    return null;
  }

  // Optimized methods using single LLM call
  Future<bool> shouldUseWeatherTool(String message, {String? lastCity, String? lastWeatherType, String? conversationHistory}) async {
    final analysis = await analyzeWeatherQueryComplete(
      message, 
      lastCity: lastCity, 
      lastWeatherType: lastWeatherType, 
      conversationHistory: conversationHistory
    );
    final shouldUse = analysis['should_use_tool'] as bool;
    
    print('🔍 DEBUG: LLM shouldUseWeatherTool - result: $shouldUse, confidence: ${analysis["confidence"]}');
    return shouldUse;
  }

  Future<Map<String, dynamic>> extractWeatherToolParams(String message, {String? lastCity, String? lastWeatherType, String? conversationHistory}) async {
    final analysis = await analyzeWeatherQueryComplete(
      message, 
      lastCity: lastCity, 
      lastWeatherType: lastWeatherType, 
      conversationHistory: conversationHistory
    );
    final params = <String, dynamic>{};

    if (analysis['city'] != null) {
      params['city'] = analysis['city'];
    }

    print('🔧 DEBUG: LLM extractWeatherToolParams - city: ${analysis["city"]}, params: $params');
    return params;
  }

  Future<String> getToolName(String message, {String? lastCity, String? lastWeatherType, String? conversationHistory}) async {
    final analysis = await analyzeWeatherQueryComplete(
      message, 
      lastCity: lastCity, 
      lastWeatherType: lastWeatherType, 
      conversationHistory: conversationHistory
    );
    final toolName = analysis['tool_name'] as String? ?? 'get-current-weather';

    print('🎯 DEBUG: LLM getToolName - selected tool: $toolName');
    return toolName;
  }

  Future<String> getEnhancedMessage(String message, {String? lastCity, String? lastWeatherType, String? conversationHistory}) async {
    final analysis = await analyzeWeatherQueryComplete(
      message, 
      lastCity: lastCity, 
      lastWeatherType: lastWeatherType, 
      conversationHistory: conversationHistory
    );
    final enhancedMessage = analysis['enhanced_message'] as String? ?? message;

    print('🧠 DEBUG: LLM enhanced message: "$message" → "$enhancedMessage"');
    return enhancedMessage;
  }

  // Legacy methods (keep for backward compatibility)
  bool shouldUseWeatherToolSync(String message) {
    final lowerMessage = message.toLowerCase();

    // Don't use weather tools for simple greetings
    final greetingWords = [
      'hello',
      'hi',
      'hey',
      'good',
      'thanks',
      'thank',
      'bye',
      'goodbye',
    ];
    final messageWords = lowerMessage.split(' ');
    final isSimpleGreeting =
        messageWords.length <= 3 &&
        messageWords.any(
          (word) =>
              greetingWords.contains(word.replaceAll(RegExp(r'[^\w]'), '')),
        );

    if (isSimpleGreeting) {
      print(
        '🔍 DEBUG: LLM shouldUseWeatherTool - detected simple greeting, skipping weather tool',
      );
      return false;
    }

    final hasWeatherQuery = _containsWeatherQuery(lowerMessage);
    final city = _extractCityFromMessage(message);
    final result = hasWeatherQuery && city != null;

    print('🔍 DEBUG: LLM shouldUseWeatherTool - message: "$message"');
    print(
      '🔍 DEBUG: LLM hasWeatherQuery: $hasWeatherQuery, city: $city, result: $result',
    );

    return result;
  }

  Map<String, dynamic> extractWeatherToolParamsSync(String message) {
    final city = _extractCityFromMessage(message);
    final params = <String, dynamic>{};

    if (city != null) {
      params['city'] = city;
    }

    print(
      '🔧 DEBUG: LLM extractWeatherToolParams - city: $city, params: $params',
    );
    return params;
  }

  String getToolNameSync(String message) {
    final lowerMessage = message.toLowerCase();
    String toolName;

    if (lowerMessage.contains('forecast')) {
      toolName = 'get-weather-forecast';
    } else {
      toolName = 'get-current-weather';
    }

    print(
      '🎯 DEBUG: LLM getToolName - selected tool: $toolName for message: "$message"',
    );
    return toolName;
  }

  // Context-aware message processing
  bool isContextualWeatherQuery(
    String message, {
    String? lastCity,
    String? lastWeatherType,
    DateTime? lastWeatherRequest,
  }) {
    final lowerMessage = message.toLowerCase();

    // Check for contextual phrases
    final contextualPhrases = [
      'what about',
      'how about',
      'and',
      'also',
      'there',
      'too',
      'as well',
      'same for',
      'for',
    ];

    final hasContextualPhrase = contextualPhrases.any(
      (phrase) => lowerMessage.contains(phrase),
    );

    // Check for time-related words (indicating weather query)
    final timeWords = [
      'today',
      'tomorrow',
      'now',
      'currently',
      'this morning',
      'tonight',
    ];
    final hasTimeWord = timeWords.any((word) => lowerMessage.contains(word));

    // If it's a short message with a city name and contextual phrase
    final cityInMessage = _extractCityFromMessage(message);

    print(
      '🧠 DEBUG: Contextual analysis - hasContextual: $hasContextualPhrase, hasTime: $hasTimeWord, city: $cityInMessage, lastCity: $lastCity',
    );

    // Context scenarios:
    // 1. "what about London?" after asking about weather
    // 2. "today" after asking incomplete question
    // 3. Short city name after weather context
    if (lastCity != null &&
        (lastWeatherRequest == null ||
            DateTime.now().difference(lastWeatherRequest).inMinutes < 10)) {
      if (hasContextualPhrase && cityInMessage != null) {
        return true; // "what about London?"
      }
      if (hasTimeWord && cityInMessage == null) {
        return true; // "today"
      }
      if (cityInMessage != null && message.split(' ').length <= 3) {
        return true; // "London please"
      }
    }

    return false;
  }

  String enhanceMessageWithContext(
    String message, {
    String? lastCity,
    String? lastWeatherType,
  }) {
    final lowerMessage = message.toLowerCase();

    // If user asks "what about [city]?" - convert to full weather query
    if (lowerMessage.contains('what about') ||
        lowerMessage.contains('how about')) {
      final city = _extractCityFromMessage(message);
      if (city != null) {
        final weatherType = lastWeatherType == 'forecast'
            ? 'forecast'
            : 'weather';
        return "What's the $weatherType in $city?";
      }
    }

    // If user just says "today" or "now" - use last city
    if ((lowerMessage.contains('today') ||
            lowerMessage.contains('now') ||
            lowerMessage.contains('currently')) &&
        lastCity != null &&
        !lowerMessage.contains('weather') &&
        message.split(' ').length <= 2) {
      return "What's the weather in $lastCity today?";
    }

    // If user just mentions a city name - use last weather type
    final cityInMessage = _extractCityFromMessage(message);
    if (cityInMessage != null &&
        message.split(' ').length <= 3 &&
        !_containsWeatherQuery(lowerMessage)) {
      final weatherType = lastWeatherType == 'forecast'
          ? 'forecast'
          : 'weather';
      return "What's the $weatherType in $cityInMessage?";
    }

    return message;
  }
}
