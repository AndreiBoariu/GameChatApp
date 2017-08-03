//
//  VXSignUpVC.swift
//  Vertx
//
//  Created by Boariu Andy on 8/17/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import SDVersion
import Photos
import Firebase
import KVNProgress
import Async

class VXSignUpVC: VXBaseVC {
    
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var txfEmail: UITextField!
    @IBOutlet weak var txfName: UITextField!
    @IBOutlet weak var txfAge: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    @IBOutlet weak var txfConfirmPassword: UITextField!
    @IBOutlet weak var viewInput: UIView!
    @IBOutlet weak var consBtnAddImageTop: NSLayoutConstraint!
    
    var imagePicker          = UIImagePickerController()
    
    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //=>    Setup UI
        setupUI()
        
        //=>    Add recognizer to view big input
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewInput_tapGesture(_:)))
        viewInput.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func setupUI() {
        btnSignUp.layer.cornerRadius = 25.0
        
        //=>    For iPhone 5, minimaze space from top
        if SDiOSVersion.deviceSize() == DeviceSize.Screen4inch {
            consBtnAddImageTop.constant = 0
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - API Methods
    
    /// Check if user filled all fields, then create account, upload image, save new user in database
    func signUp() {
        view.endEditing(true)
        
        if let strEmail = txfEmail.text, !strEmail.isEmpty {
            if VertxUtils.isValidEmail(strEmail) {
                if let strName = txfName.text, !strName.isEmpty {
                    if let strAge = txfAge.text, !strAge.isEmpty {
                        if let strPassword = txfPassword.text, !strPassword.isEmpty {
                            if strPassword.length > 5 {
                                if let strConfirmPass = txfConfirmPassword.text, !strConfirmPass.isEmpty {
                                    if strPassword == strConfirmPass {
                                        
                                        let alert = UIAlertController(title: "Email confirmation",  message: "Your email is:\n\n'\(strEmail)'\n\nAre you sure this is correct? We will send you an email to verify it!", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Edit", style: .cancel, handler: { _ in
                                            self.txfEmail.becomeFirstResponder()
                                        }))
                                        alert.addAction(UIAlertAction(title: "Use it", style: .default, handler: { _ in
                                            KVNProgress.show()
                                            
                                            FIRAuth.auth()?.createUser(withEmail: strEmail, password: strPassword, completion: { (user: FIRUser?, error) in
                                                
                                                if let error = error {
                                                    
                                                    KVNProgress.dismiss()
                                                    
                                                    Async.main {
                                                        if error._code == 17007 {
                                                            //=>    FIRAuthErrorCodeEmailAlreadyInUse
                                                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Selected email already in use. Please choose another")
                                                            self.present(alert, animated: true, completion: nil)
                                                        }
                                                        else {
                                                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while creating new user! Please try again! \n\n \(error.localizedDescription)")
                                                            self.present(alert, animated: true, completion: nil)
                                                        }
                                                    }
                                                    
                                                    return
                                                }
                                                
                                                guard let curUser = user else {
                                                    KVNProgress.dismiss()
                                                    
                                                    Async.main {
                                                        let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while creating new user! Please try again!")
                                                        self.present(alert, animated: true, completion: nil)
                                                    }
                                                    
                                                    return
                                                }
                                                
                                                guard let uid = user?.uid else {
                                                    KVNProgress.dismiss()
                                                    
                                                    return
                                                }
                                                
                                                //=>    Check if user sets profile image
                                                if let imgActualProfile = self.btnChangeImage.currentImage, !imgActualProfile.isEqual(UIImage(named: "add_photo")) {
                                                    let imgProfile = VertxUtils.resizeImage(imgActualProfile, targetSize: CGSize(width: 200, height: 200))
                                                    
                                                    //=>    Convert image to .jpg
                                                    if let uploadData = UIImageJPEGRepresentation(imgProfile, 0.1) {
                                                        
                                                        let imageName = UUID().uuidString
                                                        let storageRef = FIRStorage.storage().reference().child(Constants.UserKeys.userImages).child("\(imageName).jpg")
                                                        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                                                            
                                                            if error != nil {
                                                                
                                                                KVNProgress.dismiss()
                                                                
                                                                Async.main {
                                                                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while uploading profile image! Please try again! \n\n \(String(describing: error?.localizedDescription))")
                                                                    self.present(alert, animated: true, completion: nil)
                                                                }
                                                                
                                                                return
                                                            }
                                                            
                                                            if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                                                                
                                                                var values = [Constants.UserKeys.userFullName: strName,
                                                                    Constants.UserKeys.userEmail: strEmail,
                                                                    Constants.UserKeys.userProfileURL: profileImageUrl,
                                                                    Constants.UserKeys.userAge: strAge]
                                                                
                                                                if let locationManager = appDelegate.locationManager {
                                                                    if locationManager.locationFixAchieved {
                                                                        values[Constants.UserKeys.userLatitude] = "\(locationManager.lastLocationFix.coordinate.latitude)"
                                                                        values[Constants.UserKeys.userLongitude] = "\(locationManager.lastLocationFix.coordinate.longitude)"
                                                                    }
                                                                }
                                                                
                                                                self.registerUserIntoDatabaseWithUID(curUser, uid: uid, values: values as [String : AnyObject])
                                                            }
                                                        })
                                                    }
                                                }
                                                else {
                                                    var values = [Constants.UserKeys.userFullName: strName,
                                                        Constants.UserKeys.userEmail: strEmail,
                                                        Constants.UserKeys.userAge: strAge]
                                                    
                                                    if let locationManager = appDelegate.locationManager {
                                                        if locationManager.locationFixAchieved {
                                                            values[Constants.UserKeys.userLatitude] = "\(locationManager.lastLocationFix.coordinate.latitude)"
                                                            values[Constants.UserKeys.userLongitude] = "\(locationManager.lastLocationFix.coordinate.longitude)"
                                                        }
                                                    }
                                                    
                                                    self.registerUserIntoDatabaseWithUID(curUser, uid: uid, values: values as [String : AnyObject])
                                                }
                                            })
                                        }))
                                        
                                        self.present(alert, animated:true, completion:nil)
                                    }
                                    else {
                                        let alert = VertxUtils.okCustomAlert("Oops!", message: "Re-enter password must be the same with password")
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                                else {
                                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Re-enter password must not be blank")
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                            else {
                                let alert = VertxUtils.okCustomAlert("Oops!", message: "Password must be minimum 6 chars")
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                        else {
                            let alert = VertxUtils.okCustomAlert("Oops!", message: "Password must not be blank")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else {
                        let alert = VertxUtils.okCustomAlert("Oops!", message: "Age must not be blank")
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else {
                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Name must not be blank")
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
    
    fileprivate func registerUserIntoDatabaseWithUID(_ user: FIRUser, uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        let usersReference = ref.child(Constants.UserKeys.users).child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (error, ref) in
            
            if error != nil {
                
                KVNProgress.dismiss()
                
                Async.main {
                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while creating new user! Please try again! \n\n \(error?.localizedDescription)")
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            //=>    Send verification email to user
            user.sendEmailVerification(completion: nil)
            
            KVNProgress.showSuccess(withStatus: "Account created successfully! \n Please check your inbox to verify your email", completion: {
                self.navigationController?.popViewController(animated: true)
            })
        })
    }
    
    // MARK: - Action Methods
    
    func viewInput_tapGesture(_ sender: AnyObject) {
        view.endEditing(true)
    }
    
    @IBAction func btnBack_Action() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSignUp_Action() {
        view.endEditing(true)
        
        signUp()
    }
    
    @IBAction func btnAddImage_Action() {
        view.endEditing(true)
        
        displayCameraOptionsWithTitle("Profile Image")
    }
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txfEmail {
            txfName.becomeFirstResponder()
        }
        else
            if textField == txfName {
                txfAge.becomeFirstResponder()
            }
            else
                if textField == txfAge {
                    txfPassword.becomeFirstResponder()
                }
                else
                    if textField == txfPassword {
                        txfConfirmPassword.becomeFirstResponder()
                    }
                    else
                        if textField == txfConfirmPassword {
                            //=>    Call SignUp API
                            signUp()
                        }
        
        return true
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("SIGN UP DEINIT")
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
