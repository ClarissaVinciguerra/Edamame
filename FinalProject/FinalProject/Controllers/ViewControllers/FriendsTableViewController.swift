//
//  FriendsTableViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

class FriendsTableViewController: UITableViewController {
    
    // MARK: - Properties
   // var refresher: UIRefreshControl = UIRefreshControl()
    
    private var conversations = [Conversation]()
    
    // MARK: - Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        startListeningForConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupViews()
        loadData()
    }
    
    // MARK: - Class Methods
    private func startListeningForConversations() {
        print("starting conversation fetch")
        
        guard let userUid = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey) as? String else { return }
        
        MessageController.shared.getAllConversations(for: userUid) { [weak self] (result) in
            switch result {
            case .success(let conversations):
                print("succesfully got conversation models")
                guard !conversations.isEmpty else {
                    self?.tableView.isHidden = true
                    return
                }
                self?.tableView.isHidden = false
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    func setupViews() {
    }
    
    @objc func loadData() {
        guard let friends = UserController.shared.currentUser?.friends else { return }
        
        UserController.shared.fetchUserUUIDsFrom(friends) { (result) in
            switch result {
            case .success(let friends):
                DispatchQueue.main.async {
                    UserController.shared.friends = friends
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func openConversation(_ model: Conversation) {
        
        let vc = ChatViewController(with: model.otherUserUid, otherUserName: model.name, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createNewConversation(otherUser: User) {
        
        MessageController.shared.conversationExists(with: otherUser.uuid, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: otherUser.uuid, otherUserName: otherUser.name, id: conversationId)
                vc.isNewConversation = false
                vc.title = otherUser.name
                vc.otherUser = otherUser
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
                
            case .failure(_):
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
                        let chatUser = MessageAppUser(name: UserController.shared.currentUser!.name, uid: userUid)
                        MessageController.shared.insertUser(with: chatUser) { (success) in
                            print("created chat app user successfully")
                        }
                    }
                }
                let vc = ChatViewController(with: otherUser.uuid, otherUserName: otherUser.name, id: nil)
                vc.isNewConversation = true
                vc.title = otherUser.name
                vc.otherUser = otherUser
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "friendTableViewCell", for: indexPath) as? FriendTableViewCell else { return UITableViewCell() }
        
        let conversation = conversations[indexPath.row]
        
        let otherUserUid = conversation.otherUserUid
        
        let friends = UserController.shared.friends
        var foundFriend: User?
        for friend in friends {
            if friend.uuid == otherUserUid {
                foundFriend = friend
            }
        }
        
        cell.conversation = conversation
        
        if let image = foundFriend?.images.first {
            cell.photo = image.image
        } else {
            cell.photo = nil
        }
        cell.updateViews()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let otherUser = self.conversations[indexPath.row]
        
        let otherUserUid = otherUser.otherUserUid
        let friends = UserController.shared.friends
        var foundFriend: User?
        for friend in friends {
            if friend.uuid == otherUserUid {
                foundFriend = friend
            }
        }
        
        if let friend = foundFriend {
            createNewConversation(otherUser: friend)
        }
    }
    
    // DO WE WANT TO REMOVE FRIENDSHIPS THIS WAY OR IS IT TOO RISKY?
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

