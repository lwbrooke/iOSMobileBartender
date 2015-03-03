//
//  AddDrinkTableViewController.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "AddDrinkTableViewController.h"
#import "Drink.h"
#import "IngredientsDataSource.h"
#import "AppDelegate.h"

@interface AddDrinkTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtDetail;
@property (weak, nonatomic) IBOutlet UITableView *ingredientsTableview;
@property (weak, nonatomic) IBOutlet UITextView *txtInstructions;
- (IBAction)btnActAddDrink:(id)sender;

@end

@implementation AddDrinkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // to make sure that all cells can be seen above the tab bar
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    // set the data source for the ingredients
    self.ingredientsTableview.dataSource = [IngredientsDataSource sharedInstance];
    // give the datasource a reference to the tableview so it can update it with NSFetchedResultsControllerDelegate methods
    [IngredientsDataSource sharedInstance].tableViewForCreation = self.ingredientsTableview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // make sure nothing is selected each time the view is brought up
    [[IngredientsDataSource sharedInstance] unselectAll];
}

//---------- UITextFieldDelegate Methods ----------//

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    // make the keyboard go away when the return key is pressed
    [textField resignFirstResponder];
    return YES;
}

//---------- end UITextFieldDelegate Methods ----------//

- (IBAction)btnActAddDrink:(id)sender {
    AppDelegate* delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = delegate.context;
    
    Drink* drink = [Drink drinkWithUniqueDrinkName:[self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]  inManagedObjectContext:context];
    
    if (!drink) {
        // if the drink already existed or if there was some other issue
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid drink"
                                                        message:@"A Drink with that name already exists"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // set properties
        drink.name = [self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        drink.details = self.txtDetail.text;
        drink.instructions = self.txtInstructions.text;
        drink.favorite = [NSNumber numberWithBool:NO];
        drink.deletable = [NSNumber numberWithBool:YES];
        
        // add ingredients & maintain relationships
        NSArray* selectedIngredients = [[IngredientsDataSource sharedInstance] getSelectedIngredients];
        [drink addIngredients:[[NSSet alloc] initWithArray:selectedIngredients]];
        for (Ingredient* ingredient in selectedIngredients) {
            [ingredient addDrinksObject:drink];
        }
        
        // save changes
        NSError* err;
        if (![context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
        
        // reset fields
        self.txtName.text = @"";
        self.txtDetail.text = @"";
        self.txtInstructions.text = @"";
        
        // reset ingredients selection
        [[IngredientsDataSource sharedInstance] unselectAll];
        [self.ingredientsTableview reloadData];
        [self.ingredientsTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        // scroll to top
        
        if ([self.txtInstructions isFirstResponder]) [self.txtInstructions resignFirstResponder];
        if ([self.txtDetail isFirstResponder]) [self.txtDetail resignFirstResponder];
        if ([self.txtName isFirstResponder]) [self.txtName resignFirstResponder];
    }
}
@end
