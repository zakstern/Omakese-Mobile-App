//
//  Receipt.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/31.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@class ReceiptItem;

@interface Receipt : NSObject

@property double subTotalValue, taxPercentage, taxAmountValue, tipPercentage, tipAmountValue, grandTotalValue;
@property BOOL original;
@property (strong, nonatomic) NSMutableArray *allReceiptItemsArray,*remainingReceiptItemsArray,*allocatedReceiptItemsArray;

//custom initializer
- (id)initAsOriginal;

//getters
- (ReceiptItem *)getReceiptItem:(int)currentItemNumber;
- (ReceiptItem *)getRemainingReceiptItem:(int)currentItemNumber;
- (ReceiptItem *)getAssignedReceiptItem:(int)currentItemNumber;
- (int)getNumberOfItemsInReceipt;
- (int)getNumberOfRemainingItemsInReceipt;
- (int)getNumberOfAllocatedItemsInReceipt;

//adders
- (void)addReceiptItem:(ReceiptItem *)itemToBeAdded;
- (void)addReceiptItemToRemainingReceiptItems:(ReceiptItem *)itemToBeAdded;
- (void)addReceiptItemToAssignedReceiptItems:(ReceiptItem *)itemToBeAdded;

//removers
- (void)removeReceiptItemAtIndex:(int)index;
- (void)removeRemainingReceiptItemAtIndex:(int)index;
- (void)removeAssignedItemAtIndex:(int)index;
- (void)removeReceiptItem:(ReceiptItem *)receiptItemToBeRemoved;
- (void)removeRemainingReceiptItem:(ReceiptItem *)remainingReceiptItemToBeRemoved;
- (void)removeAssignedReceiptItem:(ReceiptItem *)assignedReceiptItemToBeRemoved;

- (ReceiptItem *)splitItem:(int)itemNumberToBeSplit among:(int)numberOfChecks;
//- (void)reorderArrayForMultipleQuantities;
- (void)clearData;
- (void)calculateTotals;
- (void)loadBlankReceiptItem;


- (void)replaceReceiptItemAtIndex:(int)index WithNewReceiptItem:(ReceiptItem *)newReceiptItem;
- (void)reduceQuantityToOne;
- (id)init;
- (BOOL)isEmpty;

//new
- (BOOL)assignedReceiptItemsExist;

//Parse Methods
- (PFObject *)getParseObjectFromReceipt:(Receipt *)receipt;

@end
