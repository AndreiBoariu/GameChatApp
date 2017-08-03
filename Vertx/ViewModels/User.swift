//
//  User.swift
//  Vertx
//
//  Created by Boariu Andy on 8/27/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import Foundation
import CoreLocation

class User: NSObject {
    var id              = ""
    var name            : String?
    var age             : String?
    var email           : String?
    var profileURL      : String?
    var latitude        : String?
    var longitude       : String?
    var distance        : Double?
    var platform        : String?
    var psn             : String?
    var xboxLive        : String?
    var nintendo        : String?
    var pc              : String?
    var gameOfChoice    : String?
    var currentlyInPlay : String?
    var about           : String?
    
    init(tempID          : String,
         tempName        : String?,
         tempAge         : String?,
         tempEmail       : String?,
         tempImgURL      : String?) {
        
        id = tempID
        name = tempName
        age = tempAge
        email = tempEmail
        profileURL = tempImgURL
    }
    
    init(dictUser: [String: AnyObject]) {
        super.init()
        
        //dictUser.prettyPrint()
        
        if let strUserID = dictUser[Constants.UserKeys.userID] as? String {
            id = strUserID
        }
        
        if let strUserFullName = dictUser[Constants.UserKeys.userFullName] as? String {
            name = strUserFullName
        }
        
        if let strUserAge = dictUser[Constants.UserKeys.userAge] as? String {
            age = strUserAge
        }
        
        if let strUserEmail = dictUser[Constants.UserKeys.userEmail] as? String {
            email = strUserEmail
        }
        
        if let strUserProfileImgURL = dictUser[Constants.UserKeys.userProfileURL] as? String {
            profileURL = strUserProfileImgURL
        }
        
        if let strPlatformOfChoice = dictUser[Constants.UserKeys.userPlatformOfChoice] as? String {
            platform = strPlatformOfChoice
        }
        
        if let strPSN = dictUser[Constants.UserKeys.userPSN] as? String {
            psn = strPSN
        }
        
        if let strXboxLive = dictUser[Constants.UserKeys.userXboxLive] as? String {
            xboxLive = strXboxLive
        }
        
        if let strNintendo = dictUser[Constants.UserKeys.userNintendo] as? String {
            nintendo = strNintendo
        }
        
        if let strPc = dictUser[Constants.UserKeys.userPc] as? String {
            pc = strPc
        }
        
        if let strGameOfChoice = dictUser[Constants.UserKeys.userGameOfChoice] as? String {
            gameOfChoice = strGameOfChoice
        }
        
        if let strCurInPlay = dictUser[Constants.UserKeys.userCurrentlyInPlay] as? String {
            currentlyInPlay = strCurInPlay
        }
        
        if let strAbout = dictUser[Constants.UserKeys.userAbout] as? String {
            about = strAbout
        }
        
        if let strUserLatitude = dictUser[Constants.UserKeys.userLatitude] as? String, let strUserLongitude = dictUser[Constants.UserKeys.userLongitude] as? String {
            latitude = strUserLatitude
            longitude = strUserLongitude
            
            if let dDistance = calculateDistanceFromLoggedInUserToUserWithLatitude(strUserLatitude, andLongitude: strUserLongitude) {
                distance = dDistance
            }
            else {
                distance = DBL_MAX
            }
        }
        else {
            distance = DBL_MAX
        }
    }
    
    func calculateDistanceFromLoggedInUserToUserWithLatitude(_ strOtherUserLatitude: String, andLongitude strOtherUserLongitude : String) -> Double? {
        if let curUser = appDelegate.curUser {
            if let strUserLat = curUser.latitude, let strUserLong = curUser.longitude {
                if let dLatitude = Double(strUserLat) ,
                    let dLongitude = Double(strUserLong),
                    let dOtherLatitude = Double(strOtherUserLatitude),
                    let dOtherLongitude = Double(strOtherUserLongitude) {
                    
                    let firstLoc = CLLocation(latitude: dLatitude, longitude: dLongitude)
                    let secondLoc = CLLocation(latitude: dOtherLatitude, longitude: dOtherLongitude)
                    
                    return firstLoc.distance(from: secondLoc)
                }
            }
        }
        
        return nil
    }
    
    
    func distanceInMetersFromUserWith(_ strOtherLatitude: String?, strOtherLongitude: String?) -> CLLocationDistance? {
        
        if let strLatitude = latitude,
            let strLongitude = longitude,
            let strOtherUserLatitude = strOtherLatitude,
            let strOtherUserLongitude = strOtherLongitude {
            
            if let dLatitude = Double(strLatitude) ,
                let dLongitude = Double(strLongitude),
                let dOtherLatitude = Double(strOtherUserLatitude),
                let dOtherLongitude = Double(strOtherUserLongitude) {
                
                let firstLoc = CLLocation(latitude: dLatitude, longitude: dLongitude)
                let secondLoc = CLLocation(latitude: dOtherLatitude, longitude: dOtherLongitude)
                
                return firstLoc.distance(from: secondLoc)
            }
        }
        
        return nil
    }
}
