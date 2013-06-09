//
//  ReceiptItem.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/30.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ReceiptItem : NSObject

//Data
@property double priceValue, totalPriceValue, splitPriceValue;
@property int quantityValue, splitAmong;
@property (strong, nonatomic) NSString *itemName;
@property BOOL allocated;

//initializers
- (id)init;
- (id)initWith:(NSString *)item andPrice:(double)price andQuantity:(int)quantity;

//supporting methods
- (void)readyForAllocation;
- (void)calculateTotalPriceValue;
//- (ReceiptItem *)splitOriginalReceiptItemAmongSelectedNumber:(int)selectedNumber;

//Parse Methods
- (PFObject *)getParseObjectFromReceiptItem:(ReceiptItem *)receiptItem;


@end
