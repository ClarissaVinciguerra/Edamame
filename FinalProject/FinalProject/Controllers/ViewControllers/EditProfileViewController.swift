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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Properties
    var viewsLaidOut = false
    var profileImages: [Image] = []
    
    // MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        bioTextView.delegate = self
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disableCameraBarButton()
        initiateFetchUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //validateAuth()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if viewsLaidOut == false {
            setupViews()
            viewsLaidOut = true
            activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Actions
    @IBAction private func textFieldDidChange(_ sender: Any) {
        textFieldChanged()
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
        activityIndicator.startAnimating()
        createOrUpdateUser()
    }
    
    @IBAction func infoButtonTapped(_ sender: Any) {
        presentInfoAlert()
    }
    
    // MARK: - Class Methods
    //    private func validateAuth() {
    //        if FirebaseAuth.Auth.auth().currentUser == nil {
    //            let storyboard = UIStoryboard(name: "LogInSignUp", bundle: nil)
    //            guard let vc = storyboard.instantiateInitialViewController() else { return }
    //            vc.modalPresentationStyle = .fullScreen
    //            present(vc, animated: false)
    //        } else {
    //            guard let uidKey = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey) else { return }
    //            let uidString = "\(uidKey)"
    //            fetchUser(with: uidString)
    //        }
    //    }
    
    private func initiateFetchUser() {
        guard let uidKey = UserDefaults.standard.value(forKey: LogInStrings.firebaseUidKey) else { return }
        let uidString = "\(uidKey)"
        fetchUser(with: uidString)
    }
    // CHECK IF THIS IS NECESSARY BEFORE SUBMISSION
    private func fetchUser(with firebaseUID: String) {
        // this wont be necessary when the fetchUser function is moved
        profileImages = []
        
        UserController.shared.fetchUserBy(firebaseUID) { (result) in
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    // if success - the user needs to be set to the current user and taken to the randoVC (index[0])
                    UserController.shared.currentUser = user
                    self.profileImages = user.images
                    // these can be called in VDL of this VC
                    self.setupViews()
                    self.updateViews()
                    self.disableCameraBarButton()
                }
            case .failure(_):
                print("User does not yet exist in database")
                // If the user is not fetched send to index[3] of tab bar controller and disable other tab bars - maybe we should add an alert
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
                    self.activityIndicator.stopAnimating()
                case .failure(let error):
                    print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                    self.activityIndicator.stopAnimating()
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
        
        let firebaseuid = "\(uidKey)"
        let name = "\(nameKey)"
        var images: [UIImage] = []
        
        for image in profileImages {
            images.append(image.image)
        }
        
        if profileImages.count > 1 {
            addCityAlertToCreateUser(name: name, bio: bio, type: type, unsavedImages: images, dateOfBirth: birthdayKey, latitude: 0.0, longitude: 0.0, uuid: firebaseuid)
        } else {
            self.activityIndicator.stopAnimating()
            presentImageAlert()
        }
    }
    
    func updateViews() {
        if let currentUser = UserController.shared.currentUser {
            
//            typeOfVeganTextField.placeholder = currentUser.type
            typeOfVeganTextField.attributedPlaceholder = NSAttributedString(string: currentUser.type, attributes: [NSAttributedString.Key.foregroundColor: UIColor.spaceBlack])
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
        typeOfVeganTextField.textColor = .spaceBlack
        bioTextLabel.textColor = .spaceBlack
        
        infoButton.tintColor = .darkerGreen
        
        bioTextView.textColor = .spaceBlack
        bioTextView.backgroundColor = .whiteSmoke
        bioTextView.addCornerRadius(radius: 6)
        
        dismissKeyboard()
                
        view.backgroundColor = .white

        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    func disableCameraBarButton() {
        if profileImages.count >= 6 {
            cameraBarButton.isEnabled = false
        }
    }
    
    public func dismissKeyboard() {
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    func textFieldChanged () {
        guard let currentUser = UserController.shared.currentUser, let typeOfVegan = typeOfVeganTextField.text else { return }
        
        typeOfVeganTextField.attributedPlaceholder = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor: UIColor.spaceBlack])
        
        currentUser.type = typeOfVegan
        saveChangesButton.setTitle("Save Changes", for: .normal)
        saveChangesButton.isEnabled = true
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
