import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static List<String> messages = [
    "Les défis mathématiques t'attendent ! Viens prouver que tu es le roi des calculs !",
    "Les records sont faits pour être battus... et si c'était le tien aujourd'hui ?",
    "Pourquoi scroller quand tu peux challenger ton cerveau en 1 minute sur Mathos ?",
    "Tu as une minute à perdre ? Non ! Viens l'investir sur Mathos et booste ton cerveau!",
    "1 minute pour un exercice rapide, et ton cerveau te dira merci. Viens sur Mathos !",
    "Des amis devant toi au classement ? C'est le moment de leur montrer qui est le boss des maths !",
    "Prends une pause et montre de quoi tu es capable avec un petit challenge mathématique !",
    "Tes neurones sont prêts pour l'action ? Mathos n'attend plus que toi !",
    "T'as une minute ? Viens éclater des records sur Mathos, les maths t'attendent !",
    "Viens découvrir des concepts mathématiques funs et surprendre tout le monde avec tes progrès !",
    "Ta dose quotidienne de maths est prête. Viens te mesurer aux meilleurs !",
    "Gymnastique cérébrale au programme ? Mathos te met au défi de rester en tête !",
    "Un cerveau affûté c'est un cerveau entraîné. À toi de jouer dans Mathos !",
    "Un nouveau record à battre t'attend dans Mathos. Relève le défi et prends la tête du classement !"
  ];

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        print('Notification cliquée avec le payload : ${notificationResponse.payload}');
      },
    );
  }

  static Future<void> scheduleDailyNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Joue à Mathos !',
      _getRandomMessage(),
      _nextInstanceOfDailyNotification(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel_id',
          'Daily Notifications',
          channelDescription: 'Notifications pour inciter à jouer',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfDailyNotification() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print("Heure actuelle : $now");

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 14, 25);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print("Notification programmée à : $scheduledDate");
    return scheduledDate;
  }

  static String _getRandomMessage() {
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> requestIOSPermissions() async {
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Permissions accordées : $granted');
  }
}