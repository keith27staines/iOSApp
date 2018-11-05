

import UIKit
import AVFoundation

protocol F4SCameraViewControllerDelegate {
    func cameraCaptureDidComplete(controller: F4SCameraViewController, image: UIImage?)
}

class F4SCameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var delegate: F4SCameraViewControllerDelegate?
    
	@IBOutlet var imageView: UIImageView?
	@IBOutlet var cameraButton: UIBarButtonItem?
	@IBOutlet var overlayView: UIView?
	
	// Camera controls found in the overlay view.
	@IBOutlet var takePictureButton: UIBarButtonItem?
	@IBOutlet var doneButton: UIBarButtonItem?

    var imagePickerController: UIImagePickerController!

    var capturedImage: UIImage?
	
	// MARK: - View Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
        imagePickerController = UIImagePickerController()
		imagePickerController.modalPresentationStyle = .currentContext
		imagePickerController.delegate = self
		
		// Remove the camera button if the camera is not currently available.
		if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
			toolbarItems = self.toolbarItems?.filter { $0 != cameraButton }
		}
        showImagePicker(button: cameraButton!)
    }

	fileprivate func finishAndUpdate() {
		dismiss(animated: true, completion: { [weak self] in
			guard let strongSelf = self else {
				return
			}
            // Camera took a single picture.
            strongSelf.imageView?.image = strongSelf.capturedImage
			
		})
	}
	
	// MARK: - Toolbar Actions
	
	@IBAction func showImagePickerForCamera(_ sender: UIBarButtonItem) {
		let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
		
		if authStatus == AVAuthorizationStatus.denied {
			// Denied access to camera, alert the user.
			// The user has previously denied access. Remind the user that we need camera access to be useful.
			let alert = UIAlertController(title: "Unable to access the Camera",
										  message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.",
										  preferredStyle: UIAlertController.Style.alert)
			
			let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
			alert.addAction(okAction)
			
			let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { _ in
				// Take the user to Settings app to possibly change permission.
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
				if UIApplication.shared.canOpenURL(settingsUrl) {
					UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
						// Finished opening URL
					})
				}
			})
			alert.addAction(settingsAction)
			
			present(alert, animated: true, completion: nil)
		}
		else if (authStatus == AVAuthorizationStatus.notDetermined) {
			// The user has not yet been presented with the option to grant access to the camera hardware.
			// Ask for permission.
			//
			// (Note: you can test for this case by deleting the app on the device, if already installed).
			// (Note: we need a usage description in our Info.plist to request access.
			//
			AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
				if granted {
					DispatchQueue.main.async {
						self.showImagePicker(button: sender)
					}
				}
			})
		} else {
			// Allowed access to camera, go ahead and present the UIImagePickerController.
			showImagePicker(button: sender)
		}
	}
	
	fileprivate func showImagePicker(button: UIBarButtonItem) {
		// If the image contains multiple frames, stop animating.
		if (imageView?.isAnimating)! {
			imageView?.stopAnimating()
		}
		
		imagePickerController.sourceType = UIImagePickerController.SourceType.camera
		imagePickerController.modalPresentationStyle = UIModalPresentationStyle.fullScreen
		
		let presentationController = imagePickerController.popoverPresentationController
		presentationController?.barButtonItem = button	 // Display popover from the UIBarButtonItem as an anchor.
		presentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
		
        // The user wants to use the camera interface. Set up our custom overlay view for the camera.
        imagePickerController.showsCameraControls = false
		
        // Apply our overlay view containing the toolar to take pictures in various ways.
        overlayView?.frame = (imagePickerController.cameraOverlayView?.frame)!
        imagePickerController.cameraOverlayView = overlayView
		
		present(imagePickerController, animated: true, completion: {
			// Done presenting.
		})
	}
	
	// MARK: - Camera View Actions
    
    @IBAction func cancel(_ sender: Any) {
        imageView?.image = nil
        delegate?.cameraCaptureDidComplete(controller: self, image: nil)
        finishAndUpdate()
    }
	
	@IBAction func done(_ sender: UIBarButtonItem) {
		finishAndUpdate()
        delegate?.cameraCaptureDidComplete(controller: self, image: imageView?.image)
	}
	
	@IBAction func takePhoto(_ sender: UIBarButtonItem) {
		imagePickerController.takePicture()
	}
	
	// MARK: - UIImagePickerControllerDelegate
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

		let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)]
		capturedImage = image as? UIImage
		finishAndUpdate()
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		dismiss(animated: true)
	}
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
