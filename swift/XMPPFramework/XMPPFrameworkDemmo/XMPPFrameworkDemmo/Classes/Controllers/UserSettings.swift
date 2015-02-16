//
//  UserSettings.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class UserSettings {
    
    // Singleton
    
    class var sharedInstance : UserSettings {
        struct Static {
            static let instance : UserSettings = UserSettings()
        }
        return Static.instance
    }
    
    // Public properties
    
    var userId: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("userID") as? String
        }
        
        set {
            if let v = newValue {
                let ud = NSUserDefaults.standardUserDefaults()
                ud.setObject(v, forKey: "userID")
                ud.synchronize()
            }
        }
    }

    var userPassword: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey("userPassword") as? String
        }
        
        set {
            if let v = newValue {
                let ud = NSUserDefaults.standardUserDefaults()
                ud.setObject(v, forKey: "userPassword")
                ud.synchronize()
            }
        }
    }
}