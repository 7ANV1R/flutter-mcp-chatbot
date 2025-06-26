# Getting Started - Setup Guide

This guide will help you get the MCP Weather Chatbot running on your device, even if you're new to Flutter or mobile development.

## Prerequisites

Before we start, you'll need:

- A computer (Windows, Mac, or Linux)
- Internet connection
- About 30 minutes for setup

## Step 1: Install Flutter

### Option A: Official Installation

1. Visit [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Choose your operating system
3. Follow the installation guide
4. Run `flutter doctor` to verify installation

### Option B: Using Package Managers

**macOS (with Homebrew):**

```bash
brew install flutter
```

**Windows (with Chocolatey):**

```bash
choco install flutter
```

## Step 2: Get API Keys (Free!)

### Gemini AI API Key

1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key and save it somewhere safe

### OpenWeatherMap API Key

1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Click "Sign Up" for a free account
3. Verify your email
4. Go to "API Keys" section
5. Copy your default API key

## Step 3: Download and Setup Project

### Clone the Project

```bash
git clone [your-repo-url]
cd flutter_mcp_chat
```

### Install Dependencies

```bash
flutter pub get
```

### Configure API Keys (Secure Method)

This project uses a secure approach for API key management with `--dart-define-from-file`:

1. Copy the example configuration file:
```bash
cp .env.json.example .env.json
```

2. Edit `.env.json` with your actual API keys:
```json
{
  "GEMINI_API_KEY": "your_actual_gemini_key_here",
  "OPENWEATHER_API_KEY": "your_actual_openweather_key_here"
}
```

3. Save the file

**🔒 Security Benefits:**
- API keys are not embedded in the compiled APK
- Keys cannot be extracted from the app bundle
- More secure than traditional `.env` files
- Configuration file is automatically git-ignored

## Step 4: Run the App

### Check Everything is Ready

```bash
flutter doctor
```

Make sure all checks pass (some warnings are okay).

### Start the App

#### Using VS Code (Recommended)
If you're using VS Code, the project includes launch configurations that automatically handle the secure environment setup:

1. Open the project in VS Code
2. Press `F5` or use the Debug panel
3. Select "Flutter (Debug)" configuration
4. The app will launch with proper API key configuration

#### Using Command Line
```bash
flutter run --dart-define-from-file=.env.json
```

Choose your target device when prompted:

- Android emulator
- iOS simulator (Mac only)
- Chrome browser
- Connected physical device

## Step 5: Test the App

Once the app is running:

1. Type a message like "What's the weather in London?"
2. Wait for the AI to respond with real weather data
3. Try different cities: "How about Tokyo?"
4. Ask follow-up questions: "Will it rain today?"

## Troubleshooting

### Common Issues

**"Flutter not found"**

- Make sure Flutter is in your system PATH
- Restart your terminal/command prompt

**"No devices found"**

- Enable USB debugging on Android device
- Start an emulator: `flutter emulators --launch <emulator_id>`

**"API key invalid"**

- Double-check your API keys in `.env` file
- Make sure there are no extra spaces
- Verify the keys work on the respective websites

**"App crashes on startup"**

- Run `flutter clean && flutter pub get`
- Check you have the latest Flutter version

### Getting Help

- Check the Flutter documentation
- Visit the project's GitHub issues
- Ask questions in Flutter community forums

## Next Steps

Once you have the app running:

1. Read the [Architecture Guide](architecture.md) to understand how it works
2. Explore the [Code Structure](code-structure.md) to see the implementation
3. Try making your own modifications!

## Demo Mode

Don't have API keys yet? The app includes demo mode:

- Shows example conversations
- Demonstrates the UI
- Uses mock weather data
- Perfect for exploring the interface before setting up APIs
