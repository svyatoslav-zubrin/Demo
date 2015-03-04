//
//  CommunicatorFactory.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/23/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class CommunicatorFactory {
    
    class func communicatorForAccount(_account: Account) -> BaseCommunicator {
        switch _account.serviceType {
        default:
            return XMPPCommunicator(account: _account)
        }
    }
}