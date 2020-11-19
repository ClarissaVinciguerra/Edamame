//
//  ProfileViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

class ProfileViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameAndAgeLabel: UILabel!
    @IBOutlet weak var typeOfVeganLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var addAcceptRevokeButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    // MARK: - Lifecyle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func addAcceptRevokeButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func blockButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        
    }
    
    
    
    // MARK: - Class Methods

}
