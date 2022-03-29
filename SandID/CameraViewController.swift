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
	
	// captured image to pass onto next vc
	var capturedImage = UIImage()
	
	var cameraOverlayTop = UIView()
	var cameraOverlayBottom = UIView()
	
	var captureSquare = UIView()
	
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
		let config = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .semibold, scale: .large)
		button.setImage(buttonImage?.withConfiguration(config), for: .normal)
		button.tintColor = UIColor.white
		return button
	}()
	
	// button to proceed with photo
	private let submitButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
		button.setTitle("Continue", for: .normal)
		button.tintColor = UIColor.white
		button.layer.shadowColor = UIColor.black.cgColor
		button.layer.shadowOpacity = 1.0
		button.layer.shadowRadius = 10
		return button
	}()
	
	// info mark for photo specifications
	private let infoButton: UIButton = {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
		let buttonImage = UIImage(systemName: "info.circle")
		let config = UIImage.SymbolConfiguration(pointSize: 17.0, weight: .semibold, scale: .large)
		button.setImage(buttonImage?.withConfiguration(config), for: .normal)
		button.tintColor = UIColor.white
		return button
	}()
	
	// pop up window displaying photo specifications
	private let popUpWindow: PopUpWindow = {
		let windowText = "Hold the camera between 4 to 6 inches from sample\n\nMake sure sample fills center square"
		let window = PopUpWindow(title: "Instructions", text: windowText, buttontext: "OK")
		return window
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		
		createOverlays()
		createCaptureSquare()

		// just incase
		view.backgroundColor = .black
		
		view.layer.addSublayer(previewLayer)
		view.addSubview(captureSquare)
		view.addSubview(cameraOverlayTop)
		view.addSubview(cameraOverlayBottom)
		view.addSubview(shutterButton)
		view.addSubview(infoButton)
		
		checkCameraPermissions()
		
		shutterButton.addTarget(self, action: #selector(didTapTakePhoto), for: .touchUpInside)
		retakeButton.addTarget(self, action: #selector(tapRetakePhoto), for: .touchUpInside)
		submitButton.addTarget(self, action: #selector(onSubmitPhoto), for: .touchUpInside)
		infoButton.addTarget(self, action: #selector(tapInfoButton), for: .touchUpInside)
		
		self.present(popUpWindow, animated: true, completion: nil)
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		previewLayer.frame = view.bounds
		
		cameraOverlayTop.center = CGPoint(x: self.view.frame.width / 2, y: cameraOverlayTop.frame.height / 2)
		
		cameraOverlayBottom.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - (cameraOverlayTop.frame.height / 2))
		
		// shutter button shape
		shutterButton.center = CGPoint(x: view.frame.size.width / 2,
									   y: view.frame.size.height - 100)
		
		retakeButton.center = CGPoint(x: 50, y: 75)
		submitButton.center = CGPoint(x: self.view.frame.width - 75, y: 80)
		infoButton.center = CGPoint(x: view.bounds.minX + infoButton.frame.width, y: (cameraOverlayTop.frame.height / 4) * 3)
	}
	
	private func createOverlays() {
		let overlayHeight = (self.view.frame.height - self.view.frame.width) / 2
		cameraOverlayTop = {
			let overlay = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: overlayHeight))
			overlay.layer.opacity = 0.5
			overlay.backgroundColor = .black
			return overlay
		}()
		
		cameraOverlayBottom = {
			let overlay = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: overlayHeight))
			overlay.layer.opacity = 0.5
			overlay.backgroundColor = .black
			return overlay
		}()
	}
	
	private func createCaptureSquare() {
		let overlayHeight = (self.view.frame.height - self.view.frame.width) / 2
		let squareWidth = self.view.frame.width
		captureSquare = {
			let capSquare = UIView(frame: CGRect(x: 0, y: overlayHeight, width: squareWidth, height: squareWidth))
			capSquare.layer.borderWidth = 5.0
			capSquare.layer.borderColor = CGColor.init(red: 0, green: 0, blue: 255, alpha: 1)
			return capSquare
		}()
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
		if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
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
	
	// display info for photo specifications
	@objc private func tapInfoButton() {
		self.present(popUpWindow, animated: true, completion: nil)
	}
	
	// capture photo
	@objc private func didTapTakePhoto() {
		output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
	}
	
	// remove image view and starts new capture session
	@objc private func tapRetakePhoto() {
		print("tapped retake photo button")
		imageView.removeFromSuperview()
		view.addSubview(captureSquare)
		view.addSubview(shutterButton)
		view.addSubview(infoButton)
		self.navigationItem.setHidesBackButton(false, animated: false)
		cameraOverlayTop.layer.opacity = 0.5
		cameraOverlayBottom.layer.opacity = 0.5
		self.session?.startRunning()
	}
	
	// proceed with captured photo
	@objc private func onSubmitPhoto() {
		print("want to submit photo")
		if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhotoSubmitVC") as? PhotoSubmitViewController {
			print("got vc")
			vc.capturedImage = capturedImage
			if let navigator = self.navigationController {
				print("got nav")
				navigator.pushViewController(vc, animated: true)
			}
		}
	}
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
	
	// photo display after capture
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		guard let data = photo.fileDataRepresentation() else {
			// something went wrong when capturing photo
			return
		}
		
		session?.stopRunning()

		let sourceImage = UIImage(data: data)
		capturedImage = sourceImage!
		
		shutterButton.removeFromSuperview()
		infoButton.removeFromSuperview()
		captureSquare.removeFromSuperview()
		
		let continueButton = UIBarButtonItem(customView: submitButton)
		self.navigationItem.setRightBarButton(continueButton, animated: true)
		
		let retake = UIBarButtonItem(customView: retakeButton)
		self.navigationItem.leftItemsSupplementBackButton = true
		self.navigationItem.setLeftBarButtonItems([retake], animated: true)
		self.navigationItem.setHidesBackButton(true, animated: false)
		
		cameraOverlayTop.layer.opacity = 1.0
		cameraOverlayBottom.layer.opacity = 1.0
	}
}
