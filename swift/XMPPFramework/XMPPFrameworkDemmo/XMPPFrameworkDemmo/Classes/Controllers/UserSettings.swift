//
//  UserSettings.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/16/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

class UserSettings {
    
    private(set) var accounts: [Account] = []
    
    // Singleton
    
    class var sharedInstance : UserSettings {
        struct Static {
            static let instance : UserSettings = UserSettings()
        }
        return Static.instance
    }
    
    // MARK: - Lifecycle
    
    init() {
        loadStoredAccounts()
    }
    
    // MARK: - Public
    
    func addAccount(_account: Account) {
        accounts.append(_account)
        store()
    }
    
    func removeAccount(_account: Account) {
        if contains(accounts, _account) {
            accounts.removeObject(_account)
            store()
        }
    }
}

// MARK: - Private

private extension UserSettings {

    func loadStoredAccounts() {
        // TODO: move storage from disk to file
        if accounts.count > 0 { accounts.removeAll(keepCapacity: true) }
        
        if let a = NSUserDefaults.standardUserDefaults().objectForKey("accounts") as? [Account] {
            accounts = a
        }
    }
    
    func store() {
        // TODO: move storage from disk to file
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(accounts, forKey: "accounts")
        ud.synchronize()
    }
}