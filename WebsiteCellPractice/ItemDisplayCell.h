//
//  ItemDisplayCell.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/01.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ItemDisplayCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UITextField *itemNameDisplay;
@property (weak, nonatomic) IBOutlet UITextField *itemPriceDisplay;
@property (weak, nonatomic) IBOutlet UIButton *splitButton;
@end
