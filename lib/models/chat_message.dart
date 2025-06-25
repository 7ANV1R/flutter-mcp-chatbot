import 'weather_data.dart';

enum MessageType { user, assistant, system }

enum MessageState { 
  complete,       // Message fully received
  streaming,      // Content streaming in
  analyzing,      // Analyzing for weather intent
  fetchingWeather, // Weather data being fetched
  error          // Error state
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isError;
  final WeatherData? weatherData; // Add weather data field
  final MessageState state;       // Streaming state
  final bool isWeatherQuery;      // Whether this is a weather-related query

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    DateTime? timestamp,
    this.isError = false,
    this.weatherData, // Add weather data parameter
    this.state = MessageState.complete,
    this.isWeatherQuery = false,
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isError,
    WeatherData? weatherData,
    MessageState? state,
    bool? isWeatherQuery,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      weatherData: weatherData ?? this.weatherData,
      state: state ?? this.state,
      isWeatherQuery: isWeatherQuery ?? this.isWeatherQuery,
    );
  }
}
