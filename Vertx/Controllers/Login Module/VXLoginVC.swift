//
//  VXLoginVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/17/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import SDVersion
import KVNProgress
import Async

class VXLoginVC: VXBaseVC {

    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var viewInput: UIView!
    @IBOutlet weak var consViewInputBottom: NSLayoutConstraint!
    @IBOutlet weak var consImgLogoTop: NSLayoutConstraint!
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        #if DEBUG
            txfEmail.text = "boariu.andrey@gmail.com"
            //txfEmail.text = "naomi.boariu@gmail.com"
            txfPassword.text = "Andrei9011"
        #endif
        
        //=>    Setup UI
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //=>    Add observer only for iPhone 4
        if SDiOSVersion.deviceSize() == DeviceSize.Screen3Dot5inch {
            NotificationCenter.default.addObserver(self, selector: #selector(VXLoginVC.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if SDiOSVersion.deviceSize() == DeviceSize.Screen3Dot5inch {
            NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillShow)
        }
    }
    
    
    // MARK: - Notification Methods
    
    func keyboardWillShowNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
                let frame                           = frameValue.cgRectValue
                consViewInputBottom.constant     = frame.size.height
                
                if let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                    UIView.animate(withDuration: duration, animations: {
                        self.view.layoutIfNeeded()
                        }, completion: { (finished) in
                            
                    })
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func setupUI() {
        //=>    Prefill last login credentials
        if let strEmail = SessionManager.currentUserEmail {
           txfEmail.text = strEmail
        }
        
        if let strPassword = SessionManager.currentUserPassword {
            txfPassword.text = strPassword
        }
        
        btnSignIn.layer.cornerRadius = 25.0
        btnSignUp.layer.cornerRadius = 25.0
        btnSignUp.layer.borderWidth = 1.5
        btnSignUp.layer.borderColor = UIColor.vertxDarkOrange().cgColor
        
        if SDiOSVersion.deviceSize() == DeviceSize.Screen3Dot5inch || SDiOSVersion.deviceSize() == DeviceSize.Screen4inch {
            consImgLogoTop.constant = -30
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - API Methods
    
    /// Check if fields are completed corectly then login user with Firebase
    func loginUser() {
        view.endEditing(true)
        
        if let strEmail = txfEmail.text, !strEmail.isEmpty {
            if VertxUtils.isValidEmail(strEmail) {
                if let strPassword = txfPassword.text, !strPassword.isEmpty {
                    
                    KVNProgress.show()
                    
                    FIRAuth.auth()?.signIn(withEmail: strEmail, password: strPassword, completion: { (user, error) in
                        if let user = user {
                            
                            KVNProgress.dismiss()
                            
                            if !user.isEmailVerified {
                                Async.main(block: {
                                    let alertVC = UIAlertController(title: "Oops", message: "Your email address has not yet been verified. \n Do you want us to send another verification email to `\(strEmail)`?", preferredStyle: .alert)
                                    let alertActionOkay = UIAlertAction(title: "Yes", style: .default) {
                                        (_) in
                                        user.sendEmailVerification(completion: nil)
                                    }
                                    let alertActionCancel = UIAlertAction(title: "No", style: .default, handler: nil)
                                    
                                    alertVC.addAction(alertActionCancel)
                                    alertVC.addAction(alertActionOkay)
                                    
                                    self.present(alertVC, animated: true, completion: nil)
                                })
                            }
                            else {
                                
                                //=>    Update user with details
                                self.updateUserInfo(user.uid)
                                
                                //=>    Save local just to prefill after logout
                                SessionManager.currentUserEmail = strEmail
                                SessionManager.currentUserPassword = strPassword
                                SessionManager.syncUserDefaults()
                                
                                KVNProgress.showSuccess(withStatus: "Logged in successfully!", completion: {
                                    self.dismiss(animated: true, completion: nil)
                                })
                            }
                        }
                        else
                            if let error = error {
                                
                                KVNProgress.dismiss()
                                
                                Async.main(block: {
                                    if error.code == 17009 {
                                        //=>    FIRAuthErrorCodeWrongPassword
                                        let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems password is wrong. Please try again")
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                    else
                                        if error.code == 17011 {
                                            //=>    FIRAuthErrorCodeUserNotFound
                                            let alert = VertxUtils.okCustomAlert("Oops!", message: "No user found with this email")
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                        else {
                                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while creating new user! Please try again! \n\n \(error.localizedDescription)")
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                })
                        }
                    })
                }
                else {
                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Password must not be blank")
                    self.present(alert, animated: true, completion: nil)
                }
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
        
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child(Constants.UserKeys.users).child(uid)
        usersReference.updateChildValues(dictParams)
    }
    
    // MARK: - Action Methods
    
    @IBAction func btnBackground_Action() {
        view.endEditing(true)
    }
    
    @IBAction func btnSignIn_Action() {
        loginUser()
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txfEmail {
            txfPassword.becomeFirstResponder()
        }
        else
            if textField == txfPassword {
                //=>    Login user
                loginUser()
            }
        
        return true
    }
    
    // MARK: - Memory Cleanup

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("LOGIN DEINIT")
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
