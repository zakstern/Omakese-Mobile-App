//
//  AllocatedCheckCollectionCell.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 4/1/13.
//  Copyright (c) 2013 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddReceiptItemCell.h"
#import "ReceiptItemCell.h"
#import "FullCheckCollectionCell.h"
#import "CustomInputAccessoryView.h"

@class Bill,Receipt,ReceiptItem,ReceiptItemCell,TotalCell,FullCheckCollectionCell,AddReceiptItemCell;

@interface AllocatedCheckCollectionCell : FullCheckCollectionCell <UITableViewDataSource,UITableViewDelegate,AddReceiptItemCellDelegate,ReceiptItemCellDelegate,CustomInputAccessoryViewDelegate>

////UI Elements
@property (weak, nonatomic) IBOutlet UITableView *receiptItemsTableView;
@property (weak, nonatomic) IBOutlet UITableView *totalsTableView;

//Data
@property int receiptNumber;


//Methods
- (Receipt *)getReceiptOfSelf;
- (void)reloadTables;
- (void)createWithBill:(Bill *) billToLoad forReceiptNumber:(int)receiptNumber;

//ReceiptItemCellDelegate Methods
- (ReceiptItem *)getReceiptItemForCell:(ReceiptItemCell *)sender;
- (NSIndexPath *)indexPathForReceiptItemCell:(ReceiptItemCell *)sender;
- (void)textFieldHasBeenEditedIn: (ReceiptItemCell *)receiptItemCellChanged;
- (void)textField:(UITextField *)textField beganEditingIn:(ReceiptItemCell *)receiptItemCellBeingEdited;
- (void)textField:(UITextField *)textField willEndEditingIn:(ReceiptItemCell *)receiptItemCellBeingEdited;

//CustomInputAccessoryViewDelegate Methods
- (void)doneWasTappedInSender: (UITextField *)sender;
- (void)nextWasTappedInSender: (UITextField *)sender;
- (void)prevWasTappedInSender: (UITextField *)sender;

@end
