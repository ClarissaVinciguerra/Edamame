//
//  FriendsTableViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

class FriendsTableViewController: UITableViewController {
    
    // MARK: - Properties
    var refresher: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupViews()
        loadData()
    }
    
    // MARK: - Class Metobarhods
    func setupViews() {
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh page")
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.tableView.addSubview(refresher)
        
    }
    
    @objc func loadData() {
        guard let friends = UserController.shared.currentUser?.friends else { return }
        
        UserController.shared.fetchUsersFrom(friends) { (result) in
            switch result {
            case .success(let friends):
                DispatchQueue.main.async {
                    UserController.shared.friends = friends
                    self.tableView.reloadData()
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
    
    private func createNewConversation(otherUserName: String, otherUserUid: String, otherUser: User) {
        //let uid = MessageController.safeEmail(uid: result.uid)
        
        MessageController.shared.conversationExists(with: otherUserUid, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: otherUserUid, otherUserName: otherUserName, id: conversationId)
                vc.isNewConversation = false
                vc.title = otherUserName
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
                MessageController.shared.userExists(with: otherUserUid) { (result) in
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
                let vc = ChatViewController(with: otherUserUid, otherUserName: otherUserName, id: nil)
                vc.isNewConversation = true
                vc.title = otherUserName
                vc.otherUser = otherUser
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserController.shared.friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        
        let friend = UserController.shared.friends[indexPath.row]
        
        cell.textLabel?.text = friend.name
        
        if let firstImage = friend.images.first {
            cell.imageView?.image = firstImage.image
        } else {
            // create and insert default image here
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let otherUser = UserController.shared.friends[indexPath.row]

        createNewConversation(otherUserName: otherUser.name, otherUserUid: otherUser.uuid, otherUser: otherUser)

    }
    
    // DO WE WANT TO REMOVE FRIENDSHIPS THIS WAY OR IS IT TOO RISKY?
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //        if segue.identifier == "toMessagesTVC" {
    //
    //        }
    //    }
}

