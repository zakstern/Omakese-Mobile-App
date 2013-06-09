//
//  ItemDisplayCell.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/01.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "ItemDisplayCell.h"

@implementation ItemDisplayCell
@synthesize itemNameDisplay,itemPriceDisplay,splitButton,doneButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
