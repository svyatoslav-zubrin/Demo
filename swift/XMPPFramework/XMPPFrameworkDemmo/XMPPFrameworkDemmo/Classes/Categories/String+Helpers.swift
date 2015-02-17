//
//  String+Helpers.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/17/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}