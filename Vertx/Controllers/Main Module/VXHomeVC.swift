//
//  VXHomeVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/17/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase

class VXHomeVC: VXBaseVC {

    @IBOutlet weak var viewFeeds: UIView!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var viewNearBy: UIView!
    @IBOutlet weak var viewSettings: UIView!
    @IBOutlet weak var viewFavorite: UIView!
    @IBOutlet weak var viewMessages: UIView!
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //=>    Setup UI
        setupUI()        
    }
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func setupUI() {
        viewFeeds.layer.cornerRadius = 5.0
        viewProfile.layer.cornerRadius = 5.0
        viewNearBy.layer.cornerRadius = 5.0
        viewSettings.layer.cornerRadius = 5.0
        viewFavorite.layer.cornerRadius = 5.0
        viewMessages.layer.cornerRadius = 5.0
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    
    @IBAction func btnFeeds_Action(_ sender: UIButton) {
        if let feedVC = storyboard?.instantiateViewController(withIdentifier: "VXFeedsVC") as? VXFeedsVC {
            feedVC.feedOptionScreen = .allFeeds
            navigationController?.pushFadeViewController(feedVC)
        }
    }
    
    @IBAction func btnSettings_Action(_ sender: UIButton) {
        if let settingsVC = storyboard?.instantiateViewController(withIdentifier: "VXSettingsVC") as? VXSettingsVC {
            navigationController?.pushFadeViewController(settingsVC)
        }
    }
    
    @IBAction func btnNearBy_Action(_ sender: UIButton) {
        if let nearByVC = storyboard?.instantiateViewController(withIdentifier: "VXNearByVC") as? VXNearByVC {
            navigationController?.pushFadeViewController(nearByVC)
        }
    }
    
    @IBAction func btnAbout_Action(_ sender: UIButton) {
        if let aboutVC = storyboard?.instantiateViewController(withIdentifier: "VXAboutVC") as? VXAboutVC {
            navigationController?.pushFadeViewController(aboutVC)
        }
    }
    
    @IBAction func btnProfile_Action(_ sender: UIButton) {
        if let myProfileVC = storyboard?.instantiateViewController(withIdentifier: "VXMyProfileVC") as? VXMyProfileVC {
            navigationController?.pushFadeViewController(myProfileVC)
        }
    }
    
    @IBAction func btnFavorites_Action(_ sender: UIButton) {
        if let favVC = storyboard?.instantiateViewController(withIdentifier: "VXFavoritesVC") as? VXFavoritesVC {
            navigationController?.pushFadeViewController(favVC)
        }
    }
    
    @IBAction func btnMessages_Action(_ sender: UIButton) {
        if let messagesVC = storyboard?.instantiateViewController(withIdentifier: "VXMyMessagesVC") as? VXMyMessagesVC {
            navigationController?.pushFadeViewController(messagesVC)
        }
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("HOME DEINIT")
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
