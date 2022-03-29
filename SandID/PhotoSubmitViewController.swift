//
//  PhotoSubmitViewController.swift
//  SandID
//
//  Created by Kiana Fithian on 2/9/22.
//

import UIKit
import BoxSDK

class PhotoSubmitViewController: UIViewController {
	
	var capturedImage: UIImage!
	
	@IBOutlet var uploadButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	
	@IBAction func onUploadData(_ sender: Any) {
		print("touched upload button")
		uploadImage()
	}
	
	private func uploadImage() {
		let data2: Data = capturedImage.pngData()!
		
		let token = ProcessInfo.processInfo.environment["BOX_API_TOKEN"]!
		let client = BoxSDK.getClient(token: token)
		
		client.files.upload(data: data2, name: "Test File6.png", parentId: "0") { (result: Result<File, BoxSDKError>) in
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
