//
//  TableViewKeyboardDismisser.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/30.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewKeyboardDismisser : UIView
@property (nonatomic, assign) IBOutlet UITableView *tableView; // weak if iOS5 only
-(id)initWithTableView:(UITableView *)tableView;

@end
