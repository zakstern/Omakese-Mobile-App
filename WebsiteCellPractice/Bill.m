//
//  Bill.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/08.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "Bill.h"
#import "Receipt.h"
#import "ReceiptItem.h"
#import <Parse/Parse.h>

@implementation Bill

@synthesize splitReceiptsArray,originalReceipt;

- (id)initWithReceipt:(Receipt *)currentReceipt andNumberInParty:(int)numberInParty
{
    self = [super init];
    if (self) {
        self.originalReceipt = currentReceipt;
        self.splitReceiptsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i<numberInParty; i++) {
            [self.splitReceiptsArray addObject:[self addBlankReceiptWithCurrent:currentReceipt]];
        }
    }
    return self;
}

- (id)initWithReceipt:(Receipt *)currentReceipt
{
    self = [super init];
    if (self) {
        self.originalReceipt = currentReceipt;
        self.splitReceiptsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addNewSplitCheck{
    [self.splitReceiptsArray addObject:[self addBlankReceiptWithCurrent:self.originalReceipt]];
}


- (Receipt *)addBlankReceiptWithCurrent:(Receipt *)taxAndTipPercentages{
    Receipt *blankReceipt = [[Receipt alloc] init];
    blankReceipt.taxPercentage = taxAndTipPercentages.taxPercentage;
    blankReceipt.tipPercentage = taxAndTipPercentages.tipPercentage;
    return blankReceipt;
}

- (Receipt *)getReceipt:(int)currentReceiptNumber{
    return (Receipt *)[self.splitReceiptsArray objectAtIndex:currentReceiptNumber];
}

- (ReceiptItem *)getReceiptItemFrom:(int)currentReceiptNumber atItemIndex:(int)currentItemIndex{
    return [[self getReceipt:currentReceiptNumber] getReceiptItem:currentItemIndex];
}

- (int)getIndexFromReceiptNumber:(int)receiptNumber ofEquivalentReceiptItem:(ReceiptItem *)equivalentReceiptItem{
    Receipt *selectedReceipt = [self.splitReceiptsArray objectAtIndex:receiptNumber];
    return[selectedReceipt.allReceiptItemsArray indexOfObject:equivalentReceiptItem];
}

- (int)numberOfReceipts{
    return self.splitReceiptsArray.count;
}

- (void)loadReceiptItemsNotYetAllocatedInto:(NSMutableArray *)displayData{
    for (ReceiptItem *displayItem in self.originalReceipt.allReceiptItemsArray) {
        if (displayItem.allocated == NO) {
            //
        }
    }
}

- (int)getNumberOfReceiptItemsFrom:(int)currentReceiptNumber{
    return [self getReceipt:currentReceiptNumber].allReceiptItemsArray.count;
}

- (void)calculateBill{
    for (int i = 0; i<splitReceiptsArray.count; i++) {
        [[self getReceipt:i] calculateTotals];
    }
    [self.originalReceipt calculateTotals];
}

- (BOOL)isFullyAllocated{
    double splitTotal = 0.0;
    for (int i =0; i<[self numberOfReceipts]; i++) {
        splitTotal += [self getReceipt:i].grandTotalValue;
    }
    return self.originalReceipt.grandTotalValue == splitTotal;
}

- (BOOL)isEmpty{
    BOOL empty = YES;
    for (int i = 0; i<splitReceiptsArray.count; i++) {
        if ([self getReceipt:i].grandTotalValue != 0) {
            empty = NO;
        } 
    }
    return empty;
}

- (BOOL)isEmptyAtReceiptNumber:(int)receiptNumber{
    if([[self getReceipt:receiptNumber] isEmpty]){
        return YES;
    }
    else{
        return NO;
    }
}

- (void)removeBlankReceipts{
    for (int i = 0; i<splitReceiptsArray.count; i++) {
        if ([self getReceipt:i].grandTotalValue == 0) {
            [splitReceiptsArray removeObjectAtIndex:i];
            i--;
        }
    }
}

- (void)removeReceiptAtIndex:(int)receiptNumber{
    [self.splitReceiptsArray removeObjectAtIndex:receiptNumber];
}

- (void)addToSplitCheck:(int)checkNumber fromItem:(ReceiptItem *)receiptItem{
    [[self getReceipt:checkNumber] addReceiptItem:receiptItem];
    [[self getReceipt:checkNumber] reduceQuantityToOne];
}

//new

- (BOOL)assignedReceiptItemsExist{
    return [self.originalReceipt assignedReceiptItemsExist];
}

- (int)numberOfRemainingReceiptItems{
    return self.originalReceipt.remainingReceiptItemsArray.count;
}

- (int)numberOfAssignedReceiptItems{
    return self.originalReceipt.allocatedReceiptItemsArray.count;
}

//Parse Methods
- (void)saveToParse{
    PFObject *bill = [PFObject objectWithClassName:@"Bill"];
    [bill setObject:[self.originalReceipt getParseObjectFromReceipt:self.originalReceipt] forKey:@"originalReceipt"];
    [bill setObject:[self getArrayWithParseObjectsFromArray:self.splitReceiptsArray] forKey:@"splitReceiptsArray"];
    [bill saveInBackground];
}

-(NSMutableArray *)getArrayWithParseObjectsFromArray:(NSMutableArray *)array{
    NSMutableArray *arrayWithParseObjects = [[NSMutableArray alloc] init];
    for (Receipt *receipt in array) {
        [arrayWithParseObjects addObject:[receipt getParseObjectFromReceipt:receipt]];
    }
    return arrayWithParseObjects;
}
- (void)updateInParse{
    
}

@end
