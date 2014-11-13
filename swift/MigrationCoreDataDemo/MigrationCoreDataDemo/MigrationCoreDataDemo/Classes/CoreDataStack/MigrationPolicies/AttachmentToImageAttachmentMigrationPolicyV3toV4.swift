//
//  AttachmentToImageAttachmentMigrationPolicyV3toV4.swift
//  MigrationCoreDataDemo
//
//  Created by Slava Zubrin on 11/10/14.
//  Copyright (c) 2014 zubrin. All rights reserved.
//

import CoreData
import UIKit

class AttachmentToImageAttachmentMigrationPolicyV3toV4: NSEntityMigrationPolicy
{
    override func createDestinationInstancesForSourceInstance(sInstance: NSManagedObject,
                                                              entityMapping mapping: NSEntityMapping,
                                                              manager: NSMigrationManager,
                                                              error: NSErrorPointer) -> Bool
    {
        // migration code goes here
        let newAttachment =
            NSEntityDescription.insertNewObjectForEntityForName("ImageAttachment",
                                                                inManagedObjectContext: manager.destinationContext)
                                                                as NSManagedObject
        
        for propertyMapping in mapping.attributeMappings as [NSPropertyMapping]!
        {
            let destinationName = propertyMapping.name!
            if let valueExpression = propertyMapping.valueExpression
            {
                let context: NSMutableDictionary = ["source" : sInstance]
                let destinationValue: AnyObject = valueExpression.expressionValueWithObject(sInstance, context: context)
                
                newAttachment.setValue(destinationValue, forKey:destinationName)
            }
        }
        
        if let image = sInstance.valueForKey("image") as? UIImage
        {
            newAttachment.setValue(image.size.width,  forKey: "width")
            newAttachment.setValue(image.size.height, forKey: "height")
        }
        
        if let body = sInstance.valueForKey("note.body") as? NSString
        {
            newAttachment.setValue(body.substringToIndex(80), forKey: "caption")
        }
        
        manager.associateSourceInstance(sInstance,
                                        withDestinationInstance: newAttachment,
                                        forEntityMapping: mapping)
        
        return true
    }
}
