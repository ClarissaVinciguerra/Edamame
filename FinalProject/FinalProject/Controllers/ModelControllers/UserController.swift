//
//  UserController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class UserController {
    
    // MARK: - Properties
    static let shared = UserController()
    let database = Firestore.firestore()
    var currentUser: User?
    var matchedUser: User? // this was used for location func - probably better to have as a local property in the VC
    let userCollection = "users"
    var randos: [User] = []
    var sentRequests: [User] = []
    var pendingRequests: [User] = []
    var friends: [User] = []
    
    // MARK: - CREATE

    func createUser(name: String, bio: String, type: String, unsavedImages: [UIImage], dateOfBirth: Date, latitude: Double, longitude: Double, firebaseUID: String, completion: @escaping (Result<User, UserError>) -> Void) {

        let newUser = User(name: name, dateOfBirth: dateOfBirth, bio: bio, type: type, latitude: latitude, longitude: longitude, firebaseUID: firebaseUID, unsavedImages: unsavedImages)
        
        let timeInterval = newUser.dateOfBirth.timeIntervalSince1970
        
        let dispatchGroup = DispatchGroup()
        var imageUUIDs: [String] = []

        for image in unsavedImages {

            dispatchGroup.enter()
            let fileName = UUID().uuidString + ".jpeg"

            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return completion(.failure(.errorConvertingImage))}

            StorageController.shared.uploadImage(with: imageData, fileName: fileName) { (result) in
                switch result {
                case .success(let fileName):
                    print("Image \(fileName) successfully uploaded!")
                    imageUUIDs.append(fileName)
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
                UserStrings.dateOfBirthKey : timeInterval,
                UserStrings.imageUUIDsKey : imageUUIDs,
                UserStrings.latitudeKey : newUser.latitude,
                UserStrings.longitudeKey : newUser.longitude,
                UserStrings.firebaseUIDKey : newUser.firebaseUID,
                UserStrings.friendsKey : newUser.friends,
                UserStrings.pendingRequestsKey : newUser.pendingRequests,
                UserStrings.sentRequestsKey : newUser.sentRequests,
                UserStrings.blockedArrayKey : newUser.blockedArray
                
            ]) { error in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    return completion(.failure(.firebaseError(error)))
                } else {
                    print("Milestone document added with ID: \(newUser.uuid)")
                    newUser.imageUUIDs = imageUUIDs
                    self.currentUser = newUser
                    return completion(.success(newUser))
                }
            }
        }
    }
    
    func appendImage(image: UIImage, user: User, completion: @escaping (Result<Void, UserError>) -> Void) {
        let documentReference = database.collection(userCollection).document(user.uuid)
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return completion(.failure(.errorConvertingImage))}
        
        StorageController.shared.uploadImage(with: imageData, fileName: UUID().uuidString) { (result) in
            switch result {
            case .success(let fileName):
                
                documentReference.updateData([
                    
                    UserStrings.imageUUIDsKey : FieldValue.arrayUnion([fileName])
                    
                ]) { (error) in
                    if let error = error {
                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                        return completion(.failure(.firebaseError(error)))
                    } else {
                        return completion(.success(()))
                    }
                }
            case .failure(let error):
                return completion(.failure(.firebaseError(error)))
            }
        }
        
    }
    
    
    // MARK: - READ
    
    func fetchUserByField(with uuid: String, completion: @escaping (Result<User, UserError>) -> Void) {
        let docRef = database.collection(userCollection)

        docRef.whereField(UserStrings.firebaseUIDKey, isEqualTo: uuid).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("There was an error fetching connections for this User. Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            } else {
                guard let doc = querySnapshot!.documents.first, let fetchedUser = User(document: doc) else { return completion(.failure(.couldNotUnwrap)) }
                
                fetchedUser.images = []
                
                let dispatchGroup = DispatchGroup()
                
                for imageUUID in fetchedUser.imageUUIDs {
                    
                    dispatchGroup.enter()
                    
                    StorageController.shared.downloadURL(for: imageUUID) { (result) in
                        switch result {
                        case .success(let url):
                            self.convertURLToImage(urlString: "\(url)") { (image) in
                                guard let image = image else { return completion(.failure(.couldNotUnwrap))}
                                fetchedUser.images.append(image)
                                dispatchGroup.leave()
                            }
                            
                        case .failure(let error):
                            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                            dispatchGroup.leave()
                        }
                        
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    self.currentUser = fetchedUser
                    completion(.success(fetchedUser))
                }
            }
        }
          
    }
    
    func fetchUserByUUID(_ uuid: String, completion: @escaping (Result<User, UserError>) -> Void) {
        let userDocRef = database.collection(userCollection).document(uuid)
        
        userDocRef.getDocument { (document, error) in
            
            if let document = document, document.exists {
                guard let user = User(document: document) else { return completion(.failure(.couldNotUnwrap)) }
                
                self.currentUser = user
                
                let dispatchGroup = DispatchGroup()
               // var images: [UIImage] = []
                
                for imageUUID in user.imageUUIDs {
                    
                    dispatchGroup.enter()
                    
                    StorageController.shared.downloadURL(for: imageUUID) { (result) in
                        switch result {
                        case .success(let url):
                            self.convertURLToImage(urlString: "\(url)") { (image) in
                                guard let image = image else { return completion(.failure(.couldNotUnwrap))}
                                user.images.append(image)
                            }
                            dispatchGroup.leave()
                            
                        case .failure(let error):
                            print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                            dispatchGroup.leave()
                        }
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(.success(user))
                }
                
            } else if let error = error {
                
                completion(.failure(.firebaseError(error)))
                
            }
        }
        completion(.failure(.noExistingUser))
    }
    
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

    func checkThatUserExists(with uuid: String, completion: @escaping ((Bool) -> Void)) {
        let docRef = database.collection(userCollection)
        
        docRef.whereField(UserStrings.firebaseUIDKey, isEqualTo: uuid).getDocuments { (querySnapshot, error) in
            if let document = querySnapshot!.documents.first {
                return completion(true)
            } else {
                print("Document does not exist")
                return completion(false)
            }
        }

    }
    
    func fetchFilteredRandos(currentUser: User, completion: @escaping (Result<[User], UserError>) -> Void) {
        let userDocRef = database.collection(userCollection)
        
        userDocRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.firebaseError(error)))
                
            } else {
                
                var randosToAppear: [User] = []
                var doNotAppearArray = currentUser.blockedArray
                doNotAppearArray.append(contentsOf: currentUser.sentRequests)
                doNotAppearArray.append(contentsOf: currentUser.friends)
                doNotAppearArray.append(currentUser.uuid)
                let outerDispatchGroup = DispatchGroup()
                
                for document in querySnapshot!.documents {
                    
                    outerDispatchGroup.enter()
                    
                    if let rando = User(document: document) {
                        
                        for uuid in rando.blockedArray {
                            if currentUser.uuid == uuid {
                                doNotAppearArray.append(rando.uuid)
                            }
                        }
                        
                        var makeThisRandoAppear = true
                        
                        for uuid in doNotAppearArray {
                            if rando.uuid == uuid {
                                makeThisRandoAppear = false
                                outerDispatchGroup.leave()
                            }
                        }
                        
                        if makeThisRandoAppear {
                            
                            let dispatchGroup = DispatchGroup()
                            
                            for imageUUID in rando.imageUUIDs {
                                
                                dispatchGroup.enter()
                                
                                
                                StorageController.shared.downloadURL(for: imageUUID) { (result) in
                                    switch result {
                                    case .success(let url):
                                        self.convertURLToImage(urlString: "\(url)") { (image) in
                                            guard let image = image else { return completion(.failure(.couldNotUnwrap))}
                                            rando.images.append(image)
                                            dispatchGroup.leave()
                                        }
                                        
                                    case .failure(let error):
                                        print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                                        dispatchGroup.leave()
                                    }
                                }
                            }
                            
                            dispatchGroup.notify(queue: .main) {
                                randosToAppear.append(rando)
                                outerDispatchGroup.leave()
                            }
                        }
                    }
                }
                
                outerDispatchGroup.notify(queue: .main) {
                    completion(.success(randosToAppear))
                }
            }
        }
    }
    
    func fetchUsersFrom (_ currentUserArray: [String], completion: @escaping (Result<[User], UserError>) -> Void) {
        
        let outerDispatchGroup = DispatchGroup()
        var fetchedUsers: [User] = []
        
        for uuid in currentUserArray {
            
            outerDispatchGroup.enter()
            
            let docRef = database.collection(userCollection).document(uuid)
            docRef.getDocument { (document, error) in
                
                
                let imageDispatchGroup = DispatchGroup()
                
                if let document = document, document.exists {
                    
                    guard let user = User(document: document) else { return }
                    
                    for imageUUID in user.imageUUIDs {
                        imageDispatchGroup.enter()
                        
                        StorageController.shared.downloadURL(for: imageUUID) { (result) in
                            switch result {
                            case .success(let url):
                                self.convertURLToImage(urlString: "\(url)") { (image) in
                                    guard let image = image else { return completion(.failure(.couldNotUnwrap))}
                                    user.images.append(image)
                                    imageDispatchGroup.leave()
                                }
                            case .failure(let error):
                                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                                imageDispatchGroup.leave()
                            }
                        }
                        
                    }
                    imageDispatchGroup.notify(queue: .main) {
                        fetchedUsers.append(user)
                        outerDispatchGroup.leave()
                    }
                } else if let error = error {
                    completion(.failure(.firebaseError(error)))
                }
            }
        }
        outerDispatchGroup.notify(queue: .main) {
            return completion(.success(fetchedUsers))
        }
    }
    
    // MARK: - UPDATE
    func updateUserBy(_ user: User, completion: @escaping (Result<User, UserError>) -> Void) {
        
        let saveImageDispatchGroup = DispatchGroup()
        
        for image in user.unsavedImages {
            
            saveImageDispatchGroup.enter()
            let fileName = UUID().uuidString + ".jpeg"
            
            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return completion(.failure(.errorConvertingImage))}
            
            StorageController.shared.uploadImage(with: imageData, fileName: fileName) { (result) in
                switch result {
                case .success(let fileName):
                    print("Image \(fileName) successfully uploaded!")
                    user.imageUUIDs.append(fileName)
                    saveImageDispatchGroup.leave()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    saveImageDispatchGroup.leave()
                }
            }
        }
        
        saveImageDispatchGroup.notify(queue: .main) {
            let documentReference = self.database.collection(self.userCollection).document(user.uuid)
            
            documentReference.updateData([
                                            UserStrings.nameKey : "\(user.name)",
                                            UserStrings.latitudeKey : user.latitude,
                                            UserStrings.longitudeKey : user.longitude,
                                            UserStrings.imageUUIDsKey : user.imageUUIDs,
                                            UserStrings.friendsKey : user.friends,
                                            UserStrings.pendingRequestsKey : user.pendingRequests,
                                            UserStrings.sentRequestsKey : user.sentRequests,
                                            UserStrings.blockedArrayKey : user.blockedArray        ]) { (error) in
                if let error = error {
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    return completion(.failure(.firebaseError(error)))
                } else {
                    self.currentUser = user
                    return completion(.success(user))
                }
            }
        }
    }
    
    // MARK: - REMOVE
   
    func removeFromSentRequestsOf (_ user: User, andOtherUser: User, completion: @escaping (Result<Bool, UserError>) -> Void) {
        
        let pendingRequestsDocRef = database.collection(userCollection).document(andOtherUser.uuid)
        let sentRequestsDocRef = database.collection(userCollection).document(user.uuid)
        
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
            
            guard let pendingRequestIndex = pendingRequestsArray.firstIndex(of: user.uuid), let sentRequestIndex = sentRequestsArray.firstIndex(of: andOtherUser.uuid) else { return completion(.failure(.couldNotUnwrap)) }
           
                pendingRequestsArray.remove(at: pendingRequestIndex)
                sentRequestsArray.remove(at: sentRequestIndex)
            transaction.updateData([UserStrings.pendingRequestsKey : pendingRequestsArray], forDocument: pendingRequestsDocRef)
            transaction.updateData([UserStrings.sentRequestsKey: sentRequestsArray], forDocument: sentRequestsDocRef)
               
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
 
    func removeFromBlockedArrayOf (currentUser: User, blockedUserUUID: String, completion: @escaping (Result<User, UserError>) -> Void) {
        
        let unblockedDocRef = database.collection(userCollection).document(currentUser.uuid)

        database.runTransaction({ (transaction, errorPointer) -> Any? in
            let unblockDocument: DocumentSnapshot
    
            do {
                try unblockDocument = transaction.getDocument(unblockedDocRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard var blockedArray = unblockDocument.data()?["blocked"] as? [String] else {
                print("There was an error fetching the blocked array for the current user.")
                return nil
            }
            
            guard let blockedIndex = blockedArray.firstIndex(of: blockedUserUUID) else { return completion(.failure(.couldNotUnwrap)) }
           
                blockedArray.remove(at: blockedIndex)
                transaction.updateData(["blocked": blockedArray], forDocument: unblockedDocRef)
               
            return completion(.success(currentUser))
        
        }) { (object, error) in
            if let error = error {
                print("There was an error deleting this UUID from the current user's blocked array: Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
   
    // MARK: - DELETE
    func deleteUserInfoWith(_ uuid: String, completion: @escaping ((Bool) -> Void)) {
        database.collection(userCollection).document(uuid).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                completion(false)
            } else {
                print("User successfully deleted.")
                completion(true)
            }
        }
    }
    
}
