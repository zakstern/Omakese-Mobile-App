//
//  ChangeTipOrTax.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/02/05.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "ChangeTipOrTax.h"
#import "Receipt.h"
#import "Bill.h"
#import "TableViewKeyboardDismisser.h"
#import "UIView+UIView_FirstResponder.h"

@interface ChangeTipOrTax ()

@end

@implementation ChangeTipOrTax
@synthesize tipPercentage,taxPercentage,currentBill,currentReceipt,doubleValueWithMaxTwoDecimalPlaces,formattedTaxPercentage,formattedTipPercentage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithBill:(Bill *)currentBill andReceipt:(Receipt *)currentReceipt{
    self = [super initWithNibName:@"ChangeTipOrTax" bundle:nil];
    if (self) {
        self.currentBill = currentBill;
        self.currentReceipt = currentReceipt;
        self.doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
        [self.doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
        [self.doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.formattedTaxPercentage = [NSNumber numberWithDouble:self.currentReceipt.taxPercentage*100];
    self.formattedTipPercentage = [NSNumber numberWithDouble:self.currentReceipt.tipPercentage*100];
    taxPercentage.text = [NSString stringWithFormat:@"%@%@",
                          [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTaxPercentage],@"%"];
    tipPercentage.text = [NSString stringWithFormat:@"%@%@",
                          [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTipPercentage],@"%"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissKeyboard:(id)sender {
    UIView *keyboardOwner = [self.view findFirstResponder];
    [keyboardOwner resignFirstResponder];
}
- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

////UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag == 1) {
        textField.text = [NSString stringWithFormat:@"%@",
                             [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTaxPercentage]];
    } else {
        textField.text = [NSString stringWithFormat:@"%@",
                          [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTipPercentage]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 1) {
        self.currentReceipt.taxPercentage = [textField.text doubleValue]/100;
        self.formattedTaxPercentage = [NSNumber numberWithDouble:self.currentReceipt.taxPercentage*100];
        taxPercentage.text = [NSString stringWithFormat:@"%@%@",
                              [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTaxPercentage],@"%"];
    } else {
        self.currentReceipt.tipPercentage = [textField.text doubleValue]/100;
        self.formattedTipPercentage = [NSNumber numberWithDouble:self.currentReceipt.tipPercentage*100];
        tipPercentage.text = [NSString stringWithFormat:@"%@%@",
                              [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTipPercentage],@"%"];
    }
    [self.currentBill calculateBill];
}
@end
