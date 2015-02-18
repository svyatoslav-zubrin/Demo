//
//  String+Helpers.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/17/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

extension String {
 
    // MARK: - Subscript methods
    
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex),
                                        end  : advance(startIndex, r.endIndex)))

    }
    
    // MARK: - Time helper
    
    static func getCurrentTime() -> String {
        let nowUTC = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone  = NSTimeZone.localTimeZone()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
        return dateFormatter.stringFromDate(nowUTC)
    }
}