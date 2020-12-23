//
//  PushNotifications.swift
//  FinalProject
//
//  Created by Deven Day on 12/17/20.
//

import UIKit
import FirebaseFirestore
import FirebaseMessaging
import UserNotificationsUI

class PushNotificationService {
    
    static let shared = PushNotificationService()
    
    private init() {}
    
    func sendPushNotificationTo(userID: String, body: String) {

        UserController.shared.fetchUserBy(userID) { (result) in
            switch result {
            case .success(let user):
                guard let pushID = user.pushID else { return }
                user.badgeCount += 1
                self.updateBadgeCount(with: user)
                
                self.sendPushNotificationToUser(to: pushID, title: user.name, body: body, badgeCount: user.badgeCount)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    private func sendPushNotificationToUser(to token: String, title: String, body: String, badgeCount: Int) {
        
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        else { return }
        
        let paramString : [String : Any] = ["to" : token,
                                            "notification" : [
                                                "title" : title,
                                                "body" : body,
                                                "badge" : badgeCount,
                                                "sound" : "default",
                                                "content-available": 1
                                            ]
        ]
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    private func updateBadgeCount(with user: User) {
        UserController.shared.updateBadgeCount(with: user) { (result) in
            switch result {
            case .success():
                print("User badge count updated")
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
}
