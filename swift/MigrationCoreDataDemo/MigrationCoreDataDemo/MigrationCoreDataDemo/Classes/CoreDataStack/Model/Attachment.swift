//
//  Attachment.swift
//  MigrationCoreDataDemo
//
//  Created by Slava Zubrin on 11/6/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import Foundation
import CoreData

class Attachment: NSManagedObject {

    @NSManaged var dateCreated: NSDate
    @NSManaged var note: Note
}
