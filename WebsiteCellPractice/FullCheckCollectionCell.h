//
//  FullCheckCollectionCell.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 2013/02/25.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddReceiptItemCell.h"
#import "ReceiptItemCell.h"
#import "CustomInputAccessoryView.h"

@class Bill,Receipt,ReceiptItem,ReceiptItemCell,TotalCell,FullCheckCollectionCell,AddReceiptItemCell;

@protocol FullCheckCollectionCellDelegate

//delegate methods to be implemented by the viewcontroller
- (void)editTaxOrTipWasSelectedbySender: (id)sender;
- (void)editTaxOrTipIsDoneEditingInSender: (id)sender;
- (void)remainingReceiptItem:(ReceiptItem *)remainingReceiptItem willBeSelectedInSender:(FullCheckCollectionCell *)sender;
- (void)remainingReceiptItem:(ReceiptItem *)remainingReceiptItem wasSelectedInSender:(FullCheckCollectionCell *)sender;
- (void)assignedReceiptItem:(ReceiptItem *)assignedReceiptItem wasSelectedInSender:(FullCheckCollectionCell *)sender;
- (void)remainingReceiptItem:(ReceiptItem *)remainingReceiptItem wasDeselectedInSender:(FullCheckCollectionCell *)sender;
- (void)assignedReceiptItem:(ReceiptItem *)assignedReceiptItem wasDeselectedInSender: (FullCheckCollectionCell *)sender;
- (void)assignedReceiptItem:(ReceiptItem *)assignedReceiptItem willBeDeletedInSender:(FullCheckCollectionCell *)sender;
- (BOOL)doneButtonIsShowing;
- (void)receiptItemChanged:(ReceiptItem *)receiptItemChanged willBeEditedInSender:(FullCheckCollectionCell *)sender;
- (void)receiptItemWasChanged:(ReceiptItem *)receiptItemChanged inSender:(FullCheckCollectionCell *)sender;
- (void)newReceiptItem:(ReceiptItem *)newReceiptItem wasAddedInSender:(FullCheckCollectionCell *)sender;

@end

@interface FullCheckCollectionCell : UICollectionViewCell <UITableViewDataSource,UITableViewDelegate,AddReceiptItemCellDelegate,ReceiptItemCellDelegate,CustomInputAccessoryViewDelegate>

//Delegate
@property (nonatomic,weak) IBOutlet id <FullCheckCollectionCellDelegate> delegate;

//UI Elements
@property (weak, nonatomic) IBOutlet UITableView *receiptItemsTableView;
@property (weak, nonatomic) IBOutlet UITableView *totalsTableView;
@property (weak, nonatomic) IBOutlet ReceiptItemCell *receiptItemCell;
@property (nonatomic, retain) IBOutlet TotalCell *totalCell;
@property (weak, nonatomic) IBOutlet AddReceiptItemCell *addReceiptItemCell;

//Data
@property (strong, nonatomic) Bill *currentBill;
@property (strong, nonatomic) NSMutableArray *receiptItemsToDeleteIndexPaths, *receiptItemsToAddIndexPaths;
@property (strong, nonatomic) NSMutableIndexSet *remainingReceiptItemsArrayIndexesToBeDeleted;
@property BOOL isInEditingMode;

//Methods
- (void)createWithBill:(Bill *) billToLoad;
- (void)setDisplayForAllocatedReceiptItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)reloadTables;
- (void)editTaxOrTip;
- (void)moveItemsDown;
- (void)moveItemUp:(ReceiptItem *) receiptItemToBeMovedUp;
- (BOOL)assignedItemIsSelected;
- (BOOL)remainingItemIsSelected;
- (BOOL)multipleRemainingItemsAreSelected;

//editing
- (void)changeEditingModeTo:(BOOL)isEditing;

//AddReceiptItemCellDelegate Methods
- (void)tapToAddAnItemWasTapped:(AddReceiptItemCell *)sender;

//ReceiptItemCellDelegate Methods
- (ReceiptItem *)getReceiptItemForCell:(ReceiptItemCell *)sender;
- (void)textFieldHasBeenEditedIn: (ReceiptItemCell *)sender;
- (void)textField:(UITextField *)textField beganEditingIn:(ReceiptItemCell *)receiptItemCellBeingEdited;

//CustomInputAccessoryViewDelegate Methods
- (void)doneWasTappedInSender: (UITextField *)sender;
- (void)nextWasTappedInSender: (UITextField *)sender;
- (void)prevWasTappedInSender: (UITextField *)sender;
@end
