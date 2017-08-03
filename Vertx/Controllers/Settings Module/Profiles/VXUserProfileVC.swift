//
//  VXUserProfileVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/23/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import Async
import Kingfisher

let k_TableChoice_Height : CGFloat    = 55.0

class VXUserProfileVC: VXBaseVC {
    
    @IBOutlet weak fileprivate var scrollView: TPKeyboardAvoidingScrollView!
    
    @IBOutlet weak fileprivate var lblUserName: UILabel!
    @IBOutlet weak fileprivate var btnUserProfileImg: UIButton!
    @IBOutlet weak fileprivate var btnAddRemoveFavorites: UIButton!
    @IBOutlet weak fileprivate var imgBackground: UIImageView!
    
    @IBOutlet weak fileprivate var collectionAccounts: UICollectionView!
    
    @IBOutlet weak fileprivate var tblChoices: UITableView!
    
    @IBOutlet weak fileprivate var txvAbout: UITextView!
    
    @IBOutlet weak var consViewCollectionHeight: NSLayoutConstraint!
    @IBOutlet weak var consTableHeight: NSLayoutConstraint!
    
    var selectedUser : User?
    
    var arrUserAccounts = [[String : String]]()
    var arrUserChoices = [[String : String]]()

    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Async.main(after: 0.3) {
            
        }
        
        self.setupUI()
        
        self.fillUserInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //=>    Update scroll content size
        let height = txvAbout.y + txvAbout.height + 15 // padding bottom
        scrollView.contentSize = CGSize(width: view.width, height: height)
    }

    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func setupUI() {
        //=>    Make sure we have current user logged in
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //=>    Make sure we have user id
        guard let selectedUserTemp = selectedUser else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        //=>    Check if selected user is added to favorites
        FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(uid)/\(Constants.UserKeys.userFavoritesUsers)")
            .observeSingleEvent(of: .value, with: { [unowned self] (dataSnapshot) in
                
                var bIsUserAddedToFavorites = false
                
                for data in dataSnapshot.children {
                    if let dataFavUser = data as? FIRDataSnapshot {
                        if var dictFavUser = dataFavUser.value as? [String: AnyObject] {
                            //=>    Get each fav feed id
                            if let strFavUserID = dictFavUser[Constants.UserKeys.userID] as? String {
                                //=>    Check if user already added
                                if strFavUserID == selectedUserTemp.id {
                                    bIsUserAddedToFavorites = true
                                    
                                    break
                                }
                            }
                        }
                    }
                }
                
                Async.main {
                    if bIsUserAddedToFavorites {
                        self.btnAddRemoveFavorites.setImage(UIImage(named: "remove_from_favorites"), for: UIControlState())
                    }
                    else {
                        self.btnAddRemoveFavorites.setImage(UIImage(named: "add_to_favorite"), for: UIControlState())
                    }
                }
        })
    }
    
    fileprivate func fillUserInfo() {
        //=>    Fill selected user info
        if let selectedUser = selectedUser,
            let strName = selectedUser.name,
            let strAge = selectedUser.age {
            
            //=>    Store selected user globably. We will use this value on Feeds screen for this user feeds.
            //=>    In Back action, we make this NIL !!!
            appDelegate.selectedUser = selectedUser
            
            self.lblUserName.text = "\(strName), \(strAge)"
            self.txvAbout.text = selectedUser.about
            
            //=>    Get user accounts
            if let strPSN = selectedUser.psn, !strPSN.isEmpty {
                var dictInfo = ["option" : "psn"]
                dictInfo["name"] = strPSN
                
                arrUserAccounts.append(dictInfo)
            }
            
            if let strXboxLive = selectedUser.xboxLive, !strXboxLive.isEmpty {
                var dictInfo = ["option" : "xbox"]
                dictInfo["name"] = strXboxLive
                
                arrUserAccounts.append(dictInfo)
            }
            
            if let strPC = selectedUser.pc, !strPC.isEmpty {
                var dictInfo = ["option" : "pc"]
                dictInfo["name"] = strPC
                
                arrUserAccounts.append(dictInfo)
            }
            
            if let strNintendo = selectedUser.nintendo, !strNintendo.isEmpty {
                var dictInfo = ["option" : "ninetendo"]
                dictInfo["name"] = strNintendo
                
                arrUserAccounts.append(dictInfo)
            }
            
            //=>    If array accounts count is 0, then setup height constraint for collection view
            if arrUserAccounts.count == 0 {
                consViewCollectionHeight.constant = 0
                view.layoutIfNeeded()
            }
            else {
                //=>    Reload data in collection view
                collectionAccounts.reloadData()
            }
            
            //=>    Get user choices
            if let strPlatform = selectedUser.platform, !strPlatform.isEmpty {
                var dictInfo = ["option" : "Platform of choice"]
                dictInfo["name"] = strPlatform
                
                arrUserChoices.append(dictInfo)
            }
            
            //=>    Get user choices
            if let strGame = selectedUser.gameOfChoice, !strGame.isEmpty {
                var dictInfo = ["option" : "Game of choice"]
                dictInfo["name"] = strGame
                
                arrUserChoices.append(dictInfo)
            }
            //=>    Get user choices
            if let strCurrenltyPlay = selectedUser.currentlyInPlay, !strCurrenltyPlay.isEmpty {
                var dictInfo = ["option" : "Currently in Play"]
                dictInfo["name"] = strCurrenltyPlay
                
                arrUserChoices.append(dictInfo)
            }
            
            //=>    If array accounts count is 0, then setup height constraint for table view
            if arrUserChoices.count == 0 {
                consTableHeight.constant = 0
                view.layoutIfNeeded()
            }
            else
                if arrUserChoices.count == 1 {
                    consTableHeight.constant = k_TableChoice_Height
                    view.layoutIfNeeded()
                }
                else
                    if arrUserChoices.count == 2 {
                        consTableHeight.constant = 2 * k_TableChoice_Height
                        view.layoutIfNeeded()
                    }
            
            tblChoices.reloadData()
            
            //=>    Load image url
            if let strProfileImage = selectedUser.profileURL, let urlProfileImage = URL(string: strProfileImage) {
                self.btnUserProfileImg.kf.setImage(with: urlProfileImage,
                                                   for: .normal,
                                                   placeholder: UIImage(named: "no_profile"),
                                                   options: [.transition(ImageTransition.fade(1))]) { (image, error, cacheType, imageURL) in
                                                    
                                                    //self.btnUserProfileImg.layer.cornerRadius = self.btnUserProfileImg.height / 2
                                                    self.btnUserProfileImg.imageView?.contentMode = .scaleAspectFill
                                                    //self.btnUserProfileImg.layer.masksToBounds = true
                                                    
                                                    if let imgProfile = image {
                                                        self.btnUserProfileImg.setImage(imgProfile.circle, for: UIControlState())
                                                        self.imgBackground.image = imgProfile.addDarkEffect(7)
                                                    }
                }
            }
            else {
                Async.main {
                    self.btnUserProfileImg.setImage(UIImage(named: "no_profile"), for: UIControlState())
                }
            }
        }
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    
    @IBAction func btnUserFeeds_Action(_ sender: AnyObject) {
        if let feedVC = storyboard?.instantiateViewController(withIdentifier: "VXFeedsVC") as? VXFeedsVC {
            feedVC.feedOptionScreen = .userFeeds
            feedVC.selectedUser = selectedUser
            navigationController?.pushFadeViewController(feedVC)
        }
    }
    
    @IBAction func btnStartChatWithUser_Action(_ sender: AnyObject) {
        if let chatVC = storyboard?.instantiateViewController(withIdentifier: "VXChatVC") as? VXChatVC {
            chatVC.selectedUserToChat = selectedUser
            navigationController?.pushFadeViewController(chatVC)
        }
    }
    
    @IBAction func btnBack_Action(_ sender: AnyObject) {
        //=>    Set nil selected user
        appDelegate.selectedUser = nil
        
        navigationController?.popFadeViewController()
    }
    
    @IBAction func btnAddToFavorites_Action(_ sender: UIButton) {
        //=>    Make sure we have user id
        guard let selectedUserTemp = selectedUser else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        guard let currentUser = appDelegate.curUser else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try to login again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        KVNProgress.show()
        
        FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(currentUser.id)/\(Constants.UserKeys.userFavoritesUsers)")
            .observeSingleEvent(of: .value, with: { (dataSnapshot) in
                
                var bIsUserAdded = false
                var strKeyOfUserIdForRemove : String?
                
                for data in dataSnapshot.children {
                    if let dataFavUser = data as? FIRDataSnapshot {
                        if var dictFavUser = dataFavUser.value as? [String: AnyObject] {
                            //=>    Get each fav user id
                            if let strFavUserID = dictFavUser[Constants.UserKeys.userID] as? String {
                                //=>    Check if user already added
                                if strFavUserID == selectedUserTemp.id {
                                    strKeyOfUserIdForRemove = dataFavUser.key
                                    bIsUserAdded = true
                                    break
                                }
                            }
                        }
                    }
                }
                
                //=>    Add user to favorite
                if !bIsUserAdded {
                    let dictParams = [Constants.UserKeys.userID : selectedUserTemp.id]
                    FIRDatabase.database().reference()
                        .child("\(Constants.UserKeys.users)/\(currentUser.id)/\(Constants.UserKeys.userFavoritesUsers)").childByAutoId()
                        .updateChildValues(dictParams) { (error, reference) in
                            if error != nil {
                                
                                KVNProgress.dismiss()
                                
                                Async.main {
                                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while adding user to favorite! Please try again! \n\n \(String(describing: error?.localizedDescription))")
                                    self.present(alert, animated: true, completion: nil)
                                }
                                
                                return
                            }
                            
                            KVNProgress.showSuccess(withStatus: "User added to favorites successfully!", completion: {
                                self.btnAddRemoveFavorites.setImage(UIImage(named: "remove_from_favorites"), for: UIControlState())
                            })
                    }
                }
                
                else {
                    guard let strKeyUserIdToRemove = strKeyOfUserIdForRemove else {
                        return
                    }
                    
                    KVNProgress.dismiss()
                    
                    Async.main {
                        //=>    Ask current user if wants to remove from favorites
                        let alert = UIAlertController(title: "Remove user?",  message: "Are you sure you want to remove this user from favorites?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                            
                        }))
                        alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { _ in
                            FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(currentUser.id)/\(Constants.UserKeys.userFavoritesUsers)/\(strKeyUserIdToRemove)")
                                .removeValue(completionBlock: { (error, reference) in
                                    if error != nil {
                                        
                                        KVNProgress.dismiss()
                                        
                                        Async.main {
                                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while remove user from favorite! Please try again! \n\n \(String(describing: error?.localizedDescription))")
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        
                                        return
                                    }
                                    
                                    KVNProgress.showSuccess(withStatus: "User removed successfully from favorites!", completion: {
                                        self.btnAddRemoveFavorites.setImage(UIImage(named: "add_to_favorite"), for: UIControlState())
                                    })
                                })
                        }))
                        
                        self.present(alert, animated:true, completion:nil)
                    }
                }
        })
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrUserAccounts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        
        let currentAccount = arrUserAccounts[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VXGameAccountCell_ID", for: indexPath) as! VXGameAccountCell
        
        cell.lblAccountName.text = currentAccount["name"]
        cell.setImageAccountForOption(currentAccount["option"]!)
        
        //=>    Hide separator view for last cell
        if indexPath.row == arrUserAccounts.count - 1 {
            cell.viewSeparator.isHidden = true
        }
        else {
            cell.viewSeparator.isHidden = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        //=>    We have static cells here
        let widthCell = 113.0
        let heightCell = 89.0
        
        return CGSize(width: CGFloat(widthCell), height: CGFloat(heightCell))
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUserChoices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let currentChoice = arrUserChoices[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VXUserChoiceCell_ID", for: indexPath) as! VXUserChoiceCell
        
        cell.lblOption.text = currentChoice["option"]
        cell.lblOptionName.text = currentChoice["name"]
        
        return cell
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreate d.
    }
    
    deinit {
        debugPrint("USER PROFILE DEINIT")
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
