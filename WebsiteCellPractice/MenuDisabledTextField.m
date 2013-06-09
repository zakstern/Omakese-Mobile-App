//
//  MenuDisabledTextField.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 5/9/13.
//  Copyright (c) 2013 Zak Stern. All rights reserved.
//

#import "MenuDisabledTextField.h"

@implementation MenuDisabledTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if ([UIMenuController sharedMenuController]) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end
