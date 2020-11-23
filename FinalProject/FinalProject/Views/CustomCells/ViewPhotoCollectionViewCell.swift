//
//  ViewPhotoCollectionViewCell.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

class ViewPhotoCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    
    var photo: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    //MARK: - Helper Function
    func updateViews() {
        guard let photo = photo else { return }
        imageView.image = photo
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10.0
    }
}
