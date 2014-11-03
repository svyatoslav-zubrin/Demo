//
//  Person+Utils.swift
//  MulticontextCoreDataDemo
//
//  Created by zubrin on 10/21/14.
//  Copyright (c) 2014 ___ZUBRIN___. All rights reserved.
//

import Foundation
import CoreData

// MARK: - CRUD operations

extension Person {
    
    class func save(#name: String, surname: String) {
        if let moc = CoreDataManager.sharedManager.wMOC {
            moc.performBlockAndWait({ () -> Void in
                let person = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: moc) as Person
                person.name = name
                person.surname = surname
                person.favoriteColor = Color(Color.AvalableColors.red)
            })
            CoreDataManager.sharedManager.saveContext()
        }
    }
}
