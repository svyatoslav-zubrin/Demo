//
//  Message.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 3/4/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation
import CoreData

@objc(Message) class Message: NSManagedObject
{
    @NSManaged var body: String
    @NSManaged var date: NSDate?
    @NSManaged var receiver: Interlocutor
    @NSManaged var sender: Interlocutor

    // Lifecycle

    convenience
    init(text _text: String,
         sender _sender: Interlocutor,
         receiver _receiver: Interlocutor,
         date _date: NSDate?,
         inManagedObjectContext _context: NSManagedObjectContext?)
    {
        var context = _context
        if context == nil {
            context = NSManagedObjectContext.MR_defaultContext()
        }

        let ed = NSEntityDescription.entityForName("Message", inManagedObjectContext: context!)

        assert(ed != nil)

        self.init(entity: ed!, insertIntoManagedObjectContext: context)

        body = _text
        date = _date
        sender = _sender.MR_inContext(context) as Interlocutor
        receiver = _receiver.MR_inContext(context) as Interlocutor
    }

    convenience
    init(text _text: String,
         sender _sender: Interlocutor,
         receiver _receiver: Interlocutor,
         date _date: NSDate?)
    {
        self.init(text: _text,
            sender: _sender,
            receiver: _receiver,
            date: _date,
            inManagedObjectContext: nil)
    }
}
