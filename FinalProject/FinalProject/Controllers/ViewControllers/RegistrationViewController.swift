//
//  RegistrationViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/23/20.
//

import UIKit

class RegistrationViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var birthdayMonthTextField: UITextField!
    @IBOutlet weak var birthdayDayTextField: UITextField!
    @IBOutlet weak var birthdayYearTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
