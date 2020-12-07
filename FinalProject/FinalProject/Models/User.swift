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
    static let reportCountKey = "reportCount"
    static let reportedThrice = "reportedThrice"
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
    var unsavedImages: [UIImage] = []
    var imageUUIDs: [String]
    var friends: [String]
    var pendingRequests: [String]
    var sentRequests: [String]
    var blockedArray: [String]
    var reportCount: Int
    var reportedThrice: Bool
    
    init(name: String, dateOfBirth: Date, bio: String, type: String, latitude: Double, longitude: Double, uuid: String = UUID().uuidString, firebaseUID: String, images: [UIImage] = [], unsavedImages: [UIImage] = [], imageUUIDs: [String] = [], friends: [String] = [], pendingRequests: [String] = [], sentRequests: [String] = [], blockedArray: [String] = [], reportCount: Int = 0, reportedThrice: Bool = false) {
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
        self.reportCount = reportCount
        self.imageUUIDs = imageUUIDs
        self.images = images
        self.unsavedImages = images
        self.reportedThrice = reportedThrice
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
              let blockedArray = document[UserStrings.blockedArrayKey] as? [String],
              let reportCount = document[UserStrings.reportCountKey] as? Int,
              let reportedThrice = document[UserStrings.reportedThrice] as? Bool else { return nil }
        
        let images: [UIImage] = []
        
        let dateOfBirth = Date(timeIntervalSince1970: timeInterval)
        
        self.init(name: name, dateOfBirth: dateOfBirth, bio: bio, type: type, latitude: latitude, longitude: longitude, uuid: document.documentID, firebaseUID: firebaseUID, images: images, imageUUIDs: imageUUIDs, friends: friends, pendingRequests: pendingRequests, sentRequests: sentRequests, blockedArray: blockedArray, reportCount: reportCount, reportedThrice: reportedThrice)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
