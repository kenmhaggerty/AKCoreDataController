//
//  KMHCoreDataController.m
//  KMHCoreDataController
//
//  Created by Ken M. Haggerty on 3/4/16.
//  Copyright © 2016 Flatiron School. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "KMHCoreDataController.h"
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#pragma mark - // DEFINITIONS (Private) //

NSString * const KMHCoreDataNotificationObjectKey = @"object";
NSString * const KMHCoreDataErrorDomain = @"KMHCoreDataErrorDomain";

NSString * const KMHCoreDataMigrationProgressDidChangeNotification = @"kKMHCoreDataMigrationProgressDidChangeNotification";
NSString * const KMHCoreDataWillSaveNotification = @"kKMHCoreDataWillSaveNotification";

@interface KMHCoreDataController ()
@property (nonatomic, strong, readonly) NSString *sourceStoreType;
@property (nonatomic, strong, readonly) NSURL *sourceStoreURL;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSMigrationManager *migrationManager;

// GENERAL //

+ (instancetype)initWithSourceStoreType:(NSString *)sourceStoreType url:(NSURL *)sourceStoreURL managedObjectModel:(NSManagedObjectModel *)managedObjectModel persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator managedObjectContext:(NSManagedObjectContext *)managedObjectContext;
+ (instancetype)sharedController;
+ (NSString *)extensionForType:(NSString *)sourceStoreType;

// CONVENIENCE //

+ (NSString *)sourceStoreType;
+ (NSURL *)sourceStoreURL;
+ (NSManagedObjectModel *)managedObjectModel;
+ (NSManagedObjectContext *)managedObjectContext;

// MIGRATION //

+ (void)setMigrationManager:(NSMigrationManager *)migrationManager;
+ (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL ofType:(NSString *)type toModel:(NSManagedObjectModel *)finalModel error:(NSError *)error;
+ (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata;
+ (NSArray *)modelPaths;
+ (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL modelName:(NSString *)modelName;
+ (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL movingDestinationStoreAtURL:(NSURL *)destinationStoreURL error:(NSError *)error;

// OTHER //

+ (NSManagedObjectModel *)managedObjectModelWithURL:(NSURL *)modelURL;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel sourceStoreURL:(NSURL *)sourceStoreURL type:(NSString *)sourceStoreType error:(NSError **)error;
+ (NSManagedObjectContext *)managedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end

@implementation KMHCoreDataController

#pragma mark - // SETTERS AND GETTERS //

- (void)setMigrationManager:(NSMigrationManager *)migrationManager {
    if (self.migrationManager) {
        [migrationManager removeObserver:self forKeyPath:NSStringFromSelector(@selector(migrationProgress))];
    }
    
    _migrationManager = migrationManager;
    
    if (migrationManager) {
        [migrationManager addObserver:self forKeyPath:NSStringFromSelector(@selector(migrationProgress)) options:NSKeyValueObservingOptionNew context:nil];
    }
}

#pragma mark - // INITS AND LOADS //

- (id)initWithSourceStoreType:(NSString *)sourceStoreType url:(NSURL *)sourceStoreURL managedObjectModel:(NSManagedObjectModel *)managedObjectModel persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    self = [super init];
    if (self) {
        _sourceStoreType = sourceStoreType;
        _sourceStoreURL = sourceStoreURL;
        _managedObjectModel = managedObjectModel;
        _persistentStoreCoordinator = persistentStoreCoordinator;
        _managedObjectContext = managedObjectContext;
    }
    return self;
}

- (id)init {
    return [self initWithSourceStoreType:nil url:nil managedObjectModel:nil persistentStoreCoordinator:nil managedObjectContext:nil];
}

#pragma mark - // PUBLIC METHODS (General) //

+ (void)setupWithName:(NSString *)name type:(NSString *)sourceStoreType resourceName:(NSString *)resourceName error:(NSError *)error {
    NSURL *applicationDocumentsDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    NSString *sourceStoreFilename = [name stringByAppendingString:[KMHCoreDataController extensionForType:sourceStoreType]];
    NSURL *sourceStoreURL = [applicationDocumentsDirectory URLByAppendingPathComponent:sourceStoreFilename];
    NSManagedObjectModel *managedObjectModel = [KMHCoreDataController managedObjectModelWithURL:[[NSBundle mainBundle] URLForResource:resourceName withExtension:@"momd"]];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [KMHCoreDataController persistentStoreCoordinatorWithManagedObjectModel:managedObjectModel sourceStoreURL:sourceStoreURL type:sourceStoreType error:&error];
    if (error) {
        return;
    }
    
    NSManagedObjectContext *managedObjectContext = [KMHCoreDataController managedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType persistentStoreCoordinator:persistentStoreCoordinator];
    
    [KMHCoreDataController initWithSourceStoreType:sourceStoreType url:sourceStoreURL managedObjectModel:managedObjectModel persistentStoreCoordinator:persistentStoreCoordinator managedObjectContext:managedObjectContext];
}

+ (void)save:(void (^)(BOOL success, NSError *error))completionBlock {
    NSManagedObjectContext *managedObjectContext = [KMHCoreDataController managedObjectContext];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KMHCoreDataWillSaveNotification object:nil userInfo:nil];
    
    NSError *error;
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        if (completionBlock) {
            completionBlock(NO, error);
        }
    }
    
    if (completionBlock) {
        completionBlock(YES, nil);
    }
}

#pragma mark - // PUBLIC METHODS (Objects) //

+ (id)createObjectWithClass:(NSString *)className block:(void (^)(id))block {
    NSManagedObjectContext *managedObjectContext = [KMHCoreDataController managedObjectContext];
    __block NSManagedObject *object;
    [managedObjectContext performBlockAndWait:^{
        object = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:managedObjectContext];
        if (block) {
            block(object);
        }
    }];
    return object;
}

+ (NSUInteger)countObjectsWithClass:(NSString *)className predicate:(NSPredicate *)predicate error:(NSError *)error {
    NSManagedObjectContext *managedObjectContext = [KMHCoreDataController managedObjectContext];
    __block NSUInteger count;
    __block NSError *requestError;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:className inManagedObjectContext:managedObjectContext];
        request.predicate = predicate;
        count = [managedObjectContext countForFetchRequest:request error:&requestError];
    }];
    error = requestError;
    return count;
}

+ (NSArray *)fetchObjectsWithClass:(NSString *)className predicate:(NSPredicate *)predicate sortDescriptors:(NSArray <NSSortDescriptor *> *)sortDescriptors error:(NSError **)error {
    NSManagedObjectContext *managedObjectContext = [KMHCoreDataController managedObjectContext];
    __block NSArray *objects;
    __block NSError *requestError;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [NSEntityDescription entityForName:className inManagedObjectContext:managedObjectContext];
        request.predicate = predicate;
        request.sortDescriptors = sortDescriptors;
        objects = [managedObjectContext executeFetchRequest:request error:&requestError];
    }];
    *error = requestError;
    return objects;
}

+ (void)deleteObject:(NSManagedObject *)object error:(NSError **)error {
    if (!object) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Can't delete object.",
                                   NSLocalizedFailureReasonErrorKey : @"object is nil"};
        *error = [NSError errorWithDomain:KMHCoreDataErrorDomain code:-1 userInfo:userInfo];
        return;
    }
    
    if (![object isKindOfClass:[NSManagedObject class]]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Can't delete object",
                                   NSLocalizedFailureReasonErrorKey : @"object is not an NSManagedObject"};
        *error = [NSError errorWithDomain:KMHCoreDataErrorDomain code:-1 userInfo:userInfo];
        return;
    }
    
    NSManagedObjectContext *managedObjectContext = [KMHCoreDataController managedObjectContext];
    [managedObjectContext performBlockAndWait:^{
        [managedObjectContext deleteObject:object];
    }];
}

#pragma mark - // PUBLIC METHODS (Migration) //

+ (BOOL)needsMigration:(NSError *)error {
    NSManagedObjectModel *managedObjectModel = [KMHCoreDataController managedObjectModel];
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:[KMHCoreDataController sourceStoreType] URL:[KMHCoreDataController sourceStoreURL] options:nil error:&error];
    return ![managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata];
}

+ (BOOL)migrate:(NSError *)error {
    // Enable migrations to run even while user exits app
    __block UIBackgroundTaskIdentifier backgroundTask;
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }];
    
    BOOL complete = [KMHCoreDataController progressivelyMigrateURL:[KMHCoreDataController sourceStoreURL] ofType:[KMHCoreDataController sourceStoreType] toModel:[KMHCoreDataController managedObjectModel] error:error];
    
    // Mark it as invalid
    [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
    backgroundTask = UIBackgroundTaskInvalid;
    
    return complete;
}

#pragma mark - // DELEGATED METHODS //

#pragma mark - // OVERWRITTEN METHODS //

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([object isEqual:self.migrationManager]) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(migrationProgress))]) {
            NSDictionary *userInfo = @{KMHCoreDataNotificationObjectKey : @(self.migrationManager.migrationProgress)};
            [[NSNotificationCenter defaultCenter] postNotificationName:KMHCoreDataMigrationProgressDidChangeNotification object:nil userInfo:userInfo];
        }
    }
}

#pragma mark - // PRIVATE METHODS (General) //

+ (instancetype)initWithSourceStoreType:(NSString *)sourceStoreType url:(NSURL *)sourceStoreURL managedObjectModel:(NSManagedObjectModel *)managedObjectModel persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator managedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    static KMHCoreDataController *_sharedController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedController = [[KMHCoreDataController alloc] initWithSourceStoreType:sourceStoreType url:sourceStoreURL managedObjectModel:managedObjectModel persistentStoreCoordinator:persistentStoreCoordinator managedObjectContext:managedObjectContext];
    });
    return _sharedController;
}

+ (instancetype)sharedController {
    return [KMHCoreDataController initWithSourceStoreType:nil url:nil managedObjectModel:nil persistentStoreCoordinator:nil managedObjectContext:nil];
}

+ (NSString *)extensionForType:(NSString *)sourceStoreType {
    if ([sourceStoreType isEqualToString:NSSQLiteStoreType]) {
        return @".sqlite";
    }
    
//    // n.b. OS X only
//    if ([sourceStoreType isEqualToString:NSXMLStoreType]) {
//        return @".xml";
//    }
    
//    if ([sourceStoreType isEqualToString:NSBinaryStoreType]) {
//        return <#extension#>;
//    }
//    
//    if ([sourceStoreType isEqualToString:NSInMemoryStoreType]) {
//        return <#extension#>;
//    }
    
    return nil;
}

#pragma mark - // PRIVATE METHODS (Convenience) //

+ (NSString *)sourceStoreType {
    return [KMHCoreDataController sharedController].sourceStoreType;
}

+ (NSURL *)sourceStoreURL {
    return [KMHCoreDataController sharedController].sourceStoreURL;
}

+ (NSManagedObjectModel *)managedObjectModel {
    return [KMHCoreDataController sharedController].managedObjectModel;
}

+ (NSManagedObjectContext *)managedObjectContext {
    return [KMHCoreDataController sharedController].managedObjectContext;
}

#pragma mark - // PRIVATE METHODS (Migration) //

// All migration code via Marcus Zarra and Objc.io //

+ (void)setMigrationManager:(NSMigrationManager *)migrationManager {
    [KMHCoreDataController sharedController].migrationManager = migrationManager;
}

+ (BOOL)progressivelyMigrateURL:(NSURL *)sourceStoreURL ofType:(NSString *)type toModel:(NSManagedObjectModel *)finalModel error:(NSError *)error {
    NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:type URL:sourceStoreURL options:nil error:&error];
    if (!sourceMetadata) {
        return NO;
    }
    
    if ([finalModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata]) {
        if (NULL != error) {
            error = nil;
        }
        return YES;
    }
    
    NSManagedObjectModel *sourceModel = [KMHCoreDataController sourceModelForSourceMetadata:sourceMetadata];
    NSManagedObjectModel *destinationModel;
    NSMappingModel *mappingModel;
    NSString *modelName;
    if (![KMHCoreDataController getDestinationModel:&destinationModel mappingModel:&mappingModel modelName:&modelName forSourceModel:sourceModel error:&error]) {
        return NO;
    }
    
//    NSArray *mappingModels = @[mappingModel];
//    if ([self.delegate respondsToSelector:@selector(migrationManager:mappingModelsForSourceModel:)]) {
//        NSArray *explicitMappingModels = [self.delegate migrationManager:self mappingModelsForSourceModel:sourceModel];
//        if (0 < explicitMappingModels.count) {
//            mappingModels = explicitMappingModels;
//        }
//    }
    
    // We have a mapping model, time to migrate
    NSURL *destinationStoreURL = [KMHCoreDataController destinationStoreURLWithSourceStoreURL:sourceStoreURL modelName:modelName];
    NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:sourceModel destinationModel:destinationModel];
    
    [KMHCoreDataController setMigrationManager:migrationManager];
    
    // Migrate
    BOOL success = [migrationManager migrateStoreFromURL:sourceStoreURL type:type options:nil withMappingModel:mappingModel toDestinationURL:destinationStoreURL destinationType:type destinationOptions:nil error:&error];
    
    [KMHCoreDataController setMigrationManager:nil];
    
    if (!success) {
        return NO;
    }
    
    // Migration was successful, move the files around to preserve the source in case things go bad
    if (![KMHCoreDataController backupSourceStoreAtURL:sourceStoreURL movingDestinationStoreAtURL:destinationStoreURL error:error]) {
        return NO;
    }
    
    // We may not be at the "current" model yet, so recurse
    return [KMHCoreDataController progressivelyMigrateURL:sourceStoreURL ofType:type toModel:finalModel error:error];
}

+ (NSManagedObjectModel *)sourceModelForSourceMetadata:(NSDictionary *)sourceMetadata {
    return [NSManagedObjectModel mergedModelFromBundles:@[[NSBundle mainBundle]] forStoreMetadata:sourceMetadata];
}

+ (BOOL)getDestinationModel:(NSManagedObjectModel **)destinationModel mappingModel:(NSMappingModel **)mappingModel modelName:(NSString **)modelName forSourceModel:(NSManagedObjectModel *)sourceModel error:(NSError **)error {
    NSArray *modelPaths = [KMHCoreDataController modelPaths];
    if (!modelPaths.count) {
        //Throw an error if there are no models
        if (NULL != error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Could not obtain model paths for Core Data migration."};
            *error = [NSError errorWithDomain:KMHCoreDataErrorDomain code:2 userInfo:userInfo];
        }
        return NO;
    }
    
    //See if we can find a matching destination model
    NSManagedObjectModel *model;
    NSMappingModel *mapping;
    NSString *modelPath;
    for (modelPath in modelPaths) {
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
        mapping = [NSMappingModel mappingModelFromBundles:@[[NSBundle mainBundle]] forSourceModel:sourceModel destinationModel:model];
        //If we found a mapping model then proceed
        if (mapping) {
            break;
        }
    }
    //We have tested every model, if nil here we failed
    if (!mapping) {
        if (NULL != error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"No mapping model found for Core Data migration."};
            *error = [NSError errorWithDomain:KMHCoreDataErrorDomain code:2 userInfo:userInfo];
        }
        return NO;
    }
    
    *destinationModel = model;
    *mappingModel = mapping;
    *modelName = modelPath.lastPathComponent.stringByDeletingPathExtension;
    return YES;
}

+ (NSArray *)modelPaths {
    //Find all of the mom and momd files in the Resources directory
    NSMutableArray *modelPaths = [NSMutableArray array];
    NSArray *momdArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"momd" inDirectory:nil];
    for (NSString *momdPath in momdArray) {
        NSString *resourceSubpath = [momdPath lastPathComponent];
        NSArray *array = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:resourceSubpath];
        [modelPaths addObjectsFromArray:array];
    }
    NSArray *otherModels = [[NSBundle mainBundle] pathsForResourcesOfType:@"mom" inDirectory:nil];
    [modelPaths addObjectsFromArray:otherModels];
    return modelPaths;
}

+ (NSURL *)destinationStoreURLWithSourceStoreURL:(NSURL *)sourceStoreURL modelName:(NSString *)modelName {
    // We have a mapping model, time to migrate
    NSString *storeExtension = sourceStoreURL.path.pathExtension;
    NSString *storePath = sourceStoreURL.path.stringByDeletingPathExtension;
    // Build a path to write the new store
    storePath = [NSString stringWithFormat:@"%@.%@.%@", storePath, modelName, storeExtension];
    return [NSURL fileURLWithPath:storePath];
}

+ (BOOL)backupSourceStoreAtURL:(NSURL *)sourceStoreURL movingDestinationStoreAtURL:(NSURL *)destinationStoreURL error:(NSError *)error {
    NSString *guid = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *backupPath = [NSTemporaryDirectory() stringByAppendingPathComponent:guid];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager moveItemAtPath:sourceStoreURL.path toPath:backupPath error:&error]) {
        //Failed to copy the file
        return NO;
    }
    
    //Move the destination to the source path
    if (![fileManager moveItemAtPath:destinationStoreURL.path toPath:sourceStoreURL.path error:&error]) {
        //Try to back out the source move first, no point in checking it for errors
        [fileManager moveItemAtPath:backupPath toPath:sourceStoreURL.path error:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - // PRIVATE METHODS (Other) //

+ (NSManagedObjectModel *)managedObjectModelWithURL:(NSURL *)modelURL {
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel sourceStoreURL:(NSURL *)sourceStoreURL type:(NSString *)sourceStoreType error:(NSError **)error {
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:sourceStoreType configuration:nil URL:sourceStoreURL options:nil error:error]) {
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
//        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Failed to initialize the application's saved data",
//                                   NSLocalizedFailureReasonErrorKey : @"There was an error creating or loading the application's saved data.",
//                                   NSUnderlyingErrorKey : error};
//        error = [NSError errorWithDomain:KMHCoreDataErrorDomain code:<#code#> userInfo:userInfo];
        
        return nil;
    }
    
    return persistentStoreCoordinator;
}

+ (NSManagedObjectContext *)managedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)type persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:type];
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator;
    return managedObjectContext;
}

@end
