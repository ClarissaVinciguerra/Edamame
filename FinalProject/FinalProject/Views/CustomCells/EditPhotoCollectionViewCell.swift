//
//  EditPhotoCollectionViewCell.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

protocol EditPhotoCollectionViewDelegate: class {
    func delete(cell: EditPhotoCollectionViewCell)
}

class EditPhotoCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    weak var delegate: EditPhotoCollectionViewDelegate?
    
    var photo: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let photo = photo else { return }
        imageView.image = photo
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        visualEffectView.layer.cornerRadius = visualEffectView.bounds.width / 2.0
        visualEffectView.layer.masksToBounds = true
        visualEffectView.isHidden = !isEditing
    }
    
    var isEditing: Bool = false {
        didSet {
            visualEffectView.isHidden = !isEditing
        }
    }
    
    // MARK: - Actions
    @IBAction func removePhotoButtonTapped(_ sender: Any) {
        delegate?.delete(cell: self)
    }
}
