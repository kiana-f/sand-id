//
//  PhotoSubmitViewController.swift
//  SandID
//
//  Created by Kiana Fithian on 2/9/22.
//

import UIKit
import BoxSDK
import CoreLocation
import FirebaseStorage

class PhotoSubmitViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
	
	var capturedImage: UIImage!
	var photoLatitude: String?
	var photoLongitude: String?
	
	@IBOutlet var uploadButton: UIButton!
	@IBOutlet var locationField: UITextField!
	@IBOutlet var textInputAlert: UILabel!
	@IBOutlet var nameInputAlert: UILabel!
	@IBOutlet weak var currLocationButton: UIButton!
	@IBOutlet weak var nameField: UITextField!
	
	let locationManager = CLLocationManager()
	var storage: Storage!
	var storageReference: StorageReference!

    override func viewDidLoad() {
        super.viewDidLoad()

		locationField.delegate = self
		textInputAlert.isHidden = true
		nameInputAlert.isHidden = true
		locationManager.delegate = self
		
		storage = Storage.storage()
		storageReference = storage.reference()
    }
	
	//updates current location coordinates
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		print("updating current location")
		if let location = locations.first {
			let latitude = location.coordinate.latitude
			let longitude = location.coordinate.longitude
			let latRound = round(latitude * 1000000) / 1000000.0
			let longRound = round(longitude * 1000000) / 1000000.0
			photoLatitude = "\(String(describing: latRound))"
			photoLongitude = "\(String(describing: longRound))"
			locationField.text = "\(String(describing: latRound)), \(String(describing: longRound))"
		}
		print("updated location")
	}
	
	//Handles when authorization changes
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		print("Location authorization status was changed")
	}
	
	// Handle failure to get a user’s location
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Failed to get current location")
	}
	
	//button action for using current location
	@IBAction func onUseCurrLocation(_ sender: Any) {
		checkLocationPermissions()
	}
	
	//button action for uploading image
	@IBAction func onUploadData(_ sender: Any) {
		let locationEmpty = locationField.text == ""
		let nameEmpty = nameField.text == ""
		
		if locationEmpty || nameEmpty {
			// fields are empty
			textInputAlert.isHidden = !locationEmpty
			nameInputAlert.isHidden = !nameEmpty
			nameInputAlert.text = "Fill in name"
		} else if nameField.text!.contains("_") {
			// name field contains an underscore
			nameInputAlert.isHidden = false
			nameInputAlert.text = "Name cannot contain underscores"
		} else {
			isValidName()
		}
	}
	
	// checks if an image name has already been used, updates the name if needed, and
	// uploads the photo
	// sorry this method is so ugly but async is making me put it all in one method
	private func isValidName() {
		let storageRef = storage.reference().child("SandID")
		storageRef.listAll { (result, error) in
			if let error = error {
				print("ERROR")
				print(error)
				return
			}
			
			let delimiter = "_"
			var curPhotoName = self.nameField.text!
			var foundValid = false
			
			while !foundValid {
				// go through image names and compare
				for item in result.items {
					// gets image name and separates by delimiter
					let imageName = item.name.components(separatedBy: delimiter)
					if imageName[0] == curPhotoName {
						// repeat name!
						foundValid = false
						let lastChar = curPhotoName.last!
						if let intValue = lastChar.wholeNumberValue {
							// increase already appended number
							let plusOne = intValue + 1
							curPhotoName = "\(curPhotoName.dropLast())\(plusOne)"
							
						} else {
							// append number
							curPhotoName = "\(curPhotoName)1"
						}
						break
					}
					foundValid = true
				}
			}
			
			let data: Data = self.capturedImage.pngData()!
			
			let fileName = "\(curPhotoName)_\(String(describing: self.locationField.text!))"
			let imageRef = self.storageReference.child("SandID/\(fileName).png")
			// Create file metadata including the content type
			let metadata = StorageMetadata()
			metadata.contentType = "image/png"
			
			// upload data
			imageRef.putData(data, metadata: metadata) { (meta, error) in
				guard let meta2 = meta else {
					print("ERROR")
					print(error.debugDescription)
					return
				}
				print("Upload successful")
			}
			self.returnToInitialVC()
		}
	}
	
	// retrieves current location of device
	private func getCurrentLocation() {
		locationManager.requestLocation()
	}
	
	//Return to intial vc after uploading photo
	private func returnToInitialVC() {
		let navigator = self.navigationController
		navigator?.popToRootViewController(animated: true)
	}
	
	//Handles permissions for using location of user's device
	private func checkLocationPermissions() {
		let status = locationManager.authorizationStatus
		switch status {
		case .authorizedAlways:
			getCurrentLocation()
		case .authorizedWhenInUse:
			getCurrentLocation()
		case .denied:
			print("Failed to get current location: denied")
		case .notDetermined:
			print("requesting location when in use")
			locationManager.requestWhenInUseAuthorization()
			getCurrentLocation()
		case .restricted:
			print("Failed to get current location: restricted")
		@unknown default:
			print("Some unknown authorization status")
		}
	}
	
	// Called when 'return' key pressed
	private func textFieldShouldReturn(textField:UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	// Called when the user clicks on the view outside of the UITextField
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
