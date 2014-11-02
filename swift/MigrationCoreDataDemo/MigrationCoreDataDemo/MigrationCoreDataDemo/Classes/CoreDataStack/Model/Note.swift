//
//  Note.swift
//  MigrationCoreDataDemo
//
//  Created by Slava Zubrin on 11/1/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import Foundation
import CoreData

class Note: NSManagedObject {

    @NSManaged var body: String
    @NSManaged var title: String
    @NSManaged var dateCreated: NSDate
    @NSManaged var displayIndex: NSNumber

}
