//
//  String+Helpers.swift
//  XMPPFrameworkDemmo
//
//  Created by Slava Zubrin on 2/17/15.
//  Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

extension String {
 
    // MARK: - Subscript
    
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
    
    // MARK: - Time
    
    static func getCurrentTime() -> String {
        let nowUTC = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeZone  = NSTimeZone.localTimeZone()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .MediumStyle
        return dateFormatter.stringFromDate(nowUTC)
    }
    
    // MARK: - Emoticons
    
    func stringBySubstitutingEmoticons() -> String {
        
        //See http://www.easyapns.com/iphone-emoji-alerts for a list of emoticons available
        
        var res = self.stringByReplacingOccurrencesOfString(":)", withString: "\u{e415}")
        res = res.stringByReplacingOccurrencesOfString(":(", withString: "\u{e403}")
        res = res.stringByReplacingOccurrencesOfString(";-)", withString: "\u{e405}")
        res = res.stringByReplacingOccurrencesOfString(":-x", withString: "\u{e418}")
        
        return res;
    }
}