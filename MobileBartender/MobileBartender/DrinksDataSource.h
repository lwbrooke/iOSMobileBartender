//
//  DrinksDataSource.h
//  MobileBartender
//
//  Created by Brooke, Logan on 12/9/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "Drink.h"

@interface DrinksDataSource : NSObject<UITableViewDataSource, NSFetchedResultsControllerDelegate>

+ (instancetype)sharedInstance;

- (id)init UNAVAILABLE_ATTRIBUTE;

- (Drink*)getDrinkAtIndexPath: (NSIndexPath*) indexPath;

@property (nonatomic, strong) NSFetchedResultsController* frc;
@property (nonatomic, strong) UITableView* tableView;

@end
