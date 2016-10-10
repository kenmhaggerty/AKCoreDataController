//
//  AKCoreDataController.swift
//  AKCoreDataController
//
//  Created by Ken M. Haggerty on 5/30/16.
//  Copyright © 2016 Ken M. Haggerty. All rights reserved.
//

// MARK: Imports

import Foundation
import CoreData

// MARK: Protocols

// MARK: Definitions

// MARK: - NSManagedObject (Extension)

extension NSManagedObject {
    
    // MARK: Public Methods
    
    class func objectExists(withPredicate predicate: NSPredicate?, includeSubentities: Bool = true) throws -> Bool! {
        let request = NSFetchRequest(entityName: NSStringFromClass(self))
        request.predicate = predicate
        request.includesSubentities = includeSubentities
        var error: NSError?
        let count = AKCoreDataController.managedObjectContext()!.countForFetchRequest(request, error: &error)
        if (error != nil) {
            throw error!
        }
        
        return (count > 0)
    }
    
    class func createManagedObjectObject<T: NSManagedObject>(withInitializer initializer: T? -> Void) -> T? {
        let object = NSEntityDescription.insertNewObjectForEntityForName(NSStringFromClass(object_getClass(self)), inManagedObjectContext: AKCoreDataController.managedObjectContext()!) as? T
        initializer(object)
        return object
    }
    
    class func fetchObjects<T: NSManagedObject>(withPredicate predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, includeSubentities: Bool = true) throws -> [T]? {
        let request = NSFetchRequest(entityName: NSStringFromClass(self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.includesSubentities = includeSubentities
        do {
            return try AKCoreDataController.managedObjectContext()?.executeFetchRequest(request) as? [T]
        }
        catch {
            throw error
        }
    }
}

// MARK: - AKCoreDataController

class AKCoreDataController {
    
    // MARK: [Public API]
    
    // MARK: • IBOutlets
    
    // MARK: • Variables
    
    // MARK: • Functions (Setup)
    
    class func setup(withModelName name: String!, forStoreType type: String!) {
        AKCoreDataController.modelName(name)
        AKCoreDataController.persistentStoreType(type)
    }
    
    // MARK: • Functions (Migration)
    
//    class func needsMigration() -> Bool {
//        let url = applicationDocumentsDirectory().URLByAppendingPathComponent(AKCoreDataController.persistentStoreFilename())
//        let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(AKCoreDataController.persistentStoreType()!, URL: url, options: <#T##[NSObject : AnyObject]?#>)
//        let model = AKCoreDataController.managedObjectModel()!
//        
//        return model.isConfiguration(nil, compatibleWithStoreMetadata: metadata!)
//    }
//    
//    class func migrate(error: NSErrorPointer) -> Bool! {
//        <#code#>
//    }
    
    // MARK: • Functions (Core Data)
    
    class func save() throws -> () {
        let managedObjectContext = AKCoreDataController.managedObjectContext()!
        
        if (!managedObjectContext.hasChanges) {
            return
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            throw error
        }
    }
    
    // MARK: [Private API]
    
    // MARK: • IBOutlets
    
    // MARK: • Variables
    
    private static let sharedController = AKCoreDataController()
    
    private var modelName: String!
    
    private var persistentStoreType: String!
    
    lazy private var managedObjectModel: NSManagedObjectModel! = {
        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)!
    }()
    
    lazy private var persistentStoreCoordinator: NSPersistentStoreCoordinator! = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = AKCoreDataController.applicationDocumentsDirectory().URLByAppendingPathComponent(AKCoreDataController.persistentStoreFilename())
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
        return persistentStoreCoordinator
    }()
    
    lazy private var managedObjectContext: NSManagedObjectContext! = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    // MARK: • Inits
    
    // MARK: • Setup
    
    // MARK: • Delegated
    
    // MARK: • Overwritten
    
    // MARK: • Functions (Getters)
    
    private class func modelName(name: String? = nil) -> String? {
        if (name == nil) {
            return AKCoreDataController.sharedController.modelName
        }
        
        AKCoreDataController.sharedController.modelName = name
        return nil
    }
    
    private class func persistentStoreType(type: String? = nil) -> String? {
        if (type == nil) {
            return AKCoreDataController.sharedController.persistentStoreType
        }
        
        AKCoreDataController.sharedController.persistentStoreType = type
        return nil
    }
    
    private class func managedObjectModel(model: NSManagedObjectModel? = nil) -> NSManagedObjectModel? {
        if (model == nil) {
            return AKCoreDataController.sharedController.managedObjectModel
        }
        
        AKCoreDataController.sharedController.managedObjectModel = model
        return nil
    }
    
    private class func persistentStoreCoordinator(coordinator: NSPersistentStoreCoordinator? = nil) -> NSPersistentStoreCoordinator? {
        if (coordinator == nil) {
            return AKCoreDataController.sharedController.persistentStoreCoordinator
        }
        
        AKCoreDataController.sharedController.persistentStoreCoordinator = coordinator
        return nil
    }
    
    private class func managedObjectContext(context: NSManagedObjectContext? = nil) -> NSManagedObjectContext? {
        if (context == nil) {
            return AKCoreDataController.sharedController.managedObjectContext
        }
        
        AKCoreDataController.sharedController.managedObjectContext = context
        return nil
    }
    
    // MARK: • Functions (Other)
    
    private class func applicationDocumentsDirectory() -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }
    
    private class func fileExtensionForStoreType(storeType: String) -> String? {
        if (storeType == NSSQLiteStoreType) {
            return ".sqlite"
        }
        
        return nil
    }
    
    private class func persistentStoreFilename() -> String {
        return AKCoreDataController.modelName()!+AKCoreDataController.fileExtensionForStoreType(AKCoreDataController.persistentStoreType()!)!
    }
}
