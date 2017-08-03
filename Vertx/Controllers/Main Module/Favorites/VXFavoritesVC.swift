//
//  VXFavoritesVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/30/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Async
import Firebase
import KVNProgress
import Kingfisher

class VXFavoritesVC: VXBaseVC, VXFeedProfileCellDelegate {
    
    @IBOutlet weak var btnUsers: UIButton!
    @IBOutlet weak var btnFeeds: UIButton!
    
    @IBOutlet weak var collection: UICollectionView!
    
    var curFavoriteOption = Favorites.users
    
    var arrFavoritesUsers = [User]()
    var arrFavoritesFeeds = [Feed]()
    
    /// Store each reference for removeObserver call
    fileprivate var arrFirebaseReferences = [FIRDatabaseReference]()
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //=>    Setup UI
        setupUI()
        
        //=>    Load all info
        Async.main(after: 0.3) { 
            self.loadFavorites()
        }
    }
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func loadFavorites() {
        
        guard let curUser = appDelegate.curUser else {
            return
        }
        
        KVNProgress.show()
        
        //=>    Load users
        let refUsers = FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(curUser.id)/\(Constants.UserKeys.userFavoritesUsers)")
        refUsers.observe(.value, with: { (dataSnapshot) in
            
            //=>    Remove objects from array
            self.arrFavoritesUsers.removeAll(keepingCapacity: false)
            
            //=>    If there is not value, just return
            if dataSnapshot.children.allObjects.count == 0 {
                Async.main {
                    self.dismisKVNProgress()
                    
                    self.collection.reloadData()
                }
                
                return
            }
            
            for (index, data) in dataSnapshot.children.enumerated() {
                if let dataFavUser = data as? FIRDataSnapshot {
                    if var dictFavUser = dataFavUser.value as? [String: AnyObject] {
                        //=>    Get each fav user id
                        if let strFavUserID = dictFavUser[Constants.UserKeys.userID] as? String {
                            
                            //=>    Get data for user
                            FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(strFavUserID)")
                                .observeSingleEvent(of: .value, with: { [unowned self] (dataSnapshot1) in
                                    
                                    if var dictUser = dataSnapshot1.value as? [String: AnyObject] {
                                        dictUser[Constants.UserKeys.userID] = dataSnapshot1.key as AnyObject
                                        self.arrFavoritesUsers.append(User(dictUser: dictUser))
                                    }
                                    
                                    if index == dataSnapshot.children.allObjects.count - 1 {
                                        Async.main {
                                            self.dismisKVNProgress()
                                            
                                            self.collection.reloadData()
                                        }
                                    }
                                    })
                        }
                        else {
                            self.dismisKVNProgress()
                        }
                    }
                    else {
                        self.dismisKVNProgress()
                    }
                }
                else {
                    self.dismisKVNProgress()
                }
            }
        })
        
        arrFirebaseReferences.append(refUsers)
        
        //=>    Load feeds
        let refFeeds = FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(curUser.id)/\(Constants.UserKeys.userFavoritesFeeds)")
        refFeeds.observe(.value, with: { (dataSnapshot) in
            
            //=>    Remove objects from array
            self.arrFavoritesFeeds.removeAll(keepingCapacity: false)
            
            //=>    If there is not value, just return
            if dataSnapshot.children.allObjects.count == 0 {
                Async.main{
                    self.dismisKVNProgress()
                    
                    self.collection.reloadData()
                }
                
                return
            }
            
            for (index, data) in dataSnapshot.children.enumerated() {
                if let dataFavFeed = data as? FIRDataSnapshot {
                    if var dictFavFeed = dataFavFeed.value as? [String: AnyObject] {
                        //=>    Get each fav user id
                        if let strUserID = dictFavFeed[Constants.UserKeys.userID] as? String , let strFeedID = dictFavFeed[Constants.FeedKeys.feedID] as? String {
                           
                            //=>    Load user info
                            FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(strUserID)").observeSingleEvent(of: .value, with: {[unowned self] (dataSnapshotUser) in
                                if var dictUser = dataSnapshotUser.value as? [String: AnyObject] {
                                    
                                    //=>    Get feeds of user
                                    FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(strUserID)/\(Constants.UserKeys.userFeeds)/\(strFeedID)")
                                        .observeSingleEvent(of: .value, with: { [unowned self] (dataSnapshot1) in
                                            
                                            if var dictFeed = dataSnapshot1.value as? [String: AnyObject] {
                                                //=>    Add info about user
                                                dictUser[Constants.UserKeys.userID] = dataSnapshotUser.key as AnyObject
                                                dictFeed[Constants.FeedKeys.feedCreatedByUser] = User(dictUser: dictUser)
                                                
                                                dictFeed[Constants.FeedKeys.feedID] = dataSnapshot1.key as AnyObject
                                                self.arrFavoritesFeeds.append(Feed(dictFeed: dictFeed))
                                            }
                                            
                                            if index == dataSnapshot.children.allObjects.count - 1 {
                                                Async.main {
                                                    self.dismisKVNProgress()
                                                    
                                                    self.collection.reloadData()
                                                }
                                            }
                                    })
                                }
                            })
                        }
                        else {
                            self.dismisKVNProgress()
                        }
                    }
                    else {
                        self.dismisKVNProgress()
                    }
                }
                else {
                    self.dismisKVNProgress()
                }
            }
        })
        
        arrFirebaseReferences.append(refFeeds)
    }
    
    fileprivate func dismisKVNProgress() {
        //=>    Check if this screen is visible(top on stack)
        if self.isViewTopOnStack {
            KVNProgress.dismiss()
        }
    }
    
    fileprivate func setupUI() {
        setupSegmentButtonForState(btnUsers, state: .selected)
        setupSegmentButtonForState(btnFeeds, state: UIControlState())
    }
    
    fileprivate func setupSegmentButtonForState(_ button: UIButton, state: UIControlState) {
        if state == UIControlState() {
            button.isSelected = false
            button.layer.cornerRadius = 20.0
            button.layer.borderWidth = 1.0
            button.layer.borderColor = UIColor.vertxDarkOrange().cgColor
            button.backgroundColor = UIColor.clear
        }
        else
            if state == .selected {
                button.isSelected = true
                button.layer.cornerRadius = 20.0
                button.backgroundColor = UIColor.vertxDarkOrange()
        }
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    
    @IBAction fileprivate func btnBack_Action() {
        navigationController?.popFadeViewController()
    }
    
    @IBAction fileprivate func btnUsers_Action(_ sender: UIButton) {
        if !sender.isSelected {
            
            curFavoriteOption = Favorites.users
            
            setupSegmentButtonForState(btnUsers, state: .selected)
            setupSegmentButtonForState(btnFeeds, state: UIControlState())
            
            collection.reloadData()
        }
    }
    
    @IBAction fileprivate func btnFeeds_Action(_ sender: UIButton) {
        if !sender.isSelected {
            
            curFavoriteOption = Favorites.feeds
            
            setupSegmentButtonForState(btnFeeds, state: .selected)
            setupSegmentButtonForState(btnUsers, state: UIControlState())
            
            collection.reloadData()
        }
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch curFavoriteOption {
        case .users:
            return arrFavoritesUsers.count
            
        case .feeds:
            return arrFavoritesFeeds.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        switch curFavoriteOption {
        case .users:
            let currentUser = arrFavoritesUsers[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VXUserCell_ID", for: indexPath) as! VXUserCell
            
            cell.lblUserFullName.text   = currentUser.name
            
            if let strProfileURL = currentUser.profileURL,
                let urlProfileImage = URL(string: strProfileURL) {
                
                cell.imgProfile.kf.setImage(
                    with: urlProfileImage,
                    placeholder: UIImage(named: "no_profile"),
                    options: [.transition(ImageTransition.fade(1))]
                )
                
                cell.imgProfile.kf.setImage(with: urlProfileImage,
                                            placeholder: UIImage(named: "no_profile"),
                                            options: [.transition(ImageTransition.fade(1))],
                                            completionHandler: { (image, error, cacheType, imageURL) in
                    if let img = image {
                        cell.imgProfile.image = img.circle
                        cell.imgBackground.image = img
                    }
                })
            }
            else {
                cell.imgProfile.image = UIImage(named: "profile_icon")
                cell.imgBackground.image = nil
                cell.backgroundColor = UIColor.vertxDarkBrown()
            }
            
            cell.layoutIfNeeded()
            return cell
            
        case .feeds:
            let currentFeed = arrFavoritesFeeds[indexPath.row]
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
                    cell.imgUserProfile.kf.setImage(with: urlProfileImage,
                                                    placeholder: UIImage(named: "no_profile"),
                                                    options: [.transition(ImageTransition.fade(1))])
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
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        switch curFavoriteOption {
        case .users:
            let selectedUser = arrFavoritesUsers[indexPath.row]
            
            //=>    Push user profile screen
            if let userProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "VXUserProfileVC") as? VXUserProfileVC {
                userProfileVC.selectedUser = selectedUser
                navigationController?.pushFadeViewController(userProfileVC)
            }
            
        case .feeds:
            let selectedFeed = arrFavoritesFeeds[indexPath.row]
            
            //=>    Push Feed Details screen
            if let feedDetailsVC = storyboard?.instantiateViewController(withIdentifier: "VXFeedDetailsVC") as? VXFeedDetailsVC {
                feedDetailsVC.curFeed = selectedFeed
                navigationController?.pushFadeViewController(feedDetailsVC)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        switch curFavoriteOption {
        case .users:
            //=>    We have 8px distance between cells
            let widthCell = (collectionView.frame.size.width - 8 ) / 2
            let heightCell = widthCell / 1.56
            
            return CGSize(width: widthCell, height: heightCell)
            
        case .feeds:
            //=>    We have 3 section inset, and distance between cells is 8.
            let widthCell = (collectionView.frame.size.width - 14) / 2
            let heightCell = widthCell * 1.3
            
            return CGSize(width: widthCell, height: heightCell)
        }
    }
    
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
    
    // MARK: - Memory Cleanup
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("FAVORITES DEINIT")
        
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
