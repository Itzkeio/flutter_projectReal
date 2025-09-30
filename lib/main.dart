// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'firebase_options.dart';

import 'package:permission_handler/permission_handler.dart';

// Auth pages
import 'login/login.dart';
import 'signup/signup.dart';

// App pages
import 'home/home.dart';
import 'profile/profile_page.dart';
import 'qrscan/qr_scanner.dart';
import 'qrGenerator/qr_generator.dart';

// Global theme controller (provides themeModeNotifier)
import 'theme/theme-controller.dart';

// Global plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'save_channel', // id
  'Save Notifications', // title
  description: 'Channel for profile save notifications',
  importance: Importance.high,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final status = await Permission.notification.request();
  if (!status.isGranted) {
    debugPrint("Notification permission not granted");
  }

  //Init notification
  const AndroidInitializationSettings androidInit =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

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
