//
//  PreviewImageVC.swift
//  CameraOverlay
//
//  Created by Manish's Mac on 17/06/21.
//

import UIKit

class PreviewImageVC: UIViewController {
    var imageData:Data!
    var overlayImage:UIImage?
    
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var overlayPreviewImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewImage.image = UIImage(data: imageData)
        overlayPreviewImage.isHidden = true
//        overlayPreviewImage.image = overlayImage ?? nil
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onBtnBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBtnSave(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(mainView.screenshot(), self, #selector(saveError), nil)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { isPress in
                self.dismiss(animated: true, completion: nil)
            }
            ac.addAction(action)
            present(ac, animated: true)
        }
    }
}
extension UIView {
    func screenshot() -> UIImage {
        
        if(self is UIScrollView) {
            let scrollView = self as! UIScrollView
            
            let savedContentOffset = scrollView.contentOffset
            let savedFrame = scrollView.frame
            
            UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, true, 0)
            scrollView.contentOffset = .zero
            self.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
            
            scrollView.contentOffset = savedContentOffset
            scrollView.frame = savedFrame
            
            return image!
        }
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
        
    }
}
