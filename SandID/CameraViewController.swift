//
//  CameraViewController.swift
//  SandID
//
//  Created by Kiana Fithian on 1/25/22.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
	
	var delegate: UIViewController!
	
	// capture session
	var session: AVCaptureSession?
	
	// photo output
	var output = AVCapturePhotoOutput()
	
	// preview
	let previewLayer = AVCaptureVideoPreviewLayer()
	
	// image view to hold captured image
	var imageView = UIImageView()
	
	// shutter button
	private let shutterButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		// make circular
		button.layer.cornerRadius = 50
		button.layer.borderWidth = 10
		button.layer.borderColor = UIColor.white.cgColor
		button.layer.shadowColor = UIColor.darkGray.cgColor
		button.layer.shadowOpacity = 1.0
		button.layer.shadowRadius = 50
		return button
	}()
	
	// button to retake photo
	private let retakeButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
		let buttonImage = UIImage(systemName: "xmark")
		let config = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .bold, scale: .large)
		button.setImage(buttonImage?.withConfiguration(config), for: .normal)
		button.tintColor = UIColor.white
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOpacity = 1.0
		button.layer.shadowRadius = 10
		return button
	}()
	
	// button to retake photo
	private let backButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
		let buttonImage = UIImage(systemName: "chevron.backward")
		let config = UIImage.SymbolConfiguration(pointSize: 20.0, weight: .bold, scale: .large)
		button.setImage(buttonImage?.withConfiguration(config), for: .normal)
		button.tintColor = UIColor.white
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOpacity = 1.0
		button.layer.shadowRadius = 10
		return button
	}()

    override func viewDidLoad() {
        super.viewDidLoad()

		// just incase
		view.backgroundColor = .black
		
		view.layer.addSublayer(previewLayer)
		view.addSubview(shutterButton)
		view.addSubview(backButton)
		
		checkCameraPermissions()
		shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
		retakeButton.addTarget(self, action: #selector(tapRetakePhoto), for: .touchUpInside)
		backButton.addTarget(self, action: #selector(onBackButton), for: .touchUpInside)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		previewLayer.frame = view.bounds
		
		// shutter button shape
		shutterButton.center = CGPoint(x: view.frame.size.width/2,
									   y: view.frame.size.height - 100)
		
		retakeButton.center = CGPoint(x: 50, y: 75)
		backButton.center = CGPoint(x: 50, y: 75)
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
	
	// remove image view and starts new capture session
	@objc private func tapRetakePhoto() {
		print("tapped retake photo button")
		retakeButton.removeFromSuperview()
		imageView.removeFromSuperview()
		view.addSubview(backButton)
		self.session?.startRunning()
	}
	
	@objc private func onBackButton() {
		print("tapped back button")
		self.dismiss(animated: true, completion: nil)
	}
	
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
	
	// photo display after capture
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		guard let data = photo.fileDataRepresentation() else {
			return
		}
		
		let image = UIImage(data: data)
		
		session?.stopRunning()
		
		imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFill
		imageView.frame = view.bounds
		backButton.removeFromSuperview()
		view.addSubview(imageView)
		view.addSubview(retakeButton)
	}
}
