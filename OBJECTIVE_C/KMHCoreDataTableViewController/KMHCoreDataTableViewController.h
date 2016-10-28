//
//  KMHCoreDataTableViewController.h
//  KMHCoreDataController
//
//  Created by Ken M. Haggerty on 10/21/16.
//  Copyright © 2016 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Public) //

#pragma mark - // IMPORTS (Public) //

#import <UIKit/UIKit.h>

#pragma mark - // KMHCoreDataTableViewController //

#pragma mark Notifications

extern NSString * const KMHCoreDataTableViewControllerDidLoadNotification;

#pragma mark Imports

@class NSManagedObject;

#pragma mark Protocols

@protocol KMHCoreDataDelegate <NSObject>
- (void)setCell:(UITableViewCell *)cell forManagedObject:(NSManagedObject *)managedObject;
@end

#pragma mark Methods

@interface KMHCoreDataTableViewController : UIViewController
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id <KMHCoreDataDelegate> delegate;
@property (nonatomic, strong) NSArray <NSString *> *entityNames;
- (void)reload;
@end
