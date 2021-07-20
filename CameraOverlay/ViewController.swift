//
//  ViewController.swift
//  CameraOverlay
//
//  Created by Manish's Mac on 16/06/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController{
    // MARK: - Constants
    let cameraManager = CameraManager()
    var imagePickers = UIImagePickerController()
    @IBOutlet weak var clearOverlayButtonView: UIView!
    @IBOutlet var cameraView: UIView!
    @IBOutlet weak var imgPreviewImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCameraManager()
        
        let currentCameraState = cameraManager.currentCameraStatus()
        
        if currentCameraState == .notDetermined {
            askForCameraPermissions()
        } else if currentCameraState == .ready {
            addCameraToView()
        } else {
        }
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        cameraManager.resumeCaptureSession()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cameraManager.stopCaptureSession()
    }
    
    
    // MARK: - ViewController
    fileprivate func setupCameraManager() {
        cameraManager.shouldEnableExposure = true
        
        cameraManager.writeFilesToPhoneLibrary = false
        
        cameraManager.shouldFlipFrontCameraImage = false
        cameraManager.showAccessPermissionPopupAutomatically = true
        cameraManager.shouldKeepViewAtOrientationChanges = true
    }
    
    
    fileprivate func addCameraToView() {
        cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.stillImage)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (_) -> Void in }))
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func onBtnTackPhoto(_ sender: UIButton) {
        switch cameraManager.cameraOutputMode {
        case .stillImage:
            cameraManager.capturePictureWithCompletion { result in
                switch result {
                case .failure:
                    self.cameraManager.showErrorBlock("Error occurred", "Cannot save picture.")
                case .success(let content):
                    if let capturedData = content.asData {
                        let vc = self.storyboard!.instantiateViewController(withIdentifier: "PreviewImageVC") as! PreviewImageVC
                        vc.imageData = capturedData
                        vc.overlayImage = self.imgPreviewImage.image
                        self.present(vc, animated: true)
                    }
                    break
                }
            }
        case .videoWithMic, .videoOnly: break
        }
    }
    
    
    @IBAction func onBtnSelectImage(_ sender: UIButton) {
        self.imagePickers.delegate = self
        self.imagePickers.sourceType = .photoLibrary
//            self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        self.imagePickers.allowsEditing = false
        self.imagePickers.mediaTypes = ["public.image"]
        self.imagePickers.modalPresentationStyle = .fullScreen
        self.present(self.imagePickers, animated: true, completion: nil)
    }
    
    
    @IBAction func onBtnClearOverlay(_ sender: UIButton) {
        self.imgPreviewImage.image = nil
        clearOverlayButtonView.isHidden = true
    }
    
    @IBAction func onBtnFlash(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        cameraManager.flashMode = (sender.isSelected ? .on : .off)
    }
    
    @IBAction func askForCameraPermissions() {
        cameraManager.askUserForCameraPermission { permissionGranted in
            
            if permissionGranted {
                self.addCameraToView()
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}
extension ViewController:UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imgPreviewImage.image = chosenImage
            clearOverlayButtonView.isHidden = false
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
