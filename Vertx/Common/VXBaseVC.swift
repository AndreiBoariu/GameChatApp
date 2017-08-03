//
//  VXBaseVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/17/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit

class VXBaseVC: VXImportImageVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - StatusBar Methods
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .fade
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    // MARK: - Memory Warning Methods
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
