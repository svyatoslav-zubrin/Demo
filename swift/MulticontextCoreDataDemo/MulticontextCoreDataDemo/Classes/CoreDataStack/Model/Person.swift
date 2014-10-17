//
//  Person.swift
//  MulticontextCoreDataDemo
//
//  Created by zubrin on 10/17/14.
//  Copyright (c) 2014 ___ZUBRIN___. All rights reserved.
//

import Foundation
import CoreData

class Person: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var surname: String

}
