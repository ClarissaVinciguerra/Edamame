//
//  SettingsViewController.swift
//  FinalProject
//
//  Created by Deven Day on 12/8/20.
//

import UIKit

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
        
    }
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
    }
    
    //MARK: - Methods
    func setupViews() {
        deleteButton.tintColor = .red
    }
    

}
