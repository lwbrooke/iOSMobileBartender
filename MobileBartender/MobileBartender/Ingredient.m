//
//  Ingredient.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "Ingredient.h"
#import "Drink.h"
#import "IngredientCategory.h"


@implementation Ingredient

@dynamic name;
@dynamic deletable;
@dynamic isSelected;
@dynamic category;
@dynamic drinks;

+ (NSString*) entityName {
    return @"Ingredient";
}

+ (Ingredient *)ingredientWithUniqueingredientName:(NSString *)uniqueName inManagedObjectContext:(NSManagedObjectContext *)context
{
    // fetches ingredients with the name given
    Ingredient *ingredient = nil;

    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name ==[cd] %@", uniqueName];
    [request setPredicate:predicate];
    
    NSError *err;
    ingredient = [[context executeFetchRequest:request error:&err] lastObject];
    
    if (err) {
        NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
    } else if (!ingredient) {
        // if no ingredient was found, return a new drink object
        return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                                   inManagedObjectContext:context];
    }
    
    // if a ingredient was found, or there was an error, return nil
    return nil;
}

@end
