//
//  CustomTableCell.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/29.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField, *itemTextField, *priceTextField;
@end
