import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

Future<void> showSuccessNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'save_channel', // id channel harus sama
    'Save Notifications', // nama channel
    channelDescription: 'Profile save success notification',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notifDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0, // id notif
    title,
    body,
    notifDetails,
  );
}
