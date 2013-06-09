//
//  ReceiptItemCell.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/29.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import "ReceiptItemCell.h"
#import "Bill.h"
#import "Receipt.h"
#import "ReceiptItem.h"
#import "FullCheckCollectionCell.h"
#import "AllocatedCheckCollectionCell.h"
#import "UIView+UIView_FirstResponder.h"
#import "CustomInputAccessoryView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ReceiptItemCell
@synthesize itemTextField,quantityTextField,priceTextField,currentBill,delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setupKeyboards{
    //setting up the keyboards for the text fields in the cell
    self.priceTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.quantityTextField.keyboardType = UIKeyboardTypeNumberPad;
}

-(void)setTextFieldDelegates{
    self.itemTextField.delegate = self;
    self.quantityTextField.delegate = self;
    self.priceTextField.delegate = self;
}

-(void)clearData{
    //clear cell
    self.itemTextField.text = nil;
    self.quantityTextField.text =  @"1";
    self.priceTextField.text = nil;
    self.accessoryType = UITableViewCellAccessoryNone;
}

-(void)assignBill:(Bill *)billToBeAssigned{
    self.currentBill = billToBeAssigned;
}

-(void)setAsAnAllocatedReceiptItem{
    [self setAccessoryType:UITableViewCellAccessoryNone];
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0];
}

////TEXTFIELD DELEGATE METHODS////

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//called when the textField becomes first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CustomInputAccessoryView *myInputAccessoryView=[[CustomInputAccessoryView alloc]initWithTextField:textField];
    myInputAccessoryView.delegate = self;
    [textField setInputAccessoryView:myInputAccessoryView];
    [self.delegate textField:textField beganEditingIn:self];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.delegate textField:textField willEndEditingIn:self];
    return YES;
    
}

//this method is called when a textfield resigns firstResponder.  We can update the ReceiptItem's properties based on user edits and update Receipt totals.
- (void)textFieldDidEndEditing:(UITextField *)textField{
    //find the cell and textfield that just ended editing
    ReceiptItem *receiptItemBeingChanged = [self.delegate getReceiptItemForCell:self];
    int column = textField.tag;

    //update the receiptItem
    switch (column) {
        case 1:
            //quantity text field
            receiptItemBeingChanged.quantityValue = [textField.text intValue];
            break;
        case 2:
            //itemName text field
            receiptItemBeingChanged.itemName = [textField text];
            break;
        case 3:
            //price text field
            receiptItemBeingChanged.priceValue = [textField.text doubleValue];
            break;
    }    
    [self.currentBill calculateBill]; //update bill totals
    //[self.delegate textFieldHasBeenEditedIn:receiptItemBeingChanged]; //alert delegate to reload collectionviews
    /*
    if ([textField isEqual:self.itemTextField] && receiptItemBeingChanged.totalPriceValue == 0) {
        [self.priceTextField becomeFirstResponder];
    }
     */
}

-(void)setUserInteractionForTextFields:(BOOL)canEdit{
    [self.quantityTextField setUserInteractionEnabled:canEdit];
    [self.priceTextField setUserInteractionEnabled:canEdit];
    [self.itemTextField setUserInteractionEnabled:canEdit];
}

//CustomInputAccessoryViewDelegate Methods
- (void)doneWasTappedInSender: (UITextField *)sender{
    [sender resignFirstResponder];
    ReceiptItem *receiptItemBeingChanged = [self.delegate getReceiptItemForCell:self];
    [self.delegate textFieldHasBeenEditedIn:receiptItemBeingChanged]; //alert delegate to reload collectionviews
}

- (void)nextWasTappedInSender: (UITextField *)sender{
    int column = sender.tag;
    NSIndexPath *indexPathOfCurrentCell = [delegate indexPathForReceiptItemCell:self];
    NSIndexPath *indexPathOfNextCell;
    switch (column) {
        case 1: //editing a qty textfield
            [self.itemTextField becomeFirstResponder];
            break;
        case 2: //editing an item name textfield
            [self.priceTextField becomeFirstResponder];
            break;
        case 3: //editing a price textfield
            indexPathOfNextCell = [self indexPathOfTheCellAfterTheIndexPathOfTheCurrentlyBeingEditedCell:indexPathOfCurrentCell inReceiptItemTableview:(UITableView *)sender.superview.superview.superview];
            [((ReceiptItemCell *)[(UITableView *)sender.superview.superview.superview cellForRowAtIndexPath:indexPathOfNextCell]).quantityTextField becomeFirstResponder];
            break;
    }
}
- (void)prevWasTappedInSender: (UITextField *)sender{
    int column = sender.tag;
    NSIndexPath *indexPathOfCurrentCell = [delegate indexPathForReceiptItemCell:self];
    NSIndexPath *indexPathOfPrevCell;
    switch (column) {
        case 1: //editing a qty textfield
            indexPathOfPrevCell = [self indexPathOfTheCellPreviousToTheIndexPathOfTheCurrentlyBeingEditedCell:indexPathOfCurrentCell inReceiptItemTableview:(UITableView *)sender.superview.superview.superview];
            [((ReceiptItemCell *)[(UITableView *)sender.superview.superview.superview cellForRowAtIndexPath:indexPathOfPrevCell]).priceTextField becomeFirstResponder];
            break;
        case 2: //editing an item name textfield
            [self.quantityTextField becomeFirstResponder];
            break;
        case 3: //editing a price textfield
            [self.itemTextField becomeFirstResponder];
            break;
    }
}

- (NSIndexPath *)indexPathOfTheCellAfterTheIndexPathOfTheCurrentlyBeingEditedCell: (NSIndexPath *)indexPathOfCurrentlyBeingEditedCell inReceiptItemTableview: (UITableView *)receiptItemTableView{
    NSIndexPath *nextIndexPath;
    if (![self.delegate isCellInOriginalCheck]){//allocated check
        Receipt *allocatedReceiptBeingEdited = [(AllocatedCheckCollectionCell *)receiptItemTableView.superview.superview getReceiptOfSelf];
        if (indexPathOfCurrentlyBeingEditedCell.row != [allocatedReceiptBeingEdited getNumberOfItemsInReceipt]-1) { //not the last item
            nextIndexPath = [NSIndexPath indexPathForRow:indexPathOfCurrentlyBeingEditedCell.row+1 inSection:0];
        } else {//last one
            nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        }
    }
    else{
        if (indexPathOfCurrentlyBeingEditedCell.section == 0 && indexPathOfCurrentlyBeingEditedCell.row == [self.currentBill.originalReceipt remainingReceiptItemsArray].count-1) {//last item in first section
            if ([self.currentBill.originalReceipt allocatedReceiptItemsArray].count > 0) {//there is a second section
                nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            } else {//no second section
                nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            }
        }
        else if (indexPathOfCurrentlyBeingEditedCell.section == 1 && indexPathOfCurrentlyBeingEditedCell.row == [self.currentBill.originalReceipt allocatedReceiptItemsArray].count-1){//last item in second section
            if ([self.currentBill.originalReceipt remainingReceiptItemsArray].count == 0) {//no first section
                nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
            } else { //there is a first section
                nextIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            }
        }
        else{//not last item
            nextIndexPath = [NSIndexPath indexPathForRow:indexPathOfCurrentlyBeingEditedCell.row+1 inSection:indexPathOfCurrentlyBeingEditedCell.section];
        }
    }
    return nextIndexPath;
}

- (NSIndexPath *)indexPathOfTheCellPreviousToTheIndexPathOfTheCurrentlyBeingEditedCell: (NSIndexPath *)indexPathOfCurrentlyBeingEditedCell inReceiptItemTableview: (UITableView *)receiptItemTableView{
    NSIndexPath *prevIndexPath;
    if (![self.delegate isCellInOriginalCheck]){//allocated check
        Receipt *allocatedReceiptBeingEdited = [(AllocatedCheckCollectionCell *)receiptItemTableView.superview.superview getReceiptOfSelf];
        if (indexPathOfCurrentlyBeingEditedCell.row != 0) { //not the first item
            prevIndexPath = [NSIndexPath indexPathForRow:indexPathOfCurrentlyBeingEditedCell.row-1 inSection:0];
        } else {//first one
            prevIndexPath = [NSIndexPath indexPathForRow:[allocatedReceiptBeingEdited getNumberOfItemsInReceipt]-1 inSection:0];
        }
    }
    else{
        if (indexPathOfCurrentlyBeingEditedCell.section == 0 && indexPathOfCurrentlyBeingEditedCell.row == 0) {//first item in first section
            if ([self.currentBill.originalReceipt allocatedReceiptItemsArray].count > 0) {//there is a second section
                prevIndexPath = [NSIndexPath indexPathForRow:[self.currentBill.originalReceipt getNumberOfAllocatedItemsInReceipt]-1 inSection:1];
            } else {//no second section
                prevIndexPath = [NSIndexPath indexPathForRow:[self.currentBill.originalReceipt getNumberOfRemainingItemsInReceipt]-1 inSection:0];
            }
        }
        else if (indexPathOfCurrentlyBeingEditedCell.section == 1 && indexPathOfCurrentlyBeingEditedCell.row == 0){//first item in second section
            if ([self.currentBill.originalReceipt remainingReceiptItemsArray].count == 0) {//no first section
                prevIndexPath = [NSIndexPath indexPathForRow:[self.currentBill.originalReceipt getNumberOfAllocatedItemsInReceipt]-1 inSection:1];
            } else { //there is a first section
                prevIndexPath = [NSIndexPath indexPathForRow:[self.currentBill.originalReceipt getNumberOfRemainingItemsInReceipt]-1 inSection:0];
            }
        }
        else{//not last item
            prevIndexPath = [NSIndexPath indexPathForRow:indexPathOfCurrentlyBeingEditedCell.row-1 inSection:indexPathOfCurrentlyBeingEditedCell.section];
        }
    }
    return prevIndexPath;
}
@end
