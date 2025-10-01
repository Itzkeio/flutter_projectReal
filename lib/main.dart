// lib/main.dart
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pages
import 'login/login.dart';
import 'signup/signup.dart';
import 'home/home.dart';
import 'profile/profile_page.dart';
import 'qrscan/qr_scanner.dart';
import 'qrGenerator/qr_generator.dart';

// Theme controller
import 'theme/theme-controller.dart';

// SQLite init
import 'data/app_database.dart';

// Notifikasi lokal
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'save_channel',
  'Save Notifications',
  description: 'Channel for profile save notifications',
  importance: Importance.high,
);

Future<void> _initNotifications() async {
  // iOS settings (biar gak error di iOS)
  const darwinInit = DarwinInitializationSettings();

  // Android settings
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: darwinInit,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // Android-only: buat channel + minta permission (Android 13+)
  if (Platform.isAndroid) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Permission notifikasi (Android 13+)
    final status = await Permission.notification.request();
    if (!status.isGranted) {
      debugPrint("Notification permission not granted");
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init SQLite lebih awal
  await AppDatabase().database;

  // Init notifikasi (dengan guard platform)
  await _initNotifications();

  // Tentukan initialRoute berdasarkan sesi lokal
  final sp = await SharedPreferences.getInstance();
  final currentEmail = sp.getString('current_email');
  final initialRoute =
      (currentEmail != null && currentEmail.isNotEmpty) ? '/' : '/login';

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
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

          initialRoute: initialRoute,

          routes: {
            '/login': (_) => Login(),
            '/signup': (_) => Signup(),
            '/': (_) => const HomePage(),
            '/profile': (_) => const ProfilePage(),
            QrScanner.routeName: (_) => const QrScanner(),
            QrGenerator.routeName: (_) => const QrGenerator(),
          },
        );
      },
    );
  }
}
