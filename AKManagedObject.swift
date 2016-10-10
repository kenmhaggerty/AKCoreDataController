//
//  AKManagedObject.swift
//  pcyp-ios
//
//  Created by Ken M. Haggerty on 6/14/16.
//  Copyright © 2016 Peter Cicchino Youth Project. All rights reserved.
//

// MARK: Imports

import Foundation
import CoreData

// MARK: Protocols

// MARK: Definitions

let AKManagedObjectWillBeDeallocatedNotification = "kAKManagedObjectWillBeDeallocatedNotification"
let AKManagedObjectWasCreatedNotification = "kAKManagedObjectWasCreatedNotification"
let AKManagedObjectWasFetchedNotification = "kAKManagedObjectWasFetchedNotification"
let AKManagedObjectWillSaveNotification = "kAKManagedObjectWillSaveNotification"
let AKManagedObjectDidSaveNotification = "kAKManagedObjectDidSaveNotification"
let AKManagedObjectWillBeDeletedNotification = "kAKManagedObjectWillBeDeletedNotification"

// MARK: - AKManagedObject

class AKManagedObject: NSManagedObject {
    
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
        NSNotificationCenter.postNotificationToMainThread(AKManagedObjectWillBeDeallocatedNotification, object: self, userInfo: nil)
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        
        NSNotificationCenter.postNotificationToMainThread(AKManagedObjectWasCreatedNotification, object: self, userInfo: nil)
    }
    
    override func awakeFromFetch() {
        super.awakeFromFetch()
        
        NSNotificationCenter.postNotificationToMainThread(AKManagedObjectWasFetchedNotification, object: self, userInfo: nil)
    }
    
    override func willSave() {
        self.isSaving = true
        
        super.willSave()
        
        if (self.updated && !self.inserted) {
            self.changedKeys = Array(self.changedValues().keys)
        }
        
        NSNotificationCenter.postNotificationToMainThread(AKManagedObjectWillSaveNotification, object: self, userInfo: [NOTIFICATION_OBJECT_KEY : self.changedKeys])
    }
    
    override func didSave() {
        if (self.willBeDeleted) {
            self.willBeDeleted = false
            self.wasDeleted = true
        }
        
        if ((self.changedKeys != nil) && !self.inserted) { // && !self.isDeleted
            NSNotificationCenter.postNotificationToMainThread(AKManagedObjectDidSaveNotification, object: self, userInfo: [NOTIFICATION_OBJECT_KEY : self.changedKeys!])
            self.changedKeys = nil
        }
        
        super.didSave()
        
        self.isSaving = false
    }
    
    // MARK: • Setup
    
    // MARK: • Delegated
    
    // MARK: • Functions

}
