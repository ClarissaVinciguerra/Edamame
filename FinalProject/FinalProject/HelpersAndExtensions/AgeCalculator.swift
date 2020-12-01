//
//  AgeCalculator.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/25/20.
//

import Foundation

extension Date {
    
    func calcAge() -> String? {

        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: self, to: now, options: [])
        
        return "\(calcAge.year ?? 800)"
    }
}
