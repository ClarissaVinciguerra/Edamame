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
    
    //MARK: - Helpers
    func fetchRestaurants() {
        guard let location = CLLocationManager().location else { return }
        //        let a = CLLocation(latitude: User.latitude, longitude: User.longitude)
        RestaurantController.fetchRestaurants(location: location) { (result) in
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
}//END OF CLASS
