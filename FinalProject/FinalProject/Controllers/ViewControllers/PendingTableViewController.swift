//
//  PendingTableViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

class PendingTableViewController: UITableViewController {
    // MARK: - Properties
    var refresher: UIRefreshControl = UIRefreshControl()
    
    // MARK: - Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupViews()
        loadData()
    }
    
    // MARK: - Class Methods
    func setupViews() {
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh page")
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.tableView.addSubview(refresher)
        
    }
    
    @objc func loadData() {
        guard let pendingRequests = UserController.shared.currentUser?.pendingRequests else { return }
        
        UserController.shared.fetchUsersFrom(pendingRequests) { (result) in
            switch result {
            case .success(let pendingRequests):
                DispatchQueue.main.async {
                    UserController.shared.pendingRequests = pendingRequests
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                self.activityIndicator.stopAnimating()
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
        
        if let imageObject = pendingRequest.images.first {
            cell.imageView?.image = imageObject.image
        } else {
            // add default image here
        }
        
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
