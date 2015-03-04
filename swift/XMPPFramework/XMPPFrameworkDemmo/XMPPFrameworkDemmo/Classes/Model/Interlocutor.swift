//
//  Interlocutor.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 3/4/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation
import CoreData

@objc(Interlocutor) class Interlocutor: NSManagedObject {

    @NSManaged var bareName: String
    @NSManaged var name: String
    @NSManaged var receivedMessages: NSSet
    @NSManaged var sentMessages: NSSet

    @NSManaged var account: Account
    @NSManaged var ownedAccount: Account

    init(name _name: String,
         bareName _bareName: String,
         account _account: Account,
         inManagedObjectContext _context: NSManagedObjectContext?)
    {
        var context = _context
        if context == nil
        {
            context = NSManagedObjectContext.MR_defaultContext()
        }

        let ed = NSEntityDescription.entityForName("Interlocutor", inManagedObjectContext: context!)

        assert(ed != nil)

        super.init(entity: ed!, insertIntoManagedObjectContext: context!)

        name = _name
        bareName = _bareName
        account = _account
    }

    convenience init(name _name: String,
                     bareName _bareName: String,
                     account _account: Account)
    {
        self.init(name: _name, bareName: _bareName, account: _account, inManagedObjectContext: nil)
    }

    convenience init(xmppJID _jid: XMPPJID,
                     account _account: Account,
                     inManagedObjectContext _context: NSManagedObjectContext?)
    {
        self.init(name: _jid.user, bareName: _jid.bare(), account: _account, inManagedObjectContext: _context)
    }

    convenience init(xmppJID _jid: XMPPJID,
                     account _account: Account)
    {
        self.init(xmppJID: _jid, account: _account, inManagedObjectContext: nil)
    }
}
