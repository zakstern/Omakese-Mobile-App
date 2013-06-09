//
//  TestSubViewController.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/10.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "ViewController.h"
#import "CustomTableCell.h"
#import "TaxAndTotalCell.h"
#import "Bill.h"
#import "Receipt.h"
#import "ReceiptItem.h"
#import "SplitCheckViewCollection.h"

@interface TestSubViewController : ViewController 

- (IBAction)switchReceipt:(id)sender;

//UI Elements
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *displayTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


//Data
@property (strong, nonatomic) Bill *currentBill;
@property (strong, nonatomic) NSMutableArray *displayReceipts;
@property NSString *checkNumberString;
@property int initialReceiptNumber;



- (id)initWithBill:(Bill *)splitBill;
- (id)initWithBill:(Bill *)splitBill onCurrentReceipt:(int)currentReceiptNumber;


@end
