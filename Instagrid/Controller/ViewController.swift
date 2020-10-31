//
//  ViewController.swift
//  InstaGrid
//
//  Created by Raphaël Payet on 09/10/2020.
//

import UIKit

class ViewController : UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var mainLayout: UIView!
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet weak var swipeLabel: UILabel!
    
    @IBOutlet weak var photo1: PhotoButton!
    @IBOutlet weak var photo2: PhotoButton!
    @IBOutlet weak var photo3: PhotoButton!
    @IBOutlet weak var photo4: PhotoButton!
    
    @IBOutlet weak var layout1: LayoutView!
    @IBOutlet weak var layout2: LayoutView!
    @IBOutlet weak var layout3: LayoutView!
    
    //MARK: - Properties
    var photoIndex = 0
    let screenHeight = UIScreen.main.bounds.height * 2
    let screenWidth = UIScreen.main.bounds.width * 2
    var deviceOrientation : UIDeviceOrientation = .portrait
    var isValidSwipe = false
    
    //MARK: - Actions
    @IBAction func addPhoto(_ sender: UIButton) {
        handlePhotoTap(sender.tag)
    }
    @IBAction func layoutTapped(_ sender: UIButton) {
        handleLayoutTap(tag: sender.tag)
    }
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //This function handles the parameters that needs to be here at the launch of the application.
        setupUI()
        configureDeviceOrientation()
        configureSwipe()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //This function handle when device orientation change
        if UIDevice.current.orientation == .portrait {
            swipeLabel.text = "Swipe up to share"
            deviceOrientation = .portrait
        } else {
            swipeLabel.text = "Swipe left to share"
            deviceOrientation = .landscapeLeft
        }
    }
    
    private func configureSwipe() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(sender:)))
        view.addGestureRecognizer(pan)
    }
    
    private func configureDeviceOrientation() {
        if screenHeight < screenWidth {
            swipeLabel.text = "Swipe left to share"
            deviceOrientation = .landscapeLeft
        } else {
            swipeLabel.text = "Swipe up to share"
            deviceOrientation = .portrait
        }
    }
    
    
    //MARK: - Photo Logic
    func handlePhotoTap(_ index : Int) {
        //Called when a photo is tapped.
        //Show a PickerController and add the edited photo to the right box in the main layout
        photoIndex = index
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    func handleLayoutTap(tag: Int) {
        //Change the main layout, and select or deselect the button
        switch tag {
        case 0: configureFirstLayout()
        case 1: configureSecondLayout()
        case 2: configureThirdLayout()
        default: break
        }
    }
    
    //MARK: - Swipe Logic
    @objc func handleSwipe(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began, .changed:
            moveLayout(gesture: sender)
        case .ended:
            if isValidSwipe {
                animateLayout()
                showActivityController()
            }
        default: break
        }
    }
    
    
    private func moveLayout(gesture : UIPanGestureRecognizer) {
        let translation = gesture.translation(in: mainLayout)
        if deviceOrientation == .portrait {
            let portraitTranslation = CGAffineTransform(translationX: 0, y: translation.y)
            if translation.y < 0 {
                mainLayout.transform = portraitTranslation
                isValidSwipe = true
            } else {
                mainLayout.transform = .identity
                isValidSwipe = false
            }
        } else {
            let landscapeTranslation = CGAffineTransform(translationX: translation.x, y: 0)
            if translation.x < 0 {
                mainLayout.transform = landscapeTranslation
                isValidSwipe = true
            } else {
                mainLayout.transform = .identity
                isValidSwipe = false
            }
        }
    }
    private func animateLayout() {
        UIView.animate(withDuration: 0.3) {
            if self.deviceOrientation == .portrait {
                self.mainLayout.transform = CGAffineTransform(translationX: 0, y: -self.screenHeight)
            } else {
                self.mainLayout.transform = CGAffineTransform(translationX: -self.screenWidth, y: 0)
            }
        }
    }
    private func showActivityController() {
        guard let image = getImageFromCollage() else { return }
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: [])
        activityController.completionWithItemsHandler = { (_, _, _, _error) in
            guard _error == nil else { return }
            self.showLayout()
        }
        present(activityController, animated: true)
    }
    private func showLayout() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: .curveEaseOut) {
            self.mainLayout.transform = .identity
        }
    }
    private func getImageFromCollage() -> UIImage? {
        //Get a context from the main layout frame, and create an image based on its layer.
        UIGraphicsBeginImageContextWithOptions(mainLayout.frame.size, true, 0)
        mainLayout.layer.render(in: UIGraphicsGetCurrentContext()!)
        guard let collage = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        return collage
    }
    //MARK: - Layouts
    
    func setupUI() {
        //Called in viewDidLoad. Set the default parameters for the screen
        photo4.isHidden = true
        layout1.selectedImage.isHidden = true
        layout2.selectedImage.isHidden = false
        layout3.selectedImage.isHidden = true
    }
    
    //Called when a layout is changed, the following functions configure the main layout with the appropriate pictures.
    func configureFirstLayout() {
        photo1.isHidden = false
        photo2.isHidden = true
        photo3.isHidden = false
        photo4.isHidden = false
        
        layout1.selectedImage.isHidden = false
        layout2.selectedImage.isHidden = true
        layout3.selectedImage.isHidden = true
    }
    func configureSecondLayout() {
        photo1.isHidden = false
        photo2.isHidden = false
        photo3.isHidden = false
        photo4.isHidden = true
        
        layout1.selectedImage.isHidden = true
        layout2.selectedImage.isHidden = false
        layout3.selectedImage.isHidden = true
    }
    func configureThirdLayout() {
        photo1.isHidden = false
        photo2.isHidden = false
        photo3.isHidden = false
        photo4.isHidden = false
        
        layout1.selectedImage.isHidden = true
        layout2.selectedImage.isHidden = true
        layout3.selectedImage.isHidden = false
    }
}

//MARK: - UIImage Picker Controller
extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //This is a delegate function called when the image picker controller did Finish Picking an image.
        //Assign the right photo to the right box according to its photoIndex
        //Dismiss the picker delegate after the choice
        
        guard let photo = info[.editedImage] as? UIImage else { return }
        switch photoIndex {
        case 0 : photo1.configure(with: photo)
        case 1 : photo2.configure(with: photo)
        case 2 : photo3.configure(with: photo)
        case 3 : photo4.configure(with: photo)
        default: break
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
