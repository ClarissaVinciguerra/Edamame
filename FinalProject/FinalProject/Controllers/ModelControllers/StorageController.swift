//
//  StorageController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import Foundation
import FirebaseStorage

final class StorageController {
    
    // MARK: - Properties
    static let shared = StorageController()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    // MARK: - CRUD Functions
    /// Uploads picture to firebase storage and returns completion with url string to download.
    public func uploadImage(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase for picture.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            completion(.success(fileName))
//            self.storage.child("images/\(fileName)").downloadURL (completion: { url, error in
//                guard let url = url else {
//                    print("Failed to get download url")
//                    completion(.failure(StorageErrors.failedToGetDownloadURL))
//                    return
//                }
//
//                let urlString = url.absoluteString
//                print("download url returned: \(urlString)")
//                completion(.success(urlString))
//                return
//            })
        })
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        
        reference.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
    
    public func deleteImage(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        // handle error below
        guard let imageUUID = UserController.shared.currentUser?.imageURLs.remove(at: index) else { return }
        
        // keep data in sync everywhere there is data - AVOID THE BUGS EWWWW BUGGSSSS.
        // 1. currentUser.imageURLs - must be removed locally from this array CHECK!!!!!
        // 2. The URL also exists in firestore (images array in firestore), see line 75
        // 3. the image in the storage itself
        
        storage.child("images/\(imageUUID)").delete { (error) in
            if let error = error {
                return completion(.failure(error))
            }
            completion(.success(()))
        }
    }
    
    private func removeImageUUIDFromUser() {
        
    }
    
}
