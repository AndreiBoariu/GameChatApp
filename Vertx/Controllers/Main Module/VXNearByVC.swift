//
//  VXNearByVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/25/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import KVNProgress
import Firebase
import Async
import CoreLocation
import Kingfisher
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class VXNearByVC: VXBaseVC {
    
    @IBOutlet weak fileprivate var collectionUsers: UICollectionView!
    
    var arrUsers: [User] = []

    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VXNearByVC.didChangeLocationStatus(_:)), name: Constants.NotificationKey.DidChangeLocationStatus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VXNearByVC.didReceiveFixLocation(_:)), name: NSNotification.Name(rawValue: Constants.NotificationKey.DidReceiveLocationFix), object: nil)
        
        loadUsers()
    }
    
    // MARK: - Notification Methods
    
    func didReceiveFixLocation(_ notification: Notification) {
        //=>    Make sure we have current user logged in
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //=>    Update user with details
        Async.main(after: 0.2, {
            self.updateUserInfo(uid)
        })
    }
    
    func didChangeLocationStatus(_ notification: Notification) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            //=>    Make sure we have current user logged in
            guard let uid = FIRAuth.auth()?.currentUser?.uid else {
                let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            //=>    Update user with details
            Async.main(after: 0.5, { 
                self.updateUserInfo(uid)
            })
        }
        else
            if CLLocationManager.authorizationStatus() != .notDetermined {
                let alert = UIAlertController(title: "Oops", message: "Seems like Location Services are disabled. Please enable it.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
                
                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (alert) -> Void in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    /// Update location in firebase
    func updateUserInfo(_ uid: String) {
        var dictParams = [String : String]()
        if let locationManager = appDelegate.locationManager {
            if locationManager.locationFixAchieved {
                dictParams[Constants.UserKeys.userLatitude] = "\(locationManager.lastLocationFix.coordinate.latitude)"
                dictParams[Constants.UserKeys.userLongitude] = "\(locationManager.lastLocationFix.coordinate.longitude)"
            }
        }
        
        if dictParams.keys.count == 0 {
            return
        }
        
        FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(uid)").updateChildValues(dictParams) { (error, reference) in
            self.loadUsers()
        }
    }
    
    fileprivate func loadUsers() {
        //=>    First check if user has lat and long, or location services enabled
        if let curUser = appDelegate.curUser {
            if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
                
                let alert = UIAlertController(title: "Oops", message: "Seems like Location Services are disabled for Vertx. \nPlease enable it.", preferredStyle: UIAlertControllerStyle.alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { (alert) -> Void in
                    self.navigationController?.popFadeViewController()
                }))
                
                alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (alert) -> Void in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }))
                
                self.present(alert, animated: true, completion: nil)
                
                return
            }
            else
                if curUser.latitude == nil || curUser.longitude == nil {
                    appDelegate.locationManager?.locationFixAchieved = false
                    appDelegate.locationManager?.locationManager.startUpdatingLocation()
                    
                    return
                }
        }
        
        //=>    Remove users from array
        arrUsers.removeAll(keepingCapacity: false)
        
        KVNProgress.show()
        
        //=>    Load all users
        FIRDatabase.database().reference().child(Constants.UserKeys.users).observeSingleEvent(of: .value, with: { [unowned self] (dataSnapshot) in
            for data in dataSnapshot.children {
                if let dataUser = data as? FIRDataSnapshot {
                    if var dictUser = dataUser.value as? [String: AnyObject] {
                        
                        //=>    Do not add logged in user
                        if appDelegate.curUser?.id != dataUser.key {
                            dictUser[Constants.UserKeys.userID] = dataUser.key as AnyObject
                            self.arrUsers.append(User(dictUser: dictUser))
                        }
                    }
                }
            }
            
            Async.main(after: 0.5, {
                KVNProgress.dismiss()
                
                self.arrUsers.sort(by: { $0.distance < $1.distance })
                self.collectionUsers.reloadData()
            })
        })
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    
    @IBAction fileprivate func btnBack_Action() {
        navigationController?.popFadeViewController()
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        
        let currentUser = arrUsers[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VXUserCell_ID", for: indexPath) as! VXUserCell
        
        cell.lblUserFullName.text   = currentUser.name
        cell.setDistanceLabelTextInKm(currentUser.distance)
        
        if let strProfileURL = currentUser.profileURL, let urlProfileImage = URL(string: strProfileURL) {
            cell.imgProfile.kf.setImage(with: urlProfileImage, placeholder: UIImage(named: "profile_icon"), options: [.transition(ImageTransition.fade(1))])
            { (image, error, cacheType, imageURL) in
                
                if let img = image {
                    cell.imgProfile.image = img.circle
                    cell.imgBackground.image = img
                }
            }
        }
        else {
            cell.imgProfile.image = UIImage(named: "profile_icon")
            cell.imgBackground.image = nil
            cell.backgroundColor = UIColor.vertxDarkBrown()
        }
        
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        let userSelected = arrUsers[indexPath.item]
        
        if let userProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "VXUserProfileVC") as? VXUserProfileVC {
            userProfileVC.selectedUser = userSelected
            navigationController?.pushFadeViewController(userProfileVC)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        //=>    We have 8px distance between cells
        let widthCell = (collectionView.frame.size.width - 8 ) / 2
        let heightCell = widthCell / 1.56
        
        return CGSize(width: widthCell, height: heightCell)
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("NEAR BY DEINIT")
        
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
