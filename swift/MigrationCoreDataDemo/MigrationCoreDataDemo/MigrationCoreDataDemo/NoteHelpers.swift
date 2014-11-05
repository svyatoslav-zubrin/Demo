//
//  NoteHelpers.swift
//  MigrationCoreDataDemo
//
//  Created by Slava Zubrin on 11/5/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import Foundation

extension Note
{
    class func sortByTitleDescriptor() -> NSSortDescriptor
    {
        return NSSortDescriptor(key: "title", ascending: true)
    }
    
    class func sortByDateDescriptor() -> NSSortDescriptor
    {
        return NSSortDescriptor(key: "dateCreated", ascending: true)
    }
}