//
//  AppDelegate.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging
import FirebaseInstallations

@UIApplicationMain
//@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let pushManager = PushNotificationManager(userID: "currently_logged_in_user_id")
        pushManager.registerForPushNotifications()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //MARK: - Push Notifications
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo:
                        [AnyHashable: Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
        
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
    }
    
    class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
        let userID: String
        init(userID: String) {
            self.userID = userID
            super.init()
        }
        func registerForPushNotifications() {
            if #available(iOS 10.0, *) {
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: {_, _ in })
                // For iOS 10 data message (sent via FCM)
                Messaging.messaging().delegate = self
            } else {
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
            }
            UIApplication.shared.registerForRemoteNotifications()
            updateFirestorePushTokenIfNeeded()
        }
        func updateFirestorePushTokenIfNeeded() {
            if let token = Messaging.messaging().fcmToken {
                let usersRef = Firestore.firestore().collection("users_table").document(userID)
                usersRef.setData(["fcmToken": token], merge: true)
            }
        }
        func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
            print(remoteMessage.appData)
        }
        func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
            updateFirestorePushTokenIfNeeded()
        }
        func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            print(response)
        }
    }
}

//MARK: - Extensions
