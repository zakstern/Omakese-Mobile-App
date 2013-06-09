//
//  TestReceiptViewController.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/02/03.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTableCell.h"
#import "TaxAndTotalCell.h"
#import "Bill.h"
#import "Receipt.h"
#import "ReceiptItem.h"
#import "SplitCheckViewCollection.h"
#import "FullReceiptCell.h"
#import "ChangeTipOrTax.h"

@interface TestReceiptViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>

////Data Elements////
@property (strong, nonatomic) Bill *currentBill;
@property (strong, nonatomic) NSMutableArray *displayReceipts;
@property (strong, nonatomic) NSIndexPath *indexPathForInitialReceiptNumber;

////UI Elements////
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *myCollectionViewFlowLayout;
@property (weak, nonatomic) CustomTableCell *customTableCell;
@property (nonatomic, retain) TaxAndTotalCell *taxAndTotalCell;

////Methods////
- (id)initWithBill:(Bill *)splitBill andShowInitialReceiptNumberAtIndexPath:(NSIndexPath *)initialReceiptIndexPath;

@end
