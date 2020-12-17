//
//  UserController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import CoreLocation

class UserController {
    
    // MARK: - Properties
    static let shared = UserController()
    let database = Firestore.firestore()
    var currentUser: User?
    let userCollection = "users"
    var randos: [User] = []
    var sentRequests: [User] = []
    var pendingRequests: [User] = []
    var friends: [User] = []
    
    // MARK: - CREATE
    func createUser(name: String, bio: String, type: String, city: String, cityRef: String, unsavedImages: [UIImage], dateOfBirth: Date, latitude: Double, longitude: Double, uuid: String, completion: @escaping (Result<User, UserError>) -> Void) {
        
        let newUser = User(name: name, dateOfBirth: dateOfBirth, bio: bio, type: type, city: city, cityRef: cityRef, latitude: latitude, longitude: longitude, uuid: uuid)
        
        let timeInterval = newUser.dateOfBirth.timeIntervalSince1970
        
        let dispatchGroup = DispatchGroup()
        
        for image in unsavedImages {
            
            dispatchGroup.enter()
            let fileName = UUID().uuidString + ".jpeg"
            
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return completion(.failure(.errorConvertingImage))}
            
            StorageController.shared.uploadImage(with: imageData, fileName: fileName, userID: newUser.uuid) { (result) in
                switch result {
                case .success(let fileName):
                    print("Image \(fileName) successfully uploaded!")
                    dispatchGroup.leave()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let userReference = self.database.collection(self.userCollection)
            userReference.document("\(newUser.uuid)").setData([
                UserStrings.nameKey : "\(newUser.name)",
                UserStrings.bioKey : "\(bio)",
                UserStrings.typeKey : "\(type)",
                UserStrings.cityKey : "\(city)",
                UserStrings.cityRefKey : "\(cityRef)",
                UserStrings.dateOfBirthKey : timeInterval,
                UserStrings.latitudeKey : newUser.latitude,
                UserStrings.longitudeKey : newUser.longitude,
                UserStrings.friendsKey : newUser.friends,
                UserStrings.pendingRequestsKey : newUser.pendingRequests,
                UserStrings.sentRequestsKey : newUser.sentRequests,
                UserStrings.blockedArrayKey : newUser.blockedArray,
                UserStrings.reportCountKey : newUser.reportCount
                
            ]) { error in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    return completion(.failure(.firebaseError(error)))
                } else {
                    print("Milestone document added with ID: \(newUser.uuid)")
                    self.currentUser = newUser
                    return completion(.success(newUser))
                }
            }
        }
    }
    
    // MARK: - READ
    
    func fetchUserBy(_ uuid: String, completion: @escaping (Result<User, UserError>) -> Void) {
        let userDocRef = database.collection(userCollection).document(uuid)
        
        let dispatchGroup = DispatchGroup()
        
        userDocRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                guard let user = User(document: document) else { return completion(.failure(.couldNotUnwrap)) }
                
                dispatchGroup.enter()
                
                StorageController.shared.downloadImages(with: user.uuid) { (result) in
                    switch result {
                    case .success(let images):
                        user.images = images
                        dispatchGroup.leave()
                    case .failure(let error):
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.currentUser = user
                    completion(.success(user))
                }
                
            } else if let error = error {
                
                completion(.failure(.firebaseError(error)))
                
            }
        }
        //        completion(.failure(.noExistingUser))
    }
    /*
     private func convertURLToImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
     guard let url = URL(string: urlString) else { return completion(nil) }
     
     URLSession.shared.dataTask(with: url) { (data, _, error) in
     if let error = error {
     print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
     }
     guard let data = data else { return completion(nil) }
     
     print(data)
     
     let image = UIImage(data: data)
     completion(image)
     }.resume()
     }
     */
    func checkThatUserExists(with uuid: String, completion: @escaping ((Bool) -> Void)) {
        let docRef = database.collection(userCollection).document(uuid)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                return completion(true)
            } else {
                print("Document does not exist")
                return completion(false)
            }
        }
    }
    
    func fetchFilteredRandos(currentUser: User, completion: @escaping (Result<[User], UserError>) -> Void) {
        
        let userDocRef = database.collection(userCollection)
        let dispatchGroup = DispatchGroup()
        let myLocation = CLLocation(latitude: currentUser.latitude, longitude: currentUser.longitude)
        
        userDocRef.whereField(UserStrings.cityRefKey, isEqualTo: currentUser.cityRef).getDocuments { (querySnapshot, error) in
            if let error = error {
                
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.firebaseError(error)))
                
            } else {
                
                var randosToAppear: [User] = []
                
                for document in querySnapshot!.documents {
                    
                    if let rando = User(document: document) {
                        
                        dispatchGroup.enter()
                        
                        if let rando = User(document: document) {
                            
                            let randoLocation = CLLocation(latitude: rando.latitude, longitude: rando.longitude)
                            
                            // add to filter for location within 35 mi    || myLocation.distance(from: randoLocation) > 56327
                            
                            if currentUser.sentRequests.contains(rando.uuid) || currentUser.friends.contains(rando.uuid) || currentUser.uuid == rando.uuid || currentUser.blockedArray.contains(rando.uuid) || rando.reportCount >= 3  {
                            
                                
                                dispatchGroup.leave()
                                
                            } else {
                                
                                StorageController.shared.downloadImages(with: rando.uuid) { (result) in
                                    switch result {
                                    case .success(let images):
                                        rando.images = images
                                        randosToAppear.append(rando)
                                        dispatchGroup.leave()
                                        
                                    case .failure(let error):
                                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                                        dispatchGroup.leave()
                                    }
                                }
                            }
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        completion(.success(randosToAppear))
                    }
                }
            }
        }
    }
    
    func fetchUsersFrom (_ currentUserArray: [String], completion: @escaping (Result<[User], UserError>) -> Void) {
        
        let dispatchGroup = DispatchGroup()
        var fetchedUsers: [User] = []
        
        for uuid in currentUserArray {
            
            dispatchGroup.enter()
            
            let docRef = database.collection(userCollection).document(uuid)
            docRef.getDocument { (document, error) in
                
                if let document = document, document.exists {
                    
                    guard let user = User(document: document) else { return }
                    
                    StorageController.shared.downloadImages(with: user.uuid) { (result) in
                        switch result {
                        case .success(let images):
                            user.images = images
                            fetchedUsers.append(user)
                            dispatchGroup.leave()
                            
                        case .failure(let error):
                            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                            fetchedUsers.append(user)
                            dispatchGroup.leave()
                            
                        }
                    }
                } else if let error = error {
                    completion(.failure(.firebaseError(error)))
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            return completion(.success(fetchedUsers))
        }
    }
    
    // MARK: - UPDATE
    func updateUserBy(_ user: User, updatedImages: [Image] = [], completion: @escaping (Result<User, UserError>) -> Void) {
        
        // protects against functions outside of the editProfileViewController from deleting images whilst updating for reasons such as adding a user to a blocked array or updating a friend status
        if !updatedImages.isEmpty {
            
            var updatedImageNames: [String] = []
            
            for image in updatedImages {
                // creates an array of exisitng images identified by name.
                updatedImageNames.append(image.name)
                
                // saves images that have not yet been assigned a name (new images) to storage
                if image.name.isEmpty {
                    guard let imageData = image.image.jpegData(compressionQuality: 0.5) else { return completion(.failure(.errorConvertingImage))}
                    StorageController.shared.uploadImage(with: imageData, fileName: UUID().uuidString + ".jpeg", userID: user.uuid) { (result) in
                        switch result {
                        case .success(_):
                            print("Image successfully uploaded!")
                        case .failure(let error):
                            print("\(error.localizedDescription)")
                        }
                    }
                }
            }
            
            for existingImage in user.images {
                // deletes exisiting images in storage that are not found in the new array of images that the user wants to keep
                if !updatedImageNames.contains(existingImage.name) {
                    StorageController.shared.deleteImageFromStorage(with: existingImage.name, userID: user.uuid) { (result) in
                        switch result {
                        case .success():
                            print("Image successfully deleted from storage!")
                            
                        case .failure(let error):
                            print("Error deleting image from storage: \(error.localizedDescription)")
                        }
                    }
                }
            }  
        }
   
        let documentReference = database.collection(userCollection).document(user.uuid)

        documentReference.updateData([
            UserStrings.nameKey : "\(user.name)",
            UserStrings.bioKey : user.bio,
            UserStrings.typeKey : user.type,
            UserStrings.cityKey : user.city,
            UserStrings.cityRefKey : user.cityRef,
            UserStrings.latitudeKey : user.latitude,
            UserStrings.longitudeKey : user.longitude,
            UserStrings.friendsKey : user.friends,
            UserStrings.pendingRequestsKey : user.pendingRequests,
            UserStrings.sentRequestsKey : user.sentRequests,
            UserStrings.blockedArrayKey : user.blockedArray,
            UserStrings.reportCountKey : user.reportCount
        ]) { (error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.firebaseError(error)))
            } else {
                return completion(.success(user))
            }
        }
    }
    
    // MARK: - REMOVE
    func removeFromSentRequestsOf (_ otherUserUUID: String, andPendingRequestOf currentUserUUID: String, completion: @escaping (Result<Bool, UserError>) -> Void) {
        
        let pendingRequestsDocRef = database.collection(userCollection).document(currentUserUUID)
        let sentRequestsDocRef = database.collection(userCollection).document(otherUserUUID)
        
        database.runTransaction({ (transaction, errorPointer) -> Any? in
            let pendingRequestDocument: DocumentSnapshot
            let sentRequestDocument: DocumentSnapshot
            do {
                try pendingRequestDocument = transaction.getDocument(pendingRequestsDocRef)
                try sentRequestDocument = transaction.getDocument(sentRequestsDocRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var pendingRequestsArray = pendingRequestDocument.data()?[UserStrings.pendingRequestsKey] as? [String], var sentRequestsArray = sentRequestDocument.data()?[UserStrings.sentRequestsKey] as? [String] else {
                print("There was an error fetching pending request arrays while deleting a connection")
                return nil
            }
            
            guard let pendingRequestIndex = pendingRequestsArray.firstIndex(of: otherUserUUID), let sentRequestIndex = sentRequestsArray.firstIndex(of: currentUserUUID) else { return completion(.failure(.couldNotUnwrap)) }
            
            pendingRequestsArray.remove(at: pendingRequestIndex)
            sentRequestsArray.remove(at: sentRequestIndex)
            transaction.updateData([UserStrings.pendingRequestsKey : pendingRequestsArray], forDocument: pendingRequestsDocRef)
            transaction.updateData([UserStrings.sentRequestsKey: sentRequestsArray], forDocument: sentRequestsDocRef)
            
//            if let index = currentUser?.pendingRequests.firstIndex(of: otherUserUUID) {
//                currentUser?.pendingRequests.remove(at: index)
//            }
//
            return completion(.success(true))
            
        }) { (object, error) in
            if let error = error {
                print("There was an error deleting this pending connection: Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func removeFriend (otherUserUUID: String, currentUserUUID: String, completion: @escaping (Result<Bool, UserError>) -> Void) {
        let currentUserDocRef = database.collection(userCollection).document(currentUserUUID)
        let otherUserDocRef = database.collection(userCollection).document(otherUserUUID)
        
        database.runTransaction({ (transaction, errorPointer) -> Any? in
            let currentUserDoc: DocumentSnapshot
            let otherUserDoc: DocumentSnapshot
            do {
                try currentUserDoc = transaction.getDocument(currentUserDocRef)
                try otherUserDoc = transaction.getDocument(otherUserDocRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var currentUserFriends = currentUserDoc.data()?[UserStrings.friendsKey] as? [String], var otherUserFriendsArray = otherUserDoc.data()?[UserStrings.friendsKey] as? [String] else {
                print("There was an error fetching pending request arrays while deleting a connection")
                return nil
            }
            
            guard let currentUserFriendsIndex = currentUserFriends.firstIndex(of: otherUserUUID), let otherUserFriendsIndex = otherUserFriendsArray.firstIndex(of: currentUserUUID) else { return completion(.failure(.couldNotUnwrap)) }
            
            currentUserFriends.remove(at: currentUserFriendsIndex)
            otherUserFriendsArray.remove(at: otherUserFriendsIndex)
            
            transaction.updateData([UserStrings.friendsKey : currentUserFriends], forDocument: currentUserDocRef)
            transaction.updateData([UserStrings.friendsKey: otherUserFriendsArray], forDocument: otherUserDocRef)
            
            return completion(.success(true))
            
        }) { (object, error) in
            if let error = error {
                print("There was an error deleting this pending connection: Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func deleteUserFromOtherUserArrays(_ user: User, completion: @escaping (Result<Void, UserError>) -> Void) {
       
        let dispatchGroup = DispatchGroup()
        
        for userID in user.friends {
            dispatchGroup.enter()
            
            removeFriend(otherUserUUID: userID, currentUserUUID: user.uuid) { (result) in
                switch result {
                case .success(_):
                    dispatchGroup.leave()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    dispatchGroup.leave()
                    return completion(.failure(UserError.couldNotRemove))
                }
            }
        }
        
        for userID in user.pendingRequests {
            dispatchGroup.enter()
            
            removeFromSentRequestsOf(userID, andPendingRequestOf: user.uuid) { (result) in
                switch result {
                case .success(_):
                    dispatchGroup.leave()
                case .failure(_):
                    dispatchGroup.leave()
                    return completion(.failure(UserError.couldNotRemove))
                }
            }
            
        }
        
        for userID in user.sentRequests {
            dispatchGroup.enter()
            
            removeFromSentRequestsOf(user.uuid, andPendingRequestOf: userID) { (result) in
                switch result {
                case .success(_):
                    dispatchGroup.leave()
                case .failure(_):
                    dispatchGroup.leave()
                    return completion(.failure(UserError.couldNotRemove))
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            return completion(.success(()))
        }
    }
        
    // MARK: - DELETE USER
    func deleteCurrentUser(completion: @escaping (Result<Void, UserError>) -> Void) {
        
        guard let currentUser = currentUser else { return completion(.failure(.noExistingUser)) }
        let dispatchGroup = DispatchGroup()
        
        // deletes images through filepaths in firebase storage
        for image in currentUser.images {
            dispatchGroup.enter()
            
            StorageController.shared.deleteImageFromStorage(with: image.name, userID: currentUser.uuid) { (result) in
                switch result {
                case .success():
                    dispatchGroup.leave()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.deleteUserFromOtherUserArrays(currentUser) { (result) in
                switch result {
                case .success():
                    // deletes user document from firebase cloud
                    self.database.collection(self.userCollection).document(currentUser.uuid).delete() { error in
                        if let error = error {
                            print("Error removing document: \(error)")
                            completion(.failure(.couldNotRemove))
                        } else {
                            
                            // deletes user from firebase Auth
                            self.deleteCurrentUserFromAuth(with: currentUser.uuid) { (result) in
                                switch result {
                                case .success():
                                    completion(.success(()))
                                case .failure(let error):
                                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                                    completion(.failure(.couldNotRemove))
                                }
                            }
                        }
                    }
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    completion (.failure(UserError.couldNotRemove))
                }
                
            }
        }
    }
    
    func deleteCurrentUserFromAuth(with uuid: String, completion: @escaping (Result<Void, UserError>) -> Void) {
        
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(.couldNotRemove))
            } else {
                completion(.success(()))
            }
        }
    }
}
