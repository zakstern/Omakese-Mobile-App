//
//  ViewController.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/29.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomTableCell, TaxAndTotalCell, Receipt;

@interface ViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, retain) IBOutlet UITableView *myTableView;
@property (strong, retain) UITextField *numberOfChecksTextField;
@property (weak, nonatomic) IBOutlet CustomTableCell *customTableCell;
@property (nonatomic, retain) IBOutlet TaxAndTotalCell *taxAndTotalCell;
@property (strong, nonatomic) Receipt *currentReceipt;

- (void)goToSplitCheckView:(id)sender;
- (void)clearReceipt:(id)sender;


@end
