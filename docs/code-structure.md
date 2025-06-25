# Code Structure Guide

This guide walks through the clean, organized codebase to help you understand how everything is implemented.

## Project Structure

```
flutter_mcp_chat/
├── lib/                          # Main application code
│   ├── main.dart                 # 🎯 Clean entry point (15 lines)
│   ├── app.dart                  # 📱 App configuration
│   ├── config/                   # ⚙️ Configuration
│   │   ├── app_constants.dart    # 🔧 Constants & styling
│   │   └── app_theme.dart        # 🎨 Material Design theme
│   ├── models/                   # 📊 Data models
│   │   ├── chat_message.dart     # 💬 Chat message structure
│   │   ├── weather_data.dart     # 🌡️ Weather data structure
│   │   └── models.dart           # 📦 Barrel exports
│   ├── screens/                  # 📱 Screen widgets
│   │   └── chat_screen.dart      # 💬 Main chat interface
│   ├── services/                 # 🔧 Business logic
│   │   ├── chat_service.dart     # 🤖 Chat coordination
│   │   ├── llm_service.dart      # 🧠 AI integration
│   │   ├── mcp_client.dart       # 📡 MCP protocol
│   │   ├── weather_service.dart  # 🌦️ Weather API
│   │   └── services.dart         # 📦 Barrel exports
│   └── widgets/                  # 🧩 UI components
│       ├── chat/                 # 💬 Chat-specific widgets
│       │   ├── animated_message_bubble.dart
│       │   ├── animated_send_button.dart
│       │   └── typing_indicator.dart
│       ├── ui/                   # 🎨 General UI widgets
│       │   ├── chat_app_bar.dart
│       │   ├── chat_input_area.dart
│       │   ├── chat_loading_indicator.dart
│       │   ├── chat_messages_list.dart
│       │   └── weather_widget.dart
│       └── widgets.dart          # 📦 Barrel exports
├── bin/                          # Standalone executables
│   └── weather_server.dart       # 🌤️ MCP weather server
├── docs/                         # 📚 Documentation
├── .env                          # 🔑 API keys (not in git)
└── pubspec.yaml                  # 📋 Flutter dependencies
```

## Architecture Benefits

### 🎯 **Clean Architecture Layers**
This project follows clean architecture principles with clear separation:

- **Presentation Layer** (`screens/`, `widgets/`): UI components and user interaction
- **Business Logic Layer** (`services/`): Application logic and coordination  
- **Data Layer** (`models/`): Data structures and contracts
- **Configuration Layer** (`config/`): App-wide settings and constants

### 📦 **Barrel Exports**
Clean imports using barrel files:
```dart
// Instead of multiple imports:
import '../widgets/ui/chat_app_bar.dart';
import '../widgets/ui/chat_input_area.dart';

// Use single barrel import:
import '../widgets/widgets.dart';
```

### 🔧 **Centralized Configuration**
All styling values in one place:
```dart
// AppConstants.dart
static const Color primaryBlue = Color(0xFF6366F1);
static const double borderRadius = 24.0;
static const String inputHint = 'Ask about weather...';
```

### 🧩 **Component Hierarchy**
```
ChatScreen
├── ChatAppBar
├── ChatMessagesList
│   ├── AnimatedMessageBubble
│   │   └── WeatherWidget (conditional)
│   └── TypingIndicator (conditional)
└── ChatInputArea
    ├── TextField
    └── AnimatedSendButton
```

## Core Files Explained

### `main.dart` - Ultra-Clean Entry Point (15 lines!)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: Could not load .env file: $e');
  }

  runApp(const MyApp());
}
```

**What it does**: 
- Initializes Flutter
- Loads environment variables
- Launches the app
- **That's it!** Everything else is properly abstracted

### `app.dart` - App Configuration

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: AppTheme.lightTheme,
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

**What it does**:
- Configures MaterialApp
- Applies centralized theme
- Sets up navigation
- Uses constants for configuration
// Key responsibilities:
// 1. Initialize the Flutter app
// 2. Set up the main chat interface
// 3. Handle user input and display messages
// 4. Manage UI state

class ChatScreen extends StatefulWidget {
  // Main chat interface with:
  // - Message list display
  // - Text input field
  // - Send button
  // - Weather widget integration
}
```

**What makes it special**:

- Clean Material Design interface
- Responsive layout for different screen sizes
- Smooth animations and transitions
- Integrates custom weather widgets

### `chat_service.dart` - The Coordinator

```dart
// This is the "brain" that connects everything:
// 1. Receives user messages
// 2. Decides whether to call AI or tools
// 3. Manages conversation flow
// 4. Handles errors gracefully

class ChatService {
  // Main method that processes all user input
  Future<void> sendMessage(String message) async {
    // Intelligence to decide what to do with each message
  }
}
```

**Key features**:

- Smart message routing
- Context awareness
- Error recovery
- State management

### `llm_service.dart` - AI Integration

```dart
// Handles all communication with Gemini AI:
// 1. Formats messages for AI
// 2. Handles tool calling responses
// 3. Manages conversation context
// 4. Provides fallback responses

class LLMService {
  // Sends messages to Gemini and interprets responses
  Future<String> processMessage(String message, List<ChatMessage> context) {
    // AI magic happens here
  }
}
```

**AI Features**:

- Context-aware conversations
- Smart city extraction from messages
- Tool calling intelligence
- Natural language generation

### `mcp_client.dart` - MCP Protocol Handler

```dart
// Implements Model Context Protocol for mobile:
// 1. Provides weather tools to AI
// 2. Handles tool execution
// 3. Manages MCP communication
// 4. Mobile-optimized (no external processes)

class MCPClient {
  // Available tools for the AI to use
  List<Map<String, dynamic>> get availableTools => [
    {
      'name': 'get-current-weather',
      'description': 'Get current weather for a city',
      // Tool definition...
    }
  ];
}
```

**MCP Implementation**:

- In-process tool execution
- Standardized tool definitions
- Error handling and validation
- Future-ready for more tools

### `weather_service.dart` - Weather API Client

```dart
// Handles all weather-related operations:
// 1. Calls OpenWeatherMap API
// 2. Parses weather data
// 3. Handles API errors
// 4. Provides demo data fallback

class WeatherService {
  Future<WeatherData> getCurrentWeather(String city) async {
    // Real API calls to OpenWeatherMap
    // Smart error handling
    // Data parsing and validation
  }
}
```

**Features**:

- Real-time weather data
- Comprehensive error handling
- Demo mode support
- Clean data models

## Data Models

### `ChatMessage` Model

```dart
class ChatMessage {
  final String text;          // Message content
  final bool isUser;          // User vs AI message
  final DateTime timestamp;   // When sent
  final WeatherData? weather; // Optional weather data

  // Methods for display and serialization
}
```

### `WeatherData` Model

```dart
class WeatherData {
  final String city;          // City name
  final String country;       // Country code
  final double temperature;   // Current temp
  final String condition;     // Weather condition
  final String description;   // Detailed description
  final int humidity;         // Humidity percentage
  final double windSpeed;     // Wind speed
  final int pressure;         // Atmospheric pressure

  // Helper methods for display formatting
}
```

## UI Components

### `WeatherWidget` - Custom Weather Display

```dart
class WeatherWidget extends StatelessWidget {
  // Beautiful weather card showing:
  // - Large temperature display
  // - Weather emoji/icon
  // - Detailed conditions
  // - Responsive design
}
```

**Design Features**:

- Card-based layout
- Weather-appropriate styling
- Responsive typography
- Smooth animations

## Key Programming Patterns

### 1. Service Pattern

Each major functionality is encapsulated in a service:

```dart
// Clear separation of concerns
ChatService    -> Coordination
LLMService     -> AI communication
MCPClient      -> Tool calling
WeatherService -> Weather data
```

### 2. Async/Await Pattern

All operations are asynchronous for smooth UI:

```dart
// Non-blocking operations
Future<String> processMessage() async {
  final response = await llmService.callAI();
  return response;
}
```

### 3. Error Handling Strategy

Multiple layers of error protection:

```dart
try {
  // Try real API
  return await weatherService.getCurrentWeather(city);
} catch (e) {
  // Fallback to demo data
  return WeatherData.demo(city);
}
```

### 4. State Management

Simple but effective state management:

```dart
class ChatScreen extends StatefulWidget {
  // Local state for UI
  // Service calls for business logic
  // Clear separation of concerns
}
```

## Code Quality Features

### Type Safety

- Strong typing throughout
- Null safety enabled
- Clear type annotations

### Error Handling

- Comprehensive try-catch blocks
- User-friendly error messages
- Graceful degradation

### Code Organization

- Logical file structure
- Clear naming conventions
- Consistent formatting

### Documentation

- Inline code comments
- Clear method signatures
- Comprehensive documentation

## Development Workflow

### 1. Local Development

```bash
flutter run                    # Start development
flutter hot reload            # Update code instantly
flutter hot restart          # Full app restart
```

### 2. Testing

```bash
flutter test                  # Run unit tests
flutter analyze              # Static analysis
dart format .                # Code formatting
```

### 3. Building

```bash
flutter build apk            # Android APK
flutter build ios           # iOS build
flutter build web           # Web version
```

## Customization Points

### Adding New Tools

1. Define tool in `mcp_client.dart`
2. Create service for tool logic
3. Update chat service routing
4. Add UI components if needed

### Changing AI Provider

1. Modify `llm_service.dart`
2. Update API endpoints
3. Adjust response parsing
4. Update environment variables

### UI Modifications

1. Edit widgets in `lib/widgets/`
2. Update `main.dart` for layout changes
3. Modify theme and styling
4. Add new UI components

The modular structure makes customization straightforward while maintaining clean architecture.
