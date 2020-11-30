//
//  RandoCollectionViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit
import CoreLocation

private let reuseIdentifier = "randoCell"

class RandoCollectionViewController: UICollectionViewController {
    // MARK: - Properties
    var refresher: UIRefreshControl = UIRefreshControl()
    let locationManager = CLLocationManager()
    var latitude: Double?
    var longitude: Double?
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        retrieveCurrentLocation()
        
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
        self.collectionView.addSubview(refresher)
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
            self.collectionView.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
    func retrieveCurrentLocation() {
        let status = CLLocationManager().authorizationStatus
       
        if (status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled()) {
            presentLocationPermissionsAlert()
            return
        }
        
        if (status == .notDetermined) {
            locationManager.requestWhenInUseAuthorization()
            return
        }
     
        locationManager.startUpdatingLocation()
    }
    
    func presentLocationPermissionsAlert() {
        let alertController = UIAlertController(title: "Unable to access location", message: "This app cannot be used without permission to access your location.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                })
                            }
                        }

        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
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

// MARK: - Extensions
extension RandoCollectionViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location manager authorization status changed")
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            presentLocationPermissionsAlert()
        break
        case .denied:
            presentLocationPermissionsAlert()
        break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            guard let currentUser = UserController.shared.currentUser else { return }
            currentUser.latitude = location.coordinate.latitude
            currentUser.longitude = location.coordinate.longitude
            
            UserController.shared.updateUserBy(currentUser) { (result) in
                switch result{
                case .success(let user):
                    DispatchQueue.main.async {
                        UserController.shared.currentUser = user
                        self.updateViews()
                    }
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
}
