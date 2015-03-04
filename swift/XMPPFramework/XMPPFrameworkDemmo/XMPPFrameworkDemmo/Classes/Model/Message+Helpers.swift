//
// Created by Slava Zubrin on 3/4/15.
// Copyright (c) 2015 Slava Zubrin. All rights reserved.
//

import Foundation

extension Message
{
    private struct StaticVariablesContainer
    {
        static var dateFormatter: NSDateFormatter =
        {
            let df = NSDateFormatter()
            df.timeZone  = NSTimeZone.localTimeZone()
            df.dateStyle = .MediumStyle
            df.timeStyle = .MediumStyle
            return df
        }()
    }

    class var dateFormatter: NSDateFormatter
    {
        get { return StaticVariablesContainer.dateFormatter }
        set { StaticVariablesContainer.dateFormatter = newValue }
    }

    class func dateAsString(date: NSDate) -> String
    {
        return Message.dateFormatter.stringFromDate(date)
    }

    class func stringAsDate(string: String) -> NSDate?
    {
        return Message.dateFormatter.dateFromString(string)
    }
}