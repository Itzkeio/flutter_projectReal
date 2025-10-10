// lib/utils/notification_helper.dart
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../profile/profile_page.dart'; // For the routeName

// ⭐️ ADD A GLOBAL NAVIGATOR KEY
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// This handler must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // We need to setup notifications here to display in the background
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  // Singleton pattern to ensure only one instance of the service
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  /// Initializes the notification service. Call this in your main() function.
  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _requestPermission();
    await setupFlutterNotifications();
    await _setupMessageHandlers();

    final token = await _messaging.getToken();
    debugPrint('🔑 FCM Token: $token');
  }

  /// Sets up the local notifications plugin.
  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) return;

    const channel = AndroidNotificationChannel(
      'save_channel',
      'Save Notifications',
      description: 'This channel is used for profile save notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsDarwin = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('Foreground notification tapped. Payload: ${details.payload}');
      },
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  /// Displays a notification using the flutter_local_notifications plugin.
  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'save_channel',
            'Save Notifications',
            channelDescription: 'Profile save success notification',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission();
  }

  Future<void> _setupMessageHandlers() async {
    // Handle messages received while the app is in the foreground
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📱 Got a message whilst in the foreground!');
      showNotification(message);
    });

    // Handle messages that are tapped when the app is in the background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Handles navigation when a notification is tapped.
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    if (message.data['type'] == 'profile_saved') {
      navigatorKey.currentState?.pushNamed(ProfilePage.routeName);
    }
  }
}