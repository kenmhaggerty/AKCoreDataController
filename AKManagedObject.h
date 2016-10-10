//
//  AKManagedObject.h
//  AKCoreDataController
//
//  Created by Ken M. Haggerty on 4/13/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const _Nonnull AKManagedObjectWillBeDeallocatedNotification;
extern NSString * const _Nonnull AKManagedObjectWasCreatedNotification;
extern NSString * const _Nonnull AKManagedObjectWasFetchedNotification;
extern NSString * const _Nonnull AKManagedObjectWillSaveNotification;
extern NSString * const _Nonnull AKManagedObjectDidSaveNotification;
extern NSString * const _Nonnull AKManagedObjectWillBeDeletedNotification;

NS_ASSUME_NONNULL_BEGIN

@interface AKManagedObject : NSManagedObject
@property (nonatomic, strong, readonly, nullable) NSSet *changedKeys;
@property (nonatomic, readonly) BOOL isSaving;
@property (nonatomic, readonly) BOOL willBeDeleted;
@property (nonatomic, readonly) BOOL wasDeleted;
@property (nonatomic) BOOL parentIsDeleted;
@end

NS_ASSUME_NONNULL_END

#import "AKManagedObject+CoreDataProperties.h"
