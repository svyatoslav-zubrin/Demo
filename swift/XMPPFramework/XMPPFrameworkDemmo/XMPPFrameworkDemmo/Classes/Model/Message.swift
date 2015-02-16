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
    private(set) var senderName: String
    
    init(text: String, sender: String) {
        message = text
        senderName = sender
    }
}