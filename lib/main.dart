// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// Auth pages
import 'login/login.dart';
import 'signup/signup.dart';

// App pages
import 'home/home.dart';
import 'notification/notification_page.dart';
import 'profile/profile_page.dart';
import 'qrscan/qr_scanner.dart';
import 'qrGenerator/qr_generator.dart';
// Global theme controller (provides themeModeNotifier)
import 'theme/theme-controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier, // toggled from Home
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,

          // Light theme
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.light,
            ),
          ),

          // Dark theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red,
              brightness: Brightness.dark,
            ),
          ),

          // Start on Login
          initialRoute: '/login',

          // Named routes
          routes: {
            '/login': (_) => Login(),
            '/signup': (_) => Signup(),

            '/': (_) => const HomePage(),
            // '/notifications': (_) => const NotificationsPage(),
            '/profile': (_) => const ProfilePage(),
            QrScanner.routeName: (_) => const QrScanner(),
            QrGenerator.routeName: (_) => const QrGenerator(),
            // qr_scanner.routeName: (_) => const qr_scanner(),     // '/qr-scan'
            // qr_generator.routeName: (_) => const qr_generator(), // '/qr-generate'
          },
        );
      },
    );
  }
}
