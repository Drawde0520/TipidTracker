import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/utang.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showDailyGastosReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_gastos_channel',
      'Daily Gastos Reminder',
      channelDescription: 'Reminds you to log your expenses',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Tipid Reminder 💸',
      'Mag log ka ng gastos mo today!',
      platformDetails,
    );
  }

  static Future<void> showSavingsReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'savings_channel',
      'Savings Reminder',
      channelDescription: 'Reminds you to save',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notificationsPlugin.show(
      1,
      'Alkansya Time!',
      'Maghulog ka sa alkansya mo 💰',
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> scheduleUtangReminder(Utang utang) async {
    if (utang.dueDate == null) return;
    
    // We schedule it at 9:00 AM on the due date.
    var scheduledDate = DateTime(
      utang.dueDate!.year,
      utang.dueDate!.month,
      utang.dueDate!.day,
      9, // 9 AM
      0,
    );

    // If it's already past 9 AM today, schedule for right now + 1 minute (for testing). In prod, it should skip.
    if (scheduledDate.isBefore(DateTime.now())) {
       return; 
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'utang_channel',
      'Utang Reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notificationsPlugin.zonedSchedule(
      utang.id.hashCode,
      'Utang Due Today!',
      'Pa-remind: Si ${utang.personName} ay may utang na ₱${utang.amount.toStringAsFixed(2)}.',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
