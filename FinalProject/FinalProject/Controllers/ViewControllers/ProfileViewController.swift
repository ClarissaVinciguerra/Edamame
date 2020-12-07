//
//  ProfileViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit
import CoreLocation

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
    var otherUser: User?
    
    // MARK: - Lifecyle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
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
        collectionView.backgroundColor = .edamameGreen
        
        nameAndAgeLabel.textColor = .softBlack
        distanceLabel.textColor = .softBlack
        typeOfVeganLabel.textColor = .softBlack
        bioLabel.textColor = .softBlack
        
        addAcceptRevokeButton.backgroundColor = .edamameGreen
        addAcceptRevokeButton.tintColor = .whiteSmoke
        addAcceptRevokeButton.clipsToBounds = true
        
        declineButton.backgroundColor = .edamameGreen
        declineButton.tintColor = .whiteSmoke
        declineButton.clipsToBounds = true
        
        blockButton.backgroundColor = .edamameGreen
        blockButton.tintColor = .whiteSmoke
        blockButton.clipsToBounds = true
        
        reportButton.backgroundColor = .whiteSmoke
        reportButton.addAccentBorder()
        reportButton.tintColor = .edamameGreen
        reportButton.clipsToBounds = true
    }
    
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.95))
        
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
        updateFriendStatus()
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        declineFriendRequest()
    }
    
    @IBAction func blockButtonTapped(_ sender: Any) {
        blockUser()
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        reportUser()
    }

    // MARK: - Class Methods
    func updateFriendStatus() {
        guard let otherUser = otherUser, let currentUser = UserController.shared.currentUser else { return }
       // what triggers this? accpeted a friendReq? Denies a friendReq?
        if let index = currentUser.sentRequests.firstIndex(of: otherUser.uuid) {
        
            removeSentRequestOf(currentUser, andOtherUser: otherUser)
            currentUser.sentRequests.remove(at: index)
            let index = otherUser.pendingRequests
            
            // what does this do
        } else if currentUser.pendingRequests.contains(otherUser.uuid) {
            
            removeSentRequestOf(otherUser, andOtherUser: currentUser)
            
            currentUser.friends.append(otherUser.uuid)
            otherUser.friends.append(currentUser.uuid)
            
            update(currentUser)
            update(otherUser)
            
        } else {
            currentUser.sentRequests.append(otherUser.uuid)
            otherUser.pendingRequests.append(currentUser.uuid)
            
            update(currentUser)
            update(otherUser)
               
        }
        updateViews()
    }
    
    private func update(_ user: User) {
        UserController.shared.updateUserBy(user) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    print("User Updated Successfully")
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    private func removeSentRequestOf(_ user: User, andOtherUser: User) {
        
        UserController.shared.removeFromSentRequestsOf(user, andOtherUser: andOtherUser) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    print("Sent request successfully revoked🏅 🔥 Go check Firebase! 🔥")
                    
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func declineFriendRequest() {
        guard let otherUser = otherUser, let currentUser = UserController.shared.currentUser else { return }
        
        blockUser()
        removeSentRequestOf(otherUser, andOtherUser: currentUser)
        navigationController?.popViewController(animated: true)
    }
    
    func blockUser() {
        guard let otherUser = otherUser, let currentUser = UserController.shared.currentUser else { return }
        
        currentUser.blockedArray.append(otherUser.uuid)
        UserController.shared.updateUserBy(currentUser) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    print("OtherUser UUID has been successfully appended to currentUsers blocked array.")
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func reportUser() {
        guard let otherUser = otherUser else { return }
        
        otherUser.reportCount += 1
        
        if otherUser.reportCount >= 3 {
            UserController.shared.deleteUserInfoWith(otherUser.uuid) { (result) in
                switch result {
                case .success():
                    print("User successfully removed from Cloud")
                    
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        } else {
            update(otherUser)
        }
            blockUser()
    }
    
    // MARK: - UpdateViews
    func updateViews() {
        guard let otherUser = otherUser, let currentUser = UserController.shared.currentUser else { return }
        
        let currentUserLocation = CLLocation(latitude: currentUser.latitude, longitude: currentUser.longitude)
        let otherUserLocation = CLLocation(latitude: otherUser.latitude, longitude: otherUser.longitude)
        
        distanceLabel.text = "\(round(currentUserLocation.distance(from: otherUserLocation) * 0.000621371)) mi"
        nameAndAgeLabel.text = otherUser.name
        declineButton.alpha = 0
        addAcceptRevokeButton.alpha = 1
        
        UserController.shared.fetchUserByUUID(currentUser.uuid) { (result) in
            switch result {
            case .success(let user):
                DispatchQueue.main.async { [self] in
                    
                    UserController.shared.currentUser = user
                    
                    // this ends up getting called before the friend request is revoked on the other queue
                    if currentUser.sentRequests.contains(otherUser.uuid) {
                        
                        self.addAcceptRevokeButton.setTitle("Revoke Sent Request", for: .normal)
                        
                    } else if currentUser.pendingRequests.contains(otherUser.uuid) {
                        
                        self.addAcceptRevokeButton.setTitle("Approve Request", for: .normal)
                        self.declineButton.alpha = 1
                        self.declineButton.setTitle("Decline Request", for: .normal)
                        
                    } else {
                        
                        self.addAcceptRevokeButton.setTitle("Request Friend", for: .normal)
                    }
                    
                    if currentUser.blockedArray.contains(otherUser.uuid) {
                        self.addAcceptRevokeButton.alpha = 0
                        self.blockButton.alpha = 1
                        self.blockButton.setTitle("Unblock", for: .normal)
                    } else {
                        self.blockButton.setTitle("Block", for: .normal)
                    }
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
}

//MARK: - Extensions
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return UserController.shared.currentUser?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileViewCell", for: indexPath) as? ViewPhotoCollectionViewCell else { return UICollectionViewCell() }
        
        cell.photo = UserController.shared.currentUser?.images[indexPath.row]
        
        return cell
    }
}
