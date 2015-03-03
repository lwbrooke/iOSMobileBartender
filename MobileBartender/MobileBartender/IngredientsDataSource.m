//
//  IngredientsDataSource.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "IngredientsDataSource.h"
#import "AppDelegate.h"
#import "IngredientCategory.h"

@interface IngredientsDataSource ()

@property (nonatomic, strong) NSManagedObjectContext* context;
@property (nonatomic, strong) NSFetchedResultsController* frcIngredients;
@property (nonatomic, strong) NSArray* ingredientCategories;

-(instancetype)initSingleton;
-(UITableViewCell*)configureCell:(IngredientTableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath;

@end

@implementation IngredientsDataSource

+ (instancetype)sharedInstance
{
    static dispatch_once_t token;
    static id sharedInstance = nil;
    dispatch_once(&token, ^{
        sharedInstance = [[IngredientsDataSource alloc] initSingleton];
    });
    return sharedInstance;
}

- (id)initSingleton
{
    if (self = [super init])
    {
        AppDelegate* delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        self.context = delegate.context;
        
        // get categories
        NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:[IngredientCategory entityName]];
        NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        [request setSortDescriptors:@[sortDescriptor]];
        
        NSError* err;
        self.ingredientCategories = [self.context executeFetchRequest:request error:&err];
        
        // get frc for ingredients
        request = [[NSFetchRequest alloc] initWithEntityName:[Ingredient entityName]];
        request.fetchBatchSize = 20;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"category.name" ascending:YES];
        NSSortDescriptor* sortDescriptorSecondary = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        [request setSortDescriptors:@[sortDescriptor, sortDescriptorSecondary]];
        
        self.frcIngredients = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                       managedObjectContext:self.context
                                                         sectionNameKeyPath:@"category.name"
                                                                  cacheName:nil];
        
        self.frcIngredients.delegate = self;
        
        if (![self.frcIngredients performFetch:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
    }
    return self;
}

-(void)unselectAll {
    // ensures that all ingredients are marked as unselected
    for (Ingredient* ingredient in self.frcIngredients.fetchedObjects) {
        ingredient.isSelected = [NSNumber numberWithBool:NO];
    }
    
    // save changes
    NSError* err;
    if (![self.context save:&err]) {
        NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
    }
}

- (NSArray*) getSelectedIngredients {
    // fetch all ingredients that are marked as selected
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:[Ingredient entityName]];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %d", @"isSelected", 1];
    [request setPredicate:predicate];
    
    NSError* err;
    NSArray* selectedIngredients = [self.context executeFetchRequest:request error:&err];
    if (err) {
        NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
    }
    // return array of selected ingredients
    return selectedIngredients;
}

-(UITableViewCell*)configureCell:(IngredientTableViewCell*) cell atIndexPath:(NSIndexPath*) indexPath {
    // sets up the given cell with the info from the given index path
    
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frcIngredients.sections[indexPath.section];
    Ingredient* ingredient = sectionInfo.objects[indexPath.row];
    
    cell.txtTitle.text = ingredient.name;
    if ([ingredient.deletable boolValue]) {
        // asterisk appended to user created ingredients
        cell.txtTitle.text = [cell.txtTitle.text stringByAppendingString:@" *"];
    }
    cell.chosenSwitch.on = [ingredient.isSelected boolValue];
    if (!cell.delegate) {
        cell.delegate = self;
    }
    
    return cell;
}

//---------- UITableViewDataSource methods ----------//

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.frcIngredients.sections[section] numberOfObjects];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"IngredientCell";
    IngredientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[IngredientTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return [self configureCell:cell atIndexPath:indexPath];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.ingredientCategories count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    IngredientCategory* category = self.ingredientCategories[section];
    return category.name;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frcIngredients.sections[indexPath.section];
    Ingredient* ingredient = sectionInfo.objects[indexPath.row];
    return [ingredient.deletable boolValue];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.frcIngredients sections][indexPath.section];
        Ingredient* ingredient = [sectionInfo objects][indexPath.row];
        
        // remove item from the context
        [self.context deleteObject:ingredient];
        
        // save changes
        NSError* err;
        if (![self.context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
    }
}

//---------- end UITableViewDataSource methods ----------//

//---------- IngredientTableViewCellDelegate methods ----------//

-(void)toggleIngredientAtIndexPathForCell:(UITableViewCell *)cell {
    // grabs the index path for the cell out of hte appropriate table, if there's a difference between the two
    // possible one of the views was never loaded.
    NSIndexPath* indexPath;
    if (cell.tag == 1) {
        indexPath = [self.tableViewForSelection indexPathForCell:cell];
    } else {
        indexPath = [self.tableViewForCreation indexPathForCell:cell];
    }
    
    // toggle the isSelected property on the ingredient and save
    id <NSFetchedResultsSectionInfo> sectionInfo = self.frcIngredients.sections[indexPath.section];
    Ingredient* ingredient = sectionInfo.objects[indexPath.row];
    ingredient.isSelected = [NSNumber numberWithBool:![ingredient.isSelected boolValue]];
    
    NSError* err;
    if (![self.context save:&err]) {
        NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
    }
}

//---------- end IngredientTableViewCellDelegate methods ----------//

//---------- NSFetchedResultsControllerDelegate methods ----------//

// boilerplated from the Apple documentation on NSFetchedResultsControllerDelegate
// changed the withRowAnimation to UITableViewRowAnimationAutomatic
// effects changes on both tableviews

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableViewForSelection beginUpdates];
    [self.tableViewForCreation beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableViewForSelection insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableViewForCreation insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableViewForSelection deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableViewForCreation deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableViewForSelection = self.tableViewForSelection;
    UITableView *tableViewForCreation = self.tableViewForCreation;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableViewForSelection insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableViewForCreation insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableViewForSelection deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableViewForCreation deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(IngredientTableViewCell*)[tableViewForSelection cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            [self configureCell:(IngredientTableViewCell*)[tableViewForCreation cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableViewForSelection deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableViewForSelection insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [tableViewForCreation deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableViewForCreation insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableViewForSelection endUpdates];
    [self.tableViewForCreation endUpdates];
}
//---------- end NSFetchedResultsControllerDelegate methods ----------//

@end
