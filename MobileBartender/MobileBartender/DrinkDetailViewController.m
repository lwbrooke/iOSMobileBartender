//
//  DrinkDetailViewController.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/9/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "DrinkDetailViewController.h"
#import "Ingredient.h"
#import "AppDelegate.h"

@interface DrinkDetailViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnFavorite;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UITextView *txtBoxIngredients;
@property (weak, nonatomic) IBOutlet UITextView *txtBoxInstructions;
@property (weak, nonatomic) IBOutlet UITextView *txtBoxDetails;
- (IBAction)favoriteButtonAction:(UIBarButtonItem *)sender;

@end

@implementation DrinkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // assign labels and text boxes the appropriate data
    self.lblName.text = self.drink.name;
    self.txtBoxDetails.text = self.drink.details;
    
    NSArray* ingredientsList = self.drink.ingredients.allObjects;
    NSMutableString* ingredientsString = [NSMutableString stringWithString:@""];
    for (int i = 0; i < [ingredientsList count]; i++) {
        [ingredientsString appendFormat:@"%@\n", ((Ingredient*)ingredientsList[i]).name];
    }
    self.txtBoxIngredients.text = ingredientsString;
    
    self.txtBoxInstructions.text = self.drink.instructions;
    
    // assign the favorite button the appropriate state
    self.btnFavorite.tag = self.drink.favorite.integerValue;
    if (self.btnFavorite.tag != 0) {
        self.btnFavorite.image = [UIImage imageNamed:@"Favorite"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)favoriteButtonAction:(UIBarButtonItem *)sender {
    if (sender.tag == 0) {
        // make favorite
        sender.image = [UIImage imageNamed:@"Favorite"];
        self.drink.favorite = [NSNumber numberWithBool:YES];
        sender.tag = 1;
    } else {
        // remove favorite
        sender.image = [UIImage imageNamed:@"FavoriteUnselected"];
        self.drink.favorite = [NSNumber numberWithBool:NO];
        sender.tag = 0;
    }
    
    // save changes
    AppDelegate* delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = delegate.context;
    
    NSError* err;
    if (![context save:&err])
    {
        NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
    }
    
}
@end
