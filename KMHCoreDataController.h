//
//  KMHCoreDataController.h
//  KMHCoreDataController
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>

@class NSManagedObject;

#pragma mark - // PROTOCOLS //

#pragma mark - // DEFINITIONS (Public) //

extern NSString * const KMHCoreDataNotificationObjectKey;
extern NSString * const KMHCoreDataErrorDomain;

extern NSString * const KMHCoreDataMigrationProgressDidChangeNotification;
extern NSString * const KMHCoreDataWillSaveNotification;

@interface KMHCoreDataController : NSObject

// GENERAL //

+ (void)setupWithName:(NSString *)name type:(NSString *)sourceStoreType resourceName:(NSString *)resourceName error:(NSError *)error;
+ (void)save:(void (^)(BOOL success, NSError *error))completionBlock;

// OBJECTS //

+ (id)createObjectWithClass:(NSString *)className block:(void (^)(id object))block;
+ (NSUInteger)countObjectsWithClass:(NSString *)className predicate:(NSPredicate *)predicate error:(NSError *)error;
+ (NSArray *)fetchObjectsWithClass:(NSString *)className predicate:(NSPredicate *)predicate sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors error:(NSError **)error;
+ (void)deleteObject:(NSManagedObject *)object error:(NSError **)error;

// MIGRATION //

+ (BOOL)needsMigration:(NSError *)error;
+ (BOOL)migrate:(NSError *)error;

@end
