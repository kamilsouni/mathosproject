import Flutter
import UIKit
import flutter_local_notifications // Ajout de l'import nécessaire

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  let flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin() // Création d'une instance du plugin

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Configuration des notifications locales pour iOS
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    // Initialisation des paramètres de notification pour iOS
    let darwinInitializationSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestAlertPermission: true,
        requestBadgePermission: true
    )

    let initializationSettings = InitializationSettings(
        iOS: darwinInitializationSettings
    )

    flutterLocalNotificationsPlugin.initialize(initializationSettings) { notificationResponse in
        // Gestion des actions après réception d'une notification
        print("Notification reçue avec payload : \(notificationResponse.payload ?? "")")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
