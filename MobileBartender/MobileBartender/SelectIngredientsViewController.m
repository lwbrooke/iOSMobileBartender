//
//  SelectIngredientsViewController.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "SelectIngredientsViewController.h"
#import "IngredientsDataSource.h"
#import "Drink.h"
#import "AppDelegate.h"
#import "DrinksDataSource.h"
#import "ViewDrinksViewController.h"

@interface SelectIngredientsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *ingredientsTableview;

@end

@implementation SelectIngredientsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ingredientsTableview.dataSource = [IngredientsDataSource sharedInstance];
    [IngredientsDataSource sharedInstance].tableViewForSelection = self.ingredientsTableview;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // ensures that the table is scrolled to the top and that all ingredients are unselected
    [[IngredientsDataSource sharedInstance] unselectAll];
    [self.ingredientsTableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem* button = sender;
    // prepare the fetch request info that is shared between the two buttons
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:[Drink entityName]];
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
    [request setSortDescriptors:@[sortDescriptor]];
    
    AppDelegate* delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext* context = delegate.context;
    
    if (button.tag == 1) {
        // favorites
        
        // fetch if favorite flag is on
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"favorite", @1];
        [request setPredicate:predicate];
        
        NSFetchedResultsController* frcFavorites = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                       managedObjectContext:context
                                                                                         sectionNameKeyPath:nil
                                                                                                  cacheName:nil];
        //
        
        NSError* err;
        if (![frcFavorites performFetch:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
        
        // set FetchedResultsController for data source
        [DrinksDataSource sharedInstance].frc = frcFavorites;
        frcFavorites.delegate = [DrinksDataSource sharedInstance];
        
        // set the title to show favorites on the next view
        ViewDrinksViewController* vdvc = segue.destinationViewController;
        vdvc.navigationItem.title = @"Favorites";
    } else if (button.tag == 2) {
        // find
        
        // get list of selected ingredients
        NSArray* selectedIngredients = [[IngredientsDataSource sharedInstance] getSelectedIngredients];
        // fetch if the count of ingredients that are in the list of selected ingredients is equal to the count of ingredients in the drink
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(ingredients, $i, $i IN %@).@count = ingredients.@count", selectedIngredients];
        [request setPredicate:predicate];
        
        NSFetchedResultsController* frcSearch = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                                       managedObjectContext:context
                                                                                         sectionNameKeyPath:nil
                                                                                                  cacheName:nil];
        //
        
        NSError* err;
        if (![frcSearch performFetch:&err])
        {
            NSLog(@"%s - %@", __PRETTY_FUNCTION__, err);
        }
        
        // set FetchedResultsController for data source
        [DrinksDataSource sharedInstance].frc = frcSearch;
        frcSearch.delegate = [DrinksDataSource sharedInstance];
        
        // set the title to show found on the next view
        ViewDrinksViewController* vdvc = segue.destinationViewController;
        vdvc.navigationItem.title = @"Found";
    }
}

@end
