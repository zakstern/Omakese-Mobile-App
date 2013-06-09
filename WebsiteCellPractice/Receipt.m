//
//  Receipt.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/31.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import "Receipt.h"
#import "ReceiptItem.h"
#import <Parse/Parse.h>

@implementation Receipt
@synthesize allReceiptItemsArray,remainingReceiptItemsArray,allocatedReceiptItemsArray,subTotalValue,taxAmountValue,taxPercentage,grandTotalValue,tipAmountValue,tipPercentage,original;

- (id)init
{
    self = [super init];
    if (self) {
        self.allReceiptItemsArray = [[NSMutableArray alloc] init];
        self.remainingReceiptItemsArray = [[NSMutableArray alloc] init];
        self.allocatedReceiptItemsArray = [[NSMutableArray alloc] init];
        self.taxPercentage = .115;
        self.tipPercentage = .15;
        self.original = NO;
        [self calculateTotals];
    }
    return self;
}

- (id)initAsOriginal
{
    self = [super init];
    if (self) {
        self.allReceiptItemsArray = [[NSMutableArray alloc] init];
        self.remainingReceiptItemsArray = [[NSMutableArray alloc] init];
        self.allocatedReceiptItemsArray = [[NSMutableArray alloc] init];
        self.taxPercentage = .115;
        self.tipPercentage = .15;
        self.original = YES;
        [self calculateTotals];
    }
    return self;
}

- (void)loadBlankReceiptItem{
    [self.allReceiptItemsArray addObject:[[ReceiptItem alloc] init]];
}

//adders
- (void)addReceiptItem:(ReceiptItem *)itemToBeAdded{
    [self.allReceiptItemsArray addObject:itemToBeAdded];
    if (self.original) {
        [self addReceiptItemToRemainingReceiptItems:itemToBeAdded];
    } else {
        [self addReceiptItemToAssignedReceiptItems:itemToBeAdded];
    }
}

- (void)addReceiptItemToRemainingReceiptItems:(ReceiptItem *)itemToBeAdded{
    [self.remainingReceiptItemsArray addObject:itemToBeAdded];
}
- (void)addReceiptItemToAssignedReceiptItems:(ReceiptItem *)itemToBeAdded{
    [self.allocatedReceiptItemsArray addObject:itemToBeAdded];
}

//getters
- (ReceiptItem *)getReceiptItem:(int)currentItemNumber{
    return (ReceiptItem *)[self.allReceiptItemsArray objectAtIndex:currentItemNumber];
}

- (ReceiptItem *)getRemainingReceiptItem:(int)currentItemNumber{
    return (ReceiptItem *)[self.remainingReceiptItemsArray objectAtIndex:currentItemNumber];
}

- (ReceiptItem *)getAssignedReceiptItem:(int)currentItemNumber{
    return (ReceiptItem *)[self.allocatedReceiptItemsArray objectAtIndex:currentItemNumber];
}

- (int)getNumberOfItemsInReceipt{
    return self.allReceiptItemsArray.count;
}
- (int)getNumberOfRemainingItemsInReceipt{
    return self.remainingReceiptItemsArray.count;
}
- (int)getNumberOfAllocatedItemsInReceipt{
    return self.allocatedReceiptItemsArray.count;
}

//removers

- (void)removeReceiptItemAtIndex:(int)index{
    [self.allReceiptItemsArray removeObjectAtIndex:index];
}

- (void)replaceReceiptItemAtIndex:(int)index WithNewReceiptItem:(ReceiptItem *)newReceiptItem{
    [self.allReceiptItemsArray replaceObjectAtIndex:index withObject:newReceiptItem];
    //may need to udpdate this
}

- (void)removeRemainingReceiptItemAtIndex:(int)index{
    [self.remainingReceiptItemsArray removeObjectAtIndex:index];
}
- (void)removeAssignedItemAtIndex:(int)index{
    [self.allocatedReceiptItemsArray removeObjectAtIndex:index];
}
- (void)removeReceiptItem:(ReceiptItem *)receiptItemToBeRemoved{
    [self.allReceiptItemsArray removeObject:receiptItemToBeRemoved];
}
- (void)removeRemainingReceiptItem:(ReceiptItem *)remainingReceiptItemToBeRemoved{
    [self.remainingReceiptItemsArray removeObject:remainingReceiptItemToBeRemoved];
}
- (void)removeAssignedReceiptItem:(ReceiptItem *)assignedReceiptItemToBeRemoved{
    [self.allocatedReceiptItemsArray removeObject:assignedReceiptItemToBeRemoved];
}

- (int)numberOfItemsInReceipt{
    return self.allReceiptItemsArray.count;
}

- (void)calculateTotals{
    [self calculateSubTotal];
    [self calculateTax];
    [self calculateTip];
    [self calculateGrandTotal];
}

- (void)calculateSubTotal{
    subTotalValue = 0;
    for(int i = 0; i<allReceiptItemsArray.count; i++){
        [[self getReceiptItem:i] calculateTotalPriceValue];
        if (self.original) {
            subTotalValue += [self getReceiptItem:i].totalPriceValue;
        } else {
            subTotalValue += [self getReceiptItem:i].splitPriceValue;
        }
    }
}

- (void)calculateTip{
    tipAmountValue = subTotalValue*tipPercentage;
}

- (void)calculateTax{
    taxAmountValue = subTotalValue*taxPercentage;
}

- (void)calculateGrandTotal{
    grandTotalValue = taxAmountValue+tipAmountValue+subTotalValue;
}

- (void)clearData{
    [allReceiptItemsArray removeAllObjects];
    [allReceiptItemsArray addObject:[[ReceiptItem alloc]init]];
    [self calculateTotals];
}

- (void)reduceQuantityToOne{
    ((ReceiptItem *)[self.allReceiptItemsArray objectAtIndex:self.allReceiptItemsArray.count-1]).quantityValue = 1;
}

/*
- (void)reorderArrayForMultipleQuantities{    
    for (int i = 0; i<receiptItemsArray.count; i++) {
        if ([self getReceiptItem:i].quantityValue > 1) {
            ReceiptItem *temp = [[ReceiptItem alloc] init];
            temp.quantityValue = [self getReceiptItem:i].quantityValue;
            temp.itemName = [self getReceiptItem:i].itemName;
            temp.priceValue = [self getReceiptItem:i].priceValue;
            [receiptItemsArray insertObject:temp atIndex:i+1];
            [self getReceiptItem:i].quantityValue = 1;
            [[self getReceiptItem:i] calculateTotalPriceValue];
            [self getReceiptItem:i+1].quantityValue--;
            [[self getReceiptItem:i+1] calculateTotalPriceValue];
        }
    }
}
*/

- (ReceiptItem *)splitItem:(int)itemNumberToBeSplit among:(int)numberOfChecks{
    double splitAmount = [self getReceiptItem:itemNumberToBeSplit].priceValue/numberOfChecks;
    NSString *splitName = [self getReceiptItem:itemNumberToBeSplit].itemName;
    return [[ReceiptItem alloc] initWith:splitName andPrice:splitAmount andQuantity:1];
}

- (BOOL)isEmpty{
    if (self.grandTotalValue == 0) {
        return YES;
    } else {
        return NO;
    }
}

//new
- (BOOL)assignedReceiptItemsExist{
    return self.allocatedReceiptItemsArray.count > 0;
}

//Parse Methods
- (PFObject *)getParseObjectFromReceipt:(Receipt *)receipt{
    PFObject *item = [PFObject objectWithClassName:@"Receipt"];
    [item setObject:[NSNumber numberWithDouble:[self taxPercentage]] forKey:@"taxPercentage"];
    [item setObject:[NSNumber numberWithDouble:[self tipPercentage]] forKey:@"tipPercentage"];
    [item setObject:[self getArrayWithParseObjectsFromArray:[self allReceiptItemsArray]] forKey:@"allReceiptItemsArray"];
    [item setObject:[self getArrayWithParseObjectsFromArray:[self allocatedReceiptItemsArray]] forKey:@"allocatedReceiptItemsArray"];
    [item setObject:[self getArrayWithParseObjectsFromArray:[self remainingReceiptItemsArray]] forKey:@"remainingReceiptItemsArray"];
    return item;
}

-(NSMutableArray *)getArrayWithParseObjectsFromArray:(NSMutableArray *)array{
    NSMutableArray *arrayWithParseObjects = [[NSMutableArray alloc] init];
    for (ReceiptItem *receiptItem in array) {
        [arrayWithParseObjects addObject:[receiptItem getParseObjectFromReceiptItem:receiptItem]];
    }
    return arrayWithParseObjects;
}

@end
