//
//  ReceiptItem.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/30.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import "ReceiptItem.h"
#import <Parse/Parse.h>

@implementation ReceiptItem
@synthesize quantityValue,priceValue,itemName,totalPriceValue,allocated,splitAmong,splitPriceValue;

- (id)init
{
    self = [super init];
    if (self) {
        self.quantityValue = 1;
        self.totalPriceValue = 0;
        self.allocated = NO;
        self.splitAmong = 1;
        self.splitPriceValue = self.totalPriceValue/self.splitAmong;
    }
    return self;
}

- (id)initWith:(NSString *)item andPrice:(double)price andQuantity:(int)quantity{
    self = [super init];
    if (self) {
        self.quantityValue = quantity;
        self.priceValue = price;
        self.itemName = item;
        self.allocated = NO;
        self.splitAmong = 1;
        self.splitPriceValue = self.totalPriceValue/self.splitAmong;
    }
    return self;
}

- (void)calculateTotalPriceValue{
    self.totalPriceValue = self.quantityValue*self.priceValue;
    self.splitPriceValue = self.totalPriceValue/self.splitAmong;
    
}

- (void)readyForAllocation{
    [self calculateTotalPriceValue];
    self.allocated = YES;
}

/*
- (ReceiptItem *)splitOriginalReceiptItemAmongSelectedNumber:(int)selectedNumber{
    double splitAmount = self.priceValue/selectedNumber;
    NSString *splitName = self.itemName;
    return [[ReceiptItem alloc] initWith:splitName andPrice:splitAmount andQuantity:1];
}
 */

//Parse Methods
- (PFObject *)getParseObjectFromReceiptItem:(ReceiptItem *)receiptItem{
    PFObject *item = [PFObject objectWithClassName:@"ReceiptItem"];
    [item setObject:[self itemName] forKey:@"itemName"];
    [item setObject:[NSNumber numberWithDouble:[self priceValue]] forKey:@"priceValue"];
    [item setObject:[NSNumber numberWithInt:[self splitAmong]] forKey:@"splitAmong"];
    [item setObject:[NSNumber numberWithInt:[self quantityValue]] forKey:@"quantityValue"];
    [item setObject:[NSNumber numberWithBool:[self allocated]] forKey:@"allocated"];
    [item setObject:[self itemName] forKey:@"itemName"];
    return item;
}

@end
