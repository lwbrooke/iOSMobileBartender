//
//  IngredientTableViewCell.m
//  MobileBartender
//
//  Created by Brooke, Logan on 12/8/14.
//  Copyright (c) 2014 Brooke, Logan. All rights reserved.
//

#import "IngredientTableViewCell.h"

@implementation IngredientTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)switchToggled:(UISwitch *)sender {
    // calls the delegate method to toggle the ingredient represented by this cell
    [self.delegate toggleIngredientAtIndexPathForCell:self];
}

@end
