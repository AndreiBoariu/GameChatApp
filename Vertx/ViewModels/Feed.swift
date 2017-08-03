//
//  Feed.swift
//  Vertx
//
//  Created by Boariu Andy on 8/20/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import Foundation

class Feed: NSObject {
    var id              = ""
    var name            : String?
    var type            : String?
    var platform        : String?
    var about           : String?
    var imgURL          : String?
    var createdDate     : String?
    var createdByUser   : User?
    
    init(tempID          : String,
         tempName        : String?,
         tempType        : String?,
         tempPlatform    : String?,
         tempAbout       : String?,
         tempImgURL      : String?) {
        
        id = tempID
        name = tempName
        type = tempType
        platform = tempPlatform
        about = tempAbout
        imgURL = tempImgURL
    }
    
    init(dictFeed: [String: AnyObject]) {
        super.init()
        
        //dictFeed.prettyPrint()
        
        if let strFeedID = dictFeed[Constants.FeedKeys.feedID] as? String {
            id = strFeedID
        }
        
        if let strFeedName = dictFeed[Constants.FeedKeys.feedName] as? String {
            name = strFeedName
        }
        
        if let strFeedType = dictFeed[Constants.FeedKeys.feedType] as? String {
            type = strFeedType
        }
        
        if let strFeedPlatform = dictFeed[Constants.FeedKeys.feedPlatform] as? String {
            platform = strFeedPlatform
        }
        
        if let strFeedImgURL = dictFeed[Constants.FeedKeys.feedImageURL] as? String {
            imgURL = strFeedImgURL
        }
        
        if let strFeedDescription = dictFeed[Constants.FeedKeys.feedDescription] as? String {
            about = strFeedDescription
        }
        
        if let strCreatedDate = dictFeed[Constants.FeedKeys.feedCreatedDate] as? String {
            createdDate = strCreatedDate
        }
        
        if let feedCreatedByUser = dictFeed[Constants.FeedKeys.feedCreatedByUser] as? User {
            createdByUser = feedCreatedByUser
        }
    }
}