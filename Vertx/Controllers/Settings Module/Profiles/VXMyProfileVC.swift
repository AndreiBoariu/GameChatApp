//
//  VXMyProfileVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/20/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import WYPopoverController
import Async
import SDVersion
import Kingfisher

class VXMyProfileVC: VXBaseVC, WYPopoverControllerDelegate, PopoverWithTableViewVCDelegate, UITextViewDelegate {
    
    @IBOutlet weak fileprivate var lblUserName: UILabel!
    @IBOutlet weak fileprivate var btnPlatformOfChoice: UIButton!
    @IBOutlet weak fileprivate var txfXboxLive: UITextField!
    @IBOutlet weak fileprivate var txfPSN: UITextField!
    @IBOutlet weak fileprivate var txfNinetendo: UITextField!
    @IBOutlet weak fileprivate var txfPc: UITextField!
    @IBOutlet weak fileprivate var txfGameOfChoice: UITextField!
    @IBOutlet weak fileprivate var txfCurrentlyInPlay: UITextField!
    @IBOutlet weak fileprivate var txvAbout: UITextView!
    @IBOutlet weak fileprivate var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak fileprivate var viewInputFields : UIView!
    
    var customPopover = WYPopoverController()

    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        //=>    Get user info
        Async.main(after: 0.3) { 
            self.fillUserInfo()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(VXMyProfileVC.updateProfileImage(_:)), name: NSNotification.Name(rawValue: Constants.NotificationKey.UpdateProfileImage), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //=>    Update scroll content size
        let height = viewInputFields.y + txvAbout.y + txvAbout.height + 15 // padding bottom
        scrollView.contentSize = CGSize(width: view.width, height: height)
    }
    
    // MARK: - Notification Methods
    
    @objc fileprivate func updateProfileImage(_ notification: Notification) {
        uploadProfileImage()
    }
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func fillUserInfo() {
        //=>    Fill current user info
        if let curUser = appDelegate.curUser,
            let strName = curUser.name,
            let strAge = curUser.age {
            
            self.lblUserName.text = "\(strName), \(strAge)"
            
            self.btnPlatformOfChoice.setTitle(curUser.platform, for: UIControlState())
            self.txfPSN.text = curUser.psn
            self.txfXboxLive.text = curUser.xboxLive
            self.txfNinetendo.text = curUser.nintendo
            self.txfPc.text = curUser.pc
            self.txfGameOfChoice.text = curUser.gameOfChoice
            self.txfCurrentlyInPlay.text = curUser.currentlyInPlay
            
            if let strAbout = curUser.about {
                if strAbout == "" {
                    self.txvAbout.text = "About"
                }
                else {
                    self.txvAbout.text = strAbout
                }
            }
            else {
                self.txvAbout.text = "About"
            }
            
            //=>    Load image url
            if let strProfileImage = curUser.profileURL, let urlProfileImage = URL(string: strProfileImage) {
                self.btnChangeImage.kf.setImage(with: urlProfileImage,
                                                for: .normal,
                                                placeholder: UIImage(named: "no_profile"),
                                                options: [.transition(ImageTransition.fade(1))]) { (image, error, cacheType, imageURL) in
                                                    
                                                    self.btnChangeImage.imageView?.contentMode = .scaleAspectFill
                                                    
                                                    if let imgProfile = image {
                                                        self.btnChangeImage.setImage(imgProfile.circle, for: UIControlState())
                                                        self.imgViewBackground.image = imgProfile.addDarkEffect(7)
                                                    }
                }
            }
            else {
                Async.main {
                    self.btnChangeImage.setImage(UIImage(named: "no_profile"), for: UIControlState())
                }
            }
        }
    }
    
    func displayPopoverWithTableView_MenuOptions(_ sender: UIButton, arrData: [String]) {
        
        //=>    Hide keyboard if is visible
        view.endEditing(true)
        
        if customPopover.isPopoverVisible {
            //=>    Dismiss popover
            customPopover.dismissPopover(animated: true)
            customPopover.delegate = nil
            
            return
        }
        
        let popoverWithTableView       = self.storyboard?.instantiateViewController(withIdentifier: "PopoverWithTableViewVC") as? PopoverWithTableViewVC
        popoverWithTableView?.delegate = self
        popoverWithTableView?.preferredContentSize = CGSize(width: 200, height: 146)
        popoverWithTableView?.arrData  = arrData
        
        customPopover = WYPopoverController(contentViewController: popoverWithTableView)
        customPopover.delegate = self
        customPopover.passthroughViews = [sender]
        customPopover.popoverLayoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
        customPopover.wantsDefaultContentAppearance = false
        customPopover.presentPopover(from: sender.bounds, in: sender, permittedArrowDirections: WYPopoverArrowDirection(rawValue: 1|2), animated: true)
    }
    
    fileprivate func setupUI() {
        txvAbout.layer.cornerRadius   = 5.0
        txvAbout.layer.borderColor    = UIColor.vertxDarkOrange().cgColor
        txvAbout.layer.borderWidth    = 1.0
        
        customPopover.theme = WYPopoverTheme.forIOS7()
        let popoverAppearance = WYPopoverBackgroundView.appearance()
        popoverAppearance.fillTopColor = UIColor.vertxDarkOrange()
        popoverAppearance.fillBottomColor = UIColor.vertxDarkOrange()
    }
    
    /// Check which fields contains text, add them in dictionary, then call API
    fileprivate func checkFields() {
        view.endEditing(true)
        
        var dictParams = [String: String]()
        
        if let strPlatformOfChoice = btnPlatformOfChoice.currentTitle {
            dictParams[Constants.UserKeys.userPlatformOfChoice] = strPlatformOfChoice
        }
        
        if let strPSN = txfPSN.text {
            dictParams[Constants.UserKeys.userPSN] = strPSN
        }
        
        if let strXboxLive = txfXboxLive.text {
            dictParams[Constants.UserKeys.userXboxLive] = strXboxLive
        }
        
        if let strNintendo = txfNinetendo.text {
            dictParams[Constants.UserKeys.userNintendo] = strNintendo
        }
        
        if let strPC = txfPc.text {
            dictParams[Constants.UserKeys.userPc] = strPC
        }
        
        if let strGameOfChoice = txfGameOfChoice.text {
            dictParams[Constants.UserKeys.userGameOfChoice] = strGameOfChoice
        }
        
        if let strCurPlayIn = txfCurrentlyInPlay.text {
            dictParams[Constants.UserKeys.userCurrentlyInPlay] = strCurPlayIn
        }
        
        if let strAbout = txvAbout.text {
            if strAbout != "About" {
                dictParams[Constants.UserKeys.userAbout] = strAbout
            }
            else {
                dictParams[Constants.UserKeys.userAbout] = ""
            }
        }
        
        //=>    Call API just if we have at least one key
        if dictParams.keys.count > 0 {
            updateUserInfo(dictParams)
        }
    }

    // MARK: - API Methods
    
    fileprivate func updateUserInfo(_ dictInfo: [String: String]) {
        
        //=>    Make sure we have current user logged in
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        KVNProgress.show()
        
        FIRDatabase.database().reference().child(Constants.UserKeys.users).child(uid).updateChildValues(dictInfo) { (error, reference) in
            if error != nil {
                
                KVNProgress.dismiss()
                
                Async.main {
                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while editing profile! Please try again! \n\n \(error?.localizedDescription)")
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            KVNProgress.showSuccess(withStatus: "Profile updated successfully!", completion: {
                
            })
        }
    }
    
    fileprivate func uploadProfileImage() {
        
        guard let curUser = appDelegate.curUser else {
            return
        }
        
        //=>    Check if user sets profile image
        if let imgActualProfile = btnChangeImage.currentImage, !imgActualProfile.isEqual(UIImage(named: "add_photo")) {
            
            KVNProgress.show(0.0, status: "", on: btnChangeImage)
            
                //=>    Convert image to .jpg
                if let uploadData = UIImageJPEGRepresentation(imgActualProfile, 0.1) {
                    
                    if let strUserImgURL = curUser.profileURL {
                        //=>    Get reference for cur profile image, then delete
                        FIRStorage.storage().reference(forURL: strUserImgURL).delete(completion: { (error) in
                            if let error = error {
                                
                                KVNProgress.dismiss()
                                
                                Async.main {
                                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something wrong happened while update profile image! Please try again! \n\n \(error.localizedDescription)")
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                                return
                            }
                            
                            self.uploadProfileImageWithData(uploadData, forUserWithID: curUser.id)
                        })
                    }
                    else {
                        self.uploadProfileImageWithData(uploadData, forUserWithID: curUser.id)
                    }
                }
                else {
                    KVNProgress.dismiss()
                    
                    Async.main {
                        let alert = VertxUtils.okCustomAlert("Oops!", message: "Something wrong happened while transform userprofile image format! Please try again!")
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    return
                }
        }
        else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Please select profile image")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func uploadProfileImageWithData(_ dataUpload: Data, forUserWithID strUserID: String) {
        //=>    Add new image
        let imageName = UUID().uuidString
        let uploadTask = FIRStorage.storage().reference().child(Constants.UserKeys.userImages).child("\(imageName).jpg")
            .put(dataUpload, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                
                KVNProgress.dismiss()
                
                Async.main {
                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while uploading feed image! Please try again! \n\n \(error?.localizedDescription)")
                    self.present(alert, animated: true, completion: nil)
                }
            
                return
            }
            
            //=>    Update
            if let imgProfileURL = metadata?.downloadURL()?.absoluteString {
                let dictInfo = [Constants.UserKeys.userProfileURL: imgProfileURL]
                
                FIRDatabase.database().reference().child(Constants.UserKeys.users).child(strUserID).updateChildValues(dictInfo) { (error, reference) in
                    if error != nil {
                        Async.main {
                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while editing profile! Please try again! \n\n \(error?.localizedDescription)")
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        return
                    }
                }
            }
        })
        
        uploadTask.observe(.progress, handler: { (snapshot) in
            if let progress = snapshot.progress {
                let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                Async.main {
                    KVNProgress.update(CGFloat(percentComplete), animated: false)
                }
            }
        })
        uploadTask.observe(.success, handler: { (snapshot) in
            Async.main {
                KVNProgress.showSuccess(completion: {
                    uploadTask.removeAllObservers()
                })
            }
        })
        uploadTask.observe(.failure, handler: { (snapshot) in
            
            KVNProgress.dismiss()
            
            guard let storageError = snapshot.error else {
                return
            }
            
            Async.main {
                let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while editing profile! Please try again! \n\n \(storageError.localizedDescription)")
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    // MARK: - Action Methods
    
    @IBAction func myFeeds_Action(_ sender: AnyObject) {
        let feedVC = storyboard?.instantiateViewController(withIdentifier: "VXFeedsVC") as! VXFeedsVC
        feedVC.feedOptionScreen = .myFeeds
        navigationController?.pushFadeViewController(feedVC)
    }
    
    @IBAction func myMessages_Action(_ sender: AnyObject) {
        if let messagesVC = storyboard?.instantiateViewController(withIdentifier: "VXMyMessagesVC") as? VXMyMessagesVC {
            navigationController?.pushFadeViewController(messagesVC)
        }
    }
    
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        navigationController?.popFadeViewController()
    }
    
    @IBAction func btnSaveChanges_Action(_ sender: AnyObject) {
        checkFields()
    }
    
    @IBAction func btnChoosePlatform_Action(_ sender: UIButton) {
        displayPopoverWithTableView_MenuOptions(sender, arrData: Constants.arrPlatforms)
    }
    
    @IBAction func btnEditProfileImage_Action() {
        displayCameraOptionsWithTitle("Profile Image")
    }
    
    // MARK: - PopoverWithTableViewVCDelegate Methods
    func popoverWithTableViewVC_userDidSelectObject(_ obj: String) {
        if customPopover.isPopoverVisible {
            //=>    Dismiss popover
            customPopover.dismissPopover(animated: true)
            customPopover.delegate = nil
        }
        
        btnPlatformOfChoice.setTitle(obj, for: UIControlState())
    }
    
    // MARK: - WYPopoverControllerDelegate Methods
    func popoverControllerShouldDismissPopover(_ popoverController: WYPopoverController!) -> Bool {
        return true
    }
    
    func popoverControllerDidDismissPopover(_ popoverController: WYPopoverController!) {
        if popoverController == customPopover {
            customPopover.delegate = nil
        }
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfPSN {
            txfXboxLive.becomeFirstResponder()
        }
        else
            if textField == txfXboxLive {
                txfPc.becomeFirstResponder()
            }
            else
                if textField == txfPc {
                    txfNinetendo.becomeFirstResponder()
                }
                else
                    if textField == txfNinetendo {
                        txfGameOfChoice.becomeFirstResponder()
                    }
                    else
                        if textField == txfGameOfChoice {
                            txfCurrentlyInPlay.becomeFirstResponder()
                        }
                        else
                            if textField == txfCurrentlyInPlay {
                                txvAbout.becomeFirstResponder()
                                
                                return false
                            }
        
        return true
    }
    
    // MARK: - UITextViewDelegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let text = textView.text, text == "About" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text, text == "" {
            textView.text = "About"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //=>    If user taps on DONE, that means new line. Lets call API
        if text == "\n" {
            //=>    Check which fields are filled with text
            checkFields()
            
            return false
        }
        
        return true
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("MY PROFILE DEINIT")
        
        NotificationCenter.default.removeObserver(self)
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
