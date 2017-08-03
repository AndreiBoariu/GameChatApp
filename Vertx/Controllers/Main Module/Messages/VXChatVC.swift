//
//  VXChatVC.swift
//  Vertx
//
//  Created by Boariu Andy on 9/9/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import Async
import Kingfisher

class VXChatVC: VXBaseVC {
    
    @IBOutlet weak fileprivate var tblMessages: UITableView!
    @IBOutlet weak fileprivate var lblTitle: UILabel!
    
    @IBOutlet weak var consViewNewMessageBottom: NSLayoutConstraint!
    @IBOutlet weak var txvNewMessage: VerticallyCenteredTextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var arrMessages = [ChatMessage]()
    
    /// Store each reference for removeObserver call
    fileprivate var arrFirebaseReferences = [FIRDatabaseReference]()
    
    var selectedUserToChat : User?

    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
        
        setChatTitle()
        
        loadChat()
        
        NotificationCenter.default.addObserver(self, selector: #selector(VXChatVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VXChatVC.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // MARK: - Notification Methods
    
    func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.consViewNewMessageBottom.constant     = 0;
            self.view.layoutIfNeeded()
        }) 
    }
    
    func keyboardWillChangeFrame(_ notification: Notification) {
        if let dictUserInfo = notification.userInfo {
            if let rectEndFrame = (dictUserInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if let duration = dictUserInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                    UIView.animate(withDuration: duration, animations: { () -> Void in
                        self.consViewNewMessageBottom.constant     = rectEndFrame.size.height;
                        self.view.layoutIfNeeded()
                        }, completion: { (finished) -> Void in
                            self.scrollTableToBottom(true)
                    })
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func setChatTitle() {
        //=>    Make sure we have user id
        guard let selectedUser = selectedUserToChat else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        Async.background {
            if let strImgUrl = selectedUser.profileURL, let urlImage = URL(string: strImgUrl) {
                KingfisherManager.sharedManager.retrieveImageWithURL(urlImage, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
                    if let img = image {
                        self.lblTitle.addUserProfileImage(img, andUserName: selectedUser.name!, andAppendText: nil)
                    }
                    else {
                        self.lblTitle.addUserProfileImage(nil, andUserName: selectedUser.name!, andAppendText: nil)
                    }
                })
            }
            else {
                self.lblTitle.addUserProfileImage(nil, andUserName: selectedUser.name!, andAppendText: nil)
            }
        }
    }
    
    fileprivate func setupUI() {
        tblMessages.estimatedRowHeight = 60
        tblMessages.rowHeight = UITableViewAutomaticDimension
    }
    
    fileprivate func loadChat() {
        //=>    Make sure we have current user logged in
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //=>    Make sure we have user id
        guard let selectedUser = selectedUserToChat else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        
        
        let userMessagesRef = FIRDatabase.database().reference().child(Constants.UserMessageKeys.userMessages).child(uid).child(selectedUser.id)
        userMessagesRef.observe(.childAdded, with: { (userMessageDataSnapshot) in
            let messageID = userMessageDataSnapshot.key
            
            FIRDatabase.database().reference().child(Constants.ChatMessageKeys.chatMessages).child(messageID)
                .observeSingleEvent(of: .value, with: {[unowned self] (snapshotMessage) in
                    
                    guard let dictChatMessage = snapshotMessage.value as? [String: AnyObject] else {
                        return
                    }
                    
                    self.arrMessages.append(ChatMessage(dictMessage: dictChatMessage))
                    
                    //=>    Reload table
                    self.tblMessages.beginUpdates()
                    let indexPath = IndexPath(row: self.arrMessages.count - 1, section: 0)
                    self.tblMessages.insertRows(at: [indexPath], with: .automatic)
                    self.tblMessages.endUpdates()
                    
                    self.scrollTableToBottom(true)
            })
        })
        
        arrFirebaseReferences.append(userMessagesRef)
    }
    
    func scrollTableToBottom(_ animated: Bool) {
        if arrMessages.count > 0 {
            let indexPath           = IndexPath(row: arrMessages.count - 1, section: 0)
            tblMessages.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    func didChangeText() {
        if txvNewMessage.text == k_NewMessage_Placeholder {
            txvNewMessage.text      = ""
            btnSend.isEnabled         = false
        }
        else
            if txvNewMessage.text.length == 0 {
                btnSend.isEnabled       = false
            }
            else {
                btnSend.isEnabled       = true
            }
    }
    
    // MARK: - API Methods
    
    func sendMessage_APICall() {
        //=>    Make sure we have current user logged in
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        //=>    Make sure we have user id
        guard let selectedUser = selectedUserToChat else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Something went wrong. Please try again!")
            self.present(alert, animated: true, completion: nil)
            
            navigationController?.popFadeViewController()
            
            return
        }
        
        //=>    Hide btnSend and display spinner
        spinner.isHidden = false
        spinner.startAnimating()
        btnSend.isEnabled = false
        btnSend.isHidden = true
        
        //=>    Build flow for adding new message
        let chatMessagesRef = FIRDatabase.database().reference().child(Constants.ChatMessageKeys.chatMessages)
        let childChatMessagesRef = chatMessagesRef.childByAutoId()
        
        let toUserID = selectedUser.id
        let fromUserID = uid
        
        let dictParams = [Constants.ChatMessageKeys.chatMessageText : txvNewMessage.text]
        
        var dictValues = [Constants.ChatMessageKeys.chatMessageToUserWithID: toUserID,
                          Constants.ChatMessageKeys.chatMessageFromUserWithID: fromUserID]
        if let strCreatedDate = VertxUtils.getStringDateFromDate(Date()) {
            dictValues[Constants.ChatMessageKeys.chatMessageCreatedDate] = strCreatedDate
        }
        
        dictParams.forEach({dictValues[$0] = $1})
        
        childChatMessagesRef.updateChildValues(dictValues) { (error, reference) in
            
            Async.main(block: {
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.btnSend.isHidden = false
                
                if let error = error {
                    
                    let alert = VertxUtils.okCustomAlert("Oops!", message: "Something bad happened while posting new chat message! Please try again! \n\n \(error.localizedDescription)")
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                else {
                    self.txvNewMessage.text = ""
                }
            })
            
            //=>    Save info about users
            let userMessagesRef = FIRDatabase.database().reference().child(Constants.UserMessageKeys.userMessages).child(fromUserID).child(toUserID)
            
            let messageId = childChatMessagesRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = FIRDatabase.database().reference().child(Constants.UserMessageKeys.userMessages).child(toUserID).child(fromUserID)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction fileprivate func btnBack_Action(_ sender: AnyObject) {
        navigationController?.popFadeViewController()
    }
    
    @IBAction func btnSendMessage_Action() {
        sendMessage_APICall()
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let curMessage = arrMessages[indexPath.row]
        
        if curMessage.fromUserId == FIRAuth.auth()?.currentUser?.uid {
            //=>    My Messages
            let cell = tableView.dequeueReusableCell(withIdentifier: "VXMyMessageChatCell_ID", for: indexPath) as! VXMyMessageChatCell
            cell.lblMyMessage.text = curMessage.messageText
            
            if let strCreatedDate = curMessage.createdDate {
                cell.lblTime.text = VertxUtils.getWriteMessageTimeFromCreatedTime(strCreatedDate)
            }
            
            return cell
        }
        else {
            //=>    User Messages
            let cell = tableView.dequeueReusableCell(withIdentifier: "VXUserMessageChatCell_ID", for: indexPath) as! VXUserMessageChatCell
            cell.lblUserMessage.text = curMessage.messageText
            
            if let strCreatedDate = curMessage.createdDate {
                cell.lblTime.text = VertxUtils.getWriteMessageTimeFromCreatedTime(strCreatedDate)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if txvNewMessage.isFirstResponder {
            txvNewMessage.resignFirstResponder()
        }
    }
    // MARK: - UITextFieldDelegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        txvNewMessage.text              = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        txvNewMessage.text              = k_NewMessage_Placeholder
        btnSend.isEnabled                 = false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            txvNewMessage.text          = txvNewMessage.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            sendMessage_APICall()
        }
        else {
            Async.main(after: 0.01, block: { 
                self.didChangeText()
            })
        }
        
        return true
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("CHAT DEINIT")
        
        for reference in arrFirebaseReferences {
            reference.removeAllObservers()
        }
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
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
