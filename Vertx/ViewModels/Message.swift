//
//  Message.swift
//  Vertx
//
//  Created by Boariu Andy on 9/5/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import Foundation
import Firebase

class Message: NSObject {
    
    var id = ""
    var messageText  = ""
    var createdByUserWithName       : String?
    var createdByUserWithID         : String?
    var createdByUserWithProfileURL : String?
    var createdDate                 : String?
    var createdByUser               : User?
    
    init(dictMessage: [String: AnyObject]) {
        super.init()
        
        //dictFeed.prettyPrint()
        
        if let strMessageID = dictMessage[Constants.MessageKeys.messageID] as? String {
            id = strMessageID
        }
        
        if let strMessageText = dictMessage[Constants.MessageKeys.messageText] as? String {
            messageText = strMessageText
        }
        
        if let strUserName = dictMessage[Constants.MessageKeys.messageFromUserWithName] as? String {
            createdByUserWithName = strUserName
        }
        
        if let strUserID = dictMessage[Constants.MessageKeys.messageFromUserWithID] as? String {
            createdByUserWithID = strUserID
        }
        
        if let strUserImgURL = dictMessage[Constants.MessageKeys.messageFromUserWithProfileURL] as? String {
            createdByUserWithProfileURL = strUserImgURL
        }
        
        if let strCreatedDate = dictMessage[Constants.MessageKeys.messageCreatedDate] as? String {
            createdDate = strCreatedDate
        }
        
        if let messageCreatedByUser = dictMessage[Constants.MessageKeys.messageCreatedByUser] as? User {
            createdByUser = messageCreatedByUser
        }
    }
}