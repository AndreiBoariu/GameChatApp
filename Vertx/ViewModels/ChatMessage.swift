//
//  ChatMessage.swift
//  Vertx
//
//  Created by Boariu Andy on 9/9/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import Foundation
import Firebase

class ChatMessage: NSObject {
    
    var id = ""
    var messageText  = ""
    var fromUserId: String?
    var createdDate: String?
    var toUserId: String?
    
    func chatPartnerId() -> String? {
        return fromUserId == FIRAuth.auth()?.currentUser?.uid ? toUserId : fromUserId
    }
    
    init(dictMessage: [String: AnyObject]) {
        super.init()
        
        //dictFeed.prettyPrint()
        
        if let strMessageID = dictMessage[Constants.ChatMessageKeys.chatMessageID] as? String {
            id = strMessageID
        }
        
        if let strMessageText = dictMessage[Constants.ChatMessageKeys.chatMessageText] as? String {
            messageText = strMessageText
        }
        
        if let strFromUserID = dictMessage[Constants.ChatMessageKeys.chatMessageFromUserWithID] as? String {
            fromUserId = strFromUserID
        }
        
        if let strCreatedDate = dictMessage[Constants.ChatMessageKeys.chatMessageCreatedDate] as? String {
            createdDate = strCreatedDate
        }
        
        if let strToUserID = dictMessage[Constants.ChatMessageKeys.chatMessageToUserWithID] as? String {
            toUserId = strToUserID
        }
    }
}
