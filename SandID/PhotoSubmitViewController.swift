//
//  PhotoSubmitViewController.swift
//  SandID
//
//  Created by Kiana Fithian on 2/9/22.
//

import UIKit
import BoxSDK

class PhotoSubmitViewController: UIViewController {
	
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
		let data: Data = "test content".data(using: .utf8) ?? Data(base64Encoded: "error")!
		
		let client = BoxSDK.getClient(token: "wojV7ByCxsIvkVvs8X8xT7IVDfFcutlw")

		let task: BoxUploadTask = client.files.upload(data: data, name: "Test File.txt", parentId: "0") { (result: Result<File, BoxSDKError>) in
			guard case let .success(file) = result else {
				print("Error uploading file")
				return
			}

			
			print("File \(String(describing: file.name)) was uploaded at \(file.createdAt) into \"\(file.parent?.name)\"")
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
