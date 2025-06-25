# MCP Weather Chatbot

A Flutter mobile app that demonstrates the Model Context Protocol (MCP) by creating a weather chatbot that uses real AI and external APIs.

## ✨ Vibe-Coded Project

This project was created with **vibe coding** — a relaxed, flow-driven approach where creativity and intuition lead the way. No overthinking, just good energy and clean code.

## Architecture

This app implements proper MCP architecture with:

- **MCP Server** (`bin/weather_server.dart`): Standalone server that provides weather tools via MCP protocol
- **MCP Client** (`lib/mcp_client.dart`): Flutter client that communicates with the server via stdio transport
- **LLM Integration** (`lib/llm_service.dart`): Uses Google Gemini AI for natural language processing
- **Weather API**: Integrates with OpenWeatherMap API for real weather data

## Features

- 🤖 **Real AI Chat**: Uses Google Gemini AI for natural language understanding
- 🌡️ **Live Weather Data**: Fetches real weather from OpenWeatherMap API
- 📡 **True MCP Implementation**: Proper client-server communication using MCP protocol
- 🔧 **Tool Calling**: AI automatically determines when and how to use weather tools
- 📱 **Mobile UI**: Beautiful Flutter chat interface

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
├── main.dart                 # Flutter app entry point
├── chat_service.dart         # Coordinates LLM, MCP, and UI
├── llm_service.dart          # Groq AI integration
├── mcp_client.dart           # MCP client (stdio transport)
└── models/
    └── chat_message.dart     # Chat message model

bin/
└── weather_server.dart       # MCP weather server

.env                          # API keys configuration
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
- **[Code Structure Guide](docs/code-structure.md)** - Detailed code walkthrough
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
