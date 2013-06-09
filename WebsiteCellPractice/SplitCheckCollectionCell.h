//
//  SplitCheckCollectionCell.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/28.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SplitCheckCollectionCell : UICollectionViewCell

////UI Elements////
@property (weak, nonatomic) IBOutlet UIButton *totalsDisplayButton;
@property (weak, nonatomic) IBOutlet UILabel *cellName;

////State Info////
@property BOOL isQuivering;

////Action Methods////
- (void)startQuivering;
- (void)stopQuivering;

@end
