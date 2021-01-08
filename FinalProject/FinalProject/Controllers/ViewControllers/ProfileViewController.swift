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
    @IBOutlet weak var addAcceptRevokeButton: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var viewsLaidOut = false
    var otherUser: User?
    var selfSender: Sender? {
        guard let userUid = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey)  as? String else { return nil }
        return Sender(photoURL: "",
                      senderId: userUid,
                      displayName: "Me")
    }
    
    
    // MARK: - Lifecyle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        updateViews()
        // ensures that the local version of "otherUser" has the most recent data from cloud - we may be able to take this out, but it solves previous issues of requests being sent multiple times from teh same user
        fetchOtherUser()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewsLaidOut == false {
            setupViews()
            viewsLaidOut = true
        }
    }
    
    // MARK: - Actions
    @IBAction func addAcceptRevokeButtonTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        updateFriendStatus()
    }
    
    @IBAction func declineButtonTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        declineFriendRequest()
    }
    
    @IBAction func blockButtonTapped(_ sender: Any) {
        guard let otherUser = otherUser else { return }
        checkBeforeBlockingAlert(otherUserName: otherUser.name)
    }
    
    @IBAction func reportButtonTapped(_ sender: Any) {
        presentReportUserAlert()
    }
    
    // MARK: - Class Methods
    func updateFriendStatus() {
        guard let otherUser = otherUser, let currentUser = UserController.shared.currentUser else { return }
        
        if currentUser.pendingRequests.contains(otherUser.uuid) {
           // hide button so user can't keep clicking and begin loading icon
            addAcceptRevokeButton.isEnabled = false
            declineButton.isHidden = true
            activityIndicator.startAnimating()
            
            // remove pending status and place in friends array
            removeSentRequestOf(otherUser, andPendingRequestOf: currentUser)
            
            currentUser.friends.append(otherUser.uuid)
            otherUser.friends.append(currentUser.uuid)
            
            createMessageUsers(otherUser: otherUser) { (success) in
                switch success {
                case true:
                    self.createInitialConversation(otherUser: otherUser, currentUser: currentUser)
                case false:
                    print("unable to create Message Users")
                }
            }
            
            update(currentUser)
            updateOtherUser(with: otherUser)
            
            updateViews()
            
            PushNotificationService.shared.sendPushNotificationTo(userID: otherUser.uuid, title: "\(currentUser.name) has accepted your friend request!", body: "Start a conversation.")
            
        } else if let index = currentUser.friends.firstIndex(of: otherUser.uuid) {
            // remove from friends arrays and put other user in blocked array
            currentUser.friends.remove(at: index)
            
            removeFriend(from: otherUser, and: currentUser)
            
        } else {
            // Initiate a first request and appends users to respective arrays
            currentUser.sentRequests.append(otherUser.uuid)
            otherUser.pendingRequests.append(currentUser.uuid)
            
            updateOtherUser(with: otherUser)
            update(currentUser)
            
            PushNotificationService.shared.sendPushNotificationTo(userID: otherUser.uuid, title: "\(currentUser.name) wants to connect!", body: "Check out their profile under your pending requests tab.")
            
            updateViews()
        }
    }
    
    private func createMessageUsers(otherUser: User, completion: @escaping (Bool) -> Void) {
        
        guard let userUid = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey) as? String else { return }
        MessageController.shared.userExists(with: userUid) { (result) in
            switch result {
            case true:
                return
            case false:
                let chatUser = MessageAppUser(name: UserController.shared.currentUser!.name, uid: userUid)
                MessageController.shared.insertUser(with: chatUser) { (success) in
                    print("created chat app user successfully")
                }
            }
        }
        MessageController.shared.userExists(with: otherUser.uuid) { (result) in
            switch result {
            case true:
                return
            case false:
                let chatUser = MessageAppUser(name: otherUser.name, uid: otherUser.uuid)
                MessageController.shared.insertUser(with: chatUser) { (success) in
                    print("created chat app user successfully")
                }
            }
            completion(true)
        }
    }
    
    private func createInitialConversation(otherUser: User, currentUser: User) {
        let dateString = ChatViewController.self.dateFormatter.string(from: Date())
        let newMessageID = "\(otherUser.uuid)_\(currentUser.uuid)_\(dateString)"
        
        guard let selfSender = self.selfSender else { return }
        let message = Message(sender: selfSender,
                              messageId: newMessageID,
                              sentDate: Date(),
                              kind: .text("Say hello to your new friend!"))
        
        MessageController.shared.createNewConversation (with: otherUser.uuid, otherUserName: otherUser.name, firstMessage: message) { (success) in
            switch success {
            case true:
                print("created new conversation")
            case false:
                print("failed to create new conversation")
            }
        }
    }
    
    
    private func update(_ user: User) {
        UserController.shared.updateSentOrFriendsArray (with: user) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.updateViews()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    // Called when friend status changes
    private func updateOtherUser(with otherUser: User) {
        
        UserController.shared.updatePendingOrFriendsArray(with: otherUser) { (result) in
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
    
    private func removeSentRequestOf(_ otherUser: User, andPendingRequestOf user: User) {
        UserController.shared.removeFromSentRequestsOf(otherUser.uuid, andPendingRequestOf: user.uuid) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    self.updateViews()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    private func removeFriend(from otherUser: User, and currentUser: User) {
        UserController.shared.removeFriend(otherUserUUID: otherUser.uuid, currentUserUUID: currentUser.uuid) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    // delete messages
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func declineFriendRequest() {
        guard let otherUser = otherUser, let currentUser = UserController.shared.currentUser else { return }
        
        removeSentRequestOf(otherUser, andPendingRequestOf: currentUser)
        blockUser()
        
        // add alert that says "user blocked!" here with an ok button
        
        navigationController?.popViewController(animated: true)
    }
    
    func blockUser() {
        guard let otherUser = otherUser, let currentUser = UserController.shared.currentUser else { return }
        
        var alreadyFriends = false
        
        if currentUser.friends.contains(otherUser.uuid) {
            alreadyFriends = true
            removeFriend(from: currentUser, and: otherUser)
        }
        
        MessageController.shared.deleteConversation(otherUserUid: otherUser.uuid) { [weak self] (success) in
            if success {
                print("Deleted Conversation")
            }
        }
        
        currentUser.blockedArray.append(otherUser.uuid)
        UserController.shared.updateUserBy(currentUser) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    print("OtherUser UUID has been successfully appended to currentUsers blocked array.")
                    self.userHasBeenBlockedAlert(otherUserName: otherUser.name, alreadyFriends: alreadyFriends)
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func reportUser() {
        guard let otherUser = otherUser else { return }
        
        otherUser.reportCount += 1
        
        update(otherUser)
        blockUser()
    }
    
    private func fetchOtherUser() {
        guard let user = otherUser else { return }
        UserController.shared.fetchUserBy(user.uuid) { (result) in
            switch result {
            case .success(let fetchedUser):
                DispatchQueue.main.async {
                    self.otherUser = fetchedUser
                    self.updateViews()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    // MARK: - UpdateViews
    func updateViews() {
        guard let otherUser = otherUser, let currentUser = UserController.shared.currentUser, let age = otherUser.dateOfBirth.calcAge() else { return }
        
        let currentUserLocation = CLLocation(latitude: currentUser.latitude, longitude: currentUser.longitude)
        let otherUserLocation = CLLocation(latitude: otherUser.latitude, longitude: otherUser.longitude)
        
        distanceLabel.text = "\(round(currentUserLocation.distance(from: otherUserLocation) * 0.000621371)) mi"
        nameAndAgeLabel.text = otherUser.name + " " + age
        bioTextView.text = otherUser.bio
        bioTextView.isEditable = false
        typeOfVeganLabel.text = otherUser.type
        
        declineButton.alpha = 0
        addAcceptRevokeButton.alpha = 1
        blockButton.setTitle("Block", for: .normal)
        
        if currentUser.sentRequests.contains(otherUser.uuid) {
            
            addAcceptRevokeButton.setTitle("Request Sent", for: .normal)
            addAcceptRevokeButton.isEnabled = false
            
        } else if currentUser.pendingRequests.contains(otherUser.uuid) {
            
            addAcceptRevokeButton.setTitle("Accept", for: .normal)
            declineButton.alpha = 1
            declineButton.setTitle("Decline", for: .normal)
            
        } else if currentUser.friends.contains(otherUser.uuid) {
            
            addAcceptRevokeButton.isEnabled = false
            addAcceptRevokeButton.setTitle("Friends!", for: .disabled)
            
        } else {
            
            addAcceptRevokeButton.setTitle("Request Friend", for: .normal)
        }
        
        activityIndicator.stopAnimating()
    }
    
    //MARK: - SetupViews
    func setupViews() {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.backgroundColor = .whiteSmoke
        
        nameAndAgeLabel.textColor = .softBlack
        distanceLabel.textColor = .softBlack
        typeOfVeganLabel.textColor = .softBlack
        bioTextView.textColor = .softBlack
        
        addAcceptRevokeButton.backgroundColor = .edamameGreen
        addAcceptRevokeButton.tintColor = .whiteSmoke
        addAcceptRevokeButton.addCornerRadius()
        addAcceptRevokeButton.addAccentBorder()
        
        declineButton.backgroundColor = .edamameGreen
        declineButton.tintColor = .whiteSmoke
        declineButton.addCornerRadius()
        declineButton.addAccentBorder()
        
        blockButton.backgroundColor = .whiteSmoke
        blockButton.tintColor = .darkerGreen
        blockButton.addCornerRadius()
        blockButton.addAccentBorder()
    }
    
    //MARK: - ConfigureCVLayout
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95), heightDimension: .fractionalHeight(1))
        
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPaging
        layoutSection.contentInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5)
        layoutSection.interGroupSpacing = 5
        
        return UICollectionViewCompositionalLayout(section: layoutSection)
    }
}

//MARK: - Extensions
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return otherUser?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileViewCell", for: indexPath) as? ViewPhotoCollectionViewCell else { return UICollectionViewCell() }
        if let image = otherUser?.images[indexPath.row] {
            
            cell.photo = image.image
        }
        
        return cell
    }
}
