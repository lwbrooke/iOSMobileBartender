//
//  DrinksDataSource.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/9/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "DrinksDataSource.h"
#import "AppDelegate.h"

@interface DrinksDataSource ()

@property (nonatomic, strong) NSManagedObjectContext* context;

-(instancetype)initSingleton;
-(UITableViewCell*)configureCell:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath;

@end

@implementation DrinksDataSource

+ (instancetype)sharedInstance
{
    static dispatch_once_t token;
    static id sharedInstance = nil;
    dispatch_once(&token, ^{
        sharedInstance = [[DrinksDataSource alloc] initSingleton];
    });
    return sharedInstance;
}

- (id)initSingleton
{
    if (self = [super init])
    {
        AppDelegate* delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        self.context = delegate.context;
    }
    return self;
}

-(UITableViewCell*)configureCell:(UITableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath {
    // sets up the given cell with the info from the given index path
    
    Drink* drink = self.frc.fetchedObjects[indexPath.row];
    
    cell.textLabel.text = drink.name;
    if ([drink.deletable boolValue]) {
        // if the drink was user created, append an asterisk
        cell.textLabel.text = [cell.textLabel.text stringByAppendingString:@" *"];
    }
    cell.detailTextLabel.text = drink.details;
    
    return cell;
}

- (Drink*)getDrinkAtIndexPath: (NSIndexPath*) indexPath {
    return self.frc.fetchedObjects[indexPath.row];
}
//---------- UITableViewDelegate methods ----------//

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.frc.fetchedObjects.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"DrinkCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    return [self configureCell:cell atIndexPath:indexPath];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frc.sections[indexPath.section];
    Drink* drink = sectionInfo.objects[indexPath.row];
    return [drink.deletable boolValue];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.frc sections][indexPath.section];
        Drink* drink = [sectionInfo objects][indexPath.row];
        
        // remove item from the context
        [self.context deleteObject:drink];
        
        // save changes
        NSError* err;
        if (![self.context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
    }
}

//---------- end UITableViewDelegate methods ----------//

//---------- NSFetchedResultsControllerDelegate methods ----------//

// boilerplated from the Apple documentation on NSFetchedResultsControllerDelegate
// changed the withRowAnimation to UITableViewRowAnimationAutomatic

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(UITableViewCell*)[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}
//---------- end NSFetchedResultsControllerDelegate methods ----------//


@end
