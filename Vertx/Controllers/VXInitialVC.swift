//
//  VXInitialVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/17/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Async
import Firebase
import FirebaseAuth

class VXInitialVC: VXBaseVC {
    
    /// Store each reference for removeObserver call
    fileprivate var arrFirebaseReferences = [FIRDatabaseReference]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //=>    Check if user exists
        if let curUser = FIRAuth.auth()?.currentUser {
            if curUser.isEmailVerified {
                
                //=>    Load info for current user
                loadCurrentUser(curUser.uid)
                
                //=>    Push home vc
                if let homeVC = storyboard?.instantiateViewController(withIdentifier: "VXHomeVC") as? VXHomeVC {
                    navigationController?.pushFadeViewController(homeVC)
                }
            }
            else {
                if let navLogin = self.storyboard?.instantiateViewController(withIdentifier: "Login_NC") as? UINavigationController {
                    self.present(navLogin, animated: true, completion: nil)
                }
            }
        }
        else {
            if let navLogin = self.storyboard?.instantiateViewController(withIdentifier: "Login_NC") as? UINavigationController {
                self.present(navLogin, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Custom Methods
    
    /// Just get logged in user full info
    func loadCurrentUser(_ userID: String) {
        let ref = FIRDatabase.database().reference().child("\(Constants.UserKeys.users)/\(userID)")
        ref.observe(.value, with: { (dataSnapshot) in
            if var dictUser = dataSnapshot.value as? [String: AnyObject] {
                
                //=>    Add id of cur user, then update it
                dictUser[Constants.UserKeys.userID] = dataSnapshot.key as AnyObject
                appDelegate.curUser = User(dictUser: dictUser)
            }
        })
        arrFirebaseReferences.append(ref)
    }

    // MARK: - Memory Warning Methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("INITIAL VC DEINIT")
        
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
