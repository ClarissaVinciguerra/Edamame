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
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"
    static let uuidKey = "uuid"
    static let friendsKey = "friends"
    static let pendingRequestsKey = "pendingRequests"
    static let sentRequestsKey = "sentRequests"
    static let blockedArrayKey = "blocked"
    static let reportCountKey = "reportCount"
}

struct Image {
    var name: String
    var image: UIImage
}

class User {
    var name: String
    let uuid: String
    let dateOfBirth: Date
    var bio: String
    var type: String
    var latitude: Double
    var longitude: Double
    var images: [Image]
    var localImages: [UIImage] = []
    var friends: [String]
    var pendingRequests: [String]
    var sentRequests: [String]
    var blockedArray: [String]
    var reportCount: Int
    
    init(name: String, dateOfBirth: Date, bio: String, type: String, latitude: Double, longitude: Double, uuid: String, images: [Image] = [], friends: [String] = [], pendingRequests: [String] = [], sentRequests: [String] = [], blockedArray: [String] = [], reportCount: Int = 0) {
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.bio = bio
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.uuid = uuid
        self.friends = friends
        self.pendingRequests = pendingRequests
        self.sentRequests = sentRequests
        self.blockedArray = blockedArray
        self.reportCount = reportCount
        self.images = images
    }
    
    convenience init?(document: DocumentSnapshot) {
        guard let name = document[UserStrings.nameKey] as? String,
              let timeInterval = document[UserStrings.dateOfBirthKey] as? Double,
              let bio = document[UserStrings.bioKey] as? String,
              let type = document[UserStrings.typeKey] as? String,
              let latitude = document[UserStrings.latitudeKey] as? Double,
              let longitude = document[UserStrings.longitudeKey] as? Double,
              let friends = document[UserStrings.friendsKey] as? [String],
              let pendingRequests = document[UserStrings.pendingRequestsKey] as? [String],
              let sentRequests = document[UserStrings.sentRequestsKey] as? [String],
              let blockedArray = document[UserStrings.blockedArrayKey] as? [String],
              let reportCount = document[UserStrings.reportCountKey] as? Int else { return nil }
        let dateOfBirth = Date(timeIntervalSince1970: timeInterval)
        
        self.init(name: name, dateOfBirth: dateOfBirth, bio: bio, type: type, latitude: latitude, longitude: longitude, uuid: document.documentID, images: [], friends: friends, pendingRequests: pendingRequests, sentRequests: sentRequests, blockedArray: blockedArray, reportCount: reportCount)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
