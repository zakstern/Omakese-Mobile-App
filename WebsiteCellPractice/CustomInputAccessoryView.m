//
//  CustomInputAccessoryView.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 4/19/13.
//  Copyright (c) 2013 Zak Stern. All rights reserved.
//

#import "CustomInputAccessoryView.h"

@implementation CustomInputAccessoryView

@synthesize keyboardToolbar,btnPrev,btnNext,btnDone,myTextField,delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithTextField:(UITextField*)textField
{
    self = [super initWithFrame:CGRectMake(0, 250, 320, 40)];
    if (self) {
        
        self.myTextField=textField;
        self.keyboardToolbar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
        self.btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(performDone:)];
        self.btnNext = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleBordered target:self action:@selector(performNext:)];
        self.btnPrev = [[UIBarButtonItem alloc] initWithTitle:@"Prev" style:UIBarButtonItemStyleBordered target:self action:@selector(performPrev:)];
        
        self.keyboardToolbar.barStyle = UIBarStyleDefault;
        //self.keyboardToolbar.alpha = 0.7;
        UIBarButtonItem* flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        [self.keyboardToolbar setItems:[NSArray arrayWithObjects:btnPrev,btnNext,flexSpace,btnDone,Nil] animated:NO];
        [self addSubview:self.keyboardToolbar];
    }
    return self;
}

-(IBAction)performDone:(id)sender{
    [self.delegate doneWasTappedInSender:self.myTextField];
}

-(IBAction)performNext:(id)sender{
    [self.delegate nextWasTappedInSender:self.myTextField];
}
-(IBAction)performPrev:(id)sender{
    [self.delegate prevWasTappedInSender:self.myTextField];
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
