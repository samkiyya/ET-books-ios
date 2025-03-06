import Flutter
import UIKit
import WebKit
import UserNotifications
import FBSDKCoreKit
import FBSDKLoginKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize Facebook SDK (if Facebook login is used)
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        // Configure WebView settings (to handle cookies and sessions across websites)
        if #available(iOS 11.0, *) {
            HTTPCookieStorage.shared.cookieAcceptPolicy = .always
            let webViewConfig = WKWebViewConfiguration()
            webViewConfig.websiteDataStore.httpCookieStore = WKWebsiteDataStore.default().httpCookieStore
        }

        // Request push notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }

        // Register Flutter plugins
        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // Handle URL scheme for deep links (e.g., for Facebook login or other URL schemes)
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Handle Facebook URL scheme (if Facebook login is used)
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        }
        return super.application(app, open: url, options: options)
    }

    // Handle push notification registration (e.g., to send the device token to your server)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Send the device token to your server for push notification management
        print("Device Token: \(deviceToken)")
        // Example: send this token to your server using a POST request
    }

    // Handle push notification when the app is in the foreground
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // You can handle the push notification here, trigger custom actions, or update UI
        print("Push Notification Received: \(data)")

        completionHandler(.newData)
    }

    // Optional: Handle background fetch or other background tasks (for example, with background fetch)
    override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Perform background fetch task (e.g., fetch new data from the server)
        // Call completionHandler when the fetch task is done
        print("Background Fetch Performed")
        completionHandler(.newData)
    }
}
