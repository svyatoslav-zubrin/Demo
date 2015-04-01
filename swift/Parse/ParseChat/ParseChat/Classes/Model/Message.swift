//
// Created by Slava Zubrin on 3/24/15.
// Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation
import Parse

class Message: PFObject, PFSubclassing
{
    enum AssociatedKeys: String
    {
        case Sender = "sender"
        case Receiver = "receiver"
    }

    @NSManaged var body: String
    // linked objects
    private(set) var sender: PFUser!
    {
        get
        {
            return self[AssociatedKeys.Sender.rawValue] as? PFUser
        }
        
        set
        {
            self[AssociatedKeys.Sender.rawValue] = newValue
        }
    }
    private(set) var receiver: PFUser!
    {
        get
        {
            return self[AssociatedKeys.Receiver.rawValue] as? PFUser
        }
        
        set
        {
            self[AssociatedKeys.Receiver.rawValue] = newValue
        }
    }

    convenience
    init(_ _body: String,
         sender _sender: PFUser,
         receiver _receiver: PFUser)
    {
        self.init()
        
        body = _body

        sender = _sender
        receiver = _receiver
    }

    class func parseClassName() -> String
    {
        return "Message"
    }
}
