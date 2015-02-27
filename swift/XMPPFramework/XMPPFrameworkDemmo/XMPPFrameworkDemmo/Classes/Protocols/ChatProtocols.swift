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
    // connection status
    func account(_account: Account, changedStatus newStatus: ChatStatus)
    func accountDidDisconnect(_account: Account)
    // buddies list
    func newBuddyOnline(buddy: Interlocutor)
    func buddyWentOffline(buddy: Interlocutor)
}

protocol MessageDelegate {
    func newMessageReceived(message: Message)
}