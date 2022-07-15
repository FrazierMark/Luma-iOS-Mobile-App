import UIKit
import Parse
import CoreLocation
import UserNotifications

import Alamofire
import SwiftyJSON

import AEPCore
import AEPEdge
import AEPEdgeConsent
import AEPAssurance
import AEPEdgeIdentity
import AEPUserProfile
import AEPIdentity
import AEPLifecycle
import AEPSignal
import AEPServices
import AEPMessaging


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        MobileCore.setLogLevel(.debug)
        
        let appState = application.applicationState;
        loadProducts()

        let extensions = [
                          Edge.self,
                          Consent.self,
                          Assurance.self,
                          AEPEdgeIdentity.Identity.self,
                          AEPIdentity.Identity.self,
                          UserProfile.self,
                          Lifecycle.self,
                          Signal.self,
                          Messaging.self
                        ]

        // MobileCore.setLogLevel(.trace)
        MobileCore.registerExtensions(extensions, {
            MobileCore.configureWith(appId: "3149c49c3910/301aa57f50b5/launch-387236dc11bc-development")
            MobileCore.updateConfigurationWith(configDict: ["messaging.useSandbox" : true])
            if appState != .background {
                MobileCore.lifecycleStart(additionalContextData: ["contextDataKey": "contextDataVal"])
            }
        })
        
        
        // register push notification registration process with Apple Push Notification service
        registerForPushNotifications(application: application) {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 1) {
            }
        }

        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Assurance.startSession(url: url)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }


    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Register push notification registration process with Apple Push Notification service
    func registerForPushNotifications(application: UIApplication, completionHandler: @escaping ()->() = {}) {
        let center = UNUserNotificationCenter.current()

        //Ask for user permission
        center.requestAuthorization(options: [.badge, .sound, .alert]) { [weak self] granted, _ in
            defer { completionHandler() }
            guard granted else { return }

            center.delegate = self

            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    // Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
    // deviceToken is received from Apple Push Notification service
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")

        // Send push token to experience platform
        MobileCore.setPushIdentifier(deviceToken)
    }

    // Tells the delegate that the app failed to register with Apple Push Notification service (APNs).
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
        MobileCore.setPushIdentifier(nil)
    }

    // MARK: - Handle Push Notification Interactions
    // Receiving Notifications
    // Delegate method to handle a notification that arrived while the app was running in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }

    // Handling the Selection of Custom Actions
    // Delegate method to process the user's response to a delivered notification.
    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Perform the task associated with the action.
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            Messaging.handleNotificationResponse(response, applicationOpened: true, customActionId: "ACCEPT_ACTION")

        case "DECLINE_ACTION":
            Messaging.handleNotificationResponse(response, applicationOpened: false, customActionId: "DECLINE_ACTION")

            // Handle other actions…
        default:
            Messaging.handleNotificationResponse(response, applicationOpened: true, customActionId: nil)
        }

        // Always call the completion handler when done.
        completionHandler()
    }

    func loadProducts() {
        //Perviously used remote backend, made local
        let configuration = ParseClientConfiguration {
            $0.applicationId = "parseAppId"
            $0.clientKey = "parseClientKey"
            $0.server = "https://parseapi.back4app.com"
            $0.isLocalDatastoreEnabled = true
        }
        Parse.initialize(with: configuration)
        ProductBridge.loadProducts()
    }

}

extension AppDelegate {

    func showAlertDialog(title: String!, message: String!, positive: String?, negative: String?) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if (positive != nil) {

            alert.addAction(UIAlertAction(title: positive, style: .default, handler: nil))
        }

        if (negative != nil) {

            alert.addAction(UIAlertAction(title: negative, style: .default, handler: nil))
        }

        self.window?.rootViewController!.present(alert, animated: true, completion: nil)

    }


}

