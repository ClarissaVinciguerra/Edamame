//
//  EditProfileViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit

class EditProfileViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeOfVeganTextField: UITextField!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    
    //MARK: - Properties
    var viewsLaidOut = false
    var profileImages: [UIImage] = []
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if collectionView.visibleCells.count == 5 {
            cameraBarButton.isEnabled = !cameraBarButton.isEnabled
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewsLaidOut == false {
            setupViews()
            viewsLaidOut = true
        }
    }
    
    // MARK: - Actions
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        selectPhotoAlert()
        
        if collectionView.visibleCells.count == 5 {
            cameraBarButton.isEnabled = !cameraBarButton.isEnabled
        }
    }
    
    @IBAction func saveChangesButtonTapped(_ sender: Any) {
        updateUser()
    }
    
    // MARK: - Class Methods
    func updateUser() {
        guard let currentUser = UserController.shared.currentUser, let bio = bioTextView.text, let type = typeOfVeganTextField.text, let name = nameTextField.text, !name.isEmpty else { return }
        
        currentUser.bio = bio
        currentUser.name = name
        currentUser.type = type
 
    }
    
    func setupViews() {
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    func selectPhotoAlert() {
        let alertVC = UIAlertController(title: "Add a Photo", message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.openCamera()
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.openPhotoLibrary()
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(cameraAction)
        alertVC.addAction(photoLibraryAction)
        
        present(alertVC, animated: true)
    }
    
    func configureCollectionViewLayout() -> UICollectionViewLayout {
         
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95), heightDimension: .fractionalHeight(0.95))
         
         let item = NSCollectionLayoutItem(layoutSize: itemSize)
         
     let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.33))
         
         let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
         group.interItemSpacing = .fixed(10)
         
         let section = NSCollectionLayoutSection(group: group)
         section.interGroupSpacing = 10
         section.contentInsets = .init(top: 10,
                                       leading: 10,
                                       bottom: 0,
                                       trailing: 10)
         
         return UICollectionViewCompositionalLayout(section: section)
     }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

//MARK: - Extensions
extension EditProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.profileImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editPhotoCell", for: indexPath) as? EditPhotoCollectionViewCell else { return UICollectionViewCell() }
        
        cell.photo = self.profileImages[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        cameraBarButton.isEnabled = !isEditing
        if let indexPaths = collectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = collectionView?.cellForItem(at: indexPath) as? EditPhotoCollectionViewCell {
                    cell.isEditing = editing
                }
            }
        }
    }
}

//MARK: - CV CellDelegate
extension EditProfileViewController: EditPhotoCollectionViewDelegate {
    
    func delete(cell: EditPhotoCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            
            profileImages.remove(at: indexPath.row)
            
            collectionView.deleteItems(at: [indexPath])
        }
    }
}

//MARK: - ImagePicker Delegate & NavController Delegate
extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true)
        } else {
            let alertVC = UIAlertController(title: "Camera Not Accessible", message: "You will need to make sure your camera is accessible to use this feature.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true)
        }
    }
    
    func openPhotoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true)
        } else {
            let alertVC = UIAlertController(title: "Photo Library is Not Accessible", message: "You will need to make sure your Photo Library is accessible to use this feature", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.editedImage] as? UIImage {
            self.profileImages.append(selectedImage)
            self.collectionView.reloadData()
        } else {
            if let selectedImage = info[.originalImage] as? UIImage {
                self.profileImages.append(selectedImage)
                self.collectionView.reloadData()
            }
        }
        picker.dismiss(animated: true)
    }
}
