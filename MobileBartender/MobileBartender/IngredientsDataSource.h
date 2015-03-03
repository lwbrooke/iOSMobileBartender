//
//  IngredientsDataSource.h
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "Ingredient.h"
#import "IngredientTableViewCell.h"

@interface IngredientsDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate, IngredientTableViewCellDelegate>

+ (instancetype)sharedInstance;

- (id)init UNAVAILABLE_ATTRIBUTE;

- (void)unselectAll;
- (NSArray*) getSelectedIngredients;

@property (nonatomic, strong) UITableView* tableViewForSelection;
@property (nonatomic, strong) UITableView* tableViewForCreation;
@end
