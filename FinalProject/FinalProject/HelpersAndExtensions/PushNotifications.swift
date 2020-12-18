//
//  PushNotifications.swift
//  FinalProject
//
//  Created by Deven Day on 12/17/20.
//

import Foundation

class PushNotificationService {
    
    static let shared = PushNotificationService()
    
    private init() {}
    
    func sendPushNotificationTo(userID: String, body: String) {

        UserController.shared.fetchUserBy(userID) { (result) in
            switch result {
            case .success(let user):
                guard let pushID = user.pushID
                else { return }
                self.sendMessageToUser(to: pushID, title: user.name, body: body)
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    private func sendMessageToUser(to token: String, title: String, body: String) {
        
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        else { return }
        
        let paramString : [String : Any] = ["to" : token,
                                            "notification" : [
                                                "title" : title,
                                                "body" : body,
                                                "budge" : "1",
                                                "sound" : "default"
                                            ]
        ]
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) in
        }
        task.resume()
    }
}
