//
//  EdamameLabel.swift
//  FinalProject
//
//  Created by Deven Day on 12/3/20.
//

import UIKit

class EdamameLabel: UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateFontTo(font: FontNames.sourceSansProRegular)
        self.textColor = .darkerGreen
    }
    
    func updateFontTo(font: String) {
        let size = self.font.pointSize
        self.font = UIFont(name: font, size: size)
    }
}

class EdamameLabelLight: EdamameLabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateFontTo(font: FontNames.sourceSansProLight)
        self.textColor = .edamameGreen
    }
}

class EdamameLabelBold: EdamameLabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        updateFontTo(font: FontNames.sourceSansProBold)
    }
}

