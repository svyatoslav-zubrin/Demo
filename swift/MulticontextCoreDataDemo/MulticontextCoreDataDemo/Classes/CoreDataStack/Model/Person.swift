//
//  Person.swift
//  Person
//
//  Created by Slava Zubrin on 10/28/14.
//  Copyright (c) 2014 ___ZUBRIN___. All rights reserved.
//

import Foundation
import CoreData

class Person: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var surname: String
    @NSManaged var favoriteColor: Color

    // MARK: Validation

//    func validateName(name: AnyObject?, error: NSErrorPointer) -> Bool {
//        println("Name validation function called")
//        return true
//    }
}
