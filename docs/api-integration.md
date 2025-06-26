# API Integration Guide

This guide explains how to work with the APIs used in this project and how to integrate your own.

## Current API Integrations

### 1. Google Gemini AI API

**Purpose**: Natural language processing and tool calling intelligence

#### Getting Started

1. Visit [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with Google account
3. Create new API key
4. Add to `.env.json` configuration file

#### Features Used

- **Text Generation**: Natural conversation responses
- **Tool Calling**: AI decides when to use weather tools
- **Context Awareness**: Remembers conversation history
- **Function Calling**: Structured tool parameter extraction

#### API Details

```dart
// Base URL
'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent'

// Authentication
Authorization: Bearer YOUR_API_KEY

// Request Format
{
  "contents": [
    {
      "parts": [{"text": "User message here"}]
    }
  ],
  "tools": [...tool definitions...],
  "generationConfig": {...}
}
```

#### Rate Limits (Free Tier)

- 15 requests per minute
- 1,500 requests per day
- 32,000 tokens per minute

#### Error Handling

```dart
try {
  final response = await http.post(url, body: body);
  if (response.statusCode == 429) {
    // Rate limit hit - wait and retry
  } else if (response.statusCode == 401) {
    // Invalid API key
  }
} catch (e) {
  // Network error - fallback to demo mode
}
```

### 2. OpenWeatherMap API

**Purpose**: Real-time weather data

#### Getting Started

1. Visit [OpenWeatherMap](https://openweathermap.org/api)
2. Create free account
3. Get API key from dashboard
4. Add to `.env.json` configuration file

#### Features Used

- **Current Weather**: Temperature, conditions, humidity
- **Location Data**: City and country information
- **Weather Details**: Wind, pressure, visibility
- **Weather Icons**: Condition codes for UI display

#### API Details

```dart
// Base URL
'https://api.openweathermap.org/data/2.5/weather'

// Parameters
?q={city_name}&appid={API_key}&units=metric

// Response Format
{
  "name": "London",
  "sys": {"country": "GB"},
  "main": {
    "temp": 15.23,
    "feels_like": 14.56,
    "humidity": 82
  },
  "weather": [
    {
      "main": "Clouds",
      "description": "overcast clouds"
    }
  ],
  "wind": {"speed": 3.6}
}
```

#### Rate Limits (Free Tier)

- 1,000 calls per day
- 60 calls per minute
- No authentication required beyond API key

#### Error Handling

```dart
try {
  final response = await http.get(url);
  if (response.statusCode == 404) {
    // City not found
  } else if (response.statusCode == 401) {
    // Invalid API key
  }
} catch (e) {
  // Network error - return demo data
}
```

## How to Add New APIs

### Step 1: Create a Service

```dart
// lib/new_service.dart
class NewService {
  final String apiKey;
  final http.Client httpClient;

  NewService({required this.apiKey}) : httpClient = http.Client();

  Future<NewData> fetchData(String parameter) async {
    try {
      final url = Uri.parse('https://api.example.com/endpoint?param=$parameter&key=$apiKey');
      final response = await httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NewData.fromJson(data);
      } else {
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle errors gracefully
      return NewData.demo();
    }
  }
}
```

### Step 2: Create Data Model

```dart
// lib/models/new_data.dart
class NewData {
  final String value;
  final DateTime timestamp;

  NewData({required this.value, required this.timestamp});

  factory NewData.fromJson(Map<String, dynamic> json) {
    return NewData(
      value: json['value'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  factory NewData.demo() {
    return NewData(
      value: 'Demo data',
      timestamp: DateTime.now(),
    );
  }
}
```

### Step 3: Add to MCP Client

```dart
// lib/mcp_client.dart
class MCPClient {
  List<Map<String, dynamic>> get availableTools => [
    // Existing tools...
    {
      'name': 'get-new-data',
      'description': 'Get data from new API',
      'inputSchema': {
        'type': 'object',
        'properties': {
          'parameter': {
            'type': 'string',
            'description': 'Parameter for API call'
          }
        },
        'required': ['parameter']
      }
    }
  ];

  Future<Map<String, dynamic>> callTool(String toolName, Map<String, dynamic> parameters) async {
    switch (toolName) {
      // Existing cases...
      case 'get-new-data':
        final newData = await newService.fetchData(parameters['parameter']);
        return {
          'content': [
            {
              'type': 'text',
              'text': 'New data: ${newData.value}'
            }
          ]
        };
      default:
        throw Exception('Unknown tool: $toolName');
    }
  }
}
```

### Step 4: Update Environment Configuration

```json
// .env.json
{
  "GEMINI_API_KEY": "your_gemini_key",
  "OPENWEATHER_API_KEY": "your_openweather_key",
  "NEW_API_KEY": "your_new_api_key"
}
```

### Step 5: Update Chat Service

```dart
// lib/chat_service.dart
import '../config/environment.dart';

class ChatService {
  late final NewService newService;

  void _initializeServices() {
    // Existing services...
    newService = NewService(apiKey: Env.newApiKey);
  }
}
```

### Step 6: Update Environment Class

```dart
// lib/config/environment.dart
class Env {
  // Existing keys...
  static const String newApiKey = String.fromEnvironment('NEW_API_KEY', defaultValue: '');
  
  static bool get hasValidNewApiKey => newApiKey.isNotEmpty && newApiKey != 'placeholder';
}
```

## API Best Practices

### 1. Error Handling Strategy

```dart
Future<ApiData> fetchData() async {
  try {
    // Primary API call
    return await primaryApiCall();
  } on TimeoutException {
    // Network timeout
    return await fallbackData();
  } on HttpException {
    // HTTP error
    return await fallbackData();
  } catch (e) {
    // Unknown error
    return await demoData();
  }
}
```

### 2. Rate Limiting

```dart
class RateLimiter {
  final Map<String, DateTime> _lastCalls = {};
  final Duration _minInterval = Duration(seconds: 1);

  Future<void> waitIfNeeded(String endpoint) async {
    final lastCall = _lastCalls[endpoint];
    if (lastCall != null) {
      final elapsed = DateTime.now().difference(lastCall);
      if (elapsed < _minInterval) {
        await Future.delayed(_minInterval - elapsed);
      }
    }
    _lastCalls[endpoint] = DateTime.now();
  }
}
```

### 3. Caching Strategy

```dart
class ApiCache {
  final Map<String, CacheEntry> _cache = {};
  final Duration _cacheTimeout = Duration(minutes: 5);

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }
    return null;
  }

  void put<T>(String key, T data) {
    _cache[key] = CacheEntry(data, DateTime.now().add(_cacheTimeout));
  }
}
```

### 4. Security Considerations

```dart
// Never hardcode API keys
// ❌ Bad
const apiKey = 'sk-1234567890abcdef';

// ✅ Good
final apiKey = Env.apiKey;

// Always use HTTPS
// ❌ Bad
final url = 'http://api.example.com/data';

// ✅ Good
final url = 'https://api.example.com/data';

// Validate API responses
// ✅ Good
if (response.statusCode == 200) {
  final data = json.decode(response.body);
  if (data['status'] == 'success') {
    return processData(data);
  }
}
```

## Testing APIs

### Unit Testing

```dart
// test/api_test.dart
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('Weather Service Tests', () {
    test('should fetch weather data successfully', () async {
      // Mock HTTP client
      final mockClient = MockClient();
      when(mockClient.get(any)).thenAnswer((_) async =>
        http.Response('{"name": "London", "main": {"temp": 15}}', 200));

      final service = WeatherService(httpClient: mockClient);
      final result = await service.getCurrentWeather('London');

      expect(result.city, equals('London'));
      expect(result.temperature, equals(15.0));
    });
  });
}
```

### Integration Testing

```dart
// integration_test/api_integration_test.dart
void main() {
  group('API Integration Tests', () {
    testWidgets('weather API returns real data', (tester) async {
      final service = WeatherService(apiKey: 'test_key');
      final weather = await service.getCurrentWeather('London');

      expect(weather.city, isNotEmpty);
      expect(weather.temperature, isA<double>());
    });
  });
}
```

## Troubleshooting Common Issues

### API Key Problems

- Double-check key is correct in `.env.json`
- Verify key has necessary permissions
- Check if key needs activation time

### Rate Limiting

- Implement exponential backoff
- Cache responses when possible
- Monitor usage in API dashboards

### Network Issues

- Always provide fallback data
- Implement retry logic
- Handle timeout gracefully

### Data Parsing

- Validate API response structure
- Handle missing fields gracefully
- Log parsing errors for debugging

This guide provides the foundation for working with APIs in the MCP chatbot. The patterns shown here can be applied to integrate almost any REST API into your Flutter application.
