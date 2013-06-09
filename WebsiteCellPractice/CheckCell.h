//
//  CheckCell.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/28.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Receipt;
@interface CheckCell : UICollectionViewCell

////UI Elements////
@property (nonatomic, strong) UILabel *cellNameLabel;
@property (strong, nonatomic) NSString *lineOne, *lineTwo, *lineThree, *lineFour;
@property (nonatomic, strong) UIButton *deleteButton;

////State Info////
@property BOOL isQuivering;

////Methods////
- (void)startQuivering;
- (void)stopQuivering;
- (void)clearCellatIndexPathRow:(int)indexPathRow;
- (void)setInitialDisplayForAddACheck;
- (void)setInitialDisplayForSplitCheckCellAtIndexRow:(int)indexRow;
- (void)updateDisplay:(Receipt *)receiptToBeUpdated atIndexPathRow:(int)indexPathRow;
- (void)setCellToCyan;
- (void)setCellToWhite;
- (BOOL)isCellSetToCyan;
- (void)turnBorderRed;
- (void)turnBorderGray;

@end
