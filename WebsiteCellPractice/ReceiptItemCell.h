//
//  ReceiptItemCell.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/29.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import "CustomInputAccessoryView.h"
#import <UIKit/UIKit.h>
@class Bill,Receipt,ReceiptItem,FullCheckCollectionCell,ReceiptItemCell;
@protocol ReceiptItemCellDelegate

//delegate methods to be implemented by the parent view
- (ReceiptItem *)getReceiptItemForCell:(ReceiptItemCell *)sender;
- (NSIndexPath *)indexPathForReceiptItemCell:(ReceiptItemCell *)sender;
- (void)textFieldHasBeenEditedIn: (ReceiptItemCell *)receiptItemCellChanged;
- (void)textField:(UITextField *)textField beganEditingIn:(ReceiptItemCell *)receiptItemCellBeingEdited;
- (void)textField:(UITextField *)textField willEndEditingIn:(ReceiptItemCell *)receiptItemCellBeingEdited;
- (BOOL)isCellInOriginalCheck;

@end

@interface ReceiptItemCell : UITableViewCell <UITextFieldDelegate,CustomInputAccessoryViewDelegate>

//Delegate
@property (nonatomic,weak) IBOutlet id <ReceiptItemCellDelegate> delegate;

//UI Elements
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField, *itemTextField, *priceTextField;

//Data
@property (strong, nonatomic) Bill *currentBill;

//Methods
-(void)assignBill:(Bill *)billToBeAssigned;
-(void)setAsAnAllocatedReceiptItem;
-(void)setupKeyboards;
-(void)setUserInteractionForTextFields:(BOOL)canEdit;
-(void)setTextFieldDelegates;
-(void)clearData;
- (NSIndexPath *)indexPathOfTheCellAfterTheIndexPathOfTheCurrentlyBeingEditedCell: (NSIndexPath *)indexPathOfCurrentlyBeingEditedCell inReceiptItemTableview: (UITableView *)receiptItemTableView;
- (NSIndexPath *)indexPathOfTheCellPreviousToTheIndexPathOfTheCurrentlyBeingEditedCell: (NSIndexPath *)indexPathOfCurrentlyBeingEditedCell inReceiptItemTableview: (UITableView *)receiptItemTableView;
@end
