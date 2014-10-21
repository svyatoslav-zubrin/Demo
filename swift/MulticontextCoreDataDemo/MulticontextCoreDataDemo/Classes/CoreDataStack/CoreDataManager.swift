//
//  CoreDataManager.swift
//  MulticontextCoreDataDemo
//
//  Created by Development on 10/16/14.
//  Copyright (c) 2014 ___ZUBRIN___. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: NSObject {
    
    private let coreDataModelName = "MulticontextCoreDataDemo"
    private let coreDataStoreName = "MulticontextCoreDataDemo.sqlite"
    
    // MARK: - Singleton
    class var sharedManager :CoreDataManager {
        struct Singleton {
            static let instance = CoreDataManager()
        }
        return Singleton.instance
    }
    
    // MARK: - Initializers
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: "mocDidSaveNotification:",
                                                         name: NSManagedObjectContextDidSaveNotification,
                                                         object: self.wMOC)
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.zubrin.MulticontextCoreDataDemo" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var MOM: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource(self.coreDataModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    
    // MARK: Foreground stack objects (for reading)
    
    lazy var rPSC: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.MOM)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.coreDataStoreName)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType,
                                                   configuration: nil,
                                                   URL: url,
                                                   options: self.peristentStoreOptions(),
                                                   error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application,x although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var rMOC: NSManagedObjectContext? = {
        let coordinator = self.rPSC
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: Background stack objects (for writing)
    
    lazy var wPSC: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.MOM)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.coreDataStoreName)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType,
                                                   configuration: nil,
                                                   URL: url,
                                                   options: self.peristentStoreOptions(),
                                                   error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var wMOC: NSManagedObjectContext? = {
        let coordinator = self.wPSC
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.wMOC {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func mocDidSaveNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            // Why do we need this KVO invocation. Is it some CoreData feature/trick?
            if let userInfo = notification.userInfo as? Dictionary<NSString, AnyObject> {
                if let updatedObjects = userInfo[NSUpdatedObjectsKey] as? Array<NSManagedObject> {
                    for obj in updatedObjects {
                        self.wMOC?.objectWithID(obj.objectID).willAccessValueForKey(nil)
                    }
                }
            }
            self.rMOC!.mergeChangesFromContextDidSaveNotification(notification)
        })
    }
}

// MARK: - Private

private extension CoreDataManager {

    func peristentStoreOptions() -> Dictionary<NSObject, AnyObject> {
        let options: Dictionary<NSObject, AnyObject> = [
            NSInferMappingModelAutomaticallyOption: true,
            NSMigratePersistentStoresAutomaticallyOption: true
        ]
        return options
    }
}