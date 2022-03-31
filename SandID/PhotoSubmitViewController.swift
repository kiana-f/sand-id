//
//  PhotoSubmitViewController.swift
//  SandID
//
//  Created by Kiana Fithian on 2/9/22.
//

import UIKit
import BoxSDK
import CoreLocation

class PhotoSubmitViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
	
	var capturedImage: UIImage!
	var photoLatitude: String?
	var photoLongitude: String?
	
	@IBOutlet var uploadButton: UIButton!
	@IBOutlet var locationField: UITextField!
	@IBOutlet var textInputAlert: UILabel!
	@IBOutlet weak var currLocationButton: UIButton!
	
	let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

		locationField.delegate = self
		textInputAlert.isHidden = true
		locationManager.delegate = self
    }
	
	//updates current location coordinates
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		print("updating current location")
		if let location = locations.first {
			let latitude = location.coordinate.latitude
			let longitude = location.coordinate.longitude
			photoLatitude = "\(String(describing: latitude))"
			photoLongitude = "\(String(describing: longitude))"
			locationField.text = "\(String(describing: latitude)), \(String(describing: longitude))"
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
		print("touched upload button")
		if locationField.text == "" {
			textInputAlert.isHidden = false
		} else {
			uploadImage()
		}
	}
	
	private func getCurrentLocation() {
		locationManager.requestLocation()
	}
	
	//uploads captured image to database
	private func uploadImage() {
		let data: Data = capturedImage.pngData()!
		
		let token = ProcessInfo.processInfo.environment["BOX_API_TOKEN"]!
		let client = BoxSDK.getClient(token: token)
		let fileName = "\(String(describing: locationField.text!)).png"
		client.files.upload(data: data, name: fileName, parentId: "0") { (result: Result<File, BoxSDKError>) in
			guard case let .success(file) = result else {
				print("Error uploading file")
				return
			}
		}
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
