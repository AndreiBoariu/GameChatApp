//
//  VXMyMessagesVC.swift
//  Vertx
//
//  Created by Boariu Andy on 9/9/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import UIKit
import Firebase
import Async

class VXMyMessagesVC: VXBaseVC {
    
    @IBOutlet weak fileprivate var tblMessages: UITableView!
    
    var arrMessages = [ChatMessage]()
    var dictMessages = [String: ChatMessage]()
    
    /// Store each reference for removeObserver call
    fileprivate var arrFirebaseReferences = [FIRDatabaseReference]()

    // MARK: - View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //=>    Load chats
        getUserChats()
    }

    
    
    // MARK: - Notification Methods
    
    // MARK: - Public Methods
    
    // MARK: - Custom Methods
    
    fileprivate func getUserChats() {
        //=>    Make sure we have current user logged in
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            let alert = VertxUtils.okCustomAlert("Oops!", message: "Seems your session expired. Please try to login!")
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        let ref = FIRDatabase.database().reference().child(Constants.UserMessageKeys.userMessages).child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let fromUserID = snapshot.key
            
            FIRDatabase.database().reference().child(Constants.UserMessageKeys.userMessages).child(uid).child(fromUserID).observe(.childAdded, with: { (messageSnapshot) in
                let messageID = messageSnapshot.key
                self.fetchMessageWithID(messageID)
            })
        })
    }
    
    fileprivate func fetchMessageWithID(_ messageID: String) {
        let messageRef = FIRDatabase.database().reference().child(Constants.ChatMessageKeys.chatMessages).child(messageID)
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if var dictMessage = snapshot.value as? [String: AnyObject] {
                dictMessage[Constants.ChatMessageKeys.chatMessageID] = snapshot.key as AnyObject
                let message = ChatMessage(dictMessage: dictMessage)
                
                if let chatPartnerID = message.chatPartnerId() {
                    self.dictMessages[chatPartnerID] = message
                }
                
                self.handleReloadDataInTableView()
            }
        })
    }
    
    fileprivate func handleReloadDataInTableView() {
        arrMessages = Array(dictMessages.values)
        arrMessages.sort(by: { (message1, message2) -> Bool in
            if let strDate1 = message1.createdDate, let strDate2 = message2.createdDate {
                let createdData1 = VertxUtils.getDateFromStringDate(strDate1)
                let createdData2 = VertxUtils.getDateFromStringDate(strDate2)
                
                return createdData1 > createdData2
            }
            else {
                return false
            }
        })
        
        Async.main { 
            self.tblMessages.reloadData()
        }
    }
    
    // MARK: - API Methods
    
    // MARK: - Action Methods
    
    @IBAction fileprivate func btnBack_Action(_ sender: AnyObject) {
        navigationController?.popFadeViewController()
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VXUserMessageCell_ID", for: indexPath) as! VXUserMessageCell
        
        let curMessage = arrMessages[indexPath.row]
        cell.message = curMessage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let curMessage = arrMessages[indexPath.row]
        
        guard let chatPartnerID = curMessage.chatPartnerId() else {
            return
        }
        
        FIRDatabase.database().reference().child(Constants.UserKeys.users).child(chatPartnerID).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            if var dictUser = dataSnapshot.value as? [String: AnyObject] {
                //=>    Create user
                dictUser[Constants.UserKeys.userID] = dataSnapshot.key as AnyObject
                let toUser = User(dictUser: dictUser)
                
                //=>    Pass user in Chat VC
                if let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "VXChatVC") as? VXChatVC {
                    chatVC.selectedUserToChat = toUser
                    self.navigationController?.pushFadeViewController(chatVC)
                }
            }
        })
    }
    
    // MARK: - Memory Cleanup
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("MY MESSAGES DEINIT")
        
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
