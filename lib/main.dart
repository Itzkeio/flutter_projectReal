// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:tsel_ui/utils/notification_helper.dart'; // ⬅️ IMPORT THE SERVICE

import 'firebase_options.dart';

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

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // ⭐️ THIS ONE LINE NOW SETS UP ALL PUSH NOTIFICATIONS ⭐️
  await NotificationService.instance.initialize();

  runApp(const MyApp());

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          // Assign the global navigatorKey from the helper file
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          themeMode: mode,
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
          initialRoute: '/splash',
          routes: {
            '/splash': (_) => const SplashPage(),
            '/login': (_) => Login(),
            '/signup': (_) => Signup(),
            '/': (_) => const HomePage(),
            ProfilePage.routeName: (_) => const ProfilePage(),
            QrScanner.routeName: (_) => const QrScanner(),
            QrGenerator.routeName: (_) => const QrGenerator(),
          },
        );
      },
    );
  }
}

// ... (Your SplashPage remains unchanged) ...
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
    await Future.delayed(const Duration(milliseconds: 300));
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
              Text('HJ App',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              SizedBox(height: 16),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}