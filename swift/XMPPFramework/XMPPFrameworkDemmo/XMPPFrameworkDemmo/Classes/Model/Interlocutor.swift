//
//  Interlocutor.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/17/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class Interlocutor: Equatable {
    
    private(set) var name: String
    private(set) var bareName: String
    
    init(name _name: String, bareName _bareName: String) {
        name = _name
        bareName = _bareName
    }
    
    convenience init(xmppJID _jid: XMPPJID) {
        self.init(name: _jid.user, bareName: _jid.bare())
    }
    
    func isBare() -> Bool {
        return countElements(bareName) > 0
    }
}

// MARK: - Equatable

func ==(lhs: Interlocutor, rhs: Interlocutor) -> Bool {
    return lhs.bareName == rhs.bareName
}
