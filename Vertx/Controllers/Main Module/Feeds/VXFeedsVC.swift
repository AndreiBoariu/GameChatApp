//
//  VXFeedsVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/20/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import Async
import Kingfisher
import WYPopoverController

class VXFeedsVC: VXBaseVC, VXFeedProfileCellDelegate, WYPopoverControllerDelegate, PopoverSearchVCDelegate {
    
    @IBOutlet weak fileprivate var lblTitle: UILabel!
    @IBOutlet weak fileprivate var collectionFeeds: UICollectionView!
    @IBOutlet weak fileprivate var btnSearch: UIButton!
    @IBOutlet weak fileprivate var lblNoFeedsAvailable: UILabel!
    
    var arrFeeds : [Feed] = []
    
    var feedOptionScreen = FeedScreenOption.allFeeds
    
    /// This is used when logged in user wants to get user feeds
    var selectedUser : User?
    
    /// Store each reference for removeObserver call
    fileprivate var arrFirebaseReferences = [FIRDatabaseReference]()
    
    var customPopover = WYPopoverController()
    
    //=>    Vars for search
    var arrSearchTypes: [String]?
    var strSearchText : String?
    var strSearchGamePlatform: String?
    var arrFeedsCopyMain : [Feed] = []  //=>    This is a full copy of arrFeeds
    var arrFeedsCopy : [Feed] = []      //=>    This is a copy used for filter, and first object removed([0] - is for Add New)
    var isSearching = false
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //=>    Set title
        setCorrectTitle()
        
        //=>    Load feeds with delay
        Async.main(after: 0.3) {
            self.loadFeeds()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    func displaySearchPopover(_ sender: UIButton) {
        
        //=>    Hide keyboard if is visible
        view.endEditing(true)
        
        if customPopover.isPopoverVisible {
            //=>    Dismiss popover
            customPopover.dismissPopover(animated: true)
            customPopover.delegate = nil
        }
        
        if let popoverSearch       = self.storyboard?.instantiateViewController(withIdentifier: "PopoverSearchVC") as? PopoverSearchVC {
            popoverSearch.delegate = self
            popoverSearch.preferredContentSize = CGSize(width: view.width, height: 370)
            popoverSearch.arrSearchTypesTemp = arrSearchTypes
            popoverSearch.strSearchTextTemp = strSearchText
            popoverSearch.strSearchGamePlatformTemp = strSearchGamePlatform
            
            customPopover = WYPopoverController(contentViewController: popoverSearch)
            customPopover.delegate = self
            customPopover.passthroughViews = [sender]
            customPopover.popoverLayoutMargins = UIEdgeInsetsMake(0, 0, 0, 0)
            customPopover.wantsDefaultContentAppearance = false
            
            customPopover.theme = WYPopoverTheme.forIOS7()
            customPopover.beginThemeUpdates()
            customPopover.theme.arrowHeight = 0
            customPopover.endThemeUpdates()
            
            customPopover.presentPopover(from: CGRect(x: 0, y: -2, width: 1, height: 1), in: view, permittedArrowDirections: WYPopoverArrowDirection(rawValue: 7) , animated: true)
        }
    }
    
    func setCorrectTitle() {
        switch feedOptionScreen {
        case .myFeeds:
            lblTitle.text = "My Feeds"
            
        case .allFeeds:
            lblTitle.text = "All Feeds"
            
        case .userFeeds:
            //=>    Make sure we have id of selected user
            guard let selectedUserTemp = selectedUser else {
                lblTitle.text = "User Feeds"
                
                return
            }
            
            
            
            Async.background {
                if let strImgUrl = selectedUserTemp.profileURL, let urlImage = URL(string: strImgUrl) {
                    
                    KingfisherManager.shared.retrieveImage(with: urlImage, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                        if let img = image {
                            self.lblTitle.addUserProfileImage(img, andUserName: selectedUserTemp.name!, andAppendText: "Feeds")
                        }
                        else {
                            self.lblTitle.addUserProfileImage(nil, andUserName: selectedUserTemp.name!, andAppendText: "Feeds")
                        }
                    })
                }
                else {
                    self.lblTitle.addUserProfileImage(nil, andUserName: selectedUserTemp.name!, andAppendText: "Feeds")
                }
            }
        }
    }
    
    func loadFeeds() {
        //=>    Make sure we have current user logged in
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //=>    Get feeds based on each case
        if feedOptionScreen == .myFeeds {
            loadMyFeeds(uid)
        }
        else
            if feedOptionScreen == .allFeeds {
                loadAllFeeds(uid)
            }
            else
                if feedOptionScreen == .userFeeds {
                    loadUserFeeds(uid)
                }
    }
    
    fileprivate func loadMyFeeds(_ uid : String) {
        KVNProgress.show()
        
        //=>    Get user feeds
        let ref = FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(uid)/\(Constants.UserKeys.userFeeds)")
        ref.observe(.value, with: { [unowned self] (dataSnapshot) in
            
            //=>    Remove feeds from array
            self.arrFeeds.removeAll(keepingCapacity: false)
            
            //=>    Create a nil object for Add New Feed option
            let addNewFeedOption = Feed(tempID:"", tempName: "", tempType: nil, tempPlatform: nil, tempAbout: nil, tempImgURL: nil)
            self.arrFeeds.insert(addNewFeedOption, at: 0)
            
            for data in dataSnapshot.children {
                if let dataFeed = data as? FIRDataSnapshot {
                    if var dictFeed = dataFeed.value as? [String: AnyObject] {
                        //=>    Assign feed id and cur user info
                        dictFeed[Constants.FeedKeys.feedID] = dataFeed.key as AnyObject
                        dictFeed[Constants.FeedKeys.feedCreatedByUser] = appDelegate.curUser
                        
                        self.arrFeeds.append(Feed(dictFeed: dictFeed))
                    }
                }
            }
            
            Async.main(after: 0.1, { 
                self.dismisKVNProgress()
                
                self.collectionFeeds.reloadData()
            })
        })
        
        arrFirebaseReferences.append(ref)
    }
    
    fileprivate func loadAllFeeds(_ uid : String) {
        KVNProgress.show()
        
        //=>    Load all users
        let ref = FIRDatabase.database().reference().child(Constants.UserKeys.users)
        ref.observe(.value, with: { [unowned self] (dataSnapshot) in
            
            //=>    Remove feeds from array
            self.arrFeeds.removeAll(keepingCapacity: false)
            
            //=>    Create a nil object for Add New Feed option
            let addNewFeedOption = Feed(tempID:"", tempName: "", tempType: nil, tempPlatform: nil, tempAbout: nil, tempImgURL: nil)
            self.arrFeeds.insert(addNewFeedOption, at: 0)
            
            for data in dataSnapshot.children {
                if let dataUser = data as? FIRDataSnapshot {
                    if var dictUser = dataUser.value as? [String: AnyObject] {
                        
                        //=>    Load feeda based on user id
                        let ref = FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(dataUser.key)/\(Constants.UserKeys.userFeeds)")
                        ref.observe(.value, with: { [unowned self] (dataSnapshot) in
                            
                            for data in dataSnapshot.children {
                                if let dataFeed = data as? FIRDataSnapshot {
                                    if var dictFeed = dataFeed.value as? [String: AnyObject] {
                                        
                                        //=>    Assign feed id and user object
                                        dictFeed[Constants.FeedKeys.feedID] = dataFeed.key as AnyObject
                                        
                                        dictUser[Constants.UserKeys.userID] = dataUser.key as AnyObject
                                        dictFeed[Constants.FeedKeys.feedCreatedByUser] = User(dictUser: dictUser)
                                        
                                        self.arrFeeds.append(Feed(dictFeed: dictFeed))
                                    }
                                }
                                else {
                                    self.dismisKVNProgress()
                                }
                            }
                            
                            Async.main(after: 0.1, {
                                self.dismisKVNProgress()
                                
                                self.collectionFeeds.reloadData()
                            })
                        })
                        
                        self.arrFirebaseReferences.append(ref)
                    }
                }
                else {
                    self.dismisKVNProgress()
                }
            }
        })
        
        arrFirebaseReferences.append(ref)
    }
    
    fileprivate func loadUserFeeds(_ uid : String) {
        //=>    Make sure we have id of selected user
        guard let selectedUserTemp = selectedUser else {
            return
        }
        
        KVNProgress.show()
        
        //=>    Get selected user feeds
        let ref = FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(selectedUserTemp.id)/\(Constants.UserKeys.userFeeds)")
        ref.observe(.value, with: { [unowned self] (dataSnapshot) in
            
            //=>    Remove feeds from array
            self.arrFeeds.removeAll(keepingCapacity: false)
            
            for data in dataSnapshot.children {
                if let dataFeed = data as? FIRDataSnapshot {
                    if var dictFeed = dataFeed.value as? [String: AnyObject] {
                        
                        //=>    Assign feed id and user full info
                        dictFeed[Constants.FeedKeys.feedID] = dataFeed.key as AnyObject
                        dictFeed[Constants.FeedKeys.feedCreatedByUser] = appDelegate.selectedUser
                        
                        self.arrFeeds.append(Feed(dictFeed: dictFeed))
                    }
                }
            }
            
            Async.main(after: 0.1, {
                self.dismisKVNProgress()
                
                self.collectionFeeds.reloadData()
            })
        })
        
        self.arrFirebaseReferences.append(ref)
    }
    
    fileprivate func dismisKVNProgress() {
        //=>    Check if this screen is visible(top on stack)
        if self.isViewTopOnStack {
            KVNProgress.dismiss()
        }
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    
    @IBAction func btnBack_Action() {
        navigationController?.popFadeViewController()
    }
    
    @IBAction func btnSearch_Action(_ sender: UIButton) {
        if !isSearching {
            //=>    Copy original feeds
            arrFeedsCopyMain = arrFeeds
        }
        
        isSearching = true
        
        //=>    Re-copy and remove first object, which is for ADD NEW FEED option
        arrFeedsCopy = arrFeedsCopyMain
        if feedOptionScreen != .userFeeds {
            arrFeedsCopy.remove(at: 0)
        }
        
        displaySearchPopover(sender)
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFeeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        
        let currentFeed = arrFeeds[indexPath.row]
        
        switch feedOptionScreen {
        case .myFeeds:
            if indexPath.row == 0 && isSearching == false { //=>    Add New Feed
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VXAddNewFeedCell_ID", for: indexPath) as! VXAddNewFeedCell
                cell.layoutIfNeeded()
                return cell
            }
            else { //=>     Rest of current user feeds
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VXFeedCell_ID", for: indexPath) as! VXFeedCell
                cell.lblFeedName.text = currentFeed.name
                cell.lblFeedType.text = currentFeed.type
                
                if let strImageURL = currentFeed.imgURL, let urlFeedImage = URL(string: strImageURL) {
                    cell.setFeedImageFromUrl(urlFeedImage)
                }
                
                if let strPlatform = currentFeed.platform {
                    cell.setPlatformImage(strPlatform)
                }
                
                cell.layoutIfNeeded()
                
                return cell
            }
            
        case .allFeeds:
            if indexPath.row == 0 && isSearching == false { //=>    Add New Feed
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VXAddNewFeedCell_ID", for: indexPath) as! VXAddNewFeedCell
                cell.layoutIfNeeded()
                return cell
            }
            else { //=>     Rest of all feeds
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VXFeedProfileCell_ID", for: indexPath) as! VXFeedProfileCell
                
                cell.lblFeedName.text   = currentFeed.name
                
                if let feedCreatedByUser = currentFeed.createdByUser {
                    cell.lblUserName.text   = feedCreatedByUser.name
                    cell.currentUser        = feedCreatedByUser
                }
                
                Async.main {
                    if let strImageURL = currentFeed.imgURL, let urlFeedImage = URL(string: strImageURL) {
                        cell.setFeedImageFromUrl(urlFeedImage)
                    }
                    else {
                        cell.imgFeed.image = UIImage(named: "")
                    }
                    
                    if let strProfileURL = currentFeed.createdByUser?.profileURL, let urlProfileImage = URL(string: strProfileURL) {
                        cell.imgUserProfile.kf.setImage(with: urlProfileImage, placeholder: UIImage(named: "no_profile"), options: [.transition(ImageTransition.fade(1))])
                        { (image, error, cacheType, imageURL) in
                            if let img = image {
                                cell.imgUserProfile.image = img.circle
                            }
                        }
                    }
                    else {
                        cell.imgUserProfile.image = UIImage(named: "no_profile")
                    }
                    
                    if let strPlatform = currentFeed.platform {
                        cell.setPlatformImage(strPlatform)
                    }
                }
                
                cell.delegate = self
                cell.layoutIfNeeded()
                
                return cell
            }
            
        case .userFeeds:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VXFeedCell_ID", for: indexPath) as! VXFeedCell
            cell.lblFeedName.text = currentFeed.name
            cell.lblFeedType.text = currentFeed.type
            
            if let strImageURL = currentFeed.imgURL, let urlFeedImage = URL(string: strImageURL) {
                cell.setFeedImageFromUrl(urlFeedImage)
            }
            
            if let strPlatform = currentFeed.platform {
                cell.setPlatformImage(strPlatform)
            }
            
            cell.layoutIfNeeded()
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let selectedFeed = arrFeeds[indexPath.item]
        
        if (feedOptionScreen == .myFeeds || feedOptionScreen == .allFeeds) && selectedFeed.name == "" && indexPath.row == 0  && isSearching == false {
            //=>    Add New Feed option selected
            if let addEditFeedVC = storyboard?.instantiateViewController(withIdentifier: "VXAddEditFeedVC") as? VXAddEditFeedVC {
                navigationController?.pushFadeViewController(addEditFeedVC)
            }
        }
        else {
            //=>    Push Feed Details screen
            if let feedDetailsVC = storyboard?.instantiateViewController(withIdentifier: "VXFeedDetailsVC") as? VXFeedDetailsVC {
                feedDetailsVC.curFeed = selectedFeed
                navigationController?.pushFadeViewController(feedDetailsVC)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        //=>    We have 3 section inset, and distance between cells is 8.
        let widthCell = (collectionView.frame.size.width - 14) / 2
        let heightCell = widthCell * 1.3
        
        return CGSize(width: widthCell, height: heightCell)
    }
    
//    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        // This will cancel all unfinished downloading task when the cell disappearing.
//        switch feedOptionScreen {
//        case .MyFeeds:
//            (cell as! VXFeedCell).imgFeed.kf_cancelDownloadTask()
//            
//        case .AllFeeds:
//            (cell as! VXFeedProfileCell).imgFeed.kf_cancelDownloadTask()
//            
//        case .UserFeeds:
//            (cell as! VXFeedCell).imgFeed.kf_cancelDownloadTask()
//        }
//    }
    
    // MARK: - VXFeedProfileCellDelegate Methods
    
    func vxFeedProfileCell_didSelectProfileUser(_ curUser: User) {
        
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
    
    // MARK: - WYPopoverControllerDelegate Methods
    func popoverControllerShouldDismissPopover(_ popoverController: WYPopoverController!) -> Bool {
        return false
    }
    
    func popoverControllerDidDismissPopover(_ popoverController: WYPopoverController!) {
        if popoverController == customPopover {
            customPopover.delegate = nil
        }
    }
    
    // MARK: - PopoverSearchVCDelegate Methods
    func popoverSearchVC_closePopover() {
        if customPopover.isPopoverVisible {
            customPopover.dismissPopover(animated: true)
        }
        
        strSearchText = nil
        arrSearchTypes = nil
        strSearchGamePlatform = nil
        
        isSearching = false
        
        lblNoFeedsAvailable.isHidden = true
        
        //=>    Re-add original feeds
        arrFeeds.removeAll(keepingCapacity: false)
        arrFeeds = arrFeedsCopyMain
        
        //=>    Remove temp seach arrays
        arrFeedsCopy.removeAll(keepingCapacity: false)
        arrFeedsCopyMain.removeAll(keepingCapacity: false)
        
        //=>    Reload data
        collectionFeeds.reloadData()
    }
    
    func popoverSearchVC_searchActionWithSearchText(_ strSearchTextTemp: String?, andSearchTypes arrSearchTypesTemp: [String]?, andGamePlatform strGamePlatformTemp: String?) {
        if customPopover.isPopoverVisible {
            customPopover.dismissPopover(animated: true)
        }
        
        strSearchText = strSearchTextTemp
        arrSearchTypes = arrSearchTypesTemp
        strSearchGamePlatform = strGamePlatformTemp
        
        arrFeeds.removeAll(keepingCapacity: false)
        
        //=>    Apply filter
        arrFeeds = arrFeedsCopy.filter() {
            
            var containsText = false
            var hasPlatform = false
            var hasType = false
            
            if let strText = strSearchTextTemp {
                containsText = $0.name!.contains(strText)
            }
            
            if let strPlatform = strGamePlatformTemp {
                if $0.platform! == strPlatform {
                    hasPlatform = true
                }
            }
            
            if let arrTypes = arrSearchTypesTemp {
                hasType = arrTypes.contains($0.type!)
            }
            
            return containsText || hasPlatform || hasType
        }
        
        if arrFeeds.count == 0 {
            lblNoFeedsAvailable.isHidden = false
        }
        else {
            lblNoFeedsAvailable.isHidden = true
        }
        
        collectionFeeds.reloadData()
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("FEED DEINIT")
        
        for reference in arrFirebaseReferences {
            reference.removeAllObservers()
        }
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
