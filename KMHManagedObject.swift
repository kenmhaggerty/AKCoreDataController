//
//  KMHManagedObject.swift
//  KMHCoreDataController
//
//  Created by Ken M. Haggerty on 6/14/16.
//  Copyright © 2016 Peter Cicchino Youth Project. All rights reserved.
//

// MARK: Imports

import Foundation
import CoreData

// MARK: Protocols

// MARK: Definitions

let KMHManagedObjectNotificationObjectKey = "object"

let KMHManagedObjectWillBeDeallocatedNotification = NSNotification.Name("kKMHManagedObjectWillBeDeallocatedNotification")
let KMHManagedObjectWasCreatedNotification = NSNotification.Name("kKMHManagedObjectWasCreatedNotification")
let KMHManagedObjectWasFetchedNotification = NSNotification.Name("kKMHManagedObjectWasFetchedNotification")
let KMHManagedObjectWillSaveNotification = NSNotification.Name("kKMHManagedObjectWillSaveNotification")
let KMHManagedObjectDidSaveNotification = NSNotification.Name("kKMHManagedObjectDidSaveNotification")
let KMHManagedObjectWillBeDeletedNotification = NSNotification.Name("kKMHManagedObjectWillBeDeletedNotification")

// MARK: - KMHManagedObject

class KMHManagedObject: NSManagedObject {
    
    // MARK: - Public API
    
    // MARK: • IBOutlets
    
    // MARK: • Variables
    
    private(set) var changedKeys: [String]?
    private(set) var isSaving: Bool = false
    private(set) var willBeDeleted: Bool = false
    private(set) var wasDeleted: Bool = false
    private(set) var parentIsDeleted: Bool = false
    
    // MARK: • Functions
    
    // MARK: - Private API
    
    // MARK: • IBOutlets
    
    // MARK: • Variables
    
    // MARK: • Inits
    
    deinit {
        NotificationCenter().post(name: KMHManagedObjectWillBeDeallocatedNotification, object: self, userInfo: nil)
    }
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        NotificationCenter().post(name: KMHManagedObjectWasCreatedNotification, object: self, userInfo: nil)
    }
    
    override func awakeFromFetch() {
        super.awakeFromFetch()
        
        NotificationCenter().post(name: KMHManagedObjectWasFetchedNotification, object: self, userInfo: nil)
    }
    
    override func willSave() {
        self.isSaving = true
        
        super.willSave()
        
        if (self.isUpdated && !self.isInserted) {
            self.changedKeys = Array(self.changedValues().keys)
        }
        
        NotificationCenter().post(name: KMHManagedObjectWillSaveNotification, object: self, userInfo: [KMHManagedObjectNotificationObjectKey : self.changedKeys])
    }
    
    override func didSave() {
        if (self.willBeDeleted) {
            self.willBeDeleted = false
            self.wasDeleted = true
        }
        
        if ((self.changedKeys != nil) && !self.isInserted) { // && !self.isDeleted
            NotificationCenter().post(name: KMHManagedObjectDidSaveNotification, object: self, userInfo: [KMHManagedObjectNotificationObjectKey : self.changedKeys!])
            self.changedKeys = nil
        }
        
        super.didSave()
        
        self.isSaving = false
    }
    
    // MARK: • Setup
    
    // MARK: • Delegated
    
    // MARK: • Functions

}
