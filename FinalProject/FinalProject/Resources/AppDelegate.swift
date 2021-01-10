//
//  AppDelegate.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit
import Firebase
import FirebaseInstallations
import FirebaseMessaging
import UserNotifications

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let gcmMessageIDKey = "gcm.message_id"
    var tabBarController: UITabBarController?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        requestPushNotificationPermission()
        
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        
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
    
    //MARK: - Push notifications
    // this function passes the remote notification we recieved
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("unable to register for remote notifications", error.localizedDescription)
    }
    
    private func requestPushNotificationPermission() {
        
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions  = [.alert, .badge, .sound]
        // requests authorization for specific notifications
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
    }
}

//MARK: - Extensions 
extension AppDelegate : UNUserNotificationCenterDelegate {
    /*
     func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
     Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.unknown)
     }
     */
    // Listener handler for when receiving a notification in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let notificationOptions: UNNotificationPresentationOptions  = [.banner, .badge, .sound]
        completionHandler(notificationOptions)
    }
    // Listener handler for when a notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension AppDelegate : MessagingDelegate {
    // allows you to retrieve token with token completion handler
    /* Messaging.messaging().token { token, error in
     if let error = error {
     print("Error fetching FCM registration token: \(error)")
     } else if let token = token {
     print("FCM registration token: \(token)")
     self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
     }
     }*/
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("user push id is ", fcmToken)
        UserController.shared.pushID = fcmToken
    }
    
    private func updatePushID(fcmToken: String) {
        if let currentUser = UserController.shared.currentUser {
            currentUser.pushID = fcmToken
            UserController.shared.updatePushID (with: currentUser) { (result) in
                switch result {
                case .success(_):
                    print("User successfully updated with new pushID: \(fcmToken)")
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
        
        UserController.shared.pushID = fcmToken
    }
}
