//
// Created by Slava Zubrin on 3/24/15.
// Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation
import Parse

class Message: PFObject, PFSubclassing
{
    private enum AssociatedKeys: String
    {
        case SenderRelation = "sender_relation"
        case ReceiverRelation = "receiver_relation"
    }

    @NSManaged var body: String
    // linked objects
    private(set) var sender: PFUser!
    private(set) var receiver: PFUser!
    // relations
    private var senderRelation: PFRelation!
    private var receiverRelation: PFRelation!

    convenience
    init(_ _body: String,
         sender _sender: PFUser,
         receiver _receiver: PFUser)
    {
        self.init()
        
        body = _body

        sender = _sender
        receiver = _receiver

        senderRelation = self.relationForKey(AssociatedKeys.SenderRelation.rawValue)
        senderRelation.addObject(_sender)

        receiverRelation = self.relationForKey(AssociatedKeys.ReceiverRelation.rawValue)
        receiverRelation.addObject(_receiver)
    }

    class func parseClassName() -> String
    {
        return "Message"
    }
}
