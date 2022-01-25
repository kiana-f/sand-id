//
//  ViewController.swift
//  SandID
//
//  Created by Kiana Fithian on 1/18/22.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
	
	// capture session
	var session: AVCaptureSession?
	
	// photo output
	var output = AVCapturePhotoOutput()
	
	// preview
	let previewLayer = AVCaptureVideoPreviewLayer()
	
	// shutter button
	private let shutterButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		// make circular
		button.layer.cornerRadius = 50
		button.layer.borderWidth = 10
		button.layer.borderColor = UIColor.white.cgColor
		return button
	}()


	override func viewDidLoad() {
		super.viewDidLoad()
		
		// just incase
		view.backgroundColor = .black
		
		// add preview layer
		view.layer.addSublayer(previewLayer)
		
		// add shutter button to screen
		view.addSubview(shutterButton)
		
		checkCameraPermissions()
		shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		previewLayer.frame = view.bounds
		
		// button shape
		shutterButton.center = CGPoint(x: view.frame.size.width/2,
									   y: view.frame.size.height - 100)
	}
	
	// camera permissions
	private func checkCameraPermissions() {
		switch AVCaptureDevice.authorizationStatus(for: .video) {
			
		case .notDetermined:
			// request permission
			print("Requesting permission")
			AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
				guard granted else {
					return
				}
				
				DispatchQueue.main.async {
					self.setUpCamera()
				}
			})
		case .restricted:
			break
			// probably throw error?
		case .denied:
			break
			// probably throw error?
		case .authorized:
			print("Authorized")
			setUpCamera()
		@unknown default:
			break
		}
		
	}
	
	// camera input and output from device
	private func setUpCamera() {
		let session = AVCaptureSession()
		if let device = AVCaptureDevice.default(for: .video) {
			do {
				let input = try AVCaptureDeviceInput(device: device)
				if session.canAddInput(input) {
					session.addInput(input)
				}
				
				if session.canAddOutput(output) {
					session.addOutput(output)
				}
				
				previewLayer.videoGravity = .resizeAspectFill
				previewLayer.session = session
				
				session.startRunning()
				self.session = session
			} catch {
				print("ERROR")
				print(error)
			}
		}
	}
	
	// capture photo
	@objc private func didTapTakePhoto() {
		output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
	}
	
}

extension ViewController: AVCapturePhotoCaptureDelegate {
	
	// photo display after capture
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		guard let data = photo.fileDataRepresentation() else {
			return
		}
		
		let image = UIImage(data: data)
		
		session?.stopRunning()
		
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFill
		imageView.frame = view.bounds
		view.addSubview(imageView)
	}
}

