//
//  PhotoSubmitViewController.swift
//  SandID
//
//  Created by Kiana Fithian on 2/9/22.
//

import UIKit
import BoxSDK

class PhotoSubmitViewController: UIViewController, UITextFieldDelegate {
	
	var capturedImage: UIImage!
	
	@IBOutlet var uploadButton: UIButton!
	@IBOutlet var locationField: UITextField!
	@IBOutlet var textInputAlert: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

		locationField.delegate = self
		textInputAlert.isHidden = true
    }
	
	@IBAction func onUploadData(_ sender: Any) {
		print("touched upload button")
		if locationField.text == "" {
			textInputAlert.isHidden = false
		} else {
			uploadImage()
		}
	}
	
	private func uploadImage() {
		let data2: Data = capturedImage.pngData()!
		
		let token = ProcessInfo.processInfo.environment["BOX_API_TOKEN"]!
		let client = BoxSDK.getClient(token: token)
		let fileName = locationField.text
		client.files.upload(data: data2, name: fileName!, parentId: "0") { (result: Result<File, BoxSDKError>) in
			guard case let .success(file) = result else {
				print("Error uploading file")
				return
			}
		}

		 //To cancel upload
//		if someConditionIsSatisfied {
//			task.cancel()
//		}
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
