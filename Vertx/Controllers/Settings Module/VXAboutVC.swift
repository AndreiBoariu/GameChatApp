//
//  VXAboutVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/17/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import MessageUI

class VXAboutVC: VXBaseVC, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var txvText: UITextView!
    
    // MARK: - View Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //=>    Show first line in text view
        txvText.setContentOffset(CGPoint.zero, animated: true)
    }
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    func presentNewMessageController() {
        if !MFMessageComposeViewController.canSendText() {
            let alertView = VertxUtils.okCustomAlert("Oops", message: "Your device doesn't support sending message!")
            self.present(alertView, animated: true, completion: nil)
            
            return
        }
        
        let messageController                       = MFMessageComposeViewController()
        messageController.messageComposeDelegate    = self
        messageController.recipients                = ["Vertx.opperations@gmail.com"]
        messageController.body                      = ""
        
        self.present(messageController, animated: true) { () -> Void in
            
        }
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    
    @IBAction fileprivate func btnBack_Action() {
        navigationController?.popFadeViewController()
    }
    
    @IBAction func btnContactUs_Action(_ sender: AnyObject) {
        presentNewMessageController()
    }
    
    // MARK: - MFMessageComposeViewControllerDelegate Methods
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch(result.rawValue) {
        case MessageComposeResultFailed.rawValue:
            let alertView  = VertxUtils.okCustomAlert("Error", message: "Failed to send SMS.")
            self.present(alertView, animated: true, completion: nil)
        
        default:
            break
        }
        
        controller.dismiss(animated: true, completion: { () -> Void in
            //UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        })
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("ABOUT DEINIT")
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
