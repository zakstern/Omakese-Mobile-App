//
//  IntegratedViewController.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/29.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FullCheckCollectionCell.h"
#import "CustomInputAccessoryView.h"
@class Receipt, Bill, ReceiptItem;

@interface IntegratedViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,FullCheckCollectionCellDelegate,CustomInputAccessoryViewDelegate>

////UI Elements////
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *fullReceiptCollectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property (weak, nonatomic) IBOutlet UITextField *taxTextField;
@property (weak, nonatomic) IBOutlet UITextField *tipTextField;
@property (weak, nonatomic) IBOutlet UIView *taxAndTipView;


- (IBAction)dismissKeyboard:(id)sender;


////Data////
@property (strong, nonatomic) Bill *currentBill;
@property int quantityTracker;
@property NSNumberFormatter *doubleValueWithMaxTwoDecimalPlaces;
@property NSNumber *formattedTaxPercentage, *formattedTipPercentage;

////Helper Methods////
- (void)clearReceipt:(id)sender;
- (void)deleteSplitCheck:(id)sender;

////FullCheckCollectionCell Delegate Methods
- (void)editTaxOrTipWasSelectedbySender: (id)sender;
- (void)editTaxOrTipIsDoneEditingInSender: (id)sender;
- (void)remainingReceiptItem:(ReceiptItem *)remainingReceiptItem willBeSelectedInSender:(FullCheckCollectionCell *)sender;
- (void)remainingReceiptItem:(ReceiptItem *)remainingReceiptItem wasSelectedInSender:(FullCheckCollectionCell *)sender;
- (void)assignedReceiptItem:(ReceiptItem *)assignedReceiptItem wasSelectedInSender:(FullCheckCollectionCell *)sender;
- (void)remainingReceiptItem:(ReceiptItem *)remainingReceiptItem wasDeselectedInSender:(FullCheckCollectionCell *)sender;
- (void)assignedReceiptItem:(ReceiptItem *)assignedReceiptItem wasDeselectedInSender: (FullCheckCollectionCell *)sender;
- (void)assignedReceiptItem:(ReceiptItem *)assignedReceiptItem willBeDeletedInSender:(FullCheckCollectionCell *)sender;
- (BOOL)doneButtonIsShowing;
- (void)receiptItemWasChanged:(ReceiptItem *)receiptItemChanged inSender:(FullCheckCollectionCell *)sender;
- (void)receiptItemChanged:(ReceiptItem *)receiptItemChanged willBeEditedInSender:(FullCheckCollectionCell *)sender;
- (void)newReceiptItem:(ReceiptItem *)newReceiptItem wasAddedInSender:(FullCheckCollectionCell *)sender;

//CustomInputAccessoryViewDelegate Methods
- (void)doneWasTappedInSender: (UITextField *)sender;
- (void)nextWasTappedInSender: (UITextField *)sender;
- (void)prevWasTappedInSender: (UITextField *)sender;

@end
