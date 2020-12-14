//
//  Alerts.swift
//  FinalProject
//
//  Created by Owen Barrott on 12/11/20.
//

import UIKit

// MARK: - LogInViewController
extension LogInViewController {
    
    func alertUserLoginError() {
        let loginError = UIAlertController(title: "Error Logging In", message: "Please enter all information to log in.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        loginError.addAction(okAction)
        present(loginError, animated: true)
    }
}

// MARK: - SignUpViewController
extension SignUpViewController {
    
    struct SignUpAlertStrings {
        static let passwordMatchKey = "Passwords must match."
        static let passwordCharacterCountKey = "Password must be at least 6 characters."
    }
    
    func alertUserSignUpError() {
        let signUpError = UIAlertController(title: "Error Signing Up", message: SignUpAlertMessage,
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        signUpError.addAction(okAction)
        present(signUpError, animated: true)
    }
}

// MARK: - EditProfileViewController
extension EditProfileViewController {
    
    func presentImageAlert() {
        let alertController = UIAlertController(title: "Add some photos!", message: "Show off at least 2 pictures of yourself to save to your profile 📸", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alertController.addAction(okayAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentInfoAlert() {
        let alertController = UIAlertController(title: "The type of plant based diet you identify most with 🌱", message: "Common types include but are not limited to: dietary vegan, cheegan, vegetarian, ovo-vegetarian, 98% vegan, vegan, etc.", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alertController.addAction(okayAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentBioAlert() {
        let alertController = UIAlertController(title: "Fill out the Bio", message: "Let others know a little bit about you...", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alertController.addAction(okayAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - ProfileViewController
extension ProfileViewController {
    
}

// MARK: - RandoCollectionViewController
extension RandoCollectionViewController {
    
    func presentLocationPermissionsAlert() {
        let alertController = UIAlertController(title: "Unable to access location", message: "This app cannot be used without permission to access your location.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                })
            }
        }
        
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - SettingsViewController
extension SettingsViewController {
    
     func deleteUserAlert() {
        let actionSheet = UIAlertController(title: "",
                                            message: "Are you sure you want to DELETE your account?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete Account", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            UserController.shared.deleteCurrentUser { (result) in
                switch result {
                case .success():
                    let storyboard = UIStoryboard(name: "LogInSignUp", bundle: nil)
                    guard let vc = storyboard.instantiateInitialViewController() else { return }
                    vc.modalPresentationStyle = .fullScreen
                    strongSelf.present(vc, animated: true)
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
}



