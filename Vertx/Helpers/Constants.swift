//
//  Constants.swift
//  Vertx
//
//  Created by Boariu Andy on 8/12/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import Foundation
import UIKit

public enum FeedScreenOption : Int {
    case allFeeds = 0
    case userFeeds
    case myFeeds
}

public enum FeedTypes: String {
    case GameDiscussion     = "Game Discussion"
    case News               = "News"
    case LookingForGroup    = "Looking for Group"
}

public enum Favorites : Int {
    case users = 0
    case feeds
}

public enum AddImage : Int {
    case fromSignUp = 0
    case fromAddEditFeed
    case fromMyProfile
}

struct Constants {
    
    static let arrPlatforms         = ["Xbox One", "PS4", "PC", "Wii U", "Xbox 360", "PS3", "Other"]
    
    struct FeedKeys {
        static let arrFeedTypes = ["Game Discussion" , "News" , "Looking for Group"]
        
        /// Node value for feed
        static let feeds            = "feeds"
        static let feedID           = "feed_id"
        static let feedName         = "feed_name"
        static let feedPlatform     = "feed_platform"
        static let feedImageURL     = "feed_imageUrl"
        static let feedType         = "feed_type"
        static let feedDescription  = "feed_description"
        static let feedCreatedDate  = "feed_createdDate"
        static let feedMessages     = "feed_messages"
        
        /// Name of folder where feed images are stored
        static let feedImages       = "feed_images"
        
        //=>    Aditional optional keys
        static let feedCreatedByUser    = "feed_createdByUser"
    }
    
    struct UserKeys {
        
        /// Node value for user
        static let users                    = "users"
        static let userID                   = "user_id"
        static let userFeeds                = "user_feeds"
        static let userFavoritesUsers       = "user_favoritesUsers"
        static let userFavoritesFeeds       = "user_favoritesFeeds"
        static let userEmail                = "user_email"
        static let userAge                  = "user_age"
        static let userLatitude             = "user_latitude"
        static let userLongitude            = "user_longitude"
        static let userFullName             = "user_fullName"
        static let userProfileURL           = "user_profileUrl"
        static let userPlatformOfChoice     = "user_platform"
        static let userXboxLive             = "user_xboxlive"
        static let userPSN                  = "user_psn"
        static let userNintendo             = "user_nintendo"
        static let userPc                   = "user_pc"
        static let userGameOfChoice         = "user_game"
        static let userCurrentlyInPlay      = "user_currentlyInPlay"
        static let userAbout                = "user_about"
        
        /// Name of folder where user profile images are stored
        static let userImages               = "profile_images"
    }
    
    struct MessageKeys {
        
        /// Node value for message
        static let messages                         = "messages"
        static let messageID                        = "message_id"
        static let messageText                      = "message_text"
        static let messageCreatedDate               = "message_createdDate"
        static let messageFromUserWithID            = "message_fromUserWithID"
        static let messageFromUserWithName          = "message_fromUserWithName"
        static let messageFromUserWithProfileURL    = "message_fromUserWithProfileURL"
        
        //=>    Aditional optional keys
        static let messageCreatedByUser             = "message_createdByUser"
    }
    
    struct ChatMessageKeys {
        /// Node value for chatMessage
        static let chatMessages                     = "chat_messages"
        static let chatMessageID                    = "chatMessage_id"
        static let chatMessageText                  = "chatMessage_text"
        static let chatMessageCreatedDate           = "chatMessage_createdDate"
        static let chatMessageFromUserWithID        = "chatMessage_fromUserWithID"
        static let chatMessageToUserWithID          = "chatMessage_toUserWithID"
    }
    
    struct UserMessageKeys {
        static let userMessages                     = "user_messages"
    }
    
    struct NotificationKey {
        static let UpdateProfileImage = "kUpdateProfileImageNotif"
        static let DidLogin = "kDidLoginNotif"
        static let DidLogout = "kDidLogoutNotif"
        static let ReloadEvents = "kReloadEvents"
        static let ReloadChannels = "kReloadChannels"
        static let ReloadMessages = "kReloadMessages"
        static let AddEditDeleteChannel = "kAddEditDeleteChannel"
        static let AddEditDeleteMessage = "kAddEditDeleteMessage"
        static let DidReceivePushNotification = "kDidReceivePushNotification"
        static let DidChangeLocationStatus = "kDidChangeLocationStatus"
        static let DidReceiveLocationFix = "kDidReceiveLocationFix"
    }
    
    struct UserDefaultsKey {
        static let LoggedInUserID                                   = "Logged in userID"
        static let DefaultNotifications                             = "Default Notifications"
        static let SleepSettings                                    = "Sleep Settings"
        static let DidRequestPermissionForNotifications             = "DidRequestPermissionForNotifications"
        static let DidRequestPermissionForContacts                  = "DidRequestPermissionForContacts"
        static let DidAskForTutorial                                = "DidAskForTutorial"
    }
    
    struct Animations {
        static let DialFlip         = 0.5
    }
    
    struct Defines {
        static let MaxContactsToShow            = 3
        static let MaxContactsToShowDetails     = 4
    }
}
