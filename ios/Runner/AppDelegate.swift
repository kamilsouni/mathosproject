import UIKit
import Flutter
import flutter_local_notifications
import GoogleSignIn

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    let flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        // Demande d'autorisation pour les notifications
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
        }

        // Configuration des paramètres de notification pour iOS
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]

        notificationCenter.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Gestion des URLs pour Google Sign In
    override func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        var handled: Bool

        // Essayer de gérer l'URL avec Google Sign In
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }

        // Si Google Sign In n'a pas géré l'URL, laisser d'autres handlers la traiter
        return false
    }

    // Gestion des notifications en arrière-plan (optionnel)
    override func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
}