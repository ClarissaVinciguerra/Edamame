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
    
    var errorDescription: String {
        switch self {
        case .firebaseError(let error):
            return "There was an error retrieving user data from Firebase ===> \(error.localizedDescription)"
        case .couldNotUnwrap:
            return "Could not unwrap user data."
        case .noExistingUser:
            return "User not found."
        }
    }
}
