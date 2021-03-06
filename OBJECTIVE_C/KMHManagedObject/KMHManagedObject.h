//
//  KMHManagedObject.h
//  KMHCoreDataController
//
//  Created by Ken M. Haggerty on 4/13/16.
//  Copyright © 2016 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * _Nonnull const KMHManagedObjectNotificationObjectKey;

extern NSString * _Nonnull const KMHManagedObjectWillBeDeallocatedNotification;
extern NSString * _Nonnull const KMHManagedObjectWasCreatedNotification;
extern NSString * _Nonnull const KMHManagedObjectWasFetchedNotification;
extern NSString * _Nonnull const KMHManagedObjectWillSaveNotification;
extern NSString * _Nonnull const KMHManagedObjectDidSaveNotification;
extern NSString * _Nonnull const KMHManagedObjectWillBeDeletedNotification;

NS_ASSUME_NONNULL_BEGIN

@interface KMHManagedObject : NSManagedObject
@property (nonatomic, strong, readonly) NSDate *instantiatedAt;
@property (nonatomic, strong, readonly) NSSet *changedKeys;
@property (nonatomic, readonly) BOOL isSaving;
@property (nonatomic, readonly) BOOL willBeDeleted;
@property (nonatomic, readonly) BOOL wasDeleted;
@property (nonatomic) BOOL parentIsDeleted;
- (void)setup;
@end

NS_ASSUME_NONNULL_END

#import "KMHManagedObject+CoreDataProperties.h"
