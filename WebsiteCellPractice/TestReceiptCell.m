//
//  TestReceiptCell.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/02/03.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "TestReceiptCell.h"

@implementation TestReceiptCell

@synthesize myTableView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"TestReceiptCell" owner:self options:nil];
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

-(void)prepareForReuse{
    [self.myTableView reloadData];
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
