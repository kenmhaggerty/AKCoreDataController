//
//  <#Class#>.h
//  <#Project#>
//
//  Created by <#Creator#> on <#M/D/YYY#>.
//  Copyright © <#YEAR#> <#Copyright#>. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import "<#Class#>.h"

#pragma mark - // <#Class#> //

NS_ASSUME_NONNULL_BEGIN

@interface <#Class#> (CoreDataProperties)

@property (nullable, nonatomic, retain) <#Class#> *<#attribute#>;

@end

@interface <#Class#> (CoreDataGeneratedAccessors)

- (void)add<#Relationship#>Object:(<#Class#> *)value;
- (void)remove<#Relationship#>Object:(<#Class#> *)value;
- (void)add<#Relationship#>:(NSSet <<#Class#> *> *)values;
- (void)remove<#Relationship#>:(NSSet <<#Class#> *> *)values;

- (void)insertObject:(<#Class#> *)value in<#Relationship#>AtIndex:(NSUInteger)idx;
- (void)removeObjectFrom<#Relationship#>AtIndex:(NSUInteger)idx;
- (void)insert<#Relationship#>:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)remove<#Relationship#>AtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectIn<#Relationship#>AtIndex:(NSUInteger)idx withObject:(<#Class#> *)value;
- (void)replace<#Relationship#>AtIndexes:(NSIndexSet *)indexes with<#Relationship#>:(NSArray *)values;
- (void)add<#Relationship#>Object:(<#Class#> *)value;
- (void)remove<#Relationship#>Object:(<#Class#> *)value;
- (void)add<#Relationship#>:(NSOrderedSet *)values;
- (void)remove<#Relationship#>:(NSOrderedSet *)values;

@end

NS_ASSUME_NONNULL_END
