//
//  Drink.h
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Ingredient;

@interface Drink : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * details;
@property (nonatomic, retain) NSString * instructions;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSNumber * deletable;
@property (nonatomic, retain) NSSet *ingredients;

+ (NSString*) entityName;
+ (Drink *)drinkWithUniqueDrinkName:(NSString *)uniqueName inManagedObjectContext:(NSManagedObjectContext *)context;
@end

@interface Drink (CoreDataGeneratedAccessors)

- (void)addIngredientsObject:(Ingredient *)value;
- (void)removeIngredientsObject:(Ingredient *)value;
- (void)addIngredients:(NSSet *)values;
- (void)removeIngredients:(NSSet *)values;

@end
