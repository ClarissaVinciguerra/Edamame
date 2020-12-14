//
//  AppDelegate.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit
import Firebase
import FirebaseInstallations
import UserNotifications

enum Identifiers {
    static let viewAction = "VIEW_IDENTIFIER"
}

@UIApplicationMain
//@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
//        registerForPushNotifications()
        
        let notificationOption = launchOptions?[.remoteNotification]
        
        if
            let notification = notificationOption as? [String: AnyObject],
            let aps = notification["aps"] as? [String: AnyObject] {
            
            //          NewsItem.makeNewsItem(aps)
            
            (window?.rootViewController as? UITabBarController)?.selectedIndex = 2
        }
        
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
//        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
//            completionHandler(.failed)
//            return
//        }
//        if aps["content-available"] as? Int == 1 {
//            let podcastStore = PodcastStore.sharedStore
//
//            podcastStore.refreshItems { didLoadNewItems in
//
//                completionHandler(didLoadNewItems ? .newData : .noData)
//            }
//        } else {
//
//            //            NewsItem.makeNewsItem(aps)
//            completionHandler(.newData)
//        }
    }
    
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
//    func registerForPushNotifications() {
//
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
//            [weak self] granted, _ in
//            print("Permission granted: \(granted)")
//            guard granted
//            else { return }
//
//            let viewAction = UNNotificationAction(
//                identifier: Identifiers.viewAction,
//                title: "View",
//                options: [.foreground])
//
//            let newsCategory = UNNotificationCategory(
//                identifier: Identifiers.newsCategory,
//                actions: [viewAction],
//                intentIdentifiers: [],
//                options: [])
//
//            UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
//            self?.getNotificationSettings()
//        }
//    }
    
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
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
    }
}

//MARK: - Extensions
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response:UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo

//        if
//            let aps = userInfo["aps"] as? [String: AnyObject],
//            let newsItem = NewsItem.makeNewsItem(aps) {
//            (window?.rootViewController as? UITabBarController)?.selectedIndex = 2
//        }

//        completionHandler()
    }
}

