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
    
    // MARK: - Class Methods

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toProfileVC" {
            
        }
    }
    

}
