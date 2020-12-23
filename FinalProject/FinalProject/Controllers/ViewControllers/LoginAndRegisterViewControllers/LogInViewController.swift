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
    @IBOutlet weak var logoImageView: UIImageView!
    
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
            
            DispatchQueue.main.async {
                self?.spinner.show(in: (self?.view)!)
            }
            
            self?.fetchUser(with: firebaseUid)
            
            DispatchQueue.main.async {
                self?.spinner.dismiss()
            }
            
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
            
            //Dismisses the current view controller and returns to the main storyboard.
//            strongSelf.tabBarController?.selectedIndex = 3
//            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Helper Methods
    private func initiateFetchUser() {
        guard let uidKey = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey) else { return }
        let uidString = "\(uidKey)"
        fetchUser(with: uidString)
    }
    // CHECK IF THIS IS NECESSARY BEFORE SUBMISSION
    private func fetchUser(with firebaseUID: String) {
        
        UserController.shared.fetchUserBy(firebaseUID) { (result) in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    UserController.shared.currentUser = user
                }
            case .failure(_):
                print("User does not yet exist in database")
                //self.updateViews()
            }
        }
    }
    
    func setupViews() {
        setupLogoImageView()
        setupEmailTextField()
        setupPasswordTextField()
        setupLogInButton()
    }
    
    // MARK: - Views
    func setupLogoImageView() {
        self.logoImageView.image = UIImage(named: "edamameLogo")
    }
    
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

