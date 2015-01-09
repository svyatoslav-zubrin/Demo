//
//  NameInfo.swift
//  WatchKitDemo
//
//  Created by Slava Zubrin on 1/9/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import UIKit

class NameInfo: NSObject {
    
    let userName: String
    let replyBlock: ([NSObject : AnyObject]!) -> Void

    init(name: String, reply: ([NSObject : AnyObject]!) -> Void) {
        userName = name
        replyBlock = reply
    }
}
