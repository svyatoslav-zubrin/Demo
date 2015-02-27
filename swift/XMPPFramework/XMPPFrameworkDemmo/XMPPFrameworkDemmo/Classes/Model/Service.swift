//
//  Service.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/19/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

enum ServiceType: Int {
    
    case Custom = 0
    case QArea  = 1
    case GTalk  = 2
    case Local  = 3
    
    static func count() -> Int {
        return 4
    }
    
    func toString() -> String {
        switch self {
        case .Custom    : return "Custom service"
        case .QArea     : return "QArea's jabber"
        case .GTalk     : return "Google talk"
        case .Local     : return "Local jabber (debug)"
        }
    }
    
    var defaultHostParameters: (name: String, port: UInt16) {
        switch self {
        case .Custom    : return ("", 5222)
        case .QArea     : return ("jabber.qarea.org", 5222)
        case .GTalk     : return ("talk.google.com", 5223)
        case .Local     : return ("szmini.local", 5222)
        }
    }
}

class Service: Equatable {
    
    let id: String!
    let hostName: String!
    let hostPort: UInt16 = 5222
    let type: ServiceType
    
    init?(type _type: ServiceType) {
        type = _type
        switch type {
        case .GTalk:
            hostName = "talk.google.com"
            id       = hostName
            hostPort = 5223
        case .QArea:
            hostName = "jabber.qarea.org"
            id       = hostName
        case .Local:
            hostName = "szmini.local"
            id       = hostName
        default:
            return nil
        }
    }
    
    init(hostName name: String, hostPort port: UInt16) {
        hostName = name
        hostPort = port
        id       = hostName
        type     = .Custom
    }
    
    convenience init(hostName name: String) {
        self.init(hostName: name, hostPort: 5222)
    }
    
    // MARK: - Private
    
    private func generateId() -> String {
        // TODO: should be replaced with either correct generation logic or with NSManagedObjectId
        return hostName
    }
}

// MARK: - Equatable

func ==(lhs: Service, rhs: Service) -> Bool {
    return lhs.id == rhs.id
        && lhs.type == rhs.type
}


