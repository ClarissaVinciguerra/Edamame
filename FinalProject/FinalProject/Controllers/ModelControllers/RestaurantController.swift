//
//  RestaurantController.swift
//  FinalProject
//
//  Created by Deven Day on 11/25/20.
//

import Foundation
import CoreLocation

class RestaurantController {
    
    static let shared = RestaurantController()
    
    static let baseURL = URL(string: "https://api.yelp.com/v3/businesses/search")!
    
    static func fetchRestaurants(location: CLLocation, completion: @escaping (Result <[Restaurant], NetworkError>) -> Void) {
        
        let parameters = ["latitude" : "\(location.coordinate.latitude)", "longitude" : "\(location.coordinate.longitude)", "term" : "vegan"]
        
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        
        let queryItems = parameters.compactMap{URLQueryItem(name: $0.key, value: $0.value)}
        components?.queryItems = queryItems
        
        guard let url = components?.url
        
        else { return completion(.failure(.invalidURL))}
        
        let headers = yelpAPIKey
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                return completion(.failure(.thrownError(error)))
            }
            
            guard let data = data else {return completion(.failure(.noData))}
            
            do {
                let topLevelObject = try JSONDecoder().decode(TopLevelObject.self, from: data)
                let restaurant = topLevelObject.businesses
                return completion(.success(restaurant))
            } catch {
                return completion(.failure((.unableToDecode)))
            }
        }.resume()
    }
}
