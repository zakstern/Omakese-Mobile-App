//
//  TotalCell.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/30.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TotalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *subTotalTextField, *taxTextField, *tipTextField, *totalTextField;
@property (weak, nonatomic) IBOutlet UIButton *editTaxOrTipButton;

- (void)updateEditTax:(double)taxPercentage OrTipButton:(double)tipPercentage;

@end
