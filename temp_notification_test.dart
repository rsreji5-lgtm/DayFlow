import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  final _notifications = FlutterLocalNotificationsPlugin();
  await _notifications.show(
    id: 999,
    title: 'Test',
    body: 'Body',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'id',
        'name',
        importance: Importance.max,
      ),
    ),
    payload: 'payload',
  );
}
