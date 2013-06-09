//
//  TableViewKeyboardDismisser.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/30.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import "TableViewKeyboardDismisser.h"

@implementation TableViewKeyboardDismisser{
    UITapGestureRecognizer *tapGR;
}

@synthesize tableView = _tableView;
-(id)initWithTableView:(UITableView *)tableView{
    if ((self = [super initWithFrame:CGRectMake(0, 0, 0, 0)])){
        _tableView = tableView;
        tapGR = [[UITapGestureRecognizer alloc] initWithTarget:_tableView action:@selector(endEditing:)];
    }
    return self;
}
-(void)didMoveToWindow{ // When the accessory view presents this delegate method will be called
    [super didMoveToWindow];
    if (self.window){ // If there is a window it is now visible, so one of it's textfields is first responder
        [_tableView addGestureRecognizer:tapGR];
    }
    else { // If there is no window the textfield is no longer first responder
        [_tableView removeGestureRecognizer:tapGR];
    }
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
