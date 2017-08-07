//
//  VXForgotPassVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/17/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import KVNProgress
import Async
import SDVersion

class VXForgotPassVC: VXBaseVC {

    @IBOutlet weak var btnBackground: UIButton!
    @IBOutlet weak var btnResendPass: UIButton!
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var consImgLogoTop: NSLayoutConstraint!
    @IBOutlet weak var consViewInputTop: NSLayoutConstraint!
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func setupUI() {
        btnResendPass.layer.cornerRadius = 25.0
        
        txfEmail.becomeFirstResponder()
        
        if SDiOSVersion.deviceSize() == DeviceSize.Screen3Dot5inch || SDiOSVersion.deviceSize() == DeviceSize.Screen4inch {
            consImgLogoTop.constant = -65
            consViewInputTop.constant = -20
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - API Methods
    
    /// Check if email is correct, and reset password trough Firebase
    func resendEmail_API() {
        view.endEditing(true)
        
        if let strEmail = txfEmail.text, !strEmail.isEmpty {
            if VertxUtils.isValidEmail(strEmail) {
                
                KVNProgress.show()
                
                FIRAuth.auth()?.sendPasswordReset(withEmail: strEmail, completion: { (error) in
                    if let error = error {
                        KVNProgress.dismiss()
                        
                        Async.main {
                            if error._code == 17011 {
                                //=>    FIRAuthErrorCodeUserNotFound
                                let alert = VertxUtils.okCustomAlert("Oops!", message: "No user found with this email")
                                self.present(alert, animated: true, completion: nil)
                            }
                            else {
                                let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while sending email to change password! Please try again! \n\n \(error.localizedDescription)")
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        
                        return
                    }
                    
                    KVNProgress.showSuccess(withStatus: "Email sent! \n Please check your inbox to change your password.", completion: {
                        self.navigationController?.popViewController(animated: true)
                    })
                })
            }
            else {
                let alert = VertxUtils.okCustomAlert("Oops!", message: "Please enter a valid email")
                self.present(alert, animated: true, completion: nil)
            }
        }
        else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Email must not be blank")
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Action Methods
    
    func imgBackground_tapGesture(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func btnBack_Action() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnResendPassword_Action(_ sender: AnyObject) {
        resendEmail_API()
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfEmail {
            resendEmail_API()
        }
        
        return true
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("FORGOT PASS DEINIT")
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
