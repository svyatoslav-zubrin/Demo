//
//  NoteHelpers.swift
//  MigrationCoreDataDemo
//
//  Created by Slava Zubrin on 11/5/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import Foundation
import UIKit

extension Note
{
    // MARK: - Class methods
    
    class func sortByTitleDescriptor() -> NSSortDescriptor
    {
        return NSSortDescriptor(key: "title", ascending: true)
    }
    
    class func sortByDateDescriptor() -> NSSortDescriptor
    {
        return NSSortDescriptor(key: "dateCreated", ascending: true)
    }
    
    // MARK: - Object methods
    
    var image: UIImage?
    {
        if let image = self.attachments?.last?.image as? UIImage
        {
            return image
        }
        return nil
    }
}