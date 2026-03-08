import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart'; // 🌟 Notification service yahan import ki hai 🌟

void main() async {
  // 🌟 App chalne se pehle background services ko active karne ke liye zaroori line 🌟
  WidgetsFlutterBinding.ensureInitialized();

  // 🌟 Notifications aur Timezones ko app ke start mein hi initialize karna 🌟
  await NotificationService.init();

  runApp(const LegalDirectoryApp());
}

class LegalDirectoryApp extends StatelessWidget {
  const LegalDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amin Gill Law', // App ka professional naam
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Material 3 ko enable kar diya hai modern UI ke liye
        useMaterial3: true,

        // ColorScheme.fromSeed zyada behtar tarike se colors generate karta hai
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0B132B), // Deep Navy Blue
          primary: const Color(0xFF0B132B),
          secondary: const Color(0xFFFFC107), // Professional Gold
          surface: const Color(0xFFF4F6F9), // Light grey background
        ),

        scaffoldBackgroundColor: const Color(0xFFF4F6F9),

        // App Bar ko aur professional look di hai
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B132B),
          foregroundColor: Colors.white, // Text aur icons ka color
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2, // Text mein thora gap acha lagta hai
          ),
        ),

        // Floating Action Button ya dosre buttons ke liye default style
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFC107),
          foregroundColor: Color(0xFF0B132B), // Gold ke upar dark blue icon
          elevation: 4,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}