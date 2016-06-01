//
//  AKCoreDataController.swift
//  AKCoreDataController
//
//  Created by Ken M. Haggerty on 5/30/16.
//  Copyright © 2016 Ken M. Haggerty. All rights reserved.
//

import Foundation
import CoreData

class AKCoreDataController {
    
    // MARK: VARIABLES (Public)
    
    // MARK: VARIABLES (Private)
    
    private static let sharedController = AKCoreDataController()
    
    private lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.urbanjusticecenter.pcyp_ios" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    private var managedObjectModel: NSManagedObjectModel!
    
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    private var managedObjectContext: NSManagedObjectContext!
    
    // MARK: INITIALIZERS
    
    // MARK: FUNCTIONS (Public)
    
    class func setup(withProjectName projectName: String!) {
        let sharedController = AKCoreDataController.sharedController
        
        // Set up managedObjectModel
        let modelURL = NSBundle.mainBundle().URLForResource(projectName, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        sharedController.managedObjectModel = managedObjectModel
        
        // Set up persistentStoreCoordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = sharedController.applicationDocumentsDirectory.URLByAppendingPathComponent(projectName+".sqlite")
        let failureReason = "There was an error creating or loading the application's saved data."
        do {
            try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        sharedController.persistentStoreCoordinator = persistentStoreCoordinator
        
        // Set up managedObjectContext
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        sharedController.managedObjectContext = managedObjectContext
    }
    
    class func save() -> NSError? {
        let managedObjectContext = AKCoreDataController.sharedController.managedObjectContext
        
        if (!managedObjectContext.hasChanges) {
            return nil
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        return nil
    }
    
    // MARK: FUNCTIONS (Private)
    
}
