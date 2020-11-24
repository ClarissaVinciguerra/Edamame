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
    var viewsLaidOut = false
    var profileImages: [UIImage] = []
    
    // MARK: - Lifecyle Functions
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
    
    func setupViews() {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = configureCollectionViewLayout()
    }
    
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .fractionalHeight(1))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPagingCentered
        layoutSection.contentInsets = .init(top: 5, leading: 0, bottom: 0, trailing: 0)
        
        return UICollectionViewCompositionalLayout(section: layoutSection)
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

//MARK: - Extensions
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // CHANGE TO POPULATE PROFILE PHOTOS FROM USER
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileViewCell", for: indexPath) as? ViewPhotoCollectionViewCell else { return UICollectionViewCell() }
        
        // FINISH THIS PART
        
        return cell
    }
}
