//
//  FriendsTableViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

class FriendsTableViewController: UITableViewController {

    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateViews()
    }
    
    // MARK: - Class Methods
    func updateViews() {
        guard let friends = UserController.shared.currentUser?.friends else { return }
        UserController.shared.fetchUsersFrom(friends) { (result) in
            switch result {
            case .success(let friends):
                DispatchQueue.main.async {
                    UserController.shared.friends = friends
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func openConversation(_ model: Conversation) {
        let vc = ChatViewController(with: model.otherUserUid, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = MessageController.safeEmail(emailAddress: result.uid)
        
        MessageController.shared.conversationExists(with: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
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
        cell.imageView?.image = friend.images[0]
        
        return cell
    }

    // DO WE WANT TO REMOVE FRIENDSHIPS THIS WAY OR IS IT TOO RISKY?
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMessagesTVC" {
            
        }
    }

}
