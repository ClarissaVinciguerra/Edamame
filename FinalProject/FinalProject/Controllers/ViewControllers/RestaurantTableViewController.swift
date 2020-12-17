//
//  RestaurantTableViewController.swift
//  FinalProject
//
//  Created by Deven Day on 11/25/20.
//

import UIKit
import CoreLocation
import SafariServices

class RestaurantTableViewController: UIViewController {
    
    //MARK: - Properties
    var restaurants: [Restaurant] = []
    
    //MARK: - Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        fetchRestaurants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //MARK: - Helper Functions
    func fetchRestaurants() {
        let userLocation = CLLocation(latitude: UserController.shared.currentUser?.latitude ?? 0,
                                      longitude: UserController.shared.currentUser?.longitude ?? 0)
        
        RestaurantController.fetchRestaurants(location: userLocation) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let restaurants):
                    self.restaurants = restaurants
                    self.tableView.reloadData()
                    self.activityIndicator.startAnimating()
                case .failure(let error):
                    print(error.localizedDescription)
                    self.activityIndicator.startAnimating()
                }
            }
        }
    }
}

//MARK: - Extensions
extension RestaurantTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRestaurant = restaurants[indexPath.row]
        let vc = SFSafariViewController(url: selectedRestaurant.url)
        
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)
        
        let restaurant = restaurants[indexPath.row]
        
        cell.textLabel?.text = restaurant.name
        cell.detailTextLabel?.text = "Rating \(restaurant.rating)"
        
        return cell
    }
}
