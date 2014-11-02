//
//  CDMUtils.swift
//  MigrationCoreDataDemo
//
//  Created by Slava Zubrin on 11/1/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import UIKit

class CDMUtils: NSObject {
   
    // MARK: - Singleton
    
    class var sharedInstance :CDMUtils {
        struct Singleton {
            static let instance = CDMUtils()
        }
        return Singleton.instance
    }

    // MARK: - Utility methods
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "--ZUBRIN--.MigrationCoreDataDemo" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
}
