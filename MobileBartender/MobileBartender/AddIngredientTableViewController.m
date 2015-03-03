//
//  AddIngredientTableViewController.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "AddIngredientTableViewController.h"
#import "AppDelegate.h"
#import "IngredientCategory.h"
#import "Ingredient.h"

@interface AddIngredientTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UIPickerView *pkrCategory;
- (IBAction)btnActAddIngredient:(id)sender;

@property (nonatomic, strong) NSArray* pkrCategoryObjects;

@end

@implementation AddIngredientTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // to make sure that all cells can be seen above the tab bar
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    // make sure the picker view has data
    self.pkrCategory.dataSource = self;
    self.pkrCategory.delegate = self;
    
    AppDelegate* delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = delegate.context;
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:[IngredientCategory entityName]];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError* err;
    self.pkrCategoryObjects = [context executeFetchRequest:request error:&err];
    
    if (![context save:&err])
    {
        NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnActAddIngredient:(id)sender {
    AppDelegate* delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = delegate.context;
    
    Ingredient* ingredient = [Ingredient ingredientWithUniqueingredientName:[self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]  inManagedObjectContext:context];
    
    
    if (!ingredient) {
        // ingredient already existed, so nil was returned
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Ingredient"
                                                        message:@"Your ingredient already exists"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    } else {
        // add new ingredient
        ingredient.name = [self.txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        ingredient.deletable = [NSNumber numberWithBool:YES];
        ingredient.isSelected = [NSNumber numberWithBool:NO];
        ingredient.category = self.pkrCategoryObjects[[self.pkrCategory selectedRowInComponent:0]];
        
        [self.pkrCategoryObjects[[self.pkrCategory selectedRowInComponent:0]] addIngredientsObject:ingredient];
        
        // save changes
        NSError* err;
        if (![context save:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
        
        // reset fields
        self.txtName.text = @"";
        [self.pkrCategory selectRow:0 inComponent:0 animated:YES];
        
        // scroll to top
        if ([self.txtName isFirstResponder]) [self.txtName resignFirstResponder];
    }
}

//---------- UIPickerViewDatasource Methods ----------//

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pkrCategoryObjects count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    IngredientCategory* category = self.pkrCategoryObjects[row];
    return category.name;
}

//---------- end UIPickerViewDatasource Methods ----------//

//---------- UIPickerViewDelegate Methods ----------//

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}

//---------- end UIPickerViewDelegate Methods ----------//

//---------- UITextFieldDelegate Methods ----------//

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    // make the keyboard go away when the return key is pressed
    [textField resignFirstResponder];
    return YES;
}

//---------- end UITextFieldDelegate Methods ----------//
@end
