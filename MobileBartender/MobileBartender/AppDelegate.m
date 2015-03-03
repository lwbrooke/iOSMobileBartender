//
//  AppDelegate.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "AppDelegate.h"
#import "Ingredient.h"
#import "IngredientCategory.h"
#import "Drink.h"

@interface AppDelegate ()
-(void) initializeCoreDataStack;
-(void) seedCoreData;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self initializeCoreDataStack];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void) initializeCoreDataStack {
    // initialize core data
    
    NSURL* inventoryModelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    NSManagedObjectModel* mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:inventoryModelURL];
    
    NSPersistentStoreCoordinator* psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* dirs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL* storeURL = [dirs lastObject];
    storeURL = [storeURL URLByAppendingPathComponent:@"MobileBartenderStore.sqlite"];
    
    NSError* err;
    [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&err];
    
    NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
    [moc setPersistentStoreCoordinator:psc];
    
    self.context = moc;
    
    // uncomment to seed the stack if there's no data
    [self seedCoreData];
}

-(void) seedCoreData {
    // only seeds if the store is below the the number of items here, as these can't be deleted
    
    // info for ease of seeding
    NSArray* categoryNames = @[@"Spirits", @"Liqueurs", @"Vermouth & Bitters", @"Non-Alcoholic", @"Garnishes", @"Others"];
    NSArray* ingredientNames = @[/*0*/@"Whiskey", @"Vodka", @"Light Rum", @"Gin", /*4*/@"Triple Sec", @"Coffee liqueur", @"Crème de Cacao", @"Maraschino liqueur", /*8*/@"Dry Vermouth", @"Sweet Vermouth", @"Angostura Bitters", @"Orange Bitters", /*12*/@"Orange juice", @"Cola", @"Tonic water", @"Grenadine", /*16*/@"Lime", @"Olive", @"Lemon", @"Cherry", /*20*/@"Salt", @"Sugar", @"Pepper", @"Sugar cube"];
    NSError* err;
    
    NSMutableArray* categories = [[NSMutableArray alloc] init];
    NSMutableArray* ingredients = [[NSMutableArray alloc] init];
    
    //----- add categories -----
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:[IngredientCategory entityName]];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    NSArray* results = [self.context executeFetchRequest:request error:&err];
    
    if (!results || results.count < 6) {
        for(int i = 0; i < 6; i++)
        {
            IngredientCategory* category = [NSEntityDescription insertNewObjectForEntityForName:[IngredientCategory entityName] inManagedObjectContext:self.context];
        
            category.name = categoryNames[i];
        
            [categories addObject:category];
        }
    
        if (![self.context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
    }
    
    //----- add ingredients -----
    request = [[NSFetchRequest alloc] initWithEntityName:[Ingredient entityName]];
    [request setSortDescriptors:@[sortDescriptor]];
    results = [self.context executeFetchRequest:request error:&err];
    
    if (!results || results.count < 24) {
        for (int i = 0; i < 24; i++) {
            Ingredient* ingredient = [NSEntityDescription insertNewObjectForEntityForName:[Ingredient entityName] inManagedObjectContext:self.context];
        
            ingredient.name = ingredientNames[i];
            ingredient.deletable = [NSNumber numberWithBool:NO];
            ingredient.isSelected = [NSNumber numberWithBool:NO];
        
            ingredient.category = categories[i/4];
        
            [ingredient.category addIngredientsObject:ingredient];
            [ingredients addObject:ingredient];
        }
    
        if (![self.context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
    }
    
    //----- add drinks -----
    request = [[NSFetchRequest alloc] initWithEntityName:[Drink entityName]];
    [request setSortDescriptors:@[sortDescriptor]];
    results = [self.context executeFetchRequest:request error:&err];
    
    if (!results || results.count < 8) {
            // Whiskey Coke
        Drink* drink = [NSEntityDescription insertNewObjectForEntityForName:[Drink entityName] inManagedObjectContext:self.context];
        
        drink.name = @"Whiskey Coke";
        drink.details = @"A simple and easy whiskey drink";
        drink.instructions = @"1. Fill a rocks glass with ice\n2. Pour 1 part whiskey and 2 parts cola over the ice\n3. Stir drink and serve";
        drink.favorite = [NSNumber numberWithBool:YES];
        drink.deletable = [NSNumber numberWithBool:NO];
        
        [drink addIngredients:[NSSet setWithArray:@[ingredients[0], ingredients[13]]]];
        
        [ingredients[0] addDrinksObject:drink];
        [ingredients[13] addDrinksObject:drink];
        
            // Screwdriver
        drink = [NSEntityDescription insertNewObjectForEntityForName:[Drink entityName] inManagedObjectContext:self.context];
        
        drink.name = @"Screwdriver";
        drink.details = @"A simple and easy vodka drink";
        drink.instructions = @"1. Pour 1 part vodka and 2 parts orange juice in the glass\n2. Stir drink and serve";
        drink.favorite = [NSNumber numberWithBool:YES];
        drink.deletable = [NSNumber numberWithBool:NO];
        
        [drink addIngredients:[NSSet setWithArray:@[ingredients[1], ingredients[12]]]];
        
        [ingredients[1] addDrinksObject:drink];
        [ingredients[12] addDrinksObject:drink];
        
            // Rum & Coke
        drink = [NSEntityDescription insertNewObjectForEntityForName:[Drink entityName] inManagedObjectContext:self.context];
        
        drink.name = @"Rum & Coke";
        drink.details = @"A simple and easy rum drink, often mistakenly called a \"Roman Coke\"";
        drink.instructions = @"1. Fill a rocks glass with ice\n2. Pour 1 part rum and 2 parts cola over the ice\n3. Stir drink and serve";
        drink.favorite = [NSNumber numberWithBool:YES];
        drink.deletable = [NSNumber numberWithBool:NO];
        
        [drink addIngredients:[NSSet setWithArray:@[ingredients[2], ingredients[13]]]];
        
        [ingredients[2] addDrinksObject:drink];
        [ingredients[13] addDrinksObject:drink];

            // Gin & Tonic
        drink = [NSEntityDescription insertNewObjectForEntityForName:[Drink entityName] inManagedObjectContext:self.context];
        
        drink.name = @"Gin & Tonic";
        drink.details = @"A classic gin drink";
        drink.instructions = @"1. Fill a rocks glass with ice\n2. Pour 1 part gin\n3. Squeeze 1 lime wedge into glass, and put the wedge in the glass\n4. Pour 2 parts tonic water\n5. Stir drink\n6. Garnish with another lime wedge and serve";
        drink.favorite = [NSNumber numberWithBool:YES];
        drink.deletable = [NSNumber numberWithBool:NO];
        
        [drink addIngredients:[NSSet setWithArray:@[ingredients[3], ingredients[14], ingredients[16]]]];
        
        [ingredients[3] addDrinksObject:drink];
        [ingredients[14] addDrinksObject:drink];
        [ingredients[16] addDrinksObject:drink];
        
        if (![self.context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
        
            // Manhattan
        drink = [NSEntityDescription insertNewObjectForEntityForName:[Drink entityName] inManagedObjectContext:self.context];
        
        drink.name = @"Manhattan";
        drink.details = @"Classic whiskey cocktail";
        drink.instructions = @"1. Pour 2 parts gin, 1 part sweet vermouth, 1/4 part Maraschino liqueur, and 1 dash Angostura bitters into a mixing glass with ice.\n2. Stir well\n3. Strain into a cocktail glass.\n4. Garnish with cherry and serve.";
        drink.favorite = [NSNumber numberWithBool:YES];
        drink.deletable = [NSNumber numberWithBool:NO];
        
        [drink addIngredients:[NSSet setWithArray:@[ingredients[0], ingredients[9], ingredients[10], ingredients[19]]]];
        
        [ingredients[0] addDrinksObject:drink];
        [ingredients[9] addDrinksObject:drink];
        [ingredients[10] addDrinksObject:drink];
        [ingredients[19] addDrinksObject:drink];
        
        if (![self.context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
        
            // Martinez
        drink = [NSEntityDescription insertNewObjectForEntityForName:[Drink entityName] inManagedObjectContext:self.context];
        
        drink.name = @"Martinez";
        drink.details = @"The precursor to the Martini";
        drink.instructions = @"1. Pour 4 parts rye whiskey, 1 part sweet vermouth, and 2-3 dashes of Angostura bitters into a mixing glass with ice.\n2. Stir well\n3. Strain into a cocktail glass.\n4. Garnish with lemon twist and serve.";
        drink.favorite = [NSNumber numberWithBool:YES];
        drink.deletable = [NSNumber numberWithBool:NO];
        
        [drink addIngredients:[NSSet setWithArray:@[ingredients[3], ingredients[9], ingredients[7], ingredients[10], ingredients[18]]]];
        
        [ingredients[3] addDrinksObject:drink];
        [ingredients[9] addDrinksObject:drink];
        [ingredients[7] addDrinksObject:drink];
        [ingredients[10] addDrinksObject:drink];
        [ingredients[18] addDrinksObject:drink];
        
        if (![self.context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
        
            // Martini
        drink = [NSEntityDescription insertNewObjectForEntityForName:[Drink entityName] inManagedObjectContext:self.context];
        
        drink.name = @"Martini";
        drink.details = @"The drink everyone thinks of when you say 'Cocktail'";
        drink.instructions = @"1. Pour 5 parts gin, and 1 part dry vermouth into a mixing glass with ice.\n2. Stir well\n3. Strain into a cocktail glass.\n4. Garnish with olive and serve.";
        drink.favorite = [NSNumber numberWithBool:YES];
        drink.deletable = [NSNumber numberWithBool:NO];
        
        [drink addIngredients:[NSSet setWithArray:@[ingredients[3], ingredients[8], ingredients[17]]]];
        
        [ingredients[3] addDrinksObject:drink];
        [ingredients[8] addDrinksObject:drink];
        [ingredients[17] addDrinksObject:drink];
        
        if (![self.context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
        
            // Vodka Tonic
        drink = [NSEntityDescription insertNewObjectForEntityForName:[Drink entityName] inManagedObjectContext:self.context];
        
        drink.name = @"Vodka Tonic";
        drink.details = @"An easy vodka cocktail";
        drink.instructions = @"1. Pour 1 part vodka, and 1 part tonic water into a highball glass with ice.\n2. Garnish with lime wedge and serve.";
        drink.favorite = [NSNumber numberWithBool:YES];
        drink.deletable = [NSNumber numberWithBool:NO];
        
        [drink addIngredients:[NSSet setWithArray:@[ingredients[1], ingredients[14], ingredients[16]]]];
        
        [ingredients[1] addDrinksObject:drink];
        [ingredients[14] addDrinksObject:drink];
        [ingredients[16] addDrinksObject:drink];
        
        if (![self.context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
    }
}

@end














