//
//  ChatProtocols.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

enum ChatStatus {
    case Available, Unavailable
}

protocol ChatDelegate {
    func myStatusChanged(newStatus: ChatStatus)
    
    func newBuddyOnline(buddy: Interlocutor)
    func buddyWentOffline(buddy: Interlocutor)
    func didDisconnect()
}

protocol MessageDelegate {
    func newMessageReceived(message: Message)
}