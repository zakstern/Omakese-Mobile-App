//
//  UIView+UIView_FirstResponder.m
//  Receiptly
//
//  Created by Zak Stern on 12/12/27.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import "UIView+UIView_FirstResponder.h"

@implementation UIView (UIView_FirstResponder)

- (UIView *)findFirstResponder
{
    if ([self isFirstResponder])
        return self;
    
    for (UIView * subView in self.subviews)
    {
        UIView * fr = [subView findFirstResponder];
        if (fr != nil)
            return fr;
    }
    
    return nil;
}
@end
