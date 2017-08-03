//
//  SessionManager.swift
//  Vertx
//
//  Created by Boariu Andy on 8/27/16.
//  Copyright © 2016 Nebel, Inc. All rights reserved.
//

import Foundation

class SessionManager {
    static let CURRENT_USER_EMAIL = "CURRENT_USER_EMAIL"
    static let CURRENT_USER_PASSWORD = "CURRENT_USER_PASSWORD"
    
    static var currentUserEmail: String? {
        get {
            return UserDefaults.standard.object(forKey: CURRENT_USER_EMAIL) as! String?
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: CURRENT_USER_EMAIL)
        }
    }
    
    static var currentUserPassword: String? {
        get {
            return UserDefaults.standard.object(forKey: CURRENT_USER_PASSWORD) as! String?
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: CURRENT_USER_PASSWORD)
        }
    }
    
    static func syncUserDefaults() {
        UserDefaults.standard.synchronize()
    }
}
