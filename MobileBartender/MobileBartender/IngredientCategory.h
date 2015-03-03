//
//  IngredientCategory.h
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Ingredient;

@interface IngredientCategory : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *ingredients;

+ (NSString*) entityName;
@end

@interface IngredientCategory (CoreDataGeneratedAccessors)

- (void)addIngredientsObject:(Ingredient *)value;
- (void)removeIngredientsObject:(Ingredient *)value;
- (void)addIngredients:(NSSet *)values;
- (void)removeIngredients:(NSSet *)values;

@end
