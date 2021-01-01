//
//  FriendRequest.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 12/30/20.
//

import Foundation
import Firebase

struct FriendshipStrings {
    static let fromUUIDKey = "sentFrom"
    static let toUUIDKey = "sentTo"
    static let acceptedKey = "accepted"
    static let terminatedKey = "terminated"
}

class Friendship {
    let uuid: String
    var fromUUID: String
    var toUUID: String
    var accepted: Bool
    var terminated: Bool
    
    init(uuid: String = UUID().uuidString, fromUUID: String, toUUID: String, accepted: Bool = false, terminated: Bool = false) {
        self.uuid = uuid
        self.fromUUID = fromUUID
        self.toUUID = toUUID
        self.accepted = accepted
        self.terminated = terminated
    }
    
    convenience init?(document: DocumentSnapshot) {
        guard let fromUUID = document[FriendshipStrings.fromUUIDKey] as? String,
              let toUUID = document[FriendshipStrings.toUUIDKey] as? String,
              let accepted = document[FriendshipStrings.acceptedKey] as? Bool,
              let terminated = document[FriendshipStrings.terminatedKey] as? Bool
              else { return nil }
       
        
        self.init(uuid: document.documentID, fromUUID: fromUUID, toUUID: toUUID, accepted: accepted, terminated: terminated)
    }
}

