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
    @IBOutlet weak var currentCityTextField: UITextField!
    @IBOutlet weak var changeCityButton: UIButton!
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var viewsLaidOut = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewsLaidOut == false {
            setupViews()
            viewsLaidOut = true
            activityIndicator.stopAnimating()
        }
    }
    
    //MARK: - Actions
    @IBAction func changeCityButtonTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        updateCity()
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        logOutAlert()
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteUserAlert()
    }
    
    //MARK: - Methods
    func setupViews() {
        guard let currentUser = UserController.shared.currentUser else { return }
        deleteButton.tintColor = .red
        
        currentCityTextField.backgroundColor = .whiteSmoke
        changeCityButton.setTitle("Save", for: .normal)
        changeCityButton.backgroundColor = .edamameGreen
        changeCityButton.addCornerRadius()
        changeCityButton.tintColor = .whiteSmoke
        currentCityLabel.text = "Current Metropolitan Area:\n\(currentUser.city)"
    }
    
    func updateCity() {
        guard let currentUser = UserController.shared.currentUser, let text = currentCityTextField.text, !text.isEmpty else { return }
        
        currentUser.city = text
        currentUser.cityRef = text.lowercased().replacingOccurrences(of: " ", with: "")
        
        UserController.shared.updateUserBy(currentUser) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.changeCityButton.setTitle("Saved!", for: .normal)
                    guard let currentUser = UserController.shared.currentUser else { return }
                    self.currentCityLabel.text = "Current Metropolitan Area:\n\(currentUser.city)"
                    self.activityIndicator.stopAnimating()
                    self.updatedCityAlert()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                self.activityIndicator.stopAnimating()
            }
        }
    }
   
}

