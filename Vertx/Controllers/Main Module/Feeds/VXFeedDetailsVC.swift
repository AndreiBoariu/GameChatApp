//
//  VXFeedDetailsVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/24/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import Async
import KVNProgress
import Kingfisher

let k_NewMessage_Placeholder        = "Write your message..."

class VXFeedDetailsVC: VXBaseVC, VXMessageCellDelegate {
    
    var headerView: UIView!
    
    @IBOutlet weak var tblMessages: UITableView!
    @IBOutlet weak var imgFeedImage: UIImageView!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var lblFeedName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblFeedDate: UILabel!
    @IBOutlet weak var lblFeedDescription: UILabel!
    @IBOutlet weak var viewFeedHeader: UIView!
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var btnEditFeed: UIButton!
    @IBOutlet weak var consViewNewMessageBottom: NSLayoutConstraint!
    @IBOutlet weak var txvNewMessage: VerticallyCenteredTextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var curFeed : Feed?
    var arrFeedMessages = [Message]()
    
    fileprivate var bIsFeedAddedToFavorites = false
    
    /// Store each reference for removeObserver call
    fileprivate var arrFirebaseReferences = [FIRDatabaseReference]()
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //=>    Load feed info
        Async.main(after: 0.3) { 
            self.loadFeedInfo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //=>    Setup UI
        setupUI()
        
        //=>    Load info about current feed in "silent" mode
        loadFeedUpdatedInfoFromFirebase()
        
        NotificationCenter.default.addObserver(self, selector: #selector(VXFeedDetailsVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VXFeedDetailsVC.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        lblFeedDescription.preferredMaxLayoutWidth = lblFeedDescription.bounds.width
        
        sizeHeaderToFit(tblMessages)
    }
    
    // MARK: - Notification Methods
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.consViewNewMessageBottom.constant     = 0;
            self.view.layoutIfNeeded()
        }) 
    }
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        if let dictUserInfo = notification.userInfo {
            if let rectEndFrame = (dictUserInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if let duration = dictUserInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                    UIView.animate(withDuration: duration, animations: { () -> Void in
                        self.consViewNewMessageBottom.constant     = rectEndFrame.size.height;
                        self.view.layoutIfNeeded()
                        }, completion: { (finished) -> Void in
                            self.scrollTableToBottom(true)
                    })
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    func scrollTableToBottom(_ animated: Bool) {
        if arrFeedMessages.count > 0 {
            let indexPath           = IndexPath(row: arrFeedMessages.count - 1, section: 0)
            tblMessages.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    fileprivate func setupUI() {
        //=>    Updates for table view
        self.edgesForExtendedLayout = UIRectEdge()
        self.automaticallyAdjustsScrollViewInsets = false
        tblMessages.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        tblMessages.estimatedRowHeight = 60
        tblMessages.rowHeight = UITableViewAutomaticDimension
        
        //=>    Mark clip to bounds
        imgFeedImage.clipsToBounds = true
        
        //=>    Make sure we have current user logged in
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard let currentFeed = curFeed else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        //=>    Make sure we have user id
        guard let userWhichCreatedFeed = currentFeed.createdByUser else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        //=>    Check if feed added to favorites
        FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(uid)/\(Constants.UserKeys.userFavoritesFeeds)")
            .observeSingleEvent(of: .value, with: { [unowned self] (dataSnapshot) in
                
                for data in dataSnapshot.children {
                    if let dataFavFeed = data as? FIRDataSnapshot {
                        if var dictFavFeed = dataFavFeed.value as? [String: AnyObject] {
                            //=>    Get each fav feed id
                            if let strFavFeedID = dictFavFeed[Constants.FeedKeys.feedID] as? String {
                                //=>    Check if user already added
                                if strFavFeedID == currentFeed.id {
                                    self.bIsFeedAddedToFavorites = true
                                    break
                                }
                            }
                        }
                    }
                }
                
                Async.main {
                    if self.bIsFeedAddedToFavorites {
                        self.btnEditFeed.setImage(UIImage(named: "remove_from_favorites"), for: UIControlState())
                    }
                    else {
                        if userWhichCreatedFeed.id != uid {
                            self.btnEditFeed.setImage(UIImage(named: "add_to_favorite"), for: UIControlState())
                        }
                        else {
                            self.btnEditFeed.setImage(UIImage(named: "edit_feed"), for: UIControlState())
                        }
                    }
                }
        })
    }
    
    func loadFeedInfo() {
        guard let currentFeed = curFeed else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        lblFeedName.text = currentFeed.name
        lblUserName.text = currentFeed.createdByUser?.name
        lblFeedDescription.text = currentFeed.about
        
        if let strCreatedDate = currentFeed.createdDate {
            lblFeedDate.text = VertxUtils.getStringDateAndTimeFromCreatedStringDate(strCreatedDate)
        }
        
        if let strImgUrl = currentFeed.imgURL, let urlImage = URL(string: strImgUrl) {
            //imgFeedImage.kf_showIndicatorWhenLoading = true
            //imgFeedImage.kf_indicatorType = .activity
            //imgFeedImage.kf_setImageWithURL(urlImage)
            //imgFeedImage.layer.masksToBounds = true
        }
        
        if let strImgUrl = currentFeed.createdByUser?.profileURL, let urlImage = URL(string: strImgUrl) {
            imgUserProfile.kf.setImage(with: urlImage, placeholder: UIImage(named: "no_profile"), options: [.transition(ImageTransition.fade(1))])
            { (image, error, cacheType, imageURL) in
                if let img = image {
                    self.imgUserProfile.image = img.circle
                }
            }
        }
        
        //=>    Load feed messages
        loadMessagesForFeed(currentFeed)
    }
    
    func didChangeText() {
        if txvNewMessage.text == k_NewMessage_Placeholder {
            txvNewMessage.text      = ""
            btnSend.isEnabled         = false
        }
        else
            if txvNewMessage.text.length == 0 {
                btnSend.isEnabled       = false
            }
            else {
                btnSend.isEnabled       = true
            }
    }
    
    // MARK: - API Methods
    
    fileprivate func loadMessagesForFeed(_ curFeed: Feed) {
        
        guard let createdByUser = curFeed.createdByUser else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let ref = FIRDatabase.database().reference()
            .child("\(Constants.UserKeys.users)/\(createdByUser.id)/\(Constants.UserKeys.userFeeds)/\(curFeed.id)/\(Constants.FeedKeys.feedMessages)")
        ref.observe(.childAdded, with: { [unowned self] (dataSnapshot) in
            
            if var dictMessage = dataSnapshot.value as? [String: AnyObject] {
                if let strMessageFromUserID = dictMessage[Constants.MessageKeys.messageFromUserWithID] as? String {
                  
                    //=>    Get creator user id, and search for his details
                    FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(strMessageFromUserID)")
                        .observeSingleEvent(of: .value, with: { [unowned self] (datUserSnapshot) in
                            if var dictUser = datUserSnapshot.value as? [String: AnyObject] {
                                
                                //=>    Assign message id and user object
                                dictMessage[Constants.MessageKeys.messageID] = dataSnapshot.key as AnyObject
                                
                                dictUser[Constants.UserKeys.userID] = datUserSnapshot.key as AnyObject
                                dictMessage[Constants.MessageKeys.messageCreatedByUser] = User(dictUser: dictUser)
                                
                                //=>    Add message in array
                                self.arrFeedMessages.append(Message(dictMessage: dictMessage))
                                
                                //=>    Reload table
                                self.tblMessages.beginUpdates()
                                let indexPath = IndexPath(row: self.arrFeedMessages.count - 1, section: 0)
                                self.tblMessages.insertRows(at: [indexPath], with: .automatic)
                                self.tblMessages.endUpdates()
                                
                                self.scrollTableToBottom(true)
                            }
                    })
                }
            }
        })
        
        arrFirebaseReferences.append(ref)
    }
    
    fileprivate func addNewMessage() {
        guard let currentFeed = curFeed else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard let createdByUser = currentFeed.createdByUser else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //=>    Hide btnSend and display spinner
        spinner.isHidden = false
        spinner.startAnimating()
        btnSend.isEnabled = false
        btnSend.isHidden = true
        
        //=>    Build dictionary with message info
        var dictParams = [String: String]()
        dictParams[Constants.MessageKeys.messageText] = txvNewMessage.text
        
        if let strCreatedDate = VertxUtils.getStringDateFromDate(Date()) {
            dictParams[Constants.MessageKeys.messageCreatedDate] = strCreatedDate
        }
        
        dictParams[Constants.MessageKeys.messageFromUserWithID] = appDelegate.curUser?.id
        
        FIRDatabase.database().reference()
            .child("\(Constants.UserKeys.users)/\(createdByUser.id)/\(Constants.UserKeys.userFeeds)/\(currentFeed.id)/\(Constants.FeedKeys.feedMessages)")
            .childByAutoId()
            .updateChildValues(dictParams) { (error, reference) in
                
                Async.main {
                    self.spinner.stopAnimating()
                    self.spinner.isHidden = true
                    self.btnSend.isHidden = false
                    
                    if error != nil {
                        
                        let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while posting new message! Please try again! \n\n \(error?.localizedDescription)")
                        self.present(alert, animated: true, completion: nil)
                        
                        
                        return
                    }
                    else {
                        self.txvNewMessage.text = ""
                    }
                }
        }
    }
    
    fileprivate func addRemoveFeedFromFavorites(_ uid: String, curFeedID: String, userWhichCreatedFeedID: String) {
        KVNProgress.show(withStatus: "", on: view)
        
        FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(uid)/\(Constants.UserKeys.userFavoritesFeeds)")
            .observeSingleEvent(of: .value, with: { [unowned self] (dataSnapshot) in
                
                var bIsFeedAddedToFavorites = false
                var strKeyOfFeedForRemove : String?
                
                for data in dataSnapshot.children {
                    if let dataFavFeed = data as? FIRDataSnapshot {
                        if var dictFavFeed = dataFavFeed.value as? [String: AnyObject] {
                            //=>    Get each fav feed id
                            if let strFavFeedID = dictFavFeed[Constants.FeedKeys.feedID] as? String {
                                //=>    Check if user already added
                                if strFavFeedID == curFeedID {
                                    strKeyOfFeedForRemove = dataFavFeed.key
                                    bIsFeedAddedToFavorites = true
                                    
                                    break
                                }
                            }
                        }
                    }
                }
                
                //=>    Add feed to favorite
                if !bIsFeedAddedToFavorites {
                    
                    //=>    Create dictionary with "user_id" and "feed_id"
                    let dictParams = [Constants.UserKeys.userID : userWhichCreatedFeedID, Constants.FeedKeys.feedID : curFeedID]
                    
                    FIRDatabase.database().reference()
                        .child("\(Constants.UserKeys.users)/\(uid)/\(Constants.UserKeys.userFavoritesFeeds)").childByAutoId()
                        .updateChildValues(dictParams) { [unowned self] (error, reference) in
                            if error != nil {
                                
                                KVNProgress.dismiss()
                                
                                Async.main {
                                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while adding feed to favorite! Please try again! \n\n \(String(describing: error?.localizedDescription))")
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                                return
                            }
                            
                            KVNProgress.showSuccess(withStatus: "Feed added to favorites successfully!", completion: {
                                self.btnEditFeed.setImage(UIImage(named: "remove_from_favorites"), for: UIControlState())
                            })
                    }
                }
                else {
                    //=>    Trying to remove feed from favorites
                    
                    KVNProgress.dismiss()
                    
                    guard let strKeyFeedIdToRemove = strKeyOfFeedForRemove else {
                        return
                    }
                    
                    Async.main {
                        //=>    Ask current user if wants to remove from favorites
                        let alert = UIAlertController(title: "Remove feed?",  message: "Are you sure you want to remove this feed from favorites?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                            
                        }))
                        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
                            
                            KVNProgress.show()
                            
                            //=>    Remove feed from favorites
                            FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(uid)/\(Constants.UserKeys.userFavoritesFeeds)/\(strKeyFeedIdToRemove)")
                                .removeValue(completionBlock: { [unowned self] (error, reference) in
                                    if error != nil {
                                        
                                        KVNProgress.dismiss()
                                        
                                        Async.main {
                                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while remove feed from favorite! Please try again! \n\n \(String(describing: error?.localizedDescription))")
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        
                                        return
                                    }
                                    
                                    KVNProgress.showSuccess(withStatus: "Feed removed successfully from favorites!", completion: { 
                                        self.btnEditFeed.setImage(UIImage(named: "add_to_favorite"), for: UIControlState())
                                    })
                            })
                        }))
                        
                        self.present(alert, animated:true, completion:nil)
                    }
                }
        })
    }

    /// Just load feed updated info from server directly, then update in feed details
    func loadFeedUpdatedInfoFromFirebase() {
        guard let currentFeed = curFeed else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let ref = FIRDatabase.database().reference()
        let feedReference = ref.child("\(Constants.UserKeys.users)/\(uid)/\(Constants.UserKeys.userFeeds)/\(currentFeed.id)")
        feedReference.observeSingleEvent(of: .value, with: { (dataSnapshot) in
            if var dictFeed = dataSnapshot.value as? [String: AnyObject] {
                if let strFeedName = dictFeed[Constants.FeedKeys.feedName] as? String {
                    self.curFeed!.name = strFeedName
                }
                
                if let strFeedType = dictFeed[Constants.FeedKeys.feedType] as? String {
                    self.curFeed!.type = strFeedType
                }
                
                if let strFeedPlatform = dictFeed[Constants.FeedKeys.feedPlatform] as? String {
                    self.curFeed!.platform = strFeedPlatform
                }
                
                if let strFeedImgURL = dictFeed[Constants.FeedKeys.feedImageURL] as? String {
                    self.curFeed!.imgURL = strFeedImgURL
                }
                
                if let strFeedDescription = dictFeed[Constants.FeedKeys.feedDescription] as? String {
                    self.curFeed!.about = strFeedDescription
                }
                
                if let strCreatedDate = dictFeed[Constants.FeedKeys.feedCreatedDate] as? String {
                    self.curFeed!.createdDate = strCreatedDate
                }
                
                self.displayUpdatedInfoFromFirebase()
            }
        })
    }
    
    func displayUpdatedInfoFromFirebase() {
        guard let currentFeed = curFeed else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        lblFeedName.text = currentFeed.name
        lblUserName.text = currentFeed.createdByUser?.name
        lblFeedDescription.text = currentFeed.about
        
        if let strCreatedDate = currentFeed.createdDate {
            lblFeedDate.text = VertxUtils.getStringDateAndTimeFromCreatedStringDate(strCreatedDate)
        }
        
        if let strImgUrl = currentFeed.imgURL, let urlImage = URL(string: strImgUrl) {
            //imgFeedImage.kf_showIndicatorWhenLoading = true
            //imgFeedImage.kf_indicatorType = .activity
            //imgFeedImage.kf_setImageWithURL(urlImage)
            imgFeedImage.layer.masksToBounds = true
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnBack_Action() {
        navigationController?.popFadeViewController()
    }
    
    @IBAction func btnSendMessage_Action() {
        addNewMessage()
    }
    
    @IBAction func btnFavoriteOrEditFeed_Action() {
        
        //=>    Make sure we have current user logged in
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        guard let currentFeed = curFeed else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //=>    Make sure we have user id
        guard let userWhichCreatedFeed = currentFeed.createdByUser else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        if bIsFeedAddedToFavorites {
            addRemoveFeedFromFavorites(uid, curFeedID: currentFeed.id, userWhichCreatedFeedID: userWhichCreatedFeed.id)
        }
        else {
            if userWhichCreatedFeed.id != uid {
                addRemoveFeedFromFavorites(uid, curFeedID: currentFeed.id, userWhichCreatedFeedID: userWhichCreatedFeed.id)
            }
            else {
                if let editFeedVC = storyboard?.instantiateViewController(withIdentifier: "VXAddEditFeedVC") as? VXAddEditFeedVC {
                    editFeedVC.curFeed = curFeed
                    navigationController?.pushFadeViewController(editFeedVC)
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFeedMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VXMessageCell_ID", for: indexPath) as! VXMessageCell
        
        let curMessage = arrFeedMessages[indexPath.row]
        
        //=>    Try to load user which created message
        if let userCreatorMessage = curMessage.createdByUser {
            cell.lblUserName.setUserNameAndTimeForWrittenMessage(userCreatorMessage.name, strTimeAgo: curMessage.createdDate)
            
            //=>    Set profile image
            if let strProfileURL = userCreatorMessage.profileURL, let urlProfileImage = URL(string: strProfileURL) {
                cell.imgUserProfile.kf.setImage(with: urlProfileImage, placeholder: UIImage(named: "no_profile"), options: [.transition(ImageTransition.fade(1))])
                { (image, error, cacheType, imageURL) in
                    if let img = image {
                        cell.imgUserProfile.image = img.circle
                    }
                }
            }
            else {
                cell.imgUserProfile.image = UIImage(named: "profile_icon")
            }
            
            cell.currentUser        = userCreatorMessage
        }
        
        cell.lblMessage.text = curMessage.messageText
        cell.delegate = self
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if txvNewMessage.isFirstResponder {
            txvNewMessage.resignFirstResponder()
        }
    }
    
    // MARK: - UIScrollViewDelegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tblHeader = tblMessages.tableHeaderView else {
            return
        }
        
        //=>    Change alpha of top view while scrolling.
        let currentVerticalOffset = scrollView.contentOffset.y
        let maximumVerticalOffset = tblHeader.height - viewTop.height // 64
        let percentageVerticalOffset = currentVerticalOffset / maximumVerticalOffset
        
        viewTop.alpha = min(1.0, percentageVerticalOffset)
    }
    
    
    // MARK: - UITextFieldDelegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        txvNewMessage.text              = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        txvNewMessage.text              = k_NewMessage_Placeholder
        btnSend.isEnabled                 = false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            txvNewMessage.text          = txvNewMessage.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            addNewMessage()
        }
        else {
            Async.main(after: 0.01, {
                self.didChangeText()
            })
        }
        
        return true
    }
    
    // MARK: - VXMessageCellDelegate Methods
    func vxMessageCell_didSelectProfileUser(_ curUser: User) {
        //=>    Check current user id
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //=>    If logged in user id is the same with selected user profile id, then push MyProfileVC
        if uid == curUser.id {
            if let myProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "VXMyProfileVC") as? VXMyProfileVC {
                navigationController?.pushFadeViewController(myProfileVC)
            }
        }
        else {
            if let userProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "VXUserProfileVC") as? VXUserProfileVC {
                userProfileVC.selectedUser = curUser
                navigationController?.pushFadeViewController(userProfileVC)
            }
        }
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("FEED DETAILS DEINIT")
        
        for reference in arrFirebaseReferences {
            reference.removeAllObservers()
        }
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
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
