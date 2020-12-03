//
//  EdamameButton.swift
//  FinalProject
//
//  Created by Deven Day on 12/3/20.
//

import UIKit

class EdamameButton: UIButton {
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupViews()
    }
    
    //MARK: - Class Functions
    func setupViews() {
        updateFontTo(font: FontNames.sourceSansProRegular)
        self.backgroundColor = .lightYellowAccent
        self.setTitleColor(.spaceBlack, for: .normal)
        self.addCornerRadius()
    }
    
    func updateFontTo(font: String) {
        guard let size = self.titleLabel?.font.pointSize else { return }
        self.titleLabel?.font = UIFont(name: font, size: size)
    }
}//END OF CLASS
