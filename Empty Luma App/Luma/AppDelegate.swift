//
//  AppDelegate.swift
//  Luma iOS Mobile Application
//
//  Developed by XScoder, https://xscoder.com
//  Enhanced by Adobe Inc. to support Adobe Experience Cloud and Adobe Experience Platform
//  All Rights reserved - 2022
//



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

    let notificationCenter = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
                    didAllow, _ in
                    if !didAllow {
                        print("User has declined notifications")
                    }
                }
        MobileCore.setLogLevel(.debug)
        // let currentAppId = "94f571f308d5/ebdd79919382/launch-1c2658732b82-development"
        let appState = application.applicationState
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
        
        let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound, .badge]) { _, error in

                    if let error = error {
                        print("error requesting authorization: \(error)")
                    }

                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        Assurance.startSession(url: url)
        return true
    }
    
    
//    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        MobileCore.setPushIdentifier(deviceToken)
//    }
    
    // Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
        func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
            let token = tokenParts.joined()
            print("Device Token: \(token)")

            // Send push token to experience platform
            MobileCore.setPushIdentifier(deviceToken)
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
