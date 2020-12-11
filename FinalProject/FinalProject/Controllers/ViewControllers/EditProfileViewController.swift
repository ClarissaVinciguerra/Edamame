//
//  EditProfileViewController.swift
//  FinalProject
//
//  Created by Clarissa Vinciguerra on 11/19/20.
//

import UIKit
import FirebaseAuth

class EditProfileViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var typeOfVeganTextField: UITextField!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cameraBarButton: UIBarButtonItem!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    //MARK: - Properties
    var viewsLaidOut = false
    var profileImages: [Image] = []
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        bioTextView.delegate = self
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disableCameraBarButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewsLaidOut == false {
            setupViews()
            viewsLaidOut = true
        }
    }
    
    // MARK: - Actions
    @IBAction private func textFieldDidChange(_ sender: Any) {
        saveChangesButton.setTitle("Save Changes", for: .normal)
        saveChangesButton.isEnabled = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveChangesButton.setTitle("Save Changes", for: .normal)
        saveChangesButton.isEnabled = true
    }
    
    @IBAction func addPhotoButtonTapped(_ sender: Any) {
        selectPhotoAlert()
        disableCameraBarButton()
        updateViews()
    }
    
    @IBAction func saveChangesButtonTapped(_ sender: Any) {
        createOrUpdateUser()
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        presentInfoAlert()
    }
    
    // MARK: - Class Methods
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "LogInSignUp", bundle: nil)
            guard let vc = storyboard.instantiateInitialViewController() else { return }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        } else {
            guard let uidKey = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey) else { return }
            let uidString = "\(uidKey)"
            fetchUser(with: uidString)
        }
    }
    
    private func fetchUser(with firebaseUID: String) {
        profileImages = []
        
        UserController.shared.fetchUserBy(firebaseUID) { (result) in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    UserController.shared.currentUser = user
                    self.profileImages = user.images
                    self.setupViews()
                    self.updateViews()
                    self.disableCameraBarButton()
                }
            case .failure(_):
                print("User does not yet exist in database")
                self.updateViews()
            }
        }
    }
    
    func createOrUpdateUser() {
        if UserController.shared.currentUser != nil {
            updateUser()
        } else {
            createUser()
        }
    }
    
    private func updateUser() {
        guard let currentUser = UserController.shared.currentUser, let bio = bioTextView.text, let type = typeOfVeganTextField.text else { return }
        
        currentUser.bio = bio
        currentUser.type = type
        
        if profileImages.count > 1 {
            UserController.shared.updateUserBy(currentUser, updatedImages: profileImages) { (result) in
                switch result {
                case .success(_):
                    self.saveChangesButton.setTitle("Saved", for: .normal)
                    self.saveChangesButton.isEnabled = false
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        } else {
            presentImageAlert()
        }
    }
    
    private func createUser() {
        guard let uidKey = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey),
              let nameKey = UserDefaults.standard.value(forKey: SignUpStrings.nameKey),
              let birthdayKey = UserDefaults.standard.value(forKey: SignUpStrings.birthday) as? Date,
              let type = typeOfVeganTextField.text,
              let bio = bioTextView.text,
              !bio.isEmpty else { return presentBioAlert() }
        
        let uid = "\(uidKey)"
        let name = "\(nameKey)"
        var images: [UIImage] = []
        
        for image in profileImages {
            images.append(image.image)
        }
        
        
        if profileImages.count > 1 {
            UserController.shared.createUser(name: name, bio: bio, type: type, unsavedImages: images, dateOfBirth: birthdayKey, latitude: 0.0, longitude: 0.0, uuid: uid) { (result) in
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.saveChangesButton.isEnabled = false
                        self.saveChangesButton.setTitle("Saved", for: .normal)
                        
                    }
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                // if it doesnt work alert user here
                }
            }
        } else {
            presentImageAlert()
        }
    }
    
    private func presentImageAlert() {
        let alertController = UIAlertController(title: "Add some photos!", message: "Show off at least 2 pictures of yourself to save to your profile 📸", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alertController.addAction(okayAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentInfoAlert() {
        let alertController = UIAlertController(title: "The type of plant based diet you identify most with 🌱", message: "Common types include but are not limited to: dietary vegan, cheegan, vegetarian, ovo-vegetarian, 98% vegan, vegan, etc.", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alertController.addAction(okayAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentBioAlert() {
        let alertController = UIAlertController(title: "Fill out the Bio", message: "Let others know a little bit about you...", preferredStyle: .alert)
        
        let okayAction = UIAlertAction(title: "Okay", style: .default)
        
        alertController.addAction(okayAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateViews() {
        if let currentUser = UserController.shared.currentUser {
            
            typeOfVeganTextField.placeholder = currentUser.type
            bioTextView.text = currentUser.bio
            saveChangesButton.setTitle("Save Changes", for: .normal)
            saveChangesButton.isEnabled = true
            
        } else {
            
            saveChangesButton.setTitle("Create Profile", for: .normal)
            
        }
    }
    
    func setupViews() {
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .whiteSmoke
        collectionView.collectionViewLayout = configureCollectionViewLayout()
        
        saveChangesButton.backgroundColor = .edamameGreen
        saveChangesButton.addCornerRadius()
        saveChangesButton.tintColor = .whiteSmoke
        
        typeOfVeganTextField.addAccentBorder(width: 0.5, color: .whiteSmoke)
        typeOfVeganTextField.addCornerRadius(radius: 6)
        typeOfVeganTextField.backgroundColor = .whiteSmoke
        bioTextLabel.textColor = .spaceBlack
        
        settingsButton.tintColor = .spaceBlack
        infoButton.tintColor = .darkerGreen
        
        bioTextView.textColor = .spaceBlack
        bioTextView.backgroundColor = .whiteSmoke
        bioTextView.addCornerRadius(radius: 6)
        
        view.backgroundColor = .white
        
        navigationItem.leftBarButtonItem = editButtonItem
        
    }
    
    func disableCameraBarButton() {
        if profileImages.count >= 6 {
            cameraBarButton.isEnabled = false
        }
    }
    
    private func selectPhotoAlert() {
        
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
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.99), heightDimension: .fractionalHeight(0.99))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.31))
        
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
    

//    private func appendImageToCloud(image: UIImage) {
//        guard let currentUser = UserController.shared.currentUser else { return }
//        UserController.shared.appendImage(image: image, user: currentUser) { (result) in
//            switch result {
//            case .success():
//                DispatchQueue.main.async {
//                    guard let currentUser = UserController.shared.currentUser else { return }
//                    currentUser.images.append(image)
//                    self.collectionView.reloadData()
//                }
//            case .failure(let error):
//                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
//                // present alert to user that iamge didnt save
//            }
//        }
//    }

}

//MARK: - Extensions
extension EditProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.profileImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "editPhotoCell", for: indexPath) as? EditPhotoCollectionViewCell else { return UICollectionViewCell() }
        
        let image = profileImages[indexPath.row]
        cell.photo = image.image
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
        if !editing {
            disableCameraBarButton()
        }
    }
}

//MARK: - CV CellDelegate
extension EditProfileViewController: EditPhotoCollectionViewDelegate {
    
    func delete(cell: EditPhotoCollectionViewCell) {
        
        if let indexPath = collectionView.indexPath(for: cell) {
            
            profileImages.remove(at: indexPath.row)
            collectionView.deleteItems(at: [indexPath])
            updateViews()
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
            
            let image = Image(name: "", image: selectedImage)
            
            profileImages.append(image)
            picker.dismiss(animated: true)
            disableCameraBarButton()
            collectionView.reloadData()
            
        }
    }
}
