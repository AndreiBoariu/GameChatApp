//
//  VXAddEditFeedVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/20/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Photos
import WYPopoverController
import Firebase
import KVNProgress
import Async
import Kingfisher

class VXAddEditFeedVC: VXBaseVC, WYPopoverControllerDelegate, PopoverWithTableViewVCDelegate {

    @IBOutlet weak var lblTopTitle: UILabel!
    @IBOutlet weak var btnCreateNewFeed: UIButton!
    @IBOutlet weak var btnFeedType: UIButton!
    @IBOutlet weak var btnFeedPlatform: UIButton!
    @IBOutlet weak var txfFeedName: UITextField!
    @IBOutlet weak var txvDescription: UITextView!
    @IBOutlet weak var btnDeleteFeed: UIButton!
    @IBOutlet weak fileprivate var scrollView: TPKeyboardAvoidingScrollView!
    
    var customPopover = WYPopoverController()
    
    var curFeed : Feed?
    var curFeedImage : UIImage?
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //=>    Setup UI
        setupUI()
        
        //=>    Load feed info if is edit selected
        if let currentFeed = curFeed {
            loadFeedDetails(currentFeed)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //=>    Update scroll content size
        let height = btnCreateNewFeed.y + btnCreateNewFeed.height + 15 // padding bottom
        scrollView.contentSize = CGSize(width: view.width, height: height)
    }
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func loadFeedDetails(_ currentFeed: Feed) {
        txfFeedName.text = currentFeed.name
        btnFeedType.setTitle(currentFeed.type, for: UIControlState())
        btnFeedPlatform.setTitle(currentFeed.platform, for: UIControlState())
        txvDescription.text = currentFeed.about
        
        //=>    Call with delay to update ui correctly
        Async.background(after: 0.2) {
            if let strFeedImageURL = currentFeed.imgURL, let urlFeedImage = URL(string: strFeedImageURL) {
                self.btnChangeImage.kf_setImageWithURL(urlFeedImage,
                                                       forState: UIControlState(),
                                                       placeholderImage: UIImage(named: "no_profile"),
                                                       optionsInfo: [.transition(ImageTransition.fade(1))]) { (image, error, cacheType, imageURL) in
                                                        
                    self.btnChangeImage.layer.cornerRadius = self.btnChangeImage.height / 2
                    self.btnChangeImage.imageView?.contentMode = .scaleAspectFill
                    self.btnChangeImage.layer.masksToBounds = true
                    
                    if let imgFeed = image {
                        self.imgViewBackground.image = imgFeed.addDarkEffect(7)
                        
                        //=>    Retain current image, to check if was changed while editing
                        self.curFeedImage = imgFeed
                    }
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
        if let _ = curFeed {
            lblTopTitle.text = "Edit Feed"
            btnCreateNewFeed.setTitle("UPDATE FEED", for: UIControlState())
            
            btnDeleteFeed.isHidden = false
        }
        else {
            btnDeleteFeed.isHidden = true
        }
        
        btnCreateNewFeed.layer.cornerRadius = 25.0
        
        txvDescription.layer.borderColor    = UIColor.vertxDarkOrange().cgColor
        txvDescription.layer.borderWidth    = 1.0
        
        customPopover.theme = WYPopoverTheme.forIOS7()
        let popoverAppearance = WYPopoverBackgroundView.appearance()
        popoverAppearance.fillTopColor = UIColor.vertxDarkOrange()
        popoverAppearance.fillBottomColor = UIColor.vertxDarkOrange()
    }
    
    // MARK: - API Methods
    
    func addNewFeed_APICall() {
        //=>    Dismiss Keyboard
        view.endEditing(true)
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //=>    Check fields
        if let strFeedName = txfFeedName.text, !strFeedName.isEmpty {
            if let strFeedType = btnFeedType.currentTitle, !strFeedType.isEmpty {
                if let strFeedPlatform = btnFeedPlatform.currentTitle, !strFeedPlatform.isEmpty {
                    if let strFeedDescription = txvDescription.text, !strFeedDescription.isEmpty {
                        //=>    Check if user sets feed image
                        if let imgActualFeed = self.btnChangeImage.currentImage, !imgActualFeed.isEqual(UIImage(named: "add_photo")) {
                            
                            KVNProgress.show()
                            
                            //=>    Convert image to .jpg
                            if let uploadData = UIImageJPEGRepresentation(imgActualFeed, 0.1) {
                                
                                let imageName = UUID().uuidString
                                let storageRef = FIRStorage.storage().reference().child(Constants.FeedKeys.feedImages).child("\(imageName).jpg")
                                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                                    
                                    if error != nil {
                                        
                                        KVNProgress.dismiss()
                                        
                                        Async.main(block: {
                                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while uploading feed image! Please try again! \n\n \(error?.localizedDescription)")
                                            self.present(alert, animated: true, completion: nil)
                                        })
                                        
                                        return
                                    }
                                    
                                    if let imgFeedURL = metadata?.downloadURL()?.absoluteString {
                                        var values = [Constants.FeedKeys.feedName : strFeedName,
                                            Constants.FeedKeys.feedType: strFeedType,
                                            Constants.FeedKeys.feedImageURL: imgFeedURL,
                                            Constants.FeedKeys.feedPlatform: strFeedPlatform,
                                            Constants.FeedKeys.feedDescription : strFeedDescription]
                                        
                                        if let strCreatedDate = VertxUtils.getStringDateFromDate(Date()) {
                                            values[Constants.FeedKeys.feedCreatedDate] = strCreatedDate
                                        }
                                        
                                        self.registerNewFeedIntoDatabaseForUserID(uid, values: values as [String : AnyObject])
                                    }
                                })
                            }
                        }
                        else {
                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Please select feed photo")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else {
                        let alert = VertxUtils.okCustomAlert("Oops!", message: "Feed description must not be blank")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Choose feed platform")
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                let alert = VertxUtils.okCustomAlert("Oops!", message: "Choose feed type")
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Feed name must not be blank")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func registerNewFeedIntoDatabaseForUserID(_ userID: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let feedReference = ref.child("\(Constants.UserKeys.users)/\(userID)/\(Constants.UserKeys.userFeeds)").childByAutoId()
        
        feedReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                
                KVNProgress.dismiss()
                
                Async.main(block: {
                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while creating new feed! Please try again! \n\n \(error?.localizedDescription)")
                    self.present(alert, animated: true, completion: nil)
                })
                
                return
            }
            
            KVNProgress.showSuccess(withStatus: "Feed created successfully!", completion: {
                self.navigationController?.popFadeViewController()
            })
        })
    }
    
    fileprivate func editFeed_APICall() {
        //=>    Dismiss Keyboard
        view.endEditing(true)
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard let currentFeed = curFeed else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong with selected feed. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        //=>    Check fields
        if let strFeedName = txfFeedName.text, !strFeedName.isEmpty {
            if let strFeedType = btnFeedType.currentTitle, !strFeedType.isEmpty {
                if let strFeedPlatform = btnFeedPlatform.currentTitle, !strFeedPlatform.isEmpty {
                    if let strFeedDescription = txvDescription.text, !strFeedDescription.isEmpty {
                        //=>    Check if user sets feed image
                        if let imgActualFeed = self.btnChangeImage.currentImage, !imgActualFeed.isEqual(UIImage(named: "add_photo")) {
                            
                            KVNProgress.show()
                            
                            //=>    Check if user changed feed image
                            if let oldImage = curFeedImage, !imgActualFeed.isEqual(oldImage) {
                                
                                //=>    Convert image to .jpg
                                if let uploadData = UIImageJPEGRepresentation(imgActualFeed, 0.1) {
                                    
                                    if let strFeedImgURL = currentFeed.imgURL {
                                        //=>    Get reference for cur feed image, then delete
                                        let refFeedImage = FIRStorage.storage().reference(forURL: strFeedImgURL)
                                        refFeedImage.delete(completion: { (error) in
                                            if let error = error {
                                                
                                                KVNProgress.dismiss()
                                                
                                                Async.main(block: {
                                                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something wrong happened while update feed image! Please try again! \n\n \(error.localizedDescription)")
                                                    self.present(alert, animated: true, completion: nil)
                                                })
                                                
                                                return
                                            }
                                            
                                            //=>    Add new image for curent image
                                            let imageName = UUID().uuidString
                                            let storageRef = FIRStorage.storage().reference().child(Constants.FeedKeys.feedImages).child("\(imageName).jpg")
                                            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                                                
                                                if error != nil {
                                                    
                                                    KVNProgress.dismiss()
                                                    
                                                    Async.main(block: {
                                                        let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while uploading feed image! Please try again! \n\n \(error?.localizedDescription)")
                                                        self.present(alert, animated: true, completion: nil)
                                                    })
                                                    
                                                    return
                                                }
                                                
                                                if let imgFeedURL = metadata?.downloadURL()?.absoluteString {
                                                    let values = [Constants.FeedKeys.feedName : strFeedName,
                                                        Constants.FeedKeys.feedType: strFeedType,
                                                        Constants.FeedKeys.feedImageURL: imgFeedURL,
                                                        Constants.FeedKeys.feedPlatform: strFeedPlatform,
                                                        Constants.FeedKeys.feedDescription : strFeedDescription]
                                                    
                                                    self.updateFeedIntoDatabaseForUserID(currentFeed.id, userID: uid, values: values as [String : AnyObject])
                                                }
                                            })
                                        })
                                    }
                                    else {
                                        KVNProgress.dismiss()
                                    }
                                }
                                else {
                                    KVNProgress.dismiss()
                                    
                                    Async.main(block: {
                                        let alert = VertxUtils.okCustomAlert("Oops!", message: "Something wrong happened while transform feed image format! Please try again!")
                                        self.present(alert, animated: true, completion: nil)
                                    })
                                    
                                    return
                                }
                            }
                            else {
                                let values = [Constants.FeedKeys.feedName : strFeedName,
                                              Constants.FeedKeys.feedType: strFeedType,
                                              Constants.FeedKeys.feedPlatform: strFeedPlatform,
                                              Constants.FeedKeys.feedDescription : strFeedDescription]
                                
                                self.updateFeedIntoDatabaseForUserID(currentFeed.id, userID: uid, values: values as [String : AnyObject])
                            }
                        }
                        else {
                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Please select feed photo")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else {
                        let alert = VertxUtils.okCustomAlert("Oops!", message: "Feed description must not be blank")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Choose feed platform")
                    self.present(alert, animated: true, completion: nil)
                }
            }
            else {
                let alert = VertxUtils.okCustomAlert("Oops!", message: "Choose feed type")
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Feed name must not be blank")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func updateFeedIntoDatabaseForUserID(_ feedID: String, userID: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let feedReference = ref.child("\(Constants.UserKeys.users)/\(userID)/\(Constants.UserKeys.userFeeds)/\(feedID)")
        
        feedReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                
                KVNProgress.dismiss()
                
                Async.main(block: {
                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while editing feed! Please try again! \n\n \(error?.localizedDescription)")
                    self.present(alert, animated: true, completion: nil)
                })
                
                return
            }
            
            KVNProgress.showSuccess(withStatus: "Feed updated successfully!", completion: {
                self.navigationController?.popFadeViewController()
            })
        })
    }
    
    // MARK: - Action Methods
    @IBAction func btnBack_Action() {
        navigationController?.popFadeViewController()
    }
    
    @IBAction func btnCreateNewFeed_Action() {
        //=>    Call API
        if let _ = curFeed {
            editFeed_APICall()
        }
        else {
            addNewFeed_APICall()
        }
    }
    
    @IBAction func btnFeedType_Action(_ sender: UIButton) {
        displayPopoverWithTableView_MenuOptions(sender, arrData: Constants.FeedKeys.arrFeedTypes)
    }
    
    @IBAction func btnFeedPlatform_Action(_ sender: UIButton) {
        displayPopoverWithTableView_MenuOptions(sender, arrData: Constants.arrPlatforms)
    }
    
    @IBAction func btnAddFeedImage_Action() {
        view.endEditing(true)
        
        displayCameraOptionsWithTitle("Feed Image")
    }
    
    @IBAction func btnDeleteFeed_Action() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard let currentFeed = curFeed else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong with selected feed. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        //=>    Present confirmation popup
        let alert = UIAlertController(title: "Are you sure?",  message: "This feed will be pemanently deleted!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            
        }))
        alert.addAction(UIAlertAction(title: "Yes, Delete", style: .destructive, handler: { _ in
            if let strFeedImgURL = currentFeed.imgURL {
                
                KVNProgress.show()
                
                //=>    Get reference for cur feed image, then delete
                let refFeedImage = FIRStorage.storage().reference(forURL: strFeedImgURL)
                refFeedImage.delete(completion: { (error) in
                    if let error = error {
                        
                        KVNProgress.dismiss()
                        
                        Async.main(block: {
                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something wrong happened while delete feed image! Please try again! \n\n \(error.localizedDescription)")
                            self.present(alert, animated: true, completion: nil)
                        })
                        
                        return
                    }
                    
                    //=>    Get reference for feed, and remove it
                    let ref = FIRDatabase.database().reference()
                    let feedReference = ref.child("\(Constants.UserKeys.users)/\(uid)/\(Constants.UserKeys.userFeeds)/\(currentFeed.id)")
                    feedReference.removeValue(completionBlock: { (error, reference) in
                        if let error = error {
                            
                            KVNProgress.dismiss()
                            
                            Async.main(block: {
                                let alert = VertxUtils.okCustomAlert("Oops!", message: "Something wrong happened while delete feed! Please try again! \n\n \(error.localizedDescription)")
                                self.present(alert, animated: true, completion: nil)
                            })
                            
                            return
                        }
                        
                        KVNProgress.showSuccess(withStatus: "Feed deleted successfully!", completion: {
                            //=>    Check if VC exists on stack, and pop to MMHomeVC
                            var bViewExistsInStack = false
                            if let arrVCs = self.navigationController?.viewControllers {
                                for vc in arrVCs {
                                    if let feedsVC = vc as? VXFeedsVC {
                                        self.navigationController?.popFade(toViewController: feedsVC)
                                        
                                        bViewExistsInStack = true
                                        
                                        break
                                    }
                                }
                            }
                            
                            //=>    Else, pop to root
                            if bViewExistsInStack == false {
                                self.navigationController?.popToRootViewController(animated: false)
                            }
                        })
                    })
                })
            }
        }))
        
        self.present(alert, animated:true, completion:nil)
    }
    
    // MARK: - PopoverWithTableViewVCDelegate Methods
    func popoverWithTableViewVC_userDidSelectObject(_ obj: String) {
        if customPopover.isPopoverVisible {
            //=>    Dismiss popover
            customPopover.dismissPopover(animated: true)
            customPopover.delegate = nil
        }
        
        //=>    Check which button was pressed
        if Constants.FeedKeys.arrFeedTypes.contains(obj) {
            //=>    Feed Type option selected
            btnFeedType.setTitle(obj, for: UIControlState())
        }
        else {
            //=>    Feed Platform option selected
            btnFeedPlatform.setTitle(obj, for: UIControlState())
        }
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
        if textField == txfFeedName {
            displayPopoverWithTableView_MenuOptions(btnFeedType, arrData: Constants.FeedKeys.arrFeedTypes)
        }
        
        return true
    }
    
    // MARK: - UITextViewDelegate Methods

    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //=>    If user taps on DONE, that means new line. Lets call API
        if text == "\n" {
            //=>    Call API
            if let _ = curFeed {
                editFeed_APICall()
            }
            else {
                addNewFeed_APICall()
            }
            
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
        debugPrint("ADD EDIT FEED DEINIT")
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
