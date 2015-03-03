//
//  Ingredient.h
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Drink, IngredientCategory;

@interface Ingredient : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * deletable;
@property (nonatomic, retain) NSNumber * isSelected;
@property (nonatomic, retain) IngredientCategory *category;
@property (nonatomic, retain) NSSet *drinks;

+ (NSString*) entityName;
+ (Ingredient *)ingredientWithUniqueingredientName:(NSString *)uniqueName inManagedObjectContext:(NSManagedObjectContext *)context;
@end

@interface Ingredient (CoreDataGeneratedAccessors)

- (void)addDrinksObject:(Drink *)value;
- (void)removeDrinksObject:(Drink *)value;
- (void)addDrinks:(NSSet *)values;
- (void)removeDrinks:(NSSet *)values;

@end
