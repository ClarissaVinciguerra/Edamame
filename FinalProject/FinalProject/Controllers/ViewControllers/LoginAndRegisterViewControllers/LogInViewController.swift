//
//  LogInSignUpViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct LogInStrings {
    static let emailKey = "email"
    static let firebaseUidKey = "firebaseUid"
    static let nameKey = "name"
}

class LogInViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    
    // MARK: - Properties
    private let spinner = JGProgressHUD(style: .dark)
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupViews()
    }
    
    // MARK: - Actions
    @IBAction func loginButtonTapped(_ sender: AnyObject? ) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        // Displays loading spinner while Firebase Authorization is being run.
        spinner.show(in: view)
        
        // Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let strongSelf = self else { return }
            
            // Dismisses spinner when authorization results are returned
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let firebaseUser = result.user
            let firebaseUid = result.user.uid
            
            UserDefaults.standard.set(email, forKey: LogInStrings.emailKey)
            UserDefaults.standard.set(firebaseUid, forKey: LogInStrings.firebaseUidKey)
            
            print("Logged In User: \(firebaseUser)")
            //Dismisses the current view controller and returns to the main storyboard.
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Helper Methods
    func setupViews() {
        setupEmailTextField()
        setupPasswordTextField()
        setupLogInButton()
    }
    
    // MARK: - Views
    func setupEmailTextField() {
        self.emailTextField.autocapitalizationType = .none
        self.emailTextField.autocorrectionType = .no
        self.emailTextField.returnKeyType = .continue
        self.emailTextField.layer.cornerRadius = 12
    }
    
    func setupPasswordTextField() {
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        passwordTextField.returnKeyType = .continue
        passwordTextField.layer.cornerRadius = 12
        passwordTextField.isSecureTextEntry = true
    }
    
    func setupLogInButton() {
        logInButton.layer.cornerRadius = 12
        logInButton.layer.masksToBounds = true
        logInButton.backgroundColor = .edamameGreen
    }
}

// MARK: - Extensions
extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            self.loginButtonTapped( nil )
        }
        return true
    }
}

