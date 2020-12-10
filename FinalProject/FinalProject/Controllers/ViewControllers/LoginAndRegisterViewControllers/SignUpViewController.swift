//
//  RegistrationViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/23/20.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct SignUpStrings {
    static let emailKey = "email"
    static let nameKey = "name"
    static let firebaseUid = "firebaseUid"
    static let birthday = "birthday"
}

class SignUpViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var birthdayDatePicker: UIDatePicker!
    @IBOutlet weak var signUpButton: UIButton!
    
    // MARK: - Properties
    private let spinner = JGProgressHUD(style: .dark)
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: - Actions
    @IBAction func signUpButtonTapped(_ sender: Any) {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              passwordTextField.text == confirmPasswordTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty,
              !name.isEmpty,
              password.count >= 6 else {
            alertUserSignUpError()
            return
        }
        let birthday = birthdayDatePicker.date
        
        
        //spinner.show(in: view)
        
        // Check if user already exists in realtime database with uuid.
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard authResult != nil, error == nil else {
                print("Error creating user")
                return
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to sign up a user with email: \(email)")
                return
            }
            
            let firebaseUser = result.user
            let firebaseUid = result.user.uid
            
            UserDefaults.standard.setValue(email, forKey: SignUpStrings.emailKey)
            UserDefaults.standard.setValue(name, forKey: SignUpStrings.nameKey)
            UserDefaults.standard.setValue(firebaseUid, forKey: SignUpStrings.firebaseUid)
            UserDefaults.standard.setValue(birthday, forKey: SignUpStrings.birthday)
            
            
            // Creates a new User from the User Model
            // let newUser = User(name: name, bio: "", type: "", latitude: 33.8121, longitude: 117.9190, uuid: firebaseUser.uid, images: <#T##[UIImage]#>, friends: <#T##[String]#>, pendingRequests: <#T##[String]#>, sentRequests: <#T##[String]#>, blockedArray: <#T##[String]#>)
            
            
            
            // Insert newUser into the realtime Database
        }
        
        //When user is successfully create, take the user to the main storyboard.
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    func setupViews() {
        setupNameTextField()
        setupEmailTextField()
        setupPasswordTextField()
        setupConfirmPasswordTextField()
        setupBirthdayDatePicker()
        setupSignUpButton()
    }
    
    func alertUserSignUpError() {
        let signUpError = UIAlertController(title: "Error Signing Up", message: "Please enter all information to register.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        signUpError.addAction(okAction)
        present(signUpError, animated: true)
    }
    
    // MARK: - Views
    func setupNameTextField(){
        nameTextField.autocapitalizationType = .none
        nameTextField.autocorrectionType = .no
        nameTextField.returnKeyType = .continue
        nameTextField.layer.cornerRadius = 12
    }
    
    func setupEmailTextField(){
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.returnKeyType = .continue
        emailTextField.layer.cornerRadius = 12
    }
    
    func setupPasswordTextField(){
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.returnKeyType = .continue
        passwordTextField.layer.cornerRadius = 12
        passwordTextField.isSecureTextEntry = false
    }
    
    func setupConfirmPasswordTextField(){
        confirmPasswordTextField.autocapitalizationType = .none
        confirmPasswordTextField.autocorrectionType = .no
        confirmPasswordTextField.returnKeyType = .done
        confirmPasswordTextField.layer.cornerRadius = 12
        confirmPasswordTextField.isSecureTextEntry = false
    }
    
    func setupBirthdayDatePicker(){
    }
    
    func setupSignUpButton(){
        signUpButton.layer.cornerRadius = 12
        signUpButton.layer.masksToBounds = true
    }
}
