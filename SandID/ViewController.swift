//
//  ViewController.swift
//  SandID
//
//  Created by Kiana Fithian on 1/18/22.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {

	@IBOutlet var openCameraButton: UIButton!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	// segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "OpenCameraSegue",
		   let cameraVC = segue.destination as? CameraViewController {
			cameraVC.delegate = self
		}
	}
	

}


