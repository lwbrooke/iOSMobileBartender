//
//  Drink.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "Drink.h"
#import "Ingredient.h"


@implementation Drink

@dynamic name;
@dynamic details;
@dynamic instructions;
@dynamic favorite;
@dynamic deletable;
@dynamic ingredients;

+ (NSString*) entityName {
    return @"Drink";
}

+ (Drink *)drinkWithUniqueDrinkName:(NSString *)uniqueName inManagedObjectContext:(NSManagedObjectContext *)context
{
    // fetches drinks with the name given
    Drink *drink = nil;
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name ==[cd] %@", uniqueName];
    [request setPredicate:predicate];
    
    NSError *err;
    drink = [[context executeFetchRequest:request error:&err] lastObject];
    
    if (err) {
        NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
    } else if (!drink) {
        // if no drink was found, return a new drink object
        return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
                                                   inManagedObjectContext:context];
    }
    // if a drink was found, or there was an error, return nil
    return nil;
}

@end
