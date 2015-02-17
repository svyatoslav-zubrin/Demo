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
    
    init(text _text: String, sender _sender: Interlocutor, receiver _receiver: Interlocutor) {
        message  = _text
        sender   = _sender
        receiver = _receiver
    }
}