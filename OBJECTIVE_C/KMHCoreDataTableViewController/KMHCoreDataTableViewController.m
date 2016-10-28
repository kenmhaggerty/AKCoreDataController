//
//  KMHCoreDataTableViewController.m
//  KMHCoreDataController
//
//  Created by Ken M. Haggerty on 10/21/16.
//  Copyright © 2016 Ken M. Haggerty. All rights reserved.
//

#pragma mark - // NOTES (Private) //

// Table view updates are not animated! Maybe in a future update

#pragma mark - // IMPORTS (Private) //

#import "KMHCoreDataTableViewController.h"

#import "KMHCoreDataController.h"

#pragma mark - // KMHCoreDataTableViewController //

#pragma mark Notifications

NSString * const KMHCoreDataTableViewControllerDidLoadNotification = @"kKMHCoreDataTableViewControllerDidLoadNotification";

#pragma mark Private Interface

@interface KMHCoreDataTableViewController ()
@property (nonatomic, strong) IBOutlet UIBarButtonItem *trashButton;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSArray <NSManagedObject *> *> *managedObjectsDictionary;
- (NSArray <NSManagedObject *> *)managedObjectsForSection:(NSUInteger)section;
- (void)deleteManagedObject:(NSManagedObject *)managedObject;
- (void)tableView:(UITableView *)tableView reloadHeaderInSection:(NSInteger)section;
- (void)presentError:(NSError *)error;
- (IBAction)trash:(id)sender;
@end

@implementation KMHCoreDataTableViewController

#pragma mark // Setters and Getters //

@synthesize entityNames = _entityNames;
@synthesize managedObjectsDictionary = _managedObjectsDictionary;

- (void)setEntityNames:(NSArray <NSString *> *)entityNames {
    if ((!entityNames && !self.entityNames) || [entityNames isEqualToArray:self.entityNames]) {
        return;
    }
    
    _entityNames = entityNames;
    
    [self reload];
}

- (NSArray <NSString *> *)entityNames {
    if (_entityNames) {
        return _entityNames;
    }
    
    _entityNames = [NSArray array];
    return self.entityNames;
}

- (void)setManagedObjectsDictionary:(NSMutableDictionary <NSString *, NSArray <NSManagedObject *> *> *)managedObjectsDictionary {
    if ((!managedObjectsDictionary && !self.managedObjectsDictionary) || [managedObjectsDictionary isEqualToDictionary:self.managedObjectsDictionary]) {
        return;
    }
    
    _managedObjectsDictionary = managedObjectsDictionary;
    
    [self.tableView reloadData];
}

- (NSMutableDictionary <NSString *, NSArray <NSManagedObject *> *> *)managedObjectsDictionary {
    if (_managedObjectsDictionary) {
        return _managedObjectsDictionary;
    }
    
    _managedObjectsDictionary = [NSMutableDictionary dictionary];
    return self.managedObjectsDictionary;
}

#pragma mark // Inits and Loads //

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KMHCoreDataTableViewControllerDidLoadNotification object:self userInfo:nil];
}

#pragma mark // Public Methods //

- (void)reload {
    NSMutableDictionary *managedObjectsDictionary = [NSMutableDictionary dictionary];
    NSArray *managedObjects;
//    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(<#selector#>)) ascending:YES];
    NSError *error;
    for (NSString *entityName in self.entityNames) {
        managedObjects = [KMHCoreDataController fetchObjectsWithEntityName:entityName predicate:nil sortDescriptors:nil error:&error];
        if (error) {
            [self presentError:error];
        }
        managedObjectsDictionary[entityName] = managedObjects;
    }
    self.managedObjectsDictionary = managedObjectsDictionary;
}

#pragma mark // Delegated Methods (UITableViewDataSource) //

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.entityNames.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"Header"];
        [header.textLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    [self tableView:tableView setHeader:header forSection:section];
    return header;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self managedObjectsForSection:section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSManagedObject *managedObject = [self managedObjectsForSection:indexPath.section][indexPath.row];
    if (self.delegate) {
        [self.delegate setCell:cell forManagedObject:managedObject];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteManagedObjectAtIndexPath:indexPath];
    }
}

#pragma mark // Delegated Methods (UITableViewDelegate) //

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 44.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark // Private Methods //

- (NSArray <NSManagedObject *> *)managedObjectsForSection:(NSUInteger)section {
    return self.managedObjectsDictionary[self.entityNames[section]];
}

- (void)deleteManagedObjectAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *managedObject = [self managedObjectsForSection:indexPath.section][indexPath.row];
    NSError *error;
    [KMHCoreDataController deleteObject:managedObject error:&error];
    if (error) {
        [self presentError:error];
    }
    
    NSString *entityName = self.entityNames[indexPath.section];
    NSMutableArray *managedObjects = [NSMutableArray arrayWithArray:[self managedObjectsForSection:indexPath.section]];
    [managedObjects removeObjectAtIndex:indexPath.row];
    self.managedObjectsDictionary[entityName] = [NSArray arrayWithArray:managedObjects];
    
    [KMHCoreDataController save:^(BOOL success, NSError *error) {
        if (error) {
            [self presentError:error];
        }
        if (!success) {
            return;
        }
        
        [self tableView:self.tableView reloadHeaderInSection:indexPath.section];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }];
}

- (void)presentError:(NSError *)error {
    NSString *title = error.localizedDescription ?: [NSString stringWithFormat:@"%@ Error %ld", error.domain, (long)error.code];
    NSMutableArray *messageComponents = [NSMutableArray array];
    if (error.localizedFailureReason && error.localizedFailureReason.length) {
        [messageComponents addObject:error.localizedFailureReason];
    }
    if (error.localizedRecoverySuggestion && error.localizedRecoverySuggestion.length) {
        [messageComponents addObject:error.localizedRecoverySuggestion];
    }
    NSString *message = [messageComponents componentsJoinedByString:@" "];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView reloadHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView headerViewForSection:section];
    if (header) {
        [self tableView:tableView setHeader:header forSection:section];
    }
}

- (void)tableView:(UITableView *)tableView setHeader:(UITableViewHeaderFooterView *)header forSection:(NSInteger)section {
    NSString *entityName = self.entityNames[section];
    NSUInteger count = [self managedObjectsForSection:section].count;
    header.textLabel.text = [NSString stringWithFormat:@"%@ (%i)", entityName, count];
}

- (IBAction)trash:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Delete All Objects" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSUInteger count;
        for (int section = 0; section < self.entityNames.count; section++) {
            count = [self managedObjectsForSection:section].count;
            while (count) {
                [self deleteManagedObjectAtIndexPath:[NSIndexPath indexPathForRow:--count inSection:section]];
            }
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
