//
//  RandoCollectionViewCell.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

class RandoCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var backgroundPlaceHolder: UIView!
    
    //MARK: - Properties
    let gradientLayer = CAGradientLayer()
    var indexPath: IndexPath!
    var user: User?
    
    var photo: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Helper Functions
    func updateViews() {
        guard let photo = photo else { return }
        imageView.image = photo
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 5.0
    
        setGradientBackground()
    }
    
    func setGradientBackground() {
        
        gradientLayer.removeFromSuperlayer()
        
        let colorTop = UIColor.clear.cgColor
        let colorBottom = UIColor.black.cgColor
        
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.cornerRadius = 5.0
        gradientLayer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientLayer.frame = self.backgroundPlaceHolder.bounds
        
        self.backgroundPlaceHolder.layer.insertSublayer(gradientLayer, at: 0)
    }
}
