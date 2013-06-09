//
//  SplitCheckViewController.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/01.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItemDisplayCell,ReceiptItem,Receipt,Bill;

@interface SplitCheckViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

//Data

@property (strong, nonatomic) Bill *currentBill;
@property int currentItemNumber;
@property (strong,nonatomic) NSArray *indexPathArrays;
@property (strong, nonatomic) ReceiptItem *currentReceiptItem;

//UI Elements
@property (weak, nonatomic) IBOutlet UITableView *oneItemTableView;
@property (weak, nonatomic) IBOutlet ItemDisplayCell *itemCell;
@property (weak, nonatomic) IBOutlet UIButton *personOneButton;
@property (weak, nonatomic) IBOutlet UIButton *personTwoButton;
@property (weak, nonatomic) IBOutlet UIButton *personThreeButton;
@property (weak, nonatomic) IBOutlet UIButton *personFourButton;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;
@property (weak, nonatomic) IBOutlet UITextField *personOneTextField;
@property (weak, nonatomic) IBOutlet UITextField *personTwoTextField;
@property (weak, nonatomic) IBOutlet UITextField *personThreeTextField;
@property (weak, nonatomic) IBOutlet UITextField *personFourTextField;
@property (weak, nonatomic) IBOutlet UILabel *personOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *personTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *personThreeLabel;
@property (weak, nonatomic) IBOutlet UILabel *personFourLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionLabel;


- (IBAction)personOne:(id)sender;
- (IBAction)personTwo:(id)sender;
- (IBAction)personThree:(id)sender;
- (IBAction)personFour:(id)sender;

- (id)initWithReceipt:(Receipt *)currentReceipt andNumberInParty:(int)numberInParty;

@end
