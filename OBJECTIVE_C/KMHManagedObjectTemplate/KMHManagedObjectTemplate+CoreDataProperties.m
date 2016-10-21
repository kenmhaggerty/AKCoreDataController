//
//  <#Class#>.m
//  <#Project#>
//
//  Created by <#Creator#> on <#M/D/YYY#>.
//  Copyright © <#YEAR#> <#Copyright#>. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "<#Class#>+CoreDataProperties.h"

#pragma mark - // <#Class#> //

@implementation <#Class#> (CoreDataProperties)

#pragma mark Setters and Getters

@dynamic <#attribute#>;

@end

@implementation <#Class#> (CoreDataGeneratedAccessors)

- (void)insertObject:(<#Class#> *)value in<#Relationship#>AtIndex:(NSUInteger)idx {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(<#relationship#>))]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(<#relationship#>))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
}

- (void)removeObjectFrom<#Relationship#>AtIndex:(NSUInteger)idx {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(<#relationship#>))]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(<#relationship#>))];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
}

- (void)insert<#Relationship#>:(NSArray *)values atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(<#relationship#>))]];
    [tmpOrderedSet insertObjects:values atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(<#relationship#>))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
}

- (void)remove<#Relationship#>AtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(<#relationship#>))]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(<#relationship#>))];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
}

- (void)replaceObjectIn<#Relationship#>AtIndex:(NSUInteger)idx withObject:(<#Class#> *)value {
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(<#relationship#>))]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(<#relationship#>))];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
}

- (void)replace<#Relationship#>AtIndexes:(NSIndexSet *)indexes with<#Relationship#>:(NSArray *)values {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(<#relationship#>))]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:values];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(<#relationship#>))];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
}

- (void)add<#Relationship#>Object:(<#Class#> *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(<#relationship#>))]];
    NSUInteger idx = [tmpOrderedSet count];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
    [tmpOrderedSet addObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(<#relationship#>))];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
}

- (void)remove<#Relationship#>Object:(<#Class#> *)value {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(<#relationship#>))]];
    NSUInteger idx = [tmpOrderedSet indexOfObject:value];
    if (idx != NSNotFound) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:idx];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
        [tmpOrderedSet removeObject:value];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(<#relationship#>))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
    }
}

- (void)add<#Relationship#>:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(<#relationship#>))]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSUInteger valuesCount = [values count];
    NSUInteger objectsCount = [tmpOrderedSet count];
    for (NSUInteger i = 0; i < valuesCount; ++i) {
        [indexes addIndex:(objectsCount + i)];
    }
    if (valuesCount > 0) {
        [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
        [tmpOrderedSet addObjectsFromArray:[values array]];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(<#relationship#>))];
        [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
    }
}

- (void)remove<#Relationship#>:(NSOrderedSet *)values {
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self mutableOrderedSetValueForKey:NSStringFromSelector(@selector(<#relationship#>))]];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (id value in values) {
        NSUInteger idx = [tmpOrderedSet indexOfObject:value];
        if (idx != NSNotFound) {
            [indexes addIndex:idx];
        }
    }
    if ([indexes count] > 0) {
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
        [tmpOrderedSet removeObjectsAtIndexes:indexes];
        [self setPrimitiveValue:tmpOrderedSet forKey:NSStringFromSelector(@selector(<#relationship#>))];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NSStringFromSelector(@selector(<#relationship#>))];
    }
}

@end
