//
//  CDMImageTransformer.swift
//  MigrationCoreDataDemo
//
//  Created by Slava Zubrin on 11/3/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import UIKit

class CDMImageTransformer: NSValueTransformer
{
   
    override class func transformedValueClass() -> AnyClass
    {
        return UIImage.self
    }
    
    class override func allowsReverseTransformation() -> Bool
    {
        return true
    }
    
    // MARK: - Transformations themself
    
    override func transformedValue(value: AnyObject?) -> AnyObject?
    {
        // UIImage -> NSData
        if value == nil
        {
            return nil
        }
        
        let image: UIImage = value as UIImage
        return UIImageJPEGRepresentation(image, 0.0)
        
        // TODO: correct bridging and conversions
//        CGDataProviderRef provider = CGImageGetDataProvider(image.CGImage);
//        NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
//        const uint8_t* bytes = [data bytes];
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject?
    {
        // NSData -> UIImage
        if value == nil
        {
            return nil
        }
        
        let data: NSData = value as NSData
        return UIImage(data: data)
    }
    
}
