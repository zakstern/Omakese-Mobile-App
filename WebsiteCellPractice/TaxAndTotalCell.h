//
//  TaxAndTotalCell.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/30.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxAndTotalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *taxTextField, *totalTextField, *subTotalTextField, *tipTextField;
@property (weak, nonatomic) IBOutlet UIButton *editTaxOrTipButton;

- (void)updateEditTax:(double)taxPercentage OrTipButton:(double)tipPercentage;

@end
