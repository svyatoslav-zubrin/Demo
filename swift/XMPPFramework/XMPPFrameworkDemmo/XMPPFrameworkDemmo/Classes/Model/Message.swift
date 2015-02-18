//
//  Message.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class Message {
    
    private(set) var message: String
    private(set) var sender: Interlocutor
    private(set) var receiver: Interlocutor
    private(set) var time: String
    
    init(text _text: String,
        sender _sender: Interlocutor,
        receiver _receiver: Interlocutor,
        time _time: String)
    {
        message  = _text
        sender   = _sender
        receiver = _receiver
        time     = _time
    }
}