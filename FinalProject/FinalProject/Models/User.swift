//
//  User.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import Foundation
import UIKit
import Firebase

struct UserStrings {
    static let nameKey = "name"
    static let dateOfBirthKey = "dateOfBirth"
    static let bioKey = "bio"
    static let typeKey = "type"
    static let imageUUIDsKey = "imageUUIDs"
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"
    static let uuidKey = "uuid"
    static let firebaseUIDKey = "firebaseUID"
    static let friendsKey = "friends"
    static let pendingRequestsKey = "pendingRequests"
    static let sentRequestsKey = "sentRequests"
    static let blockedArrayKey = "blocked"
}

class User {
    var name: String
    let uuid: String
    let firebaseUID: String
    let dateOfBirth: Date
    var bio: String
    var type: String
    var latitude: Double
    var longitude: Double
    var images: [UIImage]
//    {
//        get {
//            var imagesArray: [UIImage] = []
//            for data in imageDataArray {
//                if let image = UIImage(data: data) {
//                    imagesArray.append(image)
//                }
//            }
//            return imagesArray
//        } set {
//            for value in newValue {
//                if let imageData = value.jpegData(compressionQuality: 0.5) {
//                    imageDataArray.append(imageData)
//                }
////            if let imageData = newValue.jpegData(compressionQuality: 0.5) {
////                imageDataArray.append(imageData)
////            }
//        }
//    }
    
    var imageDataArray: [Data] = []
    var imageUUIDs: [String]
    var friends: [String]
    var pendingRequests: [String]
    var sentRequests: [String]
    var blockedArray: [String]
    
    init(name: String, dateOfBirth: Date, bio: String, type: String, latitude: Double, longitude: Double, uuid: String = UUID().uuidString, firebaseUID: String, images: [UIImage], imageUUIDs: [String] = [], friends: [String] = [], pendingRequests: [String] = [], sentRequests: [String] = [], blockedArray: [String] = []) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.bio = bio
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.uuid = uuid
        self.firebaseUID = firebaseUID
        self.friends = friends
        self.pendingRequests = pendingRequests
        self.sentRequests = sentRequests
        self.blockedArray = blockedArray
        self.imageUUIDs = imageUUIDs
        self.images = images
    }
    
    convenience init?(document: DocumentSnapshot) {
        guard let name = document[UserStrings.nameKey] as? String,
              let timeInterval = document[UserStrings.dateOfBirthKey] as? Double,
              let bio = document[UserStrings.bioKey] as? String,
              let type = document[UserStrings.typeKey] as? String,
              let latitude = document[UserStrings.latitudeKey] as? Double,
              let longitude = document[UserStrings.longitudeKey] as? Double,
              let firebaseUID = document[UserStrings.firebaseUIDKey] as? String,
              let imageUUIDs = document[UserStrings.imageUUIDsKey] as? [String],
              let friends = document[UserStrings.friendsKey] as? [String],
              let pendingRequests = document[UserStrings.pendingRequestsKey] as? [String],
              let sentRequests = document[UserStrings.sentRequestsKey] as? [String],
              let blockedArray = document[UserStrings.blockedArrayKey] as? [String] else { return nil }
        
        let images: [UIImage] = []
        
        let dateOfBirth = Date(timeIntervalSince1970: timeInterval)
        
        self.init(name: name, dateOfBirth: dateOfBirth, bio: bio, type: type, latitude: latitude, longitude: longitude, uuid: document.documentID, firebaseUID: firebaseUID, images: images, imageUUIDs: imageUUIDs, friends: friends, pendingRequests: pendingRequests, sentRequests: sentRequests, blockedArray: blockedArray)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
