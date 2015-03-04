//
//  CommunicatorsProvider.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/19/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation
import UIKit

class CommunicatorsProvider
{
    private var communicators = [XMPPCommunicator]()
    
    // Singleton
    
    class var sharedInstance : CommunicatorsProvider
    {
        struct Static
        {
            static let instance : CommunicatorsProvider = CommunicatorsProvider()
        }
        return Static.instance
    }

    // MARK: - Public
    // Manage communicators
    
    func addCommunicator(_communicator: XMPPCommunicator)
    {
        if !contains(communicators, _communicator)
        {
            communicators.append(_communicator)
        }
    }
    
    func removeCommunicator(_communicator: XMPPCommunicator)
    {
        if contains(communicators, _communicator)
        {
            communicators.removeObject(_communicator)
        }
    }
    
    func getCommunicatorByAccountId(_accountId: String) -> BaseCommunicator?
    {
        return first(communicators.filter{$0.account.accountId == _accountId})
    }

    // Manage connections status
    
    func connect(inout error: NSError?)
    {
        var failedToConnectCommunicators = [XMPPCommunicator]()

        for communicator in communicators
        {
            if !communicator.connect()
            {
                failedToConnectCommunicators.append(communicator)
            }
        }
        
        if failedToConnectCommunicators.count > 0
        {
            var description = "Accounts failed to connect:"
            for communicator in failedToConnectCommunicators
            {
                description += " " + communicator.account.humanReadableName + ","
            }
            description = description.substringToIndex(description.endIndex.predecessor())
            
            error = NSError(domain: "", code: 10001, userInfo: [NSLocalizedDescriptionKey : description])
        }
        else
        {
            error = nil
        }
    }
    
    func disconnect()
    {
        for communicator in communicators
        {
            communicator.disconnect()
        }
    }
}
