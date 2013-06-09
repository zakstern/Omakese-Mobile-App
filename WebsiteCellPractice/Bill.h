//
//  Bill.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/08.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@class Receipt, ReceiptItem;

@interface Bill : NSObject

//data
@property (strong, nonatomic) NSMutableArray *splitReceiptsArray;
@property (strong, nonatomic) Receipt *originalReceipt;

//initializers
- (id)initWithReceipt:(Receipt *)currentReceipt andNumberInParty:(int)numberInParty;
- (id)initWithReceipt:(Receipt *)currentReceipt;

//methods
- (Receipt *)getReceipt:(int)currentReceiptNumber;
- (Receipt *)addBlankReceiptWithCurrent:(Receipt *)taxAndTipPercentages;
- (ReceiptItem *)getReceiptItemFrom:(int)currentReceiptNumber atItemIndex:(int)currentItemIndex;
- (int)getIndexFromReceiptNumber:(int)receiptNumber ofEquivalentReceiptItem:(ReceiptItem *)equivalentReceiptItem;
- (int)numberOfReceipts;
- (void)addNewSplitCheck;
- (void)loadReceiptItemsNotYetAllocatedInto:(NSMutableArray *)displayData;
- (void)addToSplitCheck:(int)checkNumber fromItem:(ReceiptItem *)receiptItem;
- (int)getNumberOfReceiptItemsFrom:(int)currentReceiptNumber;
- (void)calculateBill;
- (BOOL)isFullyAllocated;
- (BOOL)isEmpty;
- (BOOL)isEmptyAtReceiptNumber:(int)receiptNumber;
- (void)removeBlankReceipts;
- (void)removeReceiptAtIndex:(int)receiptNumber;

//new

- (BOOL)assignedReceiptItemsExist;
- (int)numberOfRemainingReceiptItems;
- (int)numberOfAssignedReceiptItems;

//Parse Methods

- (void)saveToParse;
- (void)updateInParse;

@end
