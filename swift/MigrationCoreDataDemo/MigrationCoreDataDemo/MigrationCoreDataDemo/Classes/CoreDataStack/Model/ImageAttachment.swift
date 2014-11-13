//
//  MigrationCoreDataDemo.swift
//  MigrationCoreDataDemo
//
//  Created by Slava Zubrin on 11/11/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ImageAttachment: MigrationCoreDataDemo.Attachment {

    @NSManaged var caption: String?
    @NSManaged var height: NSNumber
    @NSManaged var image: UIImage?
    @NSManaged var width: NSNumber

}
