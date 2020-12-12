//
//  SettingsViewController.swift
//  FinalProject
//
//  Created by Deven Day on 12/8/20.
//

import UIKit
import Firebase
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Properties
    var viewsLaidOut = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewsLaidOut == false {
            setupViews()
            viewsLaidOut = true
        }
    }
    
    //MARK: - Actions
    @IBAction func logOutButtonTapped(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "",
                                            message: "Are you sure you want to log out?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "LogInSignUp", bundle: nil)
                guard let vc = storyboard.instantiateInitialViewController() else { return }
                vc.modalPresentationStyle = .fullScreen
                strongSelf.present(vc, animated: true)
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteUser()
    }
    
    //MARK: - Methods
    func setupViews() {
        deleteButton.tintColor = .red
    }
    
    fileprivate func deleteUser() {
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
    
    //    func deleteMyData() {
    //
    //        guard let userID = UserController.shared.currentUser?.uuid
    //
    //        else { return }
    //
    //        let docRef = Firestore.firestore().collection("users").document(userID)
    //        docRef.delete { (error) in
    //            if let error = error {
    //                print(error.localizedDescription)
    //            } else {
    //
    //                let strongSelf = self
    //
    //                // maybe use pop off instead.(if login vc already exists)
    //                let storyboard = UIStoryboard(name: "LogInSignUp", bundle: nil)
    //                guard let vc = storyboard.instantiateInitialViewController() else { return }
    //                vc.modalPresentationStyle = .fullScreen
    //                strongSelf.present(vc, animated: true)
    //
    //                print("We successfully deleted a user!")
    //            }
    //        }
    //    }
}

