//
//  EdamameTextField.swift
//  FinalProject
//
//  Created by Deven Day on 12/3/20.
//

import UIKit

class EdamameTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpViews()
    }
    
    func setUpViews() {
        setUpPlaceholderText()
        updateFontTo(name: FontNames.sourceSansProRegular)
        self.addCornerRadius(radius: 10)
        self.layer.masksToBounds = true
        
        self.addAccentBorder()
        self.textColor = .spaceBlack
        self.backgroundColor = .whiteSmoke
    }
    
    func setUpPlaceholderText() {
        let currentPlaceholder = self.placeholder
        self.attributedPlaceholder = NSAttributedString(string: currentPlaceholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.subtleText, NSAttributedString.Key.font : UIFont(name: FontNames.sourceSansProLight, size: 16)!])
    }
    
    func updateFontTo(name: String) {
        guard let size = self.font?.pointSize else {return}
        self.font = UIFont(name: name, size: size)
    }
}
