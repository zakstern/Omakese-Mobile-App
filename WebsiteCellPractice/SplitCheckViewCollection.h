//
//  SplitCheckViewCollection.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/28.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItemDisplayCell,ReceiptItem,Receipt,Bill;

@interface SplitCheckViewCollection : UIViewController <UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

////Data////

@property (strong, nonatomic) Bill *currentBill;
@property int currentItemNumber;
@property (strong,nonatomic) NSArray *indexPathArrays;
@property (strong, nonatomic) ReceiptItem *currentReceiptItem;
@property BOOL lastItem;
@property int quantityTracker;

////UI Elements////

@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
//@property (nonatomic, retain) IBOutlet SplitCheckCollectionCell *mySplitCheckCollectionCell;
@property (weak, nonatomic) IBOutlet ItemDisplayCell *itemCell;
@property (strong, nonatomic) UICollectionViewFlowLayout *myCollectionViewFlowLayout;

///Helper Methods////

- (id)initWithReceipt:(Receipt *)currentReceipt andNumberInParty:(int)numberInParty;
- (void)moveToNextItemOrEnd;
- (BOOL)isQuivering:(NSIndexPath *)indexPath;


@end
