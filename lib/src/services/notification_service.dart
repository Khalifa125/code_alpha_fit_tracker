import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'fit_tracker_channel',
      'Fit Tracker Notifications',
      channelDescription: 'Notifications for workout reminders and motivation',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
    required int intervalHours,
  }) async {
    await _notifications.cancel(1);

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'fit_tracker_workout',
      'Workout Reminders',
      channelDescription: 'Daily workout reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule repeating notification
    for (int i = 0; i < 10; i++) {
      final scheduleTime = scheduledDate.add(Duration(hours: intervalHours * i));
      await _notifications.zonedSchedule(
        1 + i,
        'Time to Workout!',
        'Keep your streak going - start your workout now!',
        tz.TZDateTime.from(scheduleTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> showMotivationNotification() async {
    final motivations = [
      'Time to move!',
      'Keep your streak!',
      'You\'re doing great!',
      'Every step counts!',
      'Let\'s crush those goals!',
      'Your body will thank you!',
      'Exercise is medicine!',
      'Stay strong, stay healthy!',
    ];

    final random = DateTime.now().millisecond % motivations.length;
    
    await showNotification(
      id: 100,
      title: 'Fit Tracker',
      body: motivations[random],
    );
  }

  Future<void> showDailyGoalReminder() async {
    await showNotification(
      id: 101,
      title: 'Daily Goals',
      body: 'Check your progress and stay on track!',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static const motivationMessages = [
    'Time to move!',
    'Keep your streak going!',
    'You\'re doing great!',
    'Every step counts!',
    'Let\'s crush those goals!',
  ];
}