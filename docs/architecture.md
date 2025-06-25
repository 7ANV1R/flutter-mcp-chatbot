# Architecture Guide - How Everything Works

This guide explains how the MCP Weather Chatbot is built and how all the pieces work together.

## High-Level Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter UI    │◄──►│   Chat Service  │◄──►│   LLM Service   │
│  (User Interface)│    │  (Coordinator)  │    │ (Gemini AI)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   MCP Client    │◄──►│ Weather Service │
                       │  (Tool Caller)  │    │ (OpenWeather)   │
                       └─────────────────┘    └─────────────────┘
```

## Core Components

### 1. Flutter UI (`main.dart`)

**What it does**: The user interface - chat bubbles, input field, weather widgets

**Key features**:

- Chat message display
- Text input handling
- Weather data visualization
- Responsive mobile design

**Technologies**: Flutter widgets, Material Design

### 2. Chat Service (`chat_service.dart`)

**What it does**: The "brain" that coordinates everything

**Responsibilities**:

- Manages conversation flow
- Decides when to call AI vs tools
- Handles user input and responses
- Manages chat history

**Think of it as**: The conductor of an orchestra, making sure everyone plays at the right time

### 3. LLM Service (`llm_service.dart`)

**What it does**: Communicates with Google's Gemini AI

**Key functions**:

- Sends user messages to AI
- Interprets AI responses
- Handles tool calling decisions
- Manages AI context and memory

**AI Features**:

- Natural language understanding
- Context awareness ("What about London?" after asking about weather)
- Tool calling intelligence (knows when to get weather data)

### 4. MCP Client (`mcp_client.dart`)

**What it does**: Handles the Model Context Protocol communication

**MCP Concepts**:

- **Tools**: Functions the AI can call (like `get-weather`)
- **Resources**: Data sources the AI can access
- **Protocol**: Standardized way for AI to use external tools

**Mobile Adaptation**: Since mobile apps can't spawn processes, this implements an in-process MCP client

### 5. Weather Service (`weather_service.dart`)

**What it does**: Fetches real weather data from OpenWeatherMap

**Features**:

- Current weather conditions
- Temperature, humidity, wind speed
- Weather descriptions and icons
- Error handling for API failures

## Data Flow

### When You Ask "What's the weather in London?"

1. **UI Capture**: Flutter captures your text input
2. **Chat Processing**: Chat service receives the message
3. **AI Analysis**: LLM service sends to Gemini AI
4. **Tool Decision**: AI decides it needs weather data
5. **MCP Call**: MCP client receives tool call request
6. **Weather Fetch**: Weather service calls OpenWeatherMap API
7. **Data Return**: Weather data flows back through the chain
8. **AI Response**: Gemini generates natural language response
9. **UI Display**: Flutter shows the response with weather widget

## Key Design Patterns

### 1. Service Layer Architecture

Each major function is separated into its own service:

- Clean separation of concerns
- Easy testing and debugging
- Modular and maintainable code

### 2. MCP Protocol Implementation

Follows the Model Context Protocol standard:

- Standardized tool calling
- Proper error handling
- Resource management
- Future-proof for other MCP tools

### 3. Reactive Programming

Uses Flutter's reactive patterns:

- State management with notifications
- Async operations with Futures
- Real-time UI updates

### 4. Error Handling Strategy

Multiple layers of error handling:

- Network failures gracefully handled
- API errors provide helpful messages
- Fallback to demo mode when needed

## Mobile-Specific Considerations

### Process Limitations

Mobile apps can't spawn external processes, so:

- MCP client runs in-process
- Weather service is embedded
- No external server processes needed

### Performance Optimizations

- Lazy loading of services
- Efficient API calling
- Minimal memory footprint
- Smooth UI interactions

### Security

- API keys stored in environment files
- Network requests use HTTPS
- No sensitive data stored locally

## Technology Choices

### Why Flutter?

- Cross-platform (iOS + Android from one codebase)
- Great performance and UI flexibility
- Strong ecosystem and community
- Excellent hot reload for development

### Why Gemini AI?

- Free tier with generous limits
- Excellent tool calling capabilities
- Fast response times
- Good context understanding

### Why OpenWeatherMap?

- Reliable weather data
- Free tier available
- Simple API
- Global coverage

### Why MCP?

- Future-proof protocol
- Standardized tool calling
- Extensible architecture
- Industry adoption growing

## Extending the Architecture

Want to add more features? The architecture supports:

### New Tools

Add services for:

- News APIs
- Stock prices
- Restaurant recommendations
- Calendar integration

### Different AI Models

Swap out LLM service for:

- OpenAI GPT
- Anthropic Claude
- Local models
- Multiple model support

### Enhanced UI

Add features like:

- Voice input
- Image sharing
- File attachments
- Video calls

The modular design makes extensions straightforward while maintaining the core MCP architecture.
