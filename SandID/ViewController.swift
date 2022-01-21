//
//  ViewController.swift
//  SandID
//
//  Created by Kiana Fithian on 1/18/22.
//

import UIKit

class ViewController: UIViewController {
	
//	@IBOutlet var imageView: UIImageView!
	@IBOutlet var cameraButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
	}
	
	
	@IBAction func didTapButton() {
		print("inside didTapButton")
		let picker = UIImagePickerController()
		picker.sourceType = .camera
		picker.delegate = self
		present(picker, animated: true)
		print("at the end of didTapButton")
	}
	
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		
		//stub
	}
}

