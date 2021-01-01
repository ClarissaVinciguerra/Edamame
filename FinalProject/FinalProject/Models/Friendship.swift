//
//  FriendRequest.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 12/30/20.
//

import Foundation

struct FriendRequestKeys {
    static let typeKey = "Friend"
    static let userRefKey = "userRef"
    static let sentKey = "sent"
    static let acceptedKey = "accepted"
    static let siblingRefKey = "siblingRef"
}

class Friend {
    var fromUUID: String
    var toUUID: String
    var status: Status
    
}
enum Status {
    case waiting
    case accepted
    case declined
    case removeFriend
}
