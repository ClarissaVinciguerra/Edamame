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
    static let bioKey = "bio"
    static let typeKey = "type"
    static let imagesKey = "images"
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"
    static let uuidKey = "uuid"
    static let friendsKey = "friends"
    static let pendingRequestsKey = "pendingRequests"
    static let sentRequestsKey = "sentRequests"
    static let blockedArrayKey = "blocked"
}

class User {
    var name: String
    let uuid: String
    var bio: String
    var type: String
    var latitude: Double
    var longitude: Double
    var images: [UIImage] {
        get {
            var imagesArray: [UIImage] = []
            for data in imageDataArray {
                if let image = UIImage(data: data) {
                    imagesArray.append(image)
                }
            }
            return imagesArray
        } set {
            for value in newValue {
                if let imageData = value.jpegData(compressionQuality: 0.5) {
                    imageDataArray.append(imageData)
                }
            }
        }
    }
    
    var imageDataArray: [Data] = []
    var friends: [String]
    var pendingRequests: [String]
    var sentRequests: [String]
    var blockedArray: [String]
    
    init(name: String, bio: String = "", type: String = "", latitude: Double, longitude: Double, uuid: String = UUID().uuidString, images: [UIImage], friends: [String] = [], pendingRequests: [String] = [], sentRequests: [String] = [], blockedArray: [String] = []) {
        self.name = name
        self.bio = bio
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.uuid = uuid
        self.friends = friends
        self.pendingRequests = pendingRequests
        self.sentRequests = sentRequests
        self.blockedArray = blockedArray
        self.images = images
    }
    
    convenience init?(document: DocumentSnapshot) {
        guard let name = document[UserStrings.nameKey] as? String else { return nil }
        guard let bio = document[UserStrings.bioKey] as? String else { return nil }
        guard let type = document[UserStrings.typeKey] as? String else { return nil }
        guard let latitude = document[UserStrings.latitudeKey] as? Double else { return nil }
        guard let longitude = document[UserStrings.longitudeKey] as? Double else { return nil }
        guard let images = document[UserStrings.imagesKey] as? [UIImage] else { return nil }
        guard let friends = document[UserStrings.friendsKey] as? [String] else { return nil }
        guard let pendingRequests = document[UserStrings.pendingRequestsKey] as? [String] else { return nil }
        guard let sentRequests = document[UserStrings.sentRequestsKey] as? [String] else { return nil }
        guard let blockedArray = document[UserStrings.blockedArrayKey] as? [String] else { return nil }
        
        self.init(name: name, bio: bio, type: type, latitude: latitude, longitude: longitude, uuid: document.documentID, images: images, friends: friends, pendingRequests: pendingRequests, sentRequests: sentRequests, blockedArray: blockedArray)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
