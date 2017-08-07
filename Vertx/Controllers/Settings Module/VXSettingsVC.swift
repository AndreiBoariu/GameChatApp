//
//  VXSettingsVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/27/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class VXSettingsVC: VXBaseVC, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblSettings: UITableView!
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //=>    Hide extra separtors
        tblSettings.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    func logout() {
        let alert = UIAlertController(title: "Logout of Vertx?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [unowned self] action in
            do {
                try FIRAuth.auth()?.signOut()
                
                //ImageCache.defaultCache.clearDiskCache()
                //ImageCache.defaultCache.clearMemoryCache()
                
                appDelegate.curUser = nil
                
            } catch let logoutError {
                print(logoutError)
            }
            
            self.navigationController?.popToRootViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) { $0})
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    
    @IBAction fileprivate func btnBack_Action() {
        navigationController?.popFadeViewController()
    }
    
    // MARK: - UITableViewDelegate Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VXSettingsCell_ID", for: indexPath) as! VXSettingsCell
        switch indexPath.row {
        case 0:
            
            cell.lblInfoLeft.text = "Version"
            cell.lblInfoRight.text = UIApplication.appVersion()
            
        
        case 1:
            cell.lblInfoLeft.text = "Build"
            cell.lblInfoRight.text = UIApplication.appBuild()
            
        case 2:
            cell.lblInfoLeft.text = "Device"
            cell.lblInfoRight.text = "\(UIDevice.current.model) (\(UIDevice.current.systemVersion))"
            
        case 3:
            cell.lblInfoLeft.text = "Logout"
            cell.accessoryType = .disclosureIndicator
            cell.isUserInteractionEnabled = true
        
        default:
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 3 {
            //=>    Logout selected
            logout()
        }
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("SETTINGS DEINIT")
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
