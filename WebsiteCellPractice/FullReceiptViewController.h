//
//  FullReceiptViewController.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/02/01.
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

@interface FullReceiptViewController : UICollectionViewController <UITableViewDataSource,UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *myCollectionViewFlowLayout;
@property (weak, nonatomic) CustomTableCell *customTableCell;
@property (nonatomic, retain) TaxAndTotalCell *taxAndTotalCell;

//Data
@property (strong, nonatomic) Bill *currentBill;
@property (strong, nonatomic) NSMutableArray *displayReceipts;
@property NSString *checkNumberString;
@property int initialReceiptNumber;

//Custom Initializers
- (id)initWithBill:(Bill *)splitBill;
//- (id)initWithBill:(Bill *)splitBill onCurrentReceipt:(int)currentReceiptNumber;

@end
