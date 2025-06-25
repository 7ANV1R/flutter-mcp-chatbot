import 'weather_data.dart';

enum MessageType { user, assistant, system }

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isError;
  final WeatherData? weatherData; // Add weather data field

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    DateTime? timestamp,
    this.isError = false,
    this.weatherData, // Add weather data parameter
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isError,
    WeatherData? weatherData,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      weatherData: weatherData ?? this.weatherData,
    );
  }
}
