//
//  StorageError.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import Foundation

public enum StorageErrors: LocalizedError {
    case failedToUpload
    case failedToGetDownloadURL
    case imageNotFound
    case failedToDelete
}
