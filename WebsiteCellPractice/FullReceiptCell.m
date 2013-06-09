//
//  FullReceiptCell.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/02/01.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "FullReceiptCell.h"

@implementation FullReceiptCell

@synthesize tableView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
       
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"FullReceiptCell" owner:self options:nil];
        if ([arrayOfViews count] < 1) {
            NSLog(@"returning nil");
            return nil;
        }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            NSLog(@"returning nil");
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
