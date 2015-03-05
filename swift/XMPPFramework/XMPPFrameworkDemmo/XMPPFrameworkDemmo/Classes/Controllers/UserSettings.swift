//
//  UserSettings.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class UserSettings
{
    // Singleton
    
    class var sharedInstance : UserSettings
    {
        struct Static
        {
            static let instance : UserSettings = UserSettings()
        }
        
        return Static.instance
    }
    
    // Other stuff should be here...
}
