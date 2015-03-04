//
//  Account+Helpers.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 3/4/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

// MARK: - Service helpers

enum ServiceType: Int
{
    case Custom = 0
    case QArea  = 1
    case GTalk  = 2
    case Local  = 3
    
    static func count() -> Int
    {
        return 4
    }
    
    func toString() -> String
    {
        switch self
        {
        case .Custom    : return "Custom service"
        case .QArea     : return "QArea's jabber"
        case .GTalk     : return "Google talk"
        case .Local     : return "Local jabber (debug)"
        }
    }
    
    var defaultHostParameters: (name: String, port: Int)
    {
        switch self
        {
        case .Custom    : return ("", 5222)
        case .QArea     : return ("jabber.qarea.org", 5222)
        case .GTalk     : return ("talk.google.com", 5223)
        case .Local     : return ("szmini.local", 5222)
        }
    }
}

// MARK: - Account helpers

extension Account
{
    var accountId: String
    {
        // TODO: correct generation of unique account identifier
        return userId
    }

    var humanReadableName: String
    {
        return userId
    }

    func isOnline() -> Bool
    {
        var isOnline = false
        if let communicator = CommunicatorsProvider.sharedInstance.getCommunicatorByAccountId(accountId) as? XMPPCommunicator
        {
            isOnline = communicator.isOpen
        }
        return isOnline
    }
}