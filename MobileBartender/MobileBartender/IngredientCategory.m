//
//  IngredientCategory.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "IngredientCategory.h"
#import "Ingredient.h"


@implementation IngredientCategory

@dynamic name;
@dynamic ingredients;

+ (NSString*) entityName {
    return @"IngredientCategory";
}

@end
