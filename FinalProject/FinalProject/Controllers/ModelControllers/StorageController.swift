//
//  StorageController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import Foundation
import FirebaseStorage
import Firebase

final class StorageController {
    
    // MARK: - Properties
    static let shared = StorageController()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    // MARK: - CRUD Functions
    /// Uploads picture to firebase storage and returns completion with url string to download.
    public func uploadImage(with data: Data, fileName: String, userID: String, completion: @escaping UploadPictureCompletion) {
        storage.child("\(userID)/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                print("Failed to upload data to firebase for picture.")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            completion(.success(fileName))
        })
    }
    
    public func downloadURL(for path: String, with userID: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child("\(userID)/\(path)")
        
        reference.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            completion(.success(url))
        }
    }
    
    public func downloadImages(with userID: String, completion: @escaping (Result<[Image], Error>) -> Void) {
        let reference = storage.child("\(userID)")
        let dg = DispatchGroup()
        
        reference.listAll { (response, error) in
            
            var images : [Image] = []
            
            if error != nil {
                completion(.failure(StorageErrors.failedToGetDownloadURL))
            }
            
            for image in response.items {
                
                dg.enter()
                image.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    
                    if error != nil {
                        
                        completion(.failure(StorageErrors.failedToGetDownloadURL))
                        dg.leave()
                        
                    } else {
                        
                        if let data = data {
                            
                            if let parsedData = UIImage(data: data)  {
                                
                                images.append(Image(name: image.name, image: parsedData))
                                dg.leave()
                            } else {
                                dg.leave()
                                return completion(.failure(StorageErrors.failedToGetDownloadURL))
                            }
                        } else {
                            dg.leave()
                            return completion(.failure(StorageErrors.failedToGetDownloadURL))
                        }
                    }
                }
            }
            dg.notify(queue: .main) {
                completion(.success(images))
            }
        }
    }
    
    public func deleteImageFromStorage(with imageUUID: String, userID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        self.storage.child("\(userID)/\(imageUUID)").delete { (error) in
            if let error = error {
                return completion(.failure(error))
            }
            completion(.success(()))
        }
    }
}
