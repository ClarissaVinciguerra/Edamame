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
        guard let uid = UserController.shared.currentUser?.uuid else { return }
        MessageController.shared.deleteUser(with: uid) { (success) in
            if success {
                print("Message user deleted successfully.")
            }
        }
        deleteUserAlert()
    }
    
    //MARK: - Methods
    func setupViews() {
        deleteButton.tintColor = .red
    }
}

