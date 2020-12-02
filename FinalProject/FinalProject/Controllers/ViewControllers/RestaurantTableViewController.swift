//
//  RestaurantTableViewController.swift
//  FinalProject
//
//  Created by Deven Day on 11/25/20.
//

import UIKit
import CoreLocation

class RestaurantTableViewController: UITableViewController {
    
    //MARK: - Properties
    var restaurants: [Restaurant] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return restaurants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath)
        
        let restaurant = restaurants[indexPath.row]
        
        cell.textLabel?.text = restaurant.name
        cell.detailTextLabel?.text = "Rating \(restaurant.rating)"
        
        return cell
    }
}
