//
//  RandoCollectionViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit
import CoreLocation
import FirebaseAuth

class RandoCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    var refresher: UIRefreshControl = UIRefreshControl()
    let locationManager = CLLocationManager()
    var latitude: Double?
    var longitude: Double?
    lazy var emptyMessage: UILabel = {
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = .whiteSmoke
        messageLabel.font = UIFont(name: "SourceSansPro-Bold", size: 48)
        messageLabel.text = "You are one of the first\nto join edamame in \(UserController.shared.currentUser?.city ?? "your area")!\n\n Make sure all notifications\nare turned on so you\ndon't miss out as our\ncommunity continues to grow."
        messageLabel.backgroundColor = .edamameGreen
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.sizeToFit()
        
        return messageLabel
    }()
    
    // MARK: - Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        retrieveCurrentLocation()
        
        guard let currentUid = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey) as? String else { return }
        fetchUser(with: currentUid)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideEmptyState()
        setupViews()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    // MARK: - Class methods
    func setupViews() {
        let backBarButton = UIBarButtonItem()
        backBarButton.title = "Back"
        self.navigationItem.backBarButtonItem = backBarButton
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh page")
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.collectionView.addSubview(refresher)
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        collectionView.backgroundColor = .edamameGreen
    }
    
    private func fetchUser(with firebaseUID: String) {
        
        UserController.shared.fetchUserBy(firebaseUID) { (result) in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    user.badgeCount = 0
                    if let pushID = UserController.shared.pushID {
                        user.pushID = pushID
                    }
                    
                    UserController.shared.currentUser = user
                    self.updateBadgeCountAndPushID(with: user)
                    if user.reportCount >= 3 {
                        self.presentAccountReportedAlert(user)
                    }
                    self.loadData()
                }
            case .failure(_):
                print("User does not yet exist in database")
                self.tabBarController?.selectedIndex = 3
            }
        }
    }
    
    private func updateBadgeCountAndPushID(with user: User) {
        UserController.shared.updateBadgeCountAndPushID(with: user) { (result) in
            switch result {
            case .success(_):
                print("PushID and badge count updated successfully.")
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    @objc func loadData() {
        guard let currentUser = UserController.shared.currentUser else { return }
        
        UserController.shared.fetchFilteredRandos(currentUser: currentUser) { (result) in
            switch result {
            case .success(let randos):
                DispatchQueue.main.async {
                    UserController.shared.randos = randos
                    self.collectionView.reloadData()
                    if randos.isEmpty {
                        self.showEmptyState()
                        self.activityIndicator.stopAnimating()
                    } else {
                        self.hideEmptyState()
                        self.updateViews()
                    }
                }
            case .failure(let error):
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
            }
        }
    }
    
    func showEmptyState() {
        collectionView.addSubview(emptyMessage)
        emptyMessage.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        emptyMessage.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
    }
    
    func hideEmptyState() {
        emptyMessage.removeFromSuperview()
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
            self.refresher.endRefreshing()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func retrieveCurrentLocation() {
        let status = CLLocationManager().authorizationStatus
        
        if (status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled()) {
            return
        }
        
        if (status == .notDetermined) {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func configureCollectionViewLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 10,
                                      leading: 10,
                                      bottom: 0,
                                      trailing: 10)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRandoProfileVC" {
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
                  let cell = collectionView.cellForItem(at: indexPath) as? RandoCollectionViewCell
            else { return }
            let destinatinon = segue.destination as? ProfileViewController
            let profile = cell.user
            destinatinon?.otherUser = profile
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return UserController.shared.randos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "randoCell", for: indexPath) as? RandoCollectionViewCell else { return UICollectionViewCell() }
        
        let rando = UserController.shared.randos[indexPath.row]
        
        cell.user = rando
        
        if let image = rando.images.first {
            cell.photo = image.image
        } else {
            cell.backgroundColor = .spaceBlack
            cell.photo = nil
        }
        
        cell.nameLabel.text = rando.name
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        
        cell?.backgroundColor?.withAlphaComponent(0.55)
    }
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
            
            UserController.shared.updateUserCurrentLocation(with: currentUser) { (result) in
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
