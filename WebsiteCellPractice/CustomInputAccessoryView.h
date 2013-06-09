//
//  CustomInputAccessoryView.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 4/19/13.
//  Copyright (c) 2013 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomInputAccessoryViewDelegate

//delegate methods to be implemented by the viewcontroller for which the inputaccessoryview appears
- (void)doneWasTappedInSender: (UITextField *)sender;
- (void)nextWasTappedInSender: (UITextField *)sender;
- (void)prevWasTappedInSender: (UITextField *)sender;
@end


@interface CustomInputAccessoryView : UIView

//Delegate
@property (nonatomic,weak) IBOutlet id <CustomInputAccessoryViewDelegate> delegate;

@property (nonatomic, strong) UIToolbar* keyboardToolbar;
@property (nonatomic, strong) UIBarButtonItem* btnDone;
@property (nonatomic, strong) UIBarButtonItem* btnNext;
@property (nonatomic, strong) UIBarButtonItem* btnPrev;
@property (nonatomic, strong) UITextField * myTextField;

- (id)initWithTextField:(UITextField*)textField;

-(IBAction)performDone:(id)sender;
-(IBAction)performNext:(id)sender;
-(IBAction)performPrev:(id)sender;

@end
