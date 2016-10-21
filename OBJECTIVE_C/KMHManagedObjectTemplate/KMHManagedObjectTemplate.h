//
//  <#Class#>.h
//  <#Project#>
//
//  Created by <#Creator#> on <#M/D/YYY#>.
//  Copyright © <#YEAR#> <#Copyright#>. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <Foundation/Foundation.h>
#import "<#Superclass#>.h"

#pragma mark - // <#Class#> //

#pragma mark Notifications

extern NSString * _Nonnull const <#Class#>NotificationObjectKey;

extern NSString * _Nonnull const <#Class#>WasCreatedNotification;
extern NSString * _Nonnull const <#Class#>WillSaveNotification;
extern NSString * _Nonnull const <#Class#>DidSaveNotification;
extern NSString * _Nonnull const <#Class#>WillBeDeletedNotification;

extern NSString * _Nonnull const <#Class#><#Attribute#>DidSaveNotification;

#pragma mark Methods

NS_ASSUME_NONNULL_BEGIN

@interface <#Class#> : <#Superclass#>

<#methods#>

@end

NS_ASSUME_NONNULL_END

#import "<#Class#>+CoreDataProperties.h"
