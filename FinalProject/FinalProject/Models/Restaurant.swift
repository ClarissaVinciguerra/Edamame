//
//  Restaurant.swift
//  FinalProject
//
//  Created by Deven Day on 11/25/20.
//

import Foundation

struct TopLevelObject: Codable {
    let businesses: [Restaurant]
}

struct Restaurant: Codable {
    let name: String
    let rating: Double
    let url: URL
}
