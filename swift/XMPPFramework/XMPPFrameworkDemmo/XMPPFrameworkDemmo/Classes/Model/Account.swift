//
//  Account.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 3/4/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation
import CoreData

@objc(Account) class Account: NSManagedObject
{
    @NSManaged var password: String
    @NSManaged var userId: String
    @NSManaged var hostName: String
    @NSManaged var hostPort: NSNumber
    @NSManaged var serviceType: NSNumber

    @NSManaged var me: Interlocutor
    @NSManaged var contacts: NSSet
}
