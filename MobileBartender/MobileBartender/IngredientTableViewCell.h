//
//  IngredientTableViewCell.h
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IngredientTableViewCellDelegate <NSObject>

-(void)toggleIngredientAtIndexPathForCell:(UITableViewCell*)cell;

@end

@interface IngredientTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *txtTitle;
@property (weak, nonatomic) IBOutlet UISwitch *chosenSwitch;
@property (nonatomic, weak) id<IngredientTableViewCellDelegate> delegate;

@end
