// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';                // ⬅️ cek user
import 'package:flutter_native_splash/flutter_native_splash.dart'; // ⬅️ native splash

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
  // ====== Tahan native splash sampai init selesai ======
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); // ⬅️

  // Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Permission notifikasi (Android 13+)
  final status = await Permission.notification.request();
  if (!status.isGranted) {
    debugPrint("Notification permission not granted");
  }

  // Init local notifications
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

  // Lepas splash native setelah MaterialApp naik
  FlutterNativeSplash.remove(); // ⬅️
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

          // MULAI dari Splash (bukan langsung Login)
          initialRoute: '/splash', // ⬅️

          routes: {
            '/splash': (_) => const SplashPage(), // ⬅️ in-app splash
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

/// ==================== In-app Splash ====================
/// Cek status login, lalu navigate ke Login atau Home.
/// Background disamakan dengan gradient Home/Profile.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // beri jeda kecil untuk branding/animasi (opsional)
    await Future.delayed(const Duration(milliseconds: 600));

    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, user == null ? '/login' : '/');
  }

  @override
  Widget build(BuildContext context) {
    const kHomeGradient = LinearGradient(
      colors: [Color(0xFFDFF6F6), Color(0xFFB7E1E6)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(gradient: kHomeGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              // ganti path logo jika beda
              // Image.asset('assets/images/logoHJ.png', height: 96),
              // kalau belum mau pakai logo, tampilkan teks dulu:
              Text('HJ App', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 16),
              SizedBox(
                width: 28, height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
