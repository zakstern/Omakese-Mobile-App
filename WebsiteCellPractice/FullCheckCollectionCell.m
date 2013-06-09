//
//  FullCheckCollectionCell.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 2013/02/25.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "FullCheckCollectionCell.h"
#import "Bill.h"
#import "Receipt.h"
#import "ReceiptItem.h"
#import "TotalCell.h"
#import "ReceiptItemCell.h"
#import "AddReceiptItemCell.h"
#import "TableViewKeyboardDismisser.h"
#import "UIView+UIView_FirstResponder.h"
#import "ChangeTipOrTax.h"
#import "IntegratedViewController.h"
#import "CustomInputAccessoryView.h"
#import <QuartzCore/QuartzCore.h>

@implementation FullCheckCollectionCell
@synthesize receiptItemsTableView,totalsTableView,currentBill,receiptItemsToAddIndexPaths,receiptItemsToDeleteIndexPaths,delegate,remainingReceiptItemsArrayIndexesToBeDeleted,isInEditingMode;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"FullCheckCollectionCell" owner:self options:nil];
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [arrayOfViews objectAtIndex:0];
    }
    return self;
}

- (void)createWithBill:(Bill *) billToLoad{
    self.currentBill = billToLoad;
    self.receiptItemsTableView.delegate = self;
    self.receiptItemsTableView.dataSource = self;
    [self.receiptItemsTableView setAllowsMultipleSelection:YES];
    self.totalsTableView.dataSource = self;
    self.totalsTableView.delegate = self;
    [self.totalsTableView setAllowsSelection:NO];
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.layer.borderWidth = 3.0f;
    [self.layer setCornerRadius:10.0f];
    self.receiptItemsToDeleteIndexPaths = [[NSMutableArray alloc] init];
    self.receiptItemsToAddIndexPaths = [[NSMutableArray alloc] init];
    self.remainingReceiptItemsArrayIndexesToBeDeleted = [[NSMutableIndexSet alloc] init];
    self.isInEditingMode = NO;
}

- (void)setDisplayForAllocatedReceiptItemAtIndexPath:(NSIndexPath *)indexPath{

    [self.receiptItemsTableView cellForRowAtIndexPath:indexPath].backgroundColor = [UIColor colorWithWhite:1.0 alpha:0];
}

- (void)reloadTables{
    [self.receiptItemsTableView reloadData];
    [self.totalsTableView reloadData];
}

////UITableViewDataSource////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == 1){
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 1 && section == 0) {
        return [self.currentBill numberOfRemainingReceiptItems]+1;
    }
    else if (tableView.tag == 1 & section == 1){
        return [self.currentBill numberOfAssignedReceiptItems];
    }
    else {
        return 1;
    }
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView.tag == 1 && section == 0) {
        return @"Remaining Items";
    }
    else if (tableView.tag == 1 && section == 1){
        return @"Assigned Items";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView tag] == 1) { //loading remaining receiptItem table
        if (indexPath.section == 0 && indexPath.row == [self.currentBill numberOfRemainingReceiptItems]) {//load addreceiptitemcell
            static NSString *CellIdentifier = @"AddReceiptItemCell";
            AddReceiptItemCell *cell = (AddReceiptItemCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                [[NSBundle mainBundle] loadNibNamed:@"AddReceiptItemCell" owner:self options:nil];
                cell = [self addReceiptItemCell];
                [self setAddReceiptItemCell:nil];
            }
            [cell setDelegate:self];
            [cell setDisplay];
            return cell;
        } else {//load receiptItems
            static NSString *CellIdentifier = @"ReceiptItemCellIdentifier";
            ReceiptItemCell *cell = (ReceiptItemCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                [[NSBundle mainBundle] loadNibNamed:@"ReceiptItemCell" owner:self options:nil];
                cell = [self receiptItemCell];
                [self setReceiptItemCell:nil];
            }
            else{
                //clear out the data on the cell that is going to be reused
                [cell clearData];
            }
            [cell assignBill:self.currentBill];
            [cell setupKeyboards];
            [cell setUserInteractionForTextFields:self.isInEditingMode];
            [cell setTextFieldDelegates];
            cell.delegate = self;
            
            //third-party class that resigns first responder when clicking elsewhere in the tableview
            cell.priceTextField.inputAccessoryView = [[TableViewKeyboardDismisser alloc] initWithTableView:tableView];
            cell.itemTextField.inputAccessoryView = [[TableViewKeyboardDismisser alloc] initWithTableView:tableView];
            cell.quantityTextField.inputAccessoryView = [[TableViewKeyboardDismisser alloc] initWithTableView:tableView];
            
            
            //tag the cell to be able to identify it later.
            cell.contentView.tag = indexPath.row;
            if (indexPath.section == 0) {//remaining receiptItems
                ReceiptItem *currentReceiptItem = [self.currentBill.originalReceipt getRemainingReceiptItem:indexPath.row];
                cell.itemTextField.text = currentReceiptItem.itemName;
                cell.quantityTextField.text = [NSString stringWithFormat:@"%i",currentReceiptItem.quantityValue];
                if (currentReceiptItem.priceValue != 0) {
                    cell.priceTextField.text = [NSString stringWithFormat:@"%.02f",currentReceiptItem.priceValue];
                }
                cell.backgroundColor = [UIColor whiteColor];
            } else { //assigned receiptItems
                ReceiptItem *currentReceiptItem = [self.currentBill.originalReceipt getAssignedReceiptItem:indexPath.row];
                cell.itemTextField.text = currentReceiptItem.itemName;
                cell.quantityTextField.text = [NSString stringWithFormat:@"%i",currentReceiptItem.quantityValue];
                if (currentReceiptItem.priceValue != 0) {
                    cell.priceTextField.text = [NSString stringWithFormat:@"%.02f",currentReceiptItem.priceValue];
                }
                [cell setAsAnAllocatedReceiptItem];
            }
            return cell;
        }
    } else {
        //setting up the totals table
        static NSString *CellIdentifier = @"TotalCellIdentifier";
        TotalCell *cell = (TotalCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            [[NSBundle mainBundle] loadNibNamed:@"TotalCell" owner:self options:nil];
            cell = [self totalCell];
            [self setTotalCell:nil];
        }
       
        //load data into total cell for original receipt
        cell.subTotalTextField.text = [NSString stringWithFormat:@"%.02f",self.currentBill.originalReceipt.subTotalValue];
        cell.taxTextField.text = [NSString stringWithFormat:@"%.02f",self.currentBill.originalReceipt.taxAmountValue];
        cell.tipTextField.text = [NSString stringWithFormat:@"%.02f",self.currentBill.originalReceipt.tipAmountValue];
        cell.totalTextField.text = [NSString stringWithFormat:@"%.02f",self.currentBill.originalReceipt.grandTotalValue];
        
        //update the display of the tax and tip button
        [cell updateEditTax:self.currentBill.originalReceipt.taxPercentage OrTipButton:self.currentBill.originalReceipt.tipPercentage];
        //set action receivers for buttons within the cells and cell title
        [cell.editTaxOrTipButton addTarget:self action:@selector(editTaxOrTip) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

////UITableViewDelegate Methods////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.receiptItemsTableView]) {
        return 44;
    }
    else{
        return 87;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.receiptItemsTableView] && ![indexPath isEqual:[NSIndexPath indexPathForRow:[self.currentBill.originalReceipt getNumberOfRemainingItemsInReceipt] inSection:0]] && [tableView indexPathsForSelectedRows].count == 0) {
        return YES;
    }
    else {
        return NO;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isInEditingMode) {
        return nil;
    }
    else if (indexPath.section == 0) {
        if (indexPath.row == [self.currentBill numberOfRemainingReceiptItems]) {
            return nil;
        }
        else if ([self.currentBill.originalReceipt getRemainingReceiptItem:indexPath.row].priceValue == 0){
            return nil; //disallows selection of a cell with no price
        }
    }
    for (NSIndexPath *selectedIndexPath in [tableView indexPathsForSelectedRows]) {
        if (selectedIndexPath.section == 1) {//disallows selection if an assigned receiptItem is already selected
            return nil;
        }else if (indexPath.section == 1 && selectedIndexPath.section == 0){ //disallows selection of an assigned receiptItem if a remaining receiptItem is already selected
            return nil;
        }
    }
    return indexPath;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{ //Gives a checkmark for cells that are selected
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    if (indexPath.section == 1) { //selected a receiptItem in the assigned items section
        ReceiptItem *selectedReceiptItem = [self.currentBill.originalReceipt getAssignedReceiptItem:indexPath.row];
        [self.delegate assignedReceiptItem:selectedReceiptItem wasSelectedInSender:self]; //let the delegate know so the appropriate split check can be highlighted
    }
    else{//selected a receiptItem in the remaining items section
        ReceiptItem *selectedReceiptItem = [self.currentBill.originalReceipt getRemainingReceiptItem:indexPath.row];
        [self.delegate remainingReceiptItem:selectedReceiptItem wasSelectedInSender:self]; //let the delegate know so that any checks selected will be updated to include the newly selected item
    }
}

//Removes checkmarks when receiptitemcells are deselected
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && [self.currentBill.originalReceipt getRemainingReceiptItem:indexPath.row].allocated == YES) {
        ReceiptItem *deselectedReceiptItem = [self.currentBill.originalReceipt getRemainingReceiptItem:indexPath.row];
        deselectedReceiptItem.splitAmong = 1;
        deselectedReceiptItem.allocated = NO;
        [self.delegate remainingReceiptItem:deselectedReceiptItem wasDeselectedInSender:self];
    }
    else if (indexPath.section == 1){
        //unselected an item from the assigned list
        ReceiptItem *deselectedReceiptItem = [self.currentBill.originalReceipt getAssignedReceiptItem:indexPath.row];
        [self.delegate assignedReceiptItem:deselectedReceiptItem wasDeselectedInSender:self];
    }
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {// Override to support editing the table view and deleting rows
    
    if (editingStyle == UITableViewCellEditingStyleDelete && ![self.delegate doneButtonIsShowing] && !self.isInEditingMode) {     //what to do when the user swipes to delete
        //remove deleted item from the data source array
        ReceiptItem *itemToBeDeleted;
        if (indexPath.section == 0) {
            itemToBeDeleted = [self.currentBill.originalReceipt getRemainingReceiptItem:indexPath.row];
            [self.currentBill.originalReceipt removeReceiptItem:itemToBeDeleted];
            [self.currentBill.originalReceipt removeRemainingReceiptItemAtIndex:indexPath.row];
        } else {
            itemToBeDeleted = [self.currentBill.originalReceipt getAssignedReceiptItem:indexPath.row];
            //alert the viewcontroller that an assigned item has been deleted
            [self.delegate assignedReceiptItem:itemToBeDeleted willBeDeletedInSender:self];
            [self.currentBill.originalReceipt removeReceiptItem:itemToBeDeleted];
            [self.currentBill.originalReceipt removeAssignedReceiptItem:itemToBeDeleted];
        }
        
        //call the method to delete the row at indexpath
        [receiptItemsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //update totals cell with subs and totals
        [self.currentBill calculateBill];
        [self.totalsTableView reloadData];
    }
}

- (void)editTaxOrTip{
    [self.delegate editTaxOrTipWasSelectedbySender:self];
}

- (void)moveItemUp:(ReceiptItem *)receiptItemToBeMovedUp{
    
    receiptItemToBeMovedUp.allocated = NO;
    
    //update data sources
    [self.currentBill.originalReceipt removeAssignedReceiptItem:receiptItemToBeMovedUp];
    [self.currentBill.originalReceipt addReceiptItemToRemainingReceiptItems:receiptItemToBeMovedUp];
        
    //update index path arrays
    if ([self.receiptItemsTableView indexPathsForSelectedRows].count > 0) {
        [self.receiptItemsToAddIndexPaths removeAllObjects];
        [self.receiptItemsToDeleteIndexPaths removeAllObjects];
        [self.receiptItemsToDeleteIndexPaths addObject:[self.receiptItemsTableView indexPathForSelectedRow]];
        [self.receiptItemsToAddIndexPaths addObject:[NSIndexPath indexPathForRow:self.currentBill.originalReceipt.remainingReceiptItemsArray.count-1 inSection:0]];
        
        [self.receiptItemsTableView beginUpdates]; //update table (move item up)
        [self.receiptItemsTableView deleteRowsAtIndexPaths:self.receiptItemsToDeleteIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.receiptItemsTableView insertRowsAtIndexPaths:self.receiptItemsToAddIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.receiptItemsTableView endUpdates];
    } 
    [self.receiptItemsTableView reloadData];
}

- (void)moveItemsDown{
    [self.remainingReceiptItemsArrayIndexesToBeDeleted removeAllIndexes];
    [self.receiptItemsToAddIndexPaths removeAllObjects];
    [self.receiptItemsToDeleteIndexPaths removeAllObjects];
    for (NSIndexPath *selectedIndexPath in [self.receiptItemsTableView indexPathsForSelectedRows]) {
            //if (((ReceiptItem *)[self.currentBill.originalReceipt getRemainingReceiptItem:selectedIndexPath.row]).allocated == YES) {
                //update data sources
        [self.currentBill.originalReceipt addReceiptItemToAssignedReceiptItems:[self.currentBill.originalReceipt getRemainingReceiptItem:selectedIndexPath.row]];
        [self.remainingReceiptItemsArrayIndexesToBeDeleted addIndex:selectedIndexPath.row];
                
        //update index path arrays
        [self.receiptItemsToDeleteIndexPaths addObject:selectedIndexPath];
        [self.receiptItemsToAddIndexPaths addObject:[NSIndexPath indexPathForRow:self.currentBill.originalReceipt.allocatedReceiptItemsArray.count-1 inSection:1]];
                
    }
    [self.currentBill.originalReceipt.remainingReceiptItemsArray removeObjectsAtIndexes:self.remainingReceiptItemsArrayIndexesToBeDeleted]; //Delete assigned items from the remaining receipt items array
    [self.receiptItemsTableView beginUpdates]; //update table (move allocated item down)
    [self.receiptItemsTableView deleteRowsAtIndexPaths:self.receiptItemsToDeleteIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.receiptItemsTableView insertRowsAtIndexPaths:self.receiptItemsToAddIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.receiptItemsTableView endUpdates];
    
    [self.receiptItemsTableView reloadData];
}

- (BOOL)assignedItemIsSelected{
    for (NSIndexPath *selectedItemIndexPath in [self.receiptItemsTableView indexPathsForSelectedRows]) {
        if (selectedItemIndexPath.section == 1) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)remainingItemIsSelected{
    for (NSIndexPath *selectedItemIndexPath in [self.receiptItemsTableView indexPathsForSelectedRows]) {
        if (selectedItemIndexPath.section == 0) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)multipleRemainingItemsAreSelected{
    if ([self.receiptItemsTableView indexPathsForSelectedRows].count > 1) {
        return YES;
    }
    return NO;
}

//AddReceiptItemCellDelegate Methods
- (void)tapToAddAnItemWasTapped:(AddReceiptItemCell *)sender{
    if (!self.isInEditingMode) {
        [self.currentBill.originalReceipt addReceiptItem:[[ReceiptItem alloc] init]];
        [self.receiptItemsTableView reloadData];
        [self.receiptItemsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.currentBill.originalReceipt getNumberOfRemainingItemsInReceipt] inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [self.delegate newReceiptItem:nil wasAddedInSender:self]; //call the delegate to switch to editing mode
        
        //set the new cell to have a cursor and the keyboard popup
        NSIndexPath *indexPathOfAddedCell = [NSIndexPath indexPathForRow:[self.currentBill.originalReceipt remainingReceiptItemsArray].count-1 inSection:0];
        [((ReceiptItemCell *)[self.receiptItemsTableView cellForRowAtIndexPath:indexPathOfAddedCell]).itemTextField becomeFirstResponder];
    }
}

//ReceiptItemCellDelegate Methods
- (ReceiptItem *)getReceiptItemForCell:(ReceiptItemCell *)sender{
    NSIndexPath *indexPathOfReceiptItemCell = [self.receiptItemsTableView indexPathForCell:sender];
    ReceiptItem *receiptItemBeingChanged;
    if (indexPathOfReceiptItemCell.section == 0) {
        receiptItemBeingChanged = [self.currentBill.originalReceipt getRemainingReceiptItem:indexPathOfReceiptItemCell.row];
    } else {
        receiptItemBeingChanged = [self.currentBill.originalReceipt getAssignedReceiptItem:indexPathOfReceiptItemCell.row];
    }
    return receiptItemBeingChanged;
}

- (NSIndexPath *)indexPathForReceiptItemCell:(ReceiptItemCell *)sender{
    return [self.receiptItemsTableView indexPathForCell:sender];
}

- (void)textField:(UITextField *)textField beganEditingIn:(ReceiptItemCell *)receiptItemCellEdited{    
    // resize the UITableView to fit above the keyboard
    // adjust the contentInset
    [self.delegate receiptItemChanged:nil willBeEditedInSender:self];
    self.receiptItemsTableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
    [self.receiptItemsTableView scrollToRowAtIndexPath:[self.receiptItemsTableView indexPathForCell:receiptItemCellEdited] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)textField:(UITextField *)textField willEndEditingIn:(ReceiptItemCell *)receiptItemCellBeingEdited{
    // resize the UITableView to the original size
    
    //self.receiptItemsTableView.frame = CGRectMake(0.0,44.0,320.0,416.0);
    
    // Undo the contentInset
    self.receiptItemsTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)textFieldHasBeenEditedIn:(ReceiptItem *)receiptItemChanged{
    [self.totalsTableView reloadData];
    [self.delegate receiptItemWasChanged:receiptItemChanged inSender:self];
}

- (void)changeEditingModeTo:(BOOL)isEditing{
    self.isInEditingMode = isEditing;
    if (self.isInEditingMode) {//switching to editing mode
        [self.receiptItemsTableView reloadData];
    } else {//switching from editing mode
        [self.receiptItemsTableView reloadData];
    }
}

- (BOOL)isCellInOriginalCheck{
    return YES;
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
