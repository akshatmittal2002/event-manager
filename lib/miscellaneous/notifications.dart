import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final initializationSettingsAndroid = AndroidInitializationSettings('ic_launcher');
    tz.initializeTimeZones();
    final initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String payload) async {
        print('Select Notification ${payload}');
      },
    );
  }

  Future<void> scheduleNotification(Task task) async {
    var time = tz.TZDateTime(tz.local, task.date.year, task.date.month, task.date.day, task.startTime.hour, task.startTime.minute);
    var timeUTC = time.subtract(DateTime.now().timeZoneOffset);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      "Event Started!",
      "${task.title} task of ${task.category.title} category started!",
      timeUTC,
      NotificationDetails(
        android: AndroidNotificationDetails(
          FirebaseAuth.instance.currentUser.uid.toString(),
          FirebaseAuth.instance.currentUser.displayName.toString(),
          channelDescription: 'Task Reminder',
          playSound: true,
          priority: Priority.high,
          importance: Importance.high,
        )
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(Task task) async {
    await flutterLocalNotificationsPlugin.cancel(task.id.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

}