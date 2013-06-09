//
//  SplitCheckViewController.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/01.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "SplitCheckViewController.h"
#import "ItemDisplayCell.h"
#import "Receipt.h"
#import "ReceiptItem.h"
#import "Bill.h"
#import "TestSubViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SplitCheckViewController ()

@end

@implementation SplitCheckViewController
@synthesize oneItemTableView,itemCell,personFourButton,personOneButton,personThreeButton,personTwoButton,currentBill,currentItemNumber,indexPathArrays,doneLabel,personFourTextField,personOneTextField,personThreeTextField,personTwoTextField,personFourLabel,personOneLabel,personThreeLabel,personTwoLabel,instructionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithReceipt:(Receipt *)currentReceipt andNumberInParty:(int)numberInParty
{
    self = [super initWithNibName:@"SplitCheckViewController" bundle:nil];
    if (self) {
        currentBill = [[Bill alloc] initWithReceipt:currentReceipt andNumberInParty:numberInParty];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Review" style:UIBarButtonItemStylePlain target:self action:@selector(reviewChecks:)]];
    [self setButtonVisibility];
    currentItemNumber = 0;
    //reorder array so that items with more than one qty can be allocated seperately
    [currentBill.originalReceipt reorderArrayForMultipleQuantities];
    
    indexPathArrays = [NSArray arrayWithObject:
                  [NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//sets the number of rows in a section of the tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

//sets section header
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Current Item";
}

//reuses or creates cells and loads them in to rows
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ItemCellIdentifier";
    ItemDisplayCell *cell = (ItemDisplayCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"ItemDisplayCell" owner:self options:nil];
        cell = [self itemCell];
        [self setItemCell:nil];
    }
    //CLEAN THIS (USE GET RECEIPTITEM)
    ReceiptItem *currentReceiptItem = (ReceiptItem *)[[[self.currentBill originalReceipt] receiptItemsArray] objectAtIndex:currentItemNumber];
    cell.itemNameDisplay.text = currentReceiptItem.itemName;
    cell.itemPriceDisplay.text = [NSString stringWithFormat:@"%.02f",currentReceiptItem.priceValue];
    
    //set action receivers for buttons within the cells
    [cell.splitButton addTarget:self action:@selector(splitBetweenParties) forControlEvents:UIControlEventTouchUpInside];
    [cell.doneButton addTarget:self action:@selector(endSplitting) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}


//USER ACTION METHODS

- (IBAction)personOne:(id)sender {
    if (![self isCurrentlySplitting] && [self addTo:personOneButton]) {
        [self addToSplitCheck:0];
        [self updateTextFieldTotals];
    }
    else if ([self isCurrentlySplitting]){
        personOneButton.selected = ![personOneButton isSelected];
    }
}

- (IBAction)personTwo:(id)sender {
    if (![self isCurrentlySplitting] && [self addTo:personTwoButton]) {
        [self addToSplitCheck:1];
        [self updateTextFieldTotals];
    } else if ([self isCurrentlySplitting]){
        personTwoButton.selected = ![personTwoButton isSelected];
    }
}

- (IBAction)personThree:(id)sender {
    if (![self isCurrentlySplitting] && [self addTo:personThreeButton]) {
        [self addToSplitCheck:2];
        [self updateTextFieldTotals];
    }else if ([self isCurrentlySplitting]){
        personThreeButton.selected = ![personThreeButton isSelected];
    }
}

- (IBAction)personFour:(id)sender {
    if (![self isCurrentlySplitting] && [self addTo:personFourButton]) {
        [self addToSplitCheck:3];
        [self updateTextFieldTotals];
    }else if ([self isCurrentlySplitting]){
        personFourButton.selected = ![personFourButton isSelected];
    }
}

- (void)reviewChecks:(id)sender{
    if (![currentBill isEmpty]) {
        TestSubViewController *test = [[TestSubViewController alloc] initWithBill:currentBill];
        test.title = @"Review";
        [self.navigationController pushViewController:test animated:YES];
    }
}

- (void)splitBetweenParties{
    instructionLabel.text = @"Tap to deselect any people.";
    ItemDisplayCell *temp = (ItemDisplayCell *)[oneItemTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    temp.splitButton.hidden = YES;
    temp.doneButton.hidden = NO;
    temp.doneButton.highlighted = YES;
    [self selectButtons];
}

- (void)endSplitting{
    
    //Change cell appearance
    ItemDisplayCell *temp = (ItemDisplayCell *)[oneItemTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    temp.splitButton.hidden = NO;
    temp.doneButton.hidden = YES;
    
    //determine the number of selected buttons and which were selected
    int numberOfSelectedButtons = 0;
    NSMutableArray *selectedButtons = [[NSMutableArray alloc] init];

    for (UIView *subView in self.view.subviews)
    {
        if ([subView isKindOfClass:[UIButton class]] && [(UIButton *)subView isSelected]){
            NSLog(@"got in loop");
            numberOfSelectedButtons++;
            [selectedButtons addObject:[NSNumber numberWithInt:subView.tag]];
        }
    }
    
    //add the split items to the appropriate receipts
    for (int i = 0; i<numberOfSelectedButtons; i++) {
        [[currentBill getReceipt:[[selectedButtons objectAtIndex:i] intValue]] addReceiptItem:[currentBill.originalReceipt splitItem:currentItemNumber among:numberOfSelectedButtons]];
    }
    
    //update totals and view after splits
    if (numberOfSelectedButtons > 0) {
        [currentBill calculateBill];
        [self moveToNextItemOrEnd];
    }
    for (UIView *subView in self.view.subviews)
    {
        if ([subView isKindOfClass:[UIButton class]] && [(UIButton *)subView isSelected]){
            ((UIButton *)subView).selected = NO;
        }
    }
    [self updateTextFieldTotals];
    instructionLabel.text = @"Tap the person whose item it is!";
}


//HELPER METHODS

- (BOOL)addTo:(UIButton *)personButton {
    if ([personButton isHidden] || currentItemNumber == [currentBill.originalReceipt numberOfItemsInReceipt]-1) {
        return NO;
    }
    else{
       return YES; 
    }
}

/*
- (void)setButtonVisibility{
    switch ([currentBill numberOfChecks]) {
     case 1:
         [personTwoButton setHidden:YES];
         [personThreeButton setHidden:YES];
         [personFourButton setHidden:YES];
         [personTwoLabel setHidden:YES];
         [personThreeLabel setHidden:YES];
         [personFourLabel setHidden:YES];
         break;
     case 2:
         [personThreeButton setHidden:YES];
         [personFourButton setHidden:YES];
         [personThreeLabel setHidden:YES];
         [personFourLabel setHidden:YES];
         break;
     case 3:
         [personThreeButton setHidden:NO];
         [personFourButton setHidden:YES];
         [personFourLabel setHidden:YES];
         break;
     case 4:
         [personThreeButton setHidden:NO];
         [personFourButton setHidden:NO];
         break;
    }
 }
 */

- (void)selectButtons{
    for (UIView *subView in self.view.subviews)
    {
        if ([subView isKindOfClass:[UIButton class]] && ![subView isHidden]){
            ((UIButton *)subView).selected = YES;
            CALayer *layer = [((UIButton *)subView) layer];
            [layer setMasksToBounds:YES];
            [layer setCornerRadius:10.0];
            [layer setBorderWidth:1.0];
            [layer setBorderColor:[[UIColor grayColor] CGColor]];
            ((UIButton *)subView).clipsToBounds = YES;
        }
    }
}

- (BOOL)isCurrentlySplitting{
    ItemDisplayCell *temp = (ItemDisplayCell *)[oneItemTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (temp.splitButton.hidden == YES) {
        return YES;
    } else {
        return NO;
    }
}

- (void)removePersonButtonActions{
    [self.personOneButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [self.personTwoButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [self.personThreeButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    [self.personFourButton removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
}

- (void)addToSplitCheck:(int)checkNumber {
    [currentBill addToSplitCheck:checkNumber fromItem:currentItemNumber];
    [currentBill calculateBill];
    [self moveToNextItemOrEnd];
}

- (void)moveToNextItemOrEnd{
    currentItemNumber++;
    if([currentBill.originalReceipt getReceiptItem:currentItemNumber].totalPriceValue == 0){
        [oneItemTableView setHidden:YES];
        [doneLabel setHidden:NO];
    }
    else{
        [oneItemTableView reloadRowsAtIndexPaths:indexPathArrays withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)updateTextFieldTotals{    
    for (UIView *subView in self.view.subviews)
    {
        if ([subView isKindOfClass:[UITextField class]] && ((UITextField *)subView).tag <[currentBill numberOfChecks]){
                ((UITextField *)subView).text = [NSString stringWithFormat:@"%.02f",[currentBill getReceipt:((UITextField *)subView).tag].grandTotalValue];
        }
    }
}

@end
