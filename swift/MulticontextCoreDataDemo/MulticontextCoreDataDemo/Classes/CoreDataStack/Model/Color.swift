//
//  Color.swift
//  MulticontextCoreDataDemo
//
//  Created by Slava Zubrin on 10/28/14.
//  Copyright (c) 2014 ___ZUBRIN___. All rights reserved.
//

import UIKit

class Color
    : NSObject
    , NSCoding
{
    
    // MARK: - AvalableColors enum

    enum AvalableColors: Int {
        case clear = 0
        case red
        case green
        case blue
        
        func toUIColor() -> UIColor {
            switch self {
            case .clear:
                return UIColor.clearColor()
            case .red:
                return UIColor.redColor()
            case .green:
                return UIColor.greenColor()
            case .blue:
                return UIColor.blueColor()
            }
        }
        
        func toString() -> String {
            switch self {
            case .clear:
                return "clear"
            case .red:
                return "red"
            case .green:
                return "green"
            case .blue:
                return "blue"
            }
        }
        
        func fromUIColor(uiColor: UIColor) -> AvalableColors {
            switch uiColor {
                case UIColor.redColor():
                    return AvalableColors.red
                case UIColor.greenColor():
                    return AvalableColors.green
                case UIColor.blueColor():
                    return AvalableColors.blue
                default:
                    return AvalableColors.clear
            }
        }
    }
    
    // MARK: -

    var color: AvalableColors = AvalableColors.clear

    var name: String {
        get {
            return self.color.toString()
        }
    }

    init(_ color: AvalableColors) {
        self.color = color
    }
    
    func toString() -> String {
        return "\"" + self.color.toString() + "\""
    }
    
    // MARK: NSCoding implementation

    required init(coder aDecoder: NSCoder) {
        self.color = AvalableColors(rawValue:aDecoder.decodeIntegerForKey("colorValue"))!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(self.color.rawValue, forKey:"colorValue")
    }
}
