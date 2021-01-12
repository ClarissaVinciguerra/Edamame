//
//  UserError.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import Foundation

enum UserError: LocalizedError {
    case firebaseError(Error)
    case couldNotUnwrap
    case noExistingUser
    case errorConvertingImage
    case couldNotRemove
    case errorDeletingUser(Error)
    
    var errorDescription: String {
        switch self {
        case .firebaseError(let error):
            return "There was an error retrieving user data from Firebase ===> \(error.localizedDescription)"
        case .couldNotUnwrap:
            return "Could not unwrap user data."
        case .noExistingUser:
            return "User not found."
        case .errorConvertingImage:
            return "Image could not be converted into data to store in Firebase."     
        case.couldNotRemove:
            return "Unable to delete user account"
        case .errorDeletingUser(let error):
            return "There was an error trying to delete a user from authentication ===> \(error.localizedDescription)"
        }
    }
}
