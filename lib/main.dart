import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/storage_service.dart';
import 'core/services/streak_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage
  final storage = StorageService();
  await storage.init();
  
  // Initialize streak service
  final streakService = StreakService(storage);
  
  // Set preferred orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(MyApp(
    storage: storage,
    streakService: streakService,
  ));
}

class MyApp extends StatefulWidget {
  final StorageService storage;
  final StreakService streakService;
  
  const MyApp({
    super.key,
    required this.storage,
    required this.streakService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark; // Start with dark mode

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark 
          ? ThemeMode.light 
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeMode: _themeMode,
      onThemeToggle: toggleTheme,
      child: MaterialApp(
        title: 'StudyBuddy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: HomeScreen(
          storage: widget.storage,
          streakService: widget.streakService,
        ),
      ),
    );
  }
}

// Theme provider to make theme accessible throughout the app
class ThemeProvider extends InheritedWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  const ThemeProvider({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return themeMode != oldWidget.themeMode;
  }
}

