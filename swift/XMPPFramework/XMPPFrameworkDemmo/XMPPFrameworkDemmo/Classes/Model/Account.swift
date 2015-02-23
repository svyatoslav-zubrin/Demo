//
//  Account.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/19/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class Account: Equatable {
    
    let service: Service
    private(set) var userId: String
    private(set) var password: String
    
    init(userIdentifier _uid: String, password _pass: String, service _service: Service) {
        
        service = _service
        userId = _uid
        password = _pass
    }
    
    var humanReadableName: String {
        return service.hostName
    }
}

// MARK: - Equatable

func ==(lhs: Account, rhs: Account) -> Bool {
    return lhs.userId == rhs.userId
        && lhs.service == rhs.service
}
