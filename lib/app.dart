import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'screens/chat_screen.dart';
import 'services/theme_service.dart';
import 'providers/theme_provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeService _themeService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _themeService = ThemeService();
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    await _themeService.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      );
    }

    return ThemeProvider(
      themeService: _themeService,
      child: AnimatedBuilder(
        animation: _themeService,
        builder: (context, child) {
          return MaterialApp(
            title: AppConstants.appTitle,
            theme: AppTheme.lightTheme(_themeService.primaryColorTheme),
            darkTheme: AppTheme.darkTheme(_themeService.primaryColorTheme),
            themeMode: _themeService.materialThemeMode,
            home: const ChatScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
