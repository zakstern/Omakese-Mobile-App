//
//  TotalCell.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/30.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import "TotalCell.h"

@implementation TotalCell
@synthesize taxTextField, totalTextField, subTotalTextField, tipTextField, editTaxOrTipButton;

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

- (void)updateEditTax:(double)taxPercentage OrTipButton:(double)tipPercentage{
    taxPercentage = taxPercentage*100;
    tipPercentage = tipPercentage*100;
    NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
    NSNumber *formattedTaxPercentage = [NSNumber numberWithDouble:taxPercentage];
    NSNumber *formattedTipPercentage = [NSNumber numberWithDouble:tipPercentage];
    NSString *percentString = @"%:";
    NSString *lineOne = [NSString stringWithFormat:@"Tax @ %@%@",
                         [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTaxPercentage], percentString];
    NSString *lineTwo = [NSString stringWithFormat:@"Tip @ %@%@",
                         [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTipPercentage], percentString];
    NSMutableAttributedString *currentAttributedTitle = [[NSMutableAttributedString alloc]initWithAttributedString:[editTaxOrTipButton attributedTitleForState:UIControlStateNormal]];
    [currentAttributedTitle replaceCharactersInRange:(NSRange){0,[currentAttributedTitle length]} withString:[NSString stringWithFormat:@"%@ \n %@",lineOne,lineTwo]];
    [editTaxOrTipButton setAttributedTitle:currentAttributedTitle forState:UIControlStateNormal];
}

@end
