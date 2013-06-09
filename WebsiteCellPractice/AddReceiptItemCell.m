//
//  AddReceiptItemCell.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 3/25/13.
//  Copyright (c) 2013 Zak Stern. All rights reserved.
//

#import "AddReceiptItemCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation AddReceiptItemCell

@synthesize addAnItemLabel,delegate;

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

- (void)setDisplay{
    //self.addAnItemLabel.clipsToBounds = YES;
    [self.contentView.layer setCornerRadius:10.0f];
    //self.contentView.layer.opacity = 0.7;
    self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
    //self.layer.opacity = 0.5;
    self.addAnItemLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:14.0];
    UITapGestureRecognizer* tapPressGesture = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tapPressGesture];
}

- (void)handleTap:(UITapGestureRecognizer *)sender{
    [self.delegate tapToAddAnItemWasTapped:self];
}

@end
