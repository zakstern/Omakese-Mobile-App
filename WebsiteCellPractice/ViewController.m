//
//  ViewController.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/29.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import "ViewController.h"
#import "CustomTableCell.h"
#import "TaxAndTotalCell.h"
#import "TableViewKeyboardDismisser.h"
#import "UIView+UIView_FirstResponder.h"
#import "ReceiptItem.h"
#import "Receipt.h"
#import "SplitCheckViewController.h"
#import "SplitCheckViewCollection.h"
#import "ChangeTipOrTax.h"
#import <Parse/Parse.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize myTableView,numberOfChecksTextField,customTableCell,taxAndTotalCell,currentReceipt;



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Split" style:UIBarButtonItemStylePlain target:self action:@selector(goToSplitCheckView:)]];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(clearReceipt:)]];
    currentReceipt = [[Receipt alloc] init];
    [currentReceipt loadBlankReceiptItem];
}

//reload when tax or tip may have been changed
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [myTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*Need to figure this out
//overriding the firstresponder method to account for unacceptable edits to UITextFields
- (BOOL)resignFirstResponder{
    NSLog(@"got in the method");
    BOOL shouldResign =  [super resignFirstResponder];
    if ([[self.view findFirstResponder] isKindOfClass:[UITextField class]] && [self.view findFirstResponder].tag == 1) {
        NSLog(@"got to first if");
        UITextField *temp = (UITextField *)[self.view findFirstResponder];
        if (temp.text.length == 0){
            NSLog(@"got to second if");
            temp.text = @"1";
        }
    }
    return shouldResign;
}
 */


//TABLEVIEW DELEGATE METHODS

//sets the number of sections in a table view 
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

//sets the number of rows in a section of the tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return [currentReceipt.receiptItemsArray count];
    } else {
        return 1;
    }
}

//reuses or creates cells and loads them in to rows
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        
        //setting up the cell for an item input
        static NSString *CellIdentifier = @"CellIdentifier";
        CustomTableCell *cell = (CustomTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"CustomTableCell" owner:self options:nil];
            cell = [self customTableCell];
            [self setCustomTableCell:nil];
        }
        else{
            //clear out the data on the cell that is going to be reused
            cell.itemTextField.text = nil;
            cell.quantityTextField.text =  @"1";
            cell.priceTextField.text = nil;
        }
        
        //setting up the keyboards for the text fields in the cell
        cell.priceTextField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.quantityTextField.keyboardType = UIKeyboardTypeNumberPad;
        
        //third-party class that resigns first responder when clicking elsewhere in the tableview
        cell.priceTextField.inputAccessoryView = [[TableViewKeyboardDismisser alloc] initWithTableView:tableView];
        cell.itemTextField.inputAccessoryView = [[TableViewKeyboardDismisser alloc] initWithTableView:tableView];
        cell.quantityTextField.inputAccessoryView = [[TableViewKeyboardDismisser alloc] initWithTableView:tableView];
        
        
        //tag the cell to be able to identify it later.
        cell.contentView.tag = [indexPath row];
        
        //load data into cells
        ReceiptItem *currentReceiptItem = (ReceiptItem *)[currentReceipt.receiptItemsArray objectAtIndex:[indexPath row]];
        cell.itemTextField.text = currentReceiptItem.itemName;
        cell.quantityTextField.text = [NSString stringWithFormat:@"%i",currentReceiptItem.quantityValue];
        if (currentReceiptItem.priceValue != 0) {
            cell.priceTextField.text = [NSString stringWithFormat:@"%.02f",currentReceiptItem.priceValue];
        }
        [self setFirstResponder];
        return cell;

    } else {
        //setting up the totals section/row
        static NSString *CellIdentifier = @"TaxAndTotalCellIdentifier";
        TaxAndTotalCell *cell = (TaxAndTotalCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"TaxAndTotalCell" owner:self options:nil];
            cell = [self taxAndTotalCell];
            [self setTaxAndTotalCell:nil];
        }
        
        //load data into total cells
        cell.subTotalTextField.text = [NSString stringWithFormat:@"%.02f",currentReceipt.subTotalValue];
        cell.taxTextField.text = [NSString stringWithFormat:@"%.02f",currentReceipt.taxAmountValue];
        cell.tipTextField.text = [NSString stringWithFormat:@"%.02f",currentReceipt.tipAmountValue];
        cell.totalTextField.text = [NSString stringWithFormat:@"%.02f",currentReceipt.grandTotalValue];
        
        //set action receivers for buttons within the cells and cell title
        [cell updateEditTax:self.currentReceipt.taxPercentage OrTipButton:self.currentReceipt.tipPercentage];
        [cell.editTaxOrTipButton addTarget:self action:@selector(editTaxOrTip) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
}

//specifies the height of the cells.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        return 44;
    }
    else{
        return 87;
    }
}

//sets rows to editable or not
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        return YES;
    }
    else {
        return NO;
    }
}

// Override to support editing the table view and deleting rows
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //what to do when the user swipes to delete
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //create an array with the indexpath of the row to be deleted
        NSArray *paths = [NSArray arrayWithObject:indexPath];
        
        //check to see if we are deleting the last row
        BOOL lastRow = NO;
        if (indexPath.row == currentReceipt.receiptItemsArray.count-1) {
            lastRow = YES;
        }
        
        //remove deleted item from the data source array
        [currentReceipt.receiptItemsArray removeObjectAtIndex:[indexPath row]];
        
        //call the method to delete the row at indexpath
        [[self myTableView] deleteRowsAtIndexPaths:paths
                                  withRowAnimation:UITableViewRowAnimationBottom];
        
        //update totals cell with subs and totals
        [currentReceipt calculateTotals];
        [[self myTableView] reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:1], nil] withRowAnimation:UITableViewRowAnimationNone];
        
        //see if we deleted the whole receipt or not (reload if so, retag if not)
        if (currentReceipt.receiptItemsArray.count == 0) {
            
            [currentReceipt loadBlankReceiptItem];
            [self.myTableView reloadData];
            
        }
        
        else {
            
            //add a new blank row if we deleted the last row
            if (lastRow == YES) {
                [self addRow];
            }
            
            //retag the remaining cells in the first section
            int tempRowInItemSection = 0;
            NSIndexPath *itemsCellPath =[[NSIndexPath alloc]init];
            CustomTableCell *cellToBeRetagged = [[CustomTableCell alloc]init];
            
            for (int i = 0; i<currentReceipt.receiptItemsArray.count; i++) {
                itemsCellPath = (NSIndexPath *)[NSIndexPath indexPathForRow:tempRowInItemSection inSection:0];
                cellToBeRetagged = (CustomTableCell *)[[self myTableView] cellForRowAtIndexPath:itemsCellPath];
                cellToBeRetagged.contentView.tag = [itemsCellPath row];
                tempRowInItemSection++;
            }
        }
    }
}

//TEXTFIELD DELEGATE METHODS

//dismisses the keyboard when the user clicks "return"
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//this method is called when a textfield resigns firstResponder.  We can update the ReceiptItem's properties based on user edits and update Receipt totals.
- (void)textFieldDidEndEditing:(UITextField *)textField{
    //find the cell and textfield that just ended editing
    int row = textField.superview.tag;
    int column = textField.tag;
    
    ReceiptItem *itemToBeUpdated = [[ReceiptItem alloc]init];
    itemToBeUpdated = [currentReceipt.receiptItemsArray objectAtIndex:row];
    
    //update the receiptItem
    switch (column) {
        case 1:
            //quantity text field
            itemToBeUpdated.quantityValue = [textField.text intValue];
            break;
        case 2:
            //itemName text field
            itemToBeUpdated.itemName = [textField text];
            break;
        case 3:
            //price text field
            itemToBeUpdated.priceValue = [textField.text doubleValue];
            break;
    }
    [currentReceipt.receiptItemsArray replaceObjectAtIndex:row withObject:itemToBeUpdated];
    //update totals cell with subs and totals
    [currentReceipt calculateTotals];
    [[self myTableView] reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:0 inSection:1], nil] withRowAnimation:UITableViewRowAnimationNone];
    
    //checking if the conditions for a new row are met and adding if so
    if(row == currentReceipt.receiptItemsArray.count-1 && itemToBeUpdated.priceValue != 0 && itemToBeUpdated.itemName.length != 0){
        [self addRow];
    }
    //else{
        //make next text field first responder
        /*if (![self textFieldIsBlank:textField]) {
            [[(CustomTableCell *)[myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]] viewWithTag:column+1] becomeFirstResponder];
        }
         */
    [self setFirstResponder];
    //}

    
}

//IBACTION METHODS

- (void)editTaxOrTip{
    //ChangeTipOrTax *changeTipOrTaxPage = [[ChangeTipOrTax alloc] initWithReceipt:self.currentReceipt];
    //[self presentViewController:changeTipOrTaxPage animated:YES completion:NULL];
}

- (void)goToSplitCheckView:(id)sender {
     if (currentReceipt.grandTotalValue != 0) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Number of Checks" message:@"Enter the number of checks:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
         alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
         numberOfChecksTextField = [alertView textFieldAtIndex:0];
         [numberOfChecksTextField setKeyboardType:UIKeyboardTypeNumberPad];
         [alertView show];
     } 
 }

- (void)clearReceipt:(id)sender {
    UIView *keyboardOwner = [self.view findFirstResponder];
    [keyboardOwner resignFirstResponder];
    [currentReceipt clearData];
    [myTableView reloadData];
}

//overriding UIAlertView method to only advance if numbers and cancel not hit
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex] && [numberOfChecksTextField.text intValue] > 0) {
        SplitCheckViewCollection *splitCheckPage = [[SplitCheckViewCollection alloc] initWithReceipt:self.currentReceipt andNumberInParty:[numberOfChecksTextField.text intValue]];
        splitCheckPage.title = @"Check Splitter";
        [self.navigationController pushViewController:splitCheckPage animated:YES];
    }
}

- (BOOL)textFieldIsBlank:(UITextField *)textField{
    if (textField.text.length == 0) {
        return YES;
    } else {
        return NO;
    }
}

- (void)addRow{
    //create an array with the indexpath of where we want to insert the row
    NSArray *paths = [NSArray arrayWithObject:
                      [NSIndexPath indexPathForRow:[currentReceipt.receiptItemsArray count] inSection:0]];
    
    [currentReceipt loadBlankReceiptItem];
    
    //call the method to insert the row at indexpath
    [[self myTableView] insertRowsAtIndexPaths:paths
                              withRowAnimation:UITableViewRowAnimationNone];
}

-(void)setFirstResponder{
    /*
    if (![(UITextField *)[(CustomTableCell *)[myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[currentReceipt.receiptItemsArray count]-1 inSection:0]] viewWithTag:2] hasText]) {
        [[(CustomTableCell *)[myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[currentReceipt.receiptItemsArray count]-1 inSection:0]] viewWithTag:2] becomeFirstResponder];
    } else {
        [[(CustomTableCell *)[myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[currentReceipt.receiptItemsArray count]-1 inSection:0]] viewWithTag:3] becomeFirstResponder];
    }
     */
}

@end
