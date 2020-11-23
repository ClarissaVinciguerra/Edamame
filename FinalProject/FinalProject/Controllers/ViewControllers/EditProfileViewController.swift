//
//  EditProfileViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

class EditProfileViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeOfVeganTextField: UITextField!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func saveChangesButtonTapped(_ sender: Any) {
        updateUser()
    }
    
    // MARK: - Class Methods
    func updateUser() {
        guard let currentUser = UserController.shared.currentUser, let bio = bioTextView.text, let type = typeOfVeganTextField.text, let name = nameTextField.text, !name.isEmpty else { return }
        
        currentUser.bio = bio
        currentUser.name = name
        currentUser.type = type
        
   //     UserController.shared.updateUserBy(currentUser, completion: <#T##(Result<User, UserError>) -> Void#>)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
