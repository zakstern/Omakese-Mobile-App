//
//  ChangeTipOrTax.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/02/05.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Receipt, Bill;

@interface ChangeTipOrTax : UIViewController <UITextFieldDelegate>


- (IBAction)dismissKeyboard:(id)sender;

- (id)initWithBill:(Bill *)currentBill andReceipt:(Receipt *)currentReceipt;

@property (weak, nonatomic) IBOutlet UITextField *tipPercentage;
@property (weak, nonatomic) IBOutlet UITextField *taxPercentage;
@property Bill *currentBill;
@property Receipt *currentReceipt;
@property NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces;
@property NSNumber *formattedTaxPercentage, *formattedTipPercentage;


- (IBAction)goBack:(id)sender;

@end
