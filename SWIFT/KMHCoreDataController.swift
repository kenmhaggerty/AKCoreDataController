//
//  KMHCoreDataController.swift
//  KMHCoreDataController
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
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(self))
        request.predicate = predicate
        request.includesSubentities = includeSubentities
        do {
            let count = try KMHCoreDataController.shared.managedObjectContext.count(for: request)
            return (count > 0)
        }
        catch let error as NSError {
            throw error
        }
    }
    
    class func createManagedObjectObject<T: NSManagedObject>(withInitializer initializer: (T?) -> Void) -> T? {
        let object = NSEntityDescription.insertNewObject(forEntityName: NSStringFromClass(object_getClass(self)), into: KMHCoreDataController.shared.managedObjectContext) as? T
        initializer(object)
        return object
    }
    
    class func fetchObjects<T: NSManagedObject>(withPredicate predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?, includeSubentities: Bool = true) throws -> [T]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: NSStringFromClass(self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.includesSubentities = includeSubentities
        do {
            return try KMHCoreDataController.shared.managedObjectContext.fetch(request) as? [T]
        }
        catch {
            throw error
        }
    }
}

// MARK: - KMHCoreDataController

class KMHCoreDataController {
    
    // MARK: [Public API]
    
    // MARK: • IBOutlets
    
    // MARK: • Variables
    
    // MARK: • Functions (Setup)
    
    class func setup(withModelName name: String!, forStoreType type: String!) {
        KMHCoreDataController.shared.modelName = name
        KMHCoreDataController.shared.persistentStoreType = type
    }
    
    // MARK: • Functions (Migration)
    
//    class func needsMigration() -> Bool {
//        let url = applicationDocumentsDirectory().URLByAppendingPathComponent(KMHCoreDataController.persistentStoreFilename())
//        let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStoreOfType(KMHCoreDataController.persistentStoreType()!, URL: url, options: <#T##[NSObject : AnyObject]?#>)
//        let model = KMHCoreDataController.managedObjectModel()!
//        
//        return model.isConfiguration(nil, compatibleWithStoreMetadata: metadata!)
//    }
//    
//    class func migrate(error: NSErrorPointer) -> Bool! {
//        <#code#>
//    }
    
    // MARK: • Functions (Core Data)
    
    class func save() throws -> () {
        let managedObjectContext = KMHCoreDataController.shared.managedObjectContext
        
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
    
    internal static let shared = KMHCoreDataController()
    
    private var modelName: String?
    
    private var persistentStoreType: String?
    
    lazy private var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
    lazy private var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = KMHCoreDataController.applicationDocumentsDirectory().appendingPathComponent(KMHCoreDataController.persistentStoreFilename())
        let failureReason = "There was an error creating or loading the application's saved data."
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return persistentStoreCoordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    // MARK: • Inits
    
    // MARK: • Setup
    
    // MARK: • Delegated
    
    // MARK: • Overwritten
    
    // MARK: • Functions (Getters)
    
//    private class func modelName(name: String? = nil) -> String? {
//        if (name == nil) {
//            return KMHCoreDataController.sharedController.modelName
//        }
//        
//        KMHCoreDataController.sharedController.modelName = name
//        return nil
//    }
//    
//    private class func persistentStoreType(type: String? = nil) -> String? {
//        if (type == nil) {
//            return KMHCoreDataController.sharedController.persistentStoreType
//        }
//        
//        KMHCoreDataController.sharedController.persistentStoreType = type
//        return nil
//    }
//    
//    private class func managedObjectModel(model: NSManagedObjectModel? = nil) -> NSManagedObjectModel? {
//        if (model == nil) {
//            return KMHCoreDataController.sharedController.managedObjectModel
//        }
//        
//        KMHCoreDataController.sharedController.managedObjectModel = model
//        return nil
//    }
//    
//    private class func persistentStoreCoordinator(coordinator: NSPersistentStoreCoordinator? = nil) -> NSPersistentStoreCoordinator? {
//        if (coordinator == nil) {
//            return KMHCoreDataController.sharedController.persistentStoreCoordinator
//        }
//        
//        KMHCoreDataController.sharedController.persistentStoreCoordinator = coordinator
//        return nil
//    }
//    
//    private class func managedObjectContext(context: NSManagedObjectContext? = nil) -> NSManagedObjectContext? {
//        if (context == nil) {
//            return KMHCoreDataController.sharedController.managedObjectContext
//        }
//        
//        KMHCoreDataController.sharedController.managedObjectContext = context
//        return nil
//    }
    
    // MARK: • Functions (Other)
    
    private class func applicationDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    }
    
    private class func fileExtensionForStoreType(storeType: String) -> String? {
        if (storeType == NSSQLiteStoreType) {
            return ".sqlite"
        }
        
        return nil
    }
    
    private class func persistentStoreFilename() -> String {
        return KMHCoreDataController.shared.modelName!+KMHCoreDataController.fileExtensionForStoreType(storeType: KMHCoreDataController.shared.persistentStoreType!)!
    }
}
