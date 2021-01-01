//
//  FriendshipController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 12/30/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift


class FriendshipController {
    
    // MARK: - Properties
    static let shared = FriendshipController()
    let database = Firestore.firestore()
    let friendshipCollection = "friendships"
    
    // MARK: - Create
    func createFriendship(from currentUserUUID: String, to otherUserUUID: String, completion: @escaping (Result<Friendship, UserError>) -> Void) {
        
        let newFriendship = Friendship(fromUUID: currentUserUUID, toUUID: otherUserUUID)
        
        let friendshipReference = self.database.collection(self.friendshipCollection)
        friendshipReference.document(newFriendship.uuid).setData([
            FriendshipStrings.fromUUIDKey : newFriendship.fromUUID,
            FriendshipStrings.toUUIDKey : newFriendship.toUUID,
            FriendshipStrings.acceptedKey : newFriendship.accepted,
            FriendshipStrings.terminatedKey : newFriendship.terminated
            
        ]) { error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.firebaseError(error)))
            } else {
                print("Friendship document added with ID: \(newFriendship.uuid)")
                return completion (.success(newFriendship))
            }
            
        }
    }
    
    // MARK: - Read
    /// Fetch all friendships with accepted == false for pendingTVC. Will need to use this function in conjunction with the fetchUsers function to fetch the actual users so their profiles can be viewed. Should this result in an array of Friendship or an array of UserUUID(String)
    func fetchPendingFriendships(by currentUserUUID: String, completion: @escaping(Result<[User], FriendshipError>) -> Void) {
        
        let friendshipRef = database.collection(friendshipCollection)
        
        friendshipRef.whereField(FriendshipStrings.toUUIDKey, isEqualTo: currentUserUUID).whereField(FriendshipStrings.acceptedKey, isEqualTo: false).whereField(FriendshipStrings.terminatedKey, isEqualTo: false).getDocuments { (querySnapshot, error) in
            
            if let error = error {
                
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.firebaseError(error)))
                
            } else {
                
                var pendingFriendships: [String] = []
                
                for document in querySnapshot!.documents {
                    
                    // populate user's pendingRequestArray with all the UUIDs in [pendingFriendships] and change return type to void
                    if let pendingFriend = Friendship(document: document) {
                        
                        pendingFriendships.append(pendingFriend.fromUUID)
                        
                    }
                    
                }
                
                UserController.shared.fetchUserUUIDsFrom(pendingFriendships) { (result) in
                    switch result {
                    case .success(let users):
                        completion (.success(users))
                    case .failure(let error):
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    }
                }
            }
        }
    }
    
    /// fetches an a relationship with an individual if it already exists - will be called in profileVC
    func fetchFriendship(with currentUserUUID: String, and otherUserUUID: String, completion: @escaping(Result<Friendship, FriendshipError>) -> Void) {
        
        let friendshipRef = database.collection(friendshipCollection)
        
        
    }
    
    
    // MARK: - Update
    
    // MARK: - Delete
}

    

