//
//  AddReceiptItemCell.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 3/25/13.
//  Copyright (c) 2013 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AddReceiptItemCell;

@protocol AddReceiptItemCellDelegate
//delegate methods to be implemented by the tableview
- (void)tapToAddAnItemWasTapped:(AddReceiptItemCell *)sender;
@end

@interface AddReceiptItemCell : UITableViewCell

//Delegate
@property (nonatomic,weak) IBOutlet id <AddReceiptItemCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *addAnItemLabel;



- (void)setDisplay;

@end
