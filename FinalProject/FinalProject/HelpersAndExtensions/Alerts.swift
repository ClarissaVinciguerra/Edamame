//
//  Alerts.swift
//  FinalProject
//
//  Created by Owen Barrott on 12/11/20.
//

import UIKit
import FirebaseAuth

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
    
    func selectPhotoAlert() {
        
        let alertVC = UIAlertController(title: "Add a Photo", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openCamera()
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.openPhotoLibrary()
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(cameraAction)
        alertVC.addAction(photoLibraryAction)
        
        present(alertVC, animated: true)
    }
    
    func addCityAlertToCreateUser(name: String, bio: String, type: String, unsavedImages: [UIImage], dateOfBirth: Date, latitude: Double, longitude: Double, uuid: String ) {
        
        let alertController = UIAlertController(title: "Which city are you closest to?", message: "You can change your metropolitan area at any time in your settings.", preferredStyle: .alert)
        
        alertController.addTextField { (textfield) in
            textfield.autocapitalizationType = .words
            
        }
        
        let createUserAction = UIAlertAction(title: "Add City", style: .default) { (result) in
            
            guard let text = alertController.textFields?.first?.text, !text.isEmpty else { return }
            
            let cityRef = text.lowercased().replacingOccurrences(of: " ", with: "")
            
            UserController.shared.createUser(name: name, bio: bio, type: type, city: text, cityRef: cityRef, unsavedImages: unsavedImages, dateOfBirth: dateOfBirth, latitude: latitude, longitude: longitude, uuid: uuid) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.saveChangesButton.isEnabled = false
                        self.saveChangesButton.setTitle("Saved", for: .normal)
                        self.activityIndicator.stopAnimating()
                    }
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    self.activityIndicator.stopAnimating()
                    self.didNotCreateUserAlert()
                    
                }
            }
        }
        
        alertController.addAction(createUserAction)
        present(alertController, animated: true)
    }
    
    func didNotCreateUserAlert() {
        let alertController = UIAlertController(title: "Oops! Something went wrong.", message: "Check your connection and try creating your profile again later", preferredStyle: .actionSheet)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alertController.addAction(okayAction)
        present(alertController, animated: true)
    }
}

// MARK: - ProfileViewController
extension ProfileViewController {
    
    func userHasBeenBlockedAlert(otherUserName: String, alreadyFriends: Bool) {
        let alertController = UIAlertController(title: "", message: "You will no longer appear in this app on \(otherUserName)'s account.", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            
            self.navigationController?.popViewController(animated: true)
            
        }
        
        alertController.addAction(okayAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func checkBeforeBlockingAlert(otherUserName: String) {
        let alertController = UIAlertController(title: "Are you sure you want to block \(otherUserName)?", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        let blockAction = UIAlertAction(title: "Block", style: .destructive) { (_) in
            self.blockUser()
        }
        
        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentReportUserAlert() {
        let alertController = UIAlertController(title: "Are you sure you want to report this user?", message: "Users should be reported for WHAT ARE WE HAVING PEOPLE REPORT USERS FOR?", preferredStyle: .alert)
        
        let reportAction = UIAlertAction(title: "Report", style: .destructive) { (_) in
            self.reportUser()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - RandoCollectionViewController
//extension RandoCollectionViewController {
extension UIViewController {
    
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
    
    func presentAccountReportedAlert(_ currentUser: User) {
        let alertController = UIAlertController(title: "This account is being deleted due to multiple reports", message: "", preferredStyle: .alert)
        
        let deleteUserAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            UserController.shared.deleteCurrentUser { (result) in
                switch result {
                case .success():
                    print("Account successfully deleted.")
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
        
        alertController.addAction(deleteUserAction)
        
        present(alertController, animated: true, completion: nil)
        
    }

}

//MARK: - SettingsViewController
extension SettingsViewController {
    
    func logOutAlert() {
        let actionSheet = UIAlertController(title: "",
                                            message: "Are you sure you want to log out?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            UserController.shared.currentUser = nil
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "LogInSignUp", bundle: nil)
                let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
                
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
//                let storyboard = UIStoryboard(name: "LogInSignUp", bundle: nil)
//                guard let vc = storyboard.instantiateInitialViewController() else { return }
//                vc.modalPresentationStyle = .fullScreen
//                strongSelf.present(vc, animated: true)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
    
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
                    let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")
                    
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
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



