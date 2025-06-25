# MCP Weather Chatbot

A Flutter mobile app that demonstrates the Model Context Protocol (MCP) by creating a weather chatbot that uses real AI and external APIs.

## ✨ Vibe-Coded Project

This project was created with **vibe coding** — a relaxed, flow-driven approach where creativity and intuition lead the way. No overthinking, just good energy and clean code.

## Architecture

This app implements proper MCP architecture with clean, scalable code organization:

- **🎯 Clean Entry Point** (`main.dart`): Minimal 15-line entry point
- **📱 App Configuration** (`app.dart`): Centralized app setup and theming
- **🌤️ MCP Server** (`bin/weather_server.dart`): Standalone server providing weather tools
- **📡 MCP Client** (`services/mcp_client.dart`): Flutter client with stdio transport
- **🧠 LLM Integration** (`services/llm_service.dart`): Google Gemini AI processing
- **🌦️ Weather API** (`services/weather_service.dart`): OpenWeatherMap integration
- **🎨 Modern UI** (`widgets/`): Modular, reusable components with animations

### Key Design Principles

- **🏗️ Clean Architecture**: Separation of UI, business logic, and data
- **📦 Modular Design**: Barrel exports for clean imports
- **🎨 Design System**: Centralized constants and theming
- **♻️ Reusable Components**: Widget-based architecture
- **🚀 Scalability**: Easy to extend and maintain

## Features

- 🤖 **Real AI Chat**: Uses Google Gemini AI for natural language understanding
- 🌡️ **Live Weather Data**: Fetches real weather from OpenWeatherMap API
- 📡 **True MCP Implementation**: Proper client-server communication using MCP protocol
- 🔧 **Tool Calling**: AI automatically determines when and how to use weather tools
- 📱 **Modern Mobile UI**: Beautiful Flutter interface with smooth animations
- 🎨 **Clean Architecture**: Modular, scalable, and maintainable codebase
- ♻️ **Reusable Components**: Widget-based design system
- 🌈 **Material Design 3**: Modern UI following Google's latest design principles
- 🔧 **Easy Configuration**: Centralized constants and theming

## Setup

### 1. Get API Keys (Free)

#### Gemini AI API Key

1. Visit [https://aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
2. Sign up for a free account
3. Generate an API key
4. Copy the key

#### OpenWeatherMap API Key

1. Visit [https://openweathermap.org/api](https://openweathermap.org/api)
2. Sign up for a free account
3. Generate an API key
4. Copy the key

### 2. Configure Environment

Edit the `.env` file in the project root:

```env
# Replace with your actual API keys
GEMINI_API_KEY=your_gemini_api_key_here
OPENWEATHER_API_KEY=your_openweather_api_key_here
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

## How It Works

### MCP Flow

1. **User sends message** → Flutter UI
2. **LLM analyzes message** → Gemini AI determines if weather tools needed
3. **Tool calling** → MCP Client calls weather server via stdio transport
4. **Weather data fetched** → MCP Server calls OpenWeatherMap API
5. **Response generated** → LLM creates natural language response
6. **Display result** → Flutter UI shows the conversation

### Example Conversation

```
User: "What's the weather in London?"

AI: I'll check the current weather in London for you...

[MCP Tool Call: get-current-weather with params: {city: "London"}]

AI: Here's the current weather information I found:

Current Weather in London, GB:
🌡️ Temperature: 15°C (feels like 13°C)
🌤️ Condition: Clouds - overcast clouds
💧 Humidity: 82%
🌬️ Wind: 3.6 m/s
🔽 Pressure: 1008 hPa

Is there anything else you'd like to know about the weather?
```

## Demo Mode

The app works in demo mode even without API keys:

- **Without Gemini API**: Uses pattern-matching for responses
- **Without Weather API**: Shows demo weather data
- **Full MCP**: Still demonstrates proper MCP client-server communication

## Project Structure

```
lib/
├── main.dart                    # 🎯 Clean entry point (15 lines!)
├── app.dart                     # 📱 App configuration
├── config/                      # ⚙️ Configuration & constants
│   ├── app_constants.dart       # 🔧 Colors, dimensions, strings
│   └── app_theme.dart          # 🎨 Material Design theme
├── models/                      # 📊 Data models
│   ├── chat_message.dart        # 💬 Chat message structure
│   ├── weather_data.dart        # 🌡️ Weather data model
│   └── models.dart             # 📦 Barrel exports
├── screens/                     # 📱 Screen widgets
│   └── chat_screen.dart        # 💬 Main chat interface
├── services/                    # 🔧 Business logic & APIs
│   ├── chat_service.dart        # 🤖 Chat coordination
│   ├── llm_service.dart         # 🧠 AI integration
│   ├── mcp_client.dart          # 📡 MCP client
│   ├── mcp_weather_server.dart  # 🌤️ MCP server
│   ├── weather_service.dart     # 🌦️ Weather API
│   └── services.dart           # 📦 Barrel exports
└── widgets/                     # 🧩 Reusable UI components
    ├── chat/                   # 💬 Chat-specific widgets
    │   ├── animated_message_bubble.dart
    │   ├── animated_send_button.dart
    │   └── typing_indicator.dart
    ├── ui/                     # 🎨 General UI widgets
    │   ├── chat_app_bar.dart
    │   ├── chat_input_area.dart
    │   ├── chat_loading_indicator.dart
    │   ├── chat_messages_list.dart
    │   └── weather_widget.dart
    └── widgets.dart            # 📦 Barrel exports

bin/
└── weather_server.dart          # 🌤️ Standalone MCP server

docs/                           # 📚 Comprehensive documentation
├── getting-started.md
├── architecture.md
├── code-structure.md
├── api-integration.md
├── mcp-guide.md
└── overview.md
```

## MCP Protocol Details

This implementation demonstrates:

- **Proper initialization**: Client-server handshake via MCP protocol
- **Tool discovery**: Client lists available tools from server
- **Tool execution**: Client calls tools with parameters, server executes and returns results
- **Error handling**: Proper MCP error responses and fallbacks
- **Transport layer**: Uses stdio transport for local communication

## Technologies Used

- **Flutter**: Mobile UI framework
- **MCP Dart**: Official Dart implementation of Model Context Protocol
- **Google Gemini**: Free AI inference API
- **OpenWeatherMap**: Free weather data API
- **HTTP**: For API communications

## Documentation

📚 **Comprehensive documentation available in the `docs/` folder:**

- **[Getting Started Guide](docs/getting-started.md)** - Setup and installation
- **[Architecture Guide](docs/architecture.md)** - How everything works together
- **[Code Structure Guide](docs/code-structure.md)** - Clean architecture and code organization
- **[API Integration Guide](docs/api-integration.md)** - Working with external APIs
- **[MCP Guide](docs/mcp-guide.md)** - Understanding Model Context Protocol
- **[Project Overview](docs/overview.md)** - High-level project explanation

## Troubleshooting

### MCP Server Issues

- Ensure `dart run bin/weather_server.dart` works standalone
- Check environment variables are properly set

### API Issues

- Verify API keys are correct in `.env` file
- Check internet connection for API calls
- Review API quotas (both services offer generous free tiers)

### Flutter Issues

- Run `flutter doctor` to check Flutter setup
- Try `flutter clean && flutter pub get`

## License

MIT License - Feel free to use this as a learning resource or starting point for your own MCP applications!
