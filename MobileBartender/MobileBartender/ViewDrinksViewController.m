//
//  ViewDrinksViewController.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "ViewDrinksViewController.h"
#import "DrinksDataSource.h"
#import "Drink.h"
#import "DrinkDetailViewController.h"

@interface ViewDrinksViewController ()
@property (weak, nonatomic) IBOutlet UITableView *drinksTableview;

@end

@implementation ViewDrinksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // set the data source and send a reference for the table
    self.drinksTableview.dataSource = [DrinksDataSource sharedInstance];
    [DrinksDataSource sharedInstance].tableView = self.drinksTableview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // give the detail view the drink for the selected cell
    UITableViewCell* cell = sender;
    Drink* drink = [[DrinksDataSource sharedInstance] getDrinkAtIndexPath: [self.drinksTableview indexPathForCell:cell]];
    DrinkDetailViewController* dvc = segue.destinationViewController;
    dvc.drink = drink;
}

@end
