//
//  PendingTableViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

class PendingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateViews()
    }
    
    // MARK: - Class Methods
    func updateViews() {
        guard let pendingRequests = UserController.shared.currentUser?.pendingRequests else { return }
        UserController.shared.fetchUsersFrom(pendingRequests) { (result) in
            switch result {
            case .success(let pendingRequests):
                DispatchQueue.main.async {
                    UserController.shared.pendingRequests = pendingRequests
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return UserController.shared.pendingRequests.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pendingRequest", for: indexPath)
        
        let pendingRequest = UserController.shared.pendingRequests[indexPath.row]
        
        cell.textLabel?.text = pendingRequest.name
        cell.imageView?.image = pendingRequest.images[0]
        
        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPendingProfileVC" {
            guard let index = tableView.indexPathForSelectedRow, let destination = segue.destination as? ProfileViewController else { return }
            let user = UserController.shared.pendingRequests[index.row]
            destination.otherUser = user
        }
    }
    
}
