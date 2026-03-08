import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Timezone initialize karna zaroori hai scheduled alarms ke liye
    tz.initializeTimeZones();

    // Android ka default icon use kar rahe hain
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(settings);
  }

  // Hearing Reminder Schedule karne ka function
  static Future<void> scheduleHearingReminder({
    required int id,
    required String clientName,
    required String dateString, // Format: DD-MM-YYYY
  }) async {
    try {
      if (dateString == 'No Date Set' || dateString.isEmpty) return;

      // Date string (DD-MM-YYYY) ko DateTime object mein convert karna
      List<String> parts = dateString.split('-');
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      DateTime hearingDate = DateTime(year, month, day);

      // Notification peshi se 1 din pehle, subah 9 baje set karna
      DateTime reminderTime = hearingDate.subtract(const Duration(days: 1)).add(const Duration(hours: 9));

      // Agar reminder ka waqt guzar chuka hai, toh alarm set na karein
      if (reminderTime.isBefore(DateTime.now())) return;

      final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'hearing_channel',
        'Hearing Reminders',
        channelDescription: 'Court hearing alerts',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.zonedSchedule(
        id,
        '⚖️ Upcoming Hearing Alert',
        'Reminder: Hearing for case "$clientName" is scheduled for tomorrow!',
        scheduledDate,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      log("Reminder scheduled for $clientName on $scheduledDate");

    } catch (e) {
      log("Notification Error: $e");
    }
  }
}