//
//  RandoCollectionViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

private let reuseIdentifier = "randoCell"

class RandoCollectionViewController: UICollectionViewController {
    // MARK: - Properties
    var refresher: UIRefreshControl = UIRefreshControl()
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        setupViews()
        loadData()
    }
    
    // MARK: - Class methods
    func setupViews() {
        let cancelBarButton = UIBarButtonItem()
        cancelBarButton.title = "Cancel"
        self.navigationItem.backBarButtonItem = cancelBarButton
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh page")
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        //self.tableView.addSubview(refresher)
    }
    
    @objc func loadData() {
        guard let currentUser = UserController.shared.currentUser else { return }
        if !currentUser.friends.isEmpty {

            UserController.shared.fetchFilteredRandos(currentUser: currentUser) { (result) in
                switch result {
                case .success(let randos):
                    DispatchQueue.main.async {
                        UserController.shared.randos = randos
                        self.updateViews()
                    }
                case .failure(let milestoneError):
                    print(milestoneError.errorDescription)
                }
            }
        }
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            //self.tableView.reloadData()
            self.refresher.endRefreshing()
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
