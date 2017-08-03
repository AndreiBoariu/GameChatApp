//
//  VXImportImageVC.swift
//  Vertx
//
//  Created by Boariu Andy on 9/1/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Photos

class VXImportImageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var btnChangeImage: UIButton!
    @IBOutlet weak var imgViewBackground: UIImageView!

    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    func displayCameraOptionsWithTitle(_ strTitle: String) {
        let alert = UIAlertController(title: strTitle,  message: "Pick either from your gallery or take a photo", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "From gallery", style: .default, handler: {
            _ in
            
            self.checkStatusOfPhotoLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "From camera", style: .default, handler: {
            _ in
            
            self.checkStatusOfCamera()
        }))
        
        self.present(alert, animated:true, completion:nil)
    }
    
    func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.delegate = self
            
            imagePicker.allowsEditing = false
            imagePicker.showsCameraControls = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            //=>    Display alert
            let alert = VertxUtils.okCustomAlert("Error", message:"No camera available.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func takePhotoFromLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.delegate = self
            
            imagePicker.allowsEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            //=>    Display alert
            let alert = VertxUtils.okCustomAlert("Error", message:"No photo library available.")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func checkStatusOfCamera() {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .authorized:
            self.takePhoto()
            break
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                if granted {
                    self.takePhoto()
                }
                else {
                    
                }
            })
            break
            
        case .restricted:
            break
            
        case .denied:
            let alert = UIAlertController(title: "Oops",  message: "We couldn't access your camera. You may need to enable Vertx to access your camera.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: {
                _ in
                
                let url = URL(string:UIApplicationOpenSettingsURLString)!
                UIApplication.shared.openURL(url)
                
            }))
            
            self.present(alert, animated:true, completion:nil)
            break
        }
    }
    
    func checkStatusOfPhotoLibrary() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status
        {
        case .authorized:
            self.takePhotoFromLibrary()
            break
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorisationStatus) -> Void in
                if authorisationStatus == .authorized {
                    self.takePhotoFromLibrary()
                }
                else {
                    
                }
            })
            break
            
        case .restricted:
            break
            
        case .denied:
            let alert = UIAlertController(title: "Oops",  message: "We couldn't access your photo library. You may need to enable Vertx to access your photo library.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: {
                _ in
                
                let url = URL(string:UIApplicationOpenSettingsURLString)!
                UIApplication.shared.openURL(url)
                
            }))
            
            self.present(alert, animated:true, completion:nil)
            break
        }
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else
            if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            btnChangeImage.layer.cornerRadius = btnChangeImage.height / 2
            btnChangeImage.imageView?.contentMode = .scaleAspectFill
            btnChangeImage.setImage(selectedImage, for: UIControlState())
            btnChangeImage.layer.masksToBounds = true
            
            imgViewBackground.image = selectedImage.addDarkEffect(7)
        }
        
        dismiss(animated: true) { 
            NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.NotificationKey.UpdateProfileImage), object: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Memory Cleanup

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
