//
//  StyleGuide.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/25/20.
//

import UIKit

struct FontNames {
    static let sourceSansProBold = "SourceSansPro-Bold"
    static let sourceSansProRegular = "SourceSansPro-Regular"
    static let sourceSansProLight = "SourceSansPro-Light"
    static let sourceSansProExtraLight = "SourceSansPro-ExtraLight"
    
}

extension UIColor {
    static let darkerGreen = UIColor(named: "darkGreen")!
    static let edamameGreen = UIColor(named: "lightGreen")!
    static let softBlack = UIColor(named: "softBlack")!
    static let lightYellowAccent = UIColor(named: "lightYellow")!
    static let spaceBlack = UIColor(named: "spaceBlack")!
    static let whiteSmoke = UIColor(named: "whiteSmoke")!
    static let subtleText = UIColor(named: "subtleText")!
    static let borderHighlight = UIColor(named: "borderhighlight")!
}

extension UIView {

    func addCornerRadius(radius: CGFloat = 4) {
        self.layer.cornerRadius = radius
    }
    
    func addAccentBorder(width: CGFloat = 3, color: UIColor = .borderHighlight) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    
    func rotate(by radians: CGFloat = (-CGFloat.pi / 2)) {
        self.transform = CGAffineTransform(rotationAngle: radians)
    }
}

