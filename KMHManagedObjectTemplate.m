//
//  <#Class#>.m
//  <#Project#>
//
//  Created by <#Creator#> on <#M/D/YYY#>.
//  Copyright © <#YEAR#> <#Copyright#>. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "<#Class#>.h"

#pragma mark - // <#Class#> //

#pragma mark Notifications

NSString * _Nonnull const <#Class#>NotificationObjectKey = @"object";

NSString * _Nonnull const <#Class#>WasCreatedNotification = @"k<#Class#>WasCreatedNotification";
NSString * _Nonnull const <#Class#>WillSaveNotification = @"k<#Class#>WillSaveNotification";
NSString * _Nonnull const <#Class#>DidSaveNotification = @"k<#Class#>DidSaveNotification";
NSString * _Nonnull const <#Class#>WillBeDeletedNotification = @"k<#Class#>WillBeDeletedNotification";

NSString * _Nonnull const <#Class#><#Attribute#>DidSaveNotification = @"k<#Class#><#Attribute#>DidSaveNotification";

#pragma mark Methods

@interface <#Class#> ()
@property (nonatomic, readwrite) BOOL willBeDeleted;
@property (nonatomic, readwrite) BOOL wasDeleted;
@end

@implementation <#Class#>

#pragma mark Setters and Getters

@dynamic willBeDeleted;
@dynamic wasDeleted;

#pragma mark Inits and Loads

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:<#Class#>WasCreatedNotification object:self userInfo:nil];
}

- (void)willSave {
    [super willSave];
    
    NSDictionary *userInfo = @{<#Class#>NotificationObjectKey : self.changedKeys};
    [[NSNotificationCenter defaultCenter] postNotificationName:<#Class#>WillSaveNotification object:self userInfo:userInfo];
}

- (void)didSave {
    if (self.willBeDeleted) {
        self.willBeDeleted = NO;
        self.wasDeleted = YES;
    }
    
    if (!self.changedKeys || self.isDeleted) {
        NSDictionary *userInfo = @{<#Class#>NotificationObjectKey : self.changedKeys};
        [[NSNotificationCenter defaultCenter] postNotificationName:<#Class#>DidSaveNotification object:self userInfo:userInfo];
    }
    
    if (self.changedKeys && !self.inserted) {
        NSDictionary *userInfo;
        if ([self.changedKeys containsObject:NSStringFromSelector(@selector(<#attribute#>))]) {
            userInfo = self.<#attribute#> ? @{<#Class#>NotificationObjectKey : self.<#attribute#>} : @{};
            [[NSNotificationCenter defaultCenter] postNotificationName:<#Class#><#Attribute#>DidSaveNotification object:self userInfo:userInfo];
        }
    }
    
    [super didSave];
}

- (void)prepareForDeletion {
    [super prepareForDeletion];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:<#Class#>WillBeDeletedNotification object:self userInfo:nil];
}

#pragma mark Public Methods

<#methods#>

#pragma mark Delegated Methods

#pragma mark Overwritten Methods

#pragma mark Private Methods

@end
