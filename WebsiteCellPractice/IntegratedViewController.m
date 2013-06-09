//
//  IntegratedViewController.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/29.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import "IntegratedViewController.h"
#import "CheckCell.h"
#import "FullCheckCollectionCell.h"
#import "AllocatedCheckCollectionCell.h"
#import "TableViewKeyboardDismisser.h"
#import "UIView+UIView_FirstResponder.h"
#import "ReceiptItem.h"
#import "Receipt.h"
#import "Bill.h"
#import "CustomInputAccessoryView.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>

@interface IntegratedViewController ()

@end

@implementation IntegratedViewController
@synthesize myCollectionView,currentBill,fullReceiptCollectionView,doneBarButton,tipTextField,taxTextField,taxAndTipView,doubleValueWithMaxTwoDecimalPlaces,formattedTaxPercentage,formattedTipPercentage;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(moveToNextItem:)];
    [self.navigationItem setRightBarButtonItem:self.editButtonItem];
    [self.myCollectionView registerClass:[CheckCell class] forCellWithReuseIdentifier:@"CheckCellIdentifier"];
    [self.fullReceiptCollectionView registerClass:[FullCheckCollectionCell class] forCellWithReuseIdentifier:@"FullCheckCollectionCellIdentifier"];
    [self.fullReceiptCollectionView registerClass:[AllocatedCheckCollectionCell class] forCellWithReuseIdentifier:@"AllocatedCheckCollectionCellIdentifier"];
    Receipt *temp = [[Receipt alloc] initAsOriginal];
    
    //TO BE DELETED EVENTUALLY - FOR TESTING ONLY
    
    ReceiptItem *tempItem = [[ReceiptItem alloc] initWith:@"Item 1" andPrice:10.0 andQuantity:1];
    ReceiptItem *tempItemTwo = [[ReceiptItem alloc] initWith:@"Item 2" andPrice:20.0 andQuantity:1];
    ReceiptItem *tempItemThree = [[ReceiptItem alloc] initWith:@"Item 3" andPrice:30.0 andQuantity:1];
    [temp addReceiptItem:tempItem];
    [temp addReceiptItem:tempItemTwo];
    [temp addReceiptItem:tempItemThree];
    self.currentBill = [[Bill alloc] initWithReceipt:temp];
    [self.currentBill calculateBill];
     
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGesture.minimumPressDuration = 1.2;
    [self.myCollectionView addGestureRecognizer:longPressGesture];
    self.myCollectionView.allowsMultipleSelection = YES;
    self.fullReceiptCollectionView.allowsSelection = NO;
    [self.fullReceiptCollectionView setPagingEnabled:YES];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////UICollectionView DataSource Methods////

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    /*
    if (collectionView.tag == 1 && ![self.currentBill isFullyAllocated]) {
        //The full receipt collection view
        return 1;
    } else {
        //split check collection view
        return [self.currentBill numberOfReceipts]+1;
    }
     */
    return [self.currentBill numberOfReceipts]+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 1) {
        //Full receipt collection view
        if (indexPath.row == 0) { //original receipt
            static NSString *cellIdentifier = @"FullCheckCollectionCellIdentifier";
            FullCheckCollectionCell *cell = (FullCheckCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
            [cell createWithBill:self.currentBill];
            [cell setDelegate:self];
            return cell;
        } else { //split receipts
            static NSString *cellIdentifier = @"AllocatedCheckCollectionCellIdentifier";
            AllocatedCheckCollectionCell *cell = (AllocatedCheckCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
            [cell createWithBill:self.currentBill forReceiptNumber:indexPath.row];
            [cell setDelegate:self];
            [cell reloadTables];
            return cell;
        }
    } else {
        //Set up the split check collection view
        static NSString *cellIdentifier = @"CheckCellIdentifier";
        CheckCell *cell = (CheckCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        if (indexPath.row == [self.currentBill numberOfReceipts]) { //setup add a check
            [cell setInitialDisplayForAddACheck];
            return cell;
        }
        else {//set up split checks
            [cell setInitialDisplayForSplitCheckCellAtIndexRow:indexPath.row];
            for (NSIndexPath *collectionIndexPath in [collectionView indexPathsForSelectedItems]) {
                if ([indexPath isEqual:collectionIndexPath]) {
                    [cell setCellToCyan]; //override to set to blue for selected paths
                }
            }
            [cell updateDisplay:[self.currentBill getReceipt:indexPath.row] atIndexPathRow:indexPath.row];
            int currentlyVisibleSplitCheckNumber = [self.fullReceiptCollectionView indexPathForCell:[[self.fullReceiptCollectionView visibleCells] objectAtIndex:0]].row;
            if (currentlyVisibleSplitCheckNumber-1 == indexPath.row) {
                [cell turnBorderRed];
            }
            [cell.deleteButton addTarget:self action:@selector(deleteSplitCheck:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }
}

////UICollectionView Delegate Methods////

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView.tag == 1) {
        return CGSizeMake(220, 490);
    } else {
        return CGSizeMake(90, 95);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([((CheckCell *)[collectionView cellForItemAtIndexPath:indexPath]) isQuivering]) {
        [(CheckCell *)[collectionView cellForItemAtIndexPath:indexPath] stopQuivering];
    }
    if (indexPath.row == [self.currentBill numberOfReceipts]){
        //User has selected the "add split check cell" and bill is not fully allocated
        [self.currentBill addNewSplitCheck];
        [collectionView insertItemsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:[self.currentBill numberOfReceipts]-1 inSection:0], nil]];
        [[collectionView cellForItemAtIndexPath:indexPath] setSelected:NO];
        [self.myCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        
        
        //TEST
        [self.fullReceiptCollectionView reloadData];
        
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView.tag == 2 && indexPath.row != [self.currentBill numberOfReceipts] && [((FullCheckCollectionCell *)[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]).receiptItemsTableView indexPathsForSelectedRows] > 0) {
        return YES;
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != [self.currentBill numberOfReceipts]) {
        //User has selected an active check cell
        [self.navigationItem setRightBarButtonItem:self.doneBarButton animated:YES];
        [((CheckCell *)[collectionView cellForItemAtIndexPath:indexPath]) setCellToCyan];
        for (NSIndexPath *selectedReceiptItemIndexPath in [((FullCheckCollectionCell *)[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]).receiptItemsTableView indexPathsForSelectedRows]) {
            ReceiptItem *selectedReceiptItem;
            if (selectedReceiptItemIndexPath.section == 0) {
                selectedReceiptItem = [self.currentBill.originalReceipt getRemainingReceiptItem:selectedReceiptItemIndexPath.row];
            } else {
                selectedReceiptItem = [self.currentBill.originalReceipt getAssignedReceiptItem:selectedReceiptItemIndexPath.row];
            }
            //sets the number to split among and calculates
            [selectedReceiptItem setSplitAmong:[self.myCollectionView indexPathsForSelectedItems].count];
            [selectedReceiptItem readyForAllocation];
            
            //adds to the newly selected item
            [self.currentBill addToSplitCheck:indexPath.row fromItem:selectedReceiptItem];
            
            //update display for all selected items
            for (NSIndexPath *selectedSplitCheckIndexPath in [self.myCollectionView indexPathsForSelectedItems]) {
                [self.currentBill calculateBill];
                Receipt *previouslySelectedReceipt = [self.currentBill getReceipt:selectedSplitCheckIndexPath.row];
                [(CheckCell *)[myCollectionView cellForItemAtIndexPath:selectedSplitCheckIndexPath] updateDisplay:previouslySelectedReceipt atIndexPathRow:selectedSplitCheckIndexPath.row];
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([(CheckCell *)[collectionView cellForItemAtIndexPath:indexPath] isCellSetToCyan]) {
        //user has deselected a check
        Receipt *deselectedReceipt = (Receipt *)[self.currentBill getReceipt:indexPath.row];
        [(CheckCell *)[collectionView cellForItemAtIndexPath:indexPath] setCellToWhite];
        for (NSIndexPath *selectedReceiptItemIndexPath in [((FullCheckCollectionCell *)[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]).receiptItemsTableView indexPathsForSelectedRows]) {
            
            ReceiptItem *selectedReceiptItem; 
            
            if (selectedReceiptItemIndexPath.section == 1) {//an assigned receiptItem is selected
                selectedReceiptItem = [self.currentBill.originalReceipt getAssignedReceiptItem:selectedReceiptItemIndexPath.row];
            }
            else{
                selectedReceiptItem = [self.currentBill.originalReceipt getRemainingReceiptItem:selectedReceiptItemIndexPath.row];
            }

            [deselectedReceipt removeReceiptItem:selectedReceiptItem];
            
            //sets the number to split among and calculates
            if ([self.myCollectionView indexPathsForSelectedItems].count >= 1) {
                [selectedReceiptItem setSplitAmong:[self.myCollectionView indexPathsForSelectedItems].count];
            } else {
                [selectedReceiptItem setSplitAmong:1];
                [selectedReceiptItem setAllocated:NO];
                if (selectedReceiptItemIndexPath.section == 1) {//an assigned item needs to be moved back up
                    [(FullCheckCollectionCell *)[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] moveItemUp:selectedReceiptItem];
                }
                [self.navigationItem setRightBarButtonItem:self.editButtonItem];
            }
            [self.currentBill calculateBill];
            //update display for all selected items
            for (NSIndexPath *selectedSplitCheckIndexPath in [self.myCollectionView indexPathsForSelectedItems]) {
                Receipt *selectedReceipt = [self.currentBill getReceipt:selectedSplitCheckIndexPath.row];
                [(CheckCell *)[myCollectionView cellForItemAtIndexPath:selectedSplitCheckIndexPath] updateDisplay:selectedReceipt atIndexPathRow:selectedSplitCheckIndexPath.row];
            }
            //update display of deselected item
            if (deselectedReceipt.grandTotalValue != 0) {
                [(CheckCell *)[myCollectionView cellForItemAtIndexPath:indexPath] updateDisplay:deselectedReceipt atIndexPathRow:indexPath.row];
            } else {
                [(CheckCell *)[myCollectionView cellForItemAtIndexPath:indexPath] clearCellatIndexPathRow:indexPath.row];
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{ //changes border of the CheckCell shown to red and sets all others to gray
    if ([collectionView isEqual:self.fullReceiptCollectionView]) {
        for (int i = 0; i<[self.currentBill numberOfReceipts]; i++) {
            [(CheckCell *)[self.myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]] turnBorderGray];
        }
        if (![[[self.fullReceiptCollectionView visibleCells] objectAtIndex:0] isEqual:[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]]) {
            [(CheckCell *)[self.myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:((AllocatedCheckCollectionCell *)[[self.fullReceiptCollectionView visibleCells] objectAtIndex:0]).receiptNumber inSection:0]] turnBorderRed];
            
            //TEST//
            //[self.currentBill saveToParse];
        }
    }
}

//FULLCHECKCOLLECTIONCELL DELEGATE METHODS

- (void)editTaxOrTipWasSelectedbySender:(id)sender{
    /*
    ChangeTipOrTax *changeTipOrTaxPage = [[ChangeTipOrTax alloc] initWithBill:self.currentBill andReceipt:self.currentBill.originalReceipt];
    [self presentViewController:changeTipOrTaxPage animated:YES completion:NULL];
     
    [self.taxTextField setHidden:NO];
    [self.tipTextField setHidden:NO];
     */
    [self.taxAndTipView setHidden:NO];
    [self.taxAndTipView.layer setBorderWidth:2];
    [self.taxAndTipView.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.myCollectionView setUserInteractionEnabled:NO];
    [self.fullReceiptCollectionView setUserInteractionEnabled:NO];
    [self.myCollectionView setAlpha:0.7];
    [self.fullReceiptCollectionView setAlpha:0.7];
    [self.taxTextField becomeFirstResponder];
    
    //Set up the textfields with tax and tip
    self.doubleValueWithMaxTwoDecimalPlaces = [[NSNumberFormatter alloc] init];
    [self.doubleValueWithMaxTwoDecimalPlaces setNumberStyle:NSNumberFormatterDecimalStyle];
    [self.doubleValueWithMaxTwoDecimalPlaces setMaximumFractionDigits:2];
    Receipt *receiptToBeModified;
    if ([sender isEqual:[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]]) {//original receipt
        receiptToBeModified = self.currentBill.originalReceipt;
    } else {//allocated checks
        int receiptNumber = [self.fullReceiptCollectionView indexPathForCell:sender].row-1;
        receiptToBeModified = [self.currentBill getReceipt:receiptNumber];
    }
    self.formattedTaxPercentage = [NSNumber numberWithDouble:receiptToBeModified.taxPercentage*100];
    self.formattedTipPercentage = [NSNumber numberWithDouble:receiptToBeModified.tipPercentage*100];
    self.taxTextField.text = [NSString stringWithFormat:@"%@%@",
                          [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTaxPercentage],@"%"];
    self.tipTextField.text = [NSString stringWithFormat:@"%@%@",
                          [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTipPercentage],@"%"];
}

//Do I need this?
- (void)editTaxOrTipIsDoneEditingInSender:(id)sender{
    [self.taxAndTipView setHidden:YES];
    [self.myCollectionView setUserInteractionEnabled:YES];
    [self.fullReceiptCollectionView setUserInteractionEnabled:YES];
    [self.myCollectionView setAlpha:1];
    [self.fullReceiptCollectionView setAlpha:1];
    [((AllocatedCheckCollectionCell *)sender).totalsTableView reloadData];
    //TEST
    [self.myCollectionView reloadData];
}

- (void)remainingReceiptItem:(ReceiptItem *)remainingReceiptItem willBeSelectedInSender:(FullCheckCollectionCell *)sender{
    [self.myCollectionView reloadData];
}

- (void)remainingReceiptItem:(ReceiptItem *)remainingReceiptItem wasSelectedInSender:(FullCheckCollectionCell *)sender{
    if ([sender multipleRemainingItemsAreSelected]) { //more than one remaining receipt items are selected

        //sets the number to split among and calculates
        [remainingReceiptItem setSplitAmong:[self.myCollectionView indexPathsForSelectedItems].count];
        [remainingReceiptItem readyForAllocation];
        
        //update display for all selected items
        for (NSIndexPath *selectedSplitCheckIndexPath in [self.myCollectionView indexPathsForSelectedItems]) {
            //adds to the newly selected item
            [self.currentBill addToSplitCheck:selectedSplitCheckIndexPath.row fromItem:remainingReceiptItem];
            
            [self.currentBill calculateBill];
            Receipt *previouslySelectedReceipt = [self.currentBill getReceipt:selectedSplitCheckIndexPath.row];
            [(CheckCell *)[myCollectionView cellForItemAtIndexPath:selectedSplitCheckIndexPath] updateDisplay:previouslySelectedReceipt atIndexPathRow:selectedSplitCheckIndexPath.row];
        }
    }
}

- (void)assignedReceiptItem:(ReceiptItem *)assignedReceiptItem wasSelectedInSender:(FullCheckCollectionCell *)sender{
    if (assignedReceiptItem != nil) {
        int i = 0;
        for (Receipt *receiptToCheck in self.currentBill.splitReceiptsArray) {
            for (ReceiptItem *receiptItemToCheck in receiptToCheck.allReceiptItemsArray) {//searching all receiptItems in each split check
                if ([receiptItemToCheck isEqual:assignedReceiptItem]) {
                    //changing that receipt to Blue if we find a match and selecting it
                    [(CheckCell *)[self.myCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]] setCellToCyan];
                    [self.myCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                }
            }
            i++;
        }
    }
}

- (void)remainingReceiptItem:(ReceiptItem *)remainingReceiptItem wasDeselectedInSender:(FullCheckCollectionCell *)sender{
    for (NSIndexPath *selectedSplitCheckIndexPath in [self.myCollectionView indexPathsForSelectedItems]) {
        Receipt *selectedReceipt = [self.currentBill getReceipt:selectedSplitCheckIndexPath.row];
        [selectedReceipt removeReceiptItem:remainingReceiptItem];//removing the deselected receipt
        [self.currentBill calculateBill];
        [(CheckCell *)[myCollectionView cellForItemAtIndexPath:selectedSplitCheckIndexPath] updateDisplay:selectedReceipt atIndexPathRow:selectedSplitCheckIndexPath.row];
    }
    if (![sender remainingItemIsSelected]) {
        [self.myCollectionView reloadData];
        [self.navigationItem setRightBarButtonItem:self.editButtonItem];
    }
}

- (void)assignedReceiptItem:(ReceiptItem *)assignedReceiptItem wasDeselectedInSender: (FullCheckCollectionCell *)sender{
    [self.myCollectionView reloadData];
    [self.navigationItem setRightBarButtonItem:self.editButtonItem];
}

- (void)assignedReceiptItem:(ReceiptItem *)assignedReceiptItem willBeDeletedInSender:(FullCheckCollectionCell *)sender{
    if (assignedReceiptItem != nil) {
        NSMutableArray *arrayOfIndexesToBeUpdated = [[NSMutableArray alloc] init];
        NSIndexPath *indexPathOfChecksToBeUpdated = [NSIndexPath indexPathForRow:0 inSection:0];
        for (Receipt *receiptToCheck in self.currentBill.splitReceiptsArray) {
            for (ReceiptItem *receiptItemToCheck in receiptToCheck.allReceiptItemsArray) {//searching all receiptItems in each split check
                if ([receiptItemToCheck isEqual:assignedReceiptItem]) {
                    [arrayOfIndexesToBeUpdated addObject:indexPathOfChecksToBeUpdated];
                    [receiptToCheck removeReceiptItem:receiptItemToCheck];
                    break;
                }
            }
            indexPathOfChecksToBeUpdated = [NSIndexPath indexPathForRow:indexPathOfChecksToBeUpdated.row+1 inSection:0];
        }
        [self.currentBill calculateBill];
        [self.myCollectionView reloadItemsAtIndexPaths:arrayOfIndexesToBeUpdated];
    }
}

- (BOOL)doneButtonIsShowing{
    return [[self.navigationItem rightBarButtonItem] isEqual:self.doneBarButton];
}

- (void)receiptItemChanged:(ReceiptItem *)receiptItemChanged willBeEditedInSender:(FullCheckCollectionCell *)sender{
    [self.navigationItem setRightBarButtonItem:nil];
}

- (void)receiptItemWasChanged:(ReceiptItem *)receiptItemChanged inSender:(FullCheckCollectionCell *)sender{
    [self.myCollectionView reloadData];
    /*
    if (receiptItemChanged.priceValue != 0) {
        [self setEditing:NO animated:YES];
    }
     */
    //[self setEditing:YES animated:YES];
    [self.navigationItem setRightBarButtonItem:self.editButtonItem];
}

- (void)newReceiptItem:(ReceiptItem *)newReceiptItem wasAddedInSender:(FullCheckCollectionCell *)sender{
    [self setEditing:YES animated:YES];
}

////UITextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    // Now add the view as an input accessory view to the selected textfield.
    CustomInputAccessoryView *myInputAccessoryView=[[CustomInputAccessoryView alloc]initWithTextField:textField];
    myInputAccessoryView.delegate = self;
    [textField setInputAccessoryView:myInputAccessoryView];
    if ([textField isEqual:self.taxTextField]) {
        textField.text = [NSString stringWithFormat:@"%@",
                          [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTaxPercentage]];
    } else {
        textField.text = [NSString stringWithFormat:@"%@",
                          [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTipPercentage]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    Receipt *receiptBeingEdited;
    if ([self.fullReceiptCollectionView indexPathForCell:[[self.fullReceiptCollectionView visibleCells] objectAtIndex:0]].row == 0) {
        receiptBeingEdited = self.currentBill.originalReceipt;
    }
    else {
        receiptBeingEdited = [self.currentBill getReceipt:[self.fullReceiptCollectionView indexPathForCell:[[self.fullReceiptCollectionView visibleCells] objectAtIndex:0]].row-1];
    }
    if ([textField isEqual:self.taxTextField]) {
        receiptBeingEdited.taxPercentage = [textField.text doubleValue]/100;
        self.formattedTaxPercentage = [NSNumber numberWithDouble:receiptBeingEdited.taxPercentage*100];
        self.taxTextField.text = [NSString stringWithFormat:@"%@%@",
                                  [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTaxPercentage],@"%"];
    } else {
        receiptBeingEdited.tipPercentage = [textField.text doubleValue]/100;
        self.formattedTipPercentage = [NSNumber numberWithDouble:receiptBeingEdited.tipPercentage*100];
        tipTextField.text = [NSString stringWithFormat:@"%@%@",
                             [doubleValueWithMaxTwoDecimalPlaces stringFromNumber:formattedTipPercentage],@"%"];
    }
    [self.currentBill calculateBill];
    [self.myCollectionView reloadData];
}

//CustomInputAccessoryViewDelegate Methods

- (void)doneWasTappedInSender: (UITextField *)sender{
    [sender resignFirstResponder];
    [self.taxAndTipView setHidden:YES];
    [self.myCollectionView setUserInteractionEnabled:YES];
    [self.fullReceiptCollectionView setUserInteractionEnabled:YES];
    [self.myCollectionView setAlpha:1];
    [self.fullReceiptCollectionView setAlpha:1];
    if ([self.fullReceiptCollectionView indexPathForCell:[[self.fullReceiptCollectionView visibleCells] objectAtIndex:0]].row != 0) {//allocated receipt
        [((AllocatedCheckCollectionCell *)[[self.fullReceiptCollectionView visibleCells] objectAtIndex:0]).totalsTableView reloadData];
    } else {//original receipt
        [((FullCheckCollectionCell *)[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]).totalsTableView reloadData];
    }

}
- (void)nextWasTappedInSender: (UITextField *)sender{
    if ([sender isEqual:self.taxTextField]) {
        [sender resignFirstResponder];
        [self.tipTextField becomeFirstResponder];
    }
}
- (void)prevWasTappedInSender: (UITextField *)sender{
    if ([sender isEqual:self.tipTextField]) {
        [sender resignFirstResponder];
        [self.taxTextField becomeFirstResponder];
    }
}

//IBACTION METHODS

- (IBAction)dismissKeyboard:(id)sender{
    UIView *keyboardOwner = [self.view findFirstResponder];
    [keyboardOwner resignFirstResponder];
}

- (void)moveToNextItem:(id)sender { //called when the user has hit the "done" button after allocating items
    if ([(FullCheckCollectionCell *)[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] remainingItemIsSelected]) {//user has hit done after allocating a remaining item
        [(FullCheckCollectionCell *)[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] moveItemsDown]; //update the FullCheckCollectionCell
    }
    else{//user has hit done after changing the allocation of an assigned item
        [(FullCheckCollectionCell *)[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] reloadTables];
    }
    [self.myCollectionView reloadItemsAtIndexPaths:[self.myCollectionView indexPathsForSelectedItems]]; //update the Split CheckCells
    [self.navigationItem setRightBarButtonItem:self.editButtonItem];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    //called when the user has hit the "edit" button or "done" after editing receiptItems
    [super setEditing:editing animated:animated];
    if ([[[self.fullReceiptCollectionView visibleCells] objectAtIndex:0] isEqual:[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]]]) {//original check
        [(FullCheckCollectionCell *)[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] changeEditingModeTo:editing];
    } else {//allocated checks
        [(AllocatedCheckCollectionCell *)[[self.fullReceiptCollectionView visibleCells] objectAtIndex:0] changeEditingModeTo:editing];
    }
    if (editing) {
        [self.myCollectionView reloadData];
    }
}

/*overriding UIAlertView method to only advance if numbers and cancel not hit
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex] && [numberOfChecksTextField.text intValue] > 0) {
        [self.currentBill create:[numberOfChecksTextField.text intValue]];
        
        CGRect firstCollectionViewFrame = [self.fullReceiptCollectionView frame];
        firstCollectionViewFrame.size.height = 392;  // change the size
        [self.fullReceiptCollectionView setFrame:firstCollectionViewFrame];
        [self.fullReceiptCollectionView reloadData];
         
        [self.myCollectionView reloadData];
        self.myCollectionView.hidden = NO;
        
        [UIView animateWithDuration:1 animations:^{
            CGRect firstCollectionViewFrame = [self.fullReceiptCollectionView frame];
            firstCollectionViewFrame.size.height -= 115;
            self.fullReceiptCollectionView.frame = firstCollectionViewFrame;
        }];
        [self.fullReceiptCollectionView reloadData];
    }
}
*/

////Helper Methods////


- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender{
    CGPoint gesturePosition = [sender locationInView:self.myCollectionView];
    if (sender.state == UIGestureRecognizerStateBegan){
        if ([self.myCollectionView indexPathForItemAtPoint:gesturePosition].row != [self.currentBill numberOfReceipts] && ![[self.navigationItem rightBarButtonItem] isEqual:self.doneBarButton]) {
            [(CheckCell *)[self.myCollectionView cellForItemAtIndexPath:[self.myCollectionView indexPathForItemAtPoint:gesturePosition]] startQuivering];
        }
    }
    
    
    //CHANGE TO HANDLE DELETION
    /*

    
    NSIndexPath *selectedIndexPath = [self.myCollectionView indexPathForItemAtPoint:gesturePosition];
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (![self.currentBill isFullyAllocated] && !self.isSplitting) {
            //initiate splitting mode if 1) items still remain, 2) it's not currently splitting
            if (selectedIndexPath.row != [self.currentBill numberOfReceipts]) {
                //only take action if cell clicked is not "add-a-check" cell
                [self.myCollectionView selectItemAtIndexPath:selectedIndexPath animated:YES scrollPosition:nil];
                self.isSplitting = YES;
                
                 self.navigationItem.rightBarButtonItem.title = @"Done";
                 self.navigationItem.rightBarButtonItem.tintColor = [UIColor blueColor];
                 [self.navigationItem.rightBarButtonItem setAction:@selector(endSplitting)];
                 
                
                CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
                transformAnimation.duration = .3;
                transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
                //transformAnimation.removedOnCompletion = NO;
                transformAnimation.fillMode = kCAFillModeForwards;
                
                CATransform3D xform = CATransform3DIdentity;
                xform = CATransform3DScale(xform, 1.1, 1.1, 1.1);
                xform = CATransform3DTranslate(xform, 5, 5, 5);
                transformAnimation.toValue = [NSValue valueWithCATransform3D:xform];
                [[self.myCollectionView cellForItemAtIndexPath:selectedIndexPath].layer addAnimation:transformAnimation forKey:@"transformAnimation"];
            }
        }
        else{ //if ([((FullCheckCollectionCell *)[self.fullReceiptCollectionView.visibleCells objectAtIndex:0]).receiptItemsTableView indexPathsForSelectedRows].count > 0 && [self.myCollectionView indexPathsForSelectedItems].count > 0) {
            //end splitting
            CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
            transformAnimation.duration = .3;
            transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
            //transformAnimation.removedOnCompletion = NO;
            transformAnimation.fillMode = kCAFillModeForwards;
            
            CATransform3D xform = CATransform3DIdentity;
            xform = CATransform3DScale(xform, 1.1, 1.1, 1.1);
            xform = CATransform3DTranslate(xform, 5, 5, 5);
            transformAnimation.toValue = [NSValue valueWithCATransform3D:xform];
            [[self.myCollectionView cellForItemAtIndexPath:selectedIndexPath].layer addAnimation:transformAnimation forKey:@"transformAnimation"];
            
            for (NSIndexPath *selectedReceiptItemIndexPath in [((FullCheckCollectionCell *)[self.fullReceiptCollectionView.visibleCells objectAtIndex:0]).receiptItemsTableView indexPathsForSelectedRows]) {
                [[self.currentBill.originalReceipt getReceiptItem:selectedReceiptItemIndexPath.row] setSplitAmong:[self.myCollectionView indexPathsForSelectedItems].count];
                [[self.currentBill.originalReceipt getReceiptItem:selectedReceiptItemIndexPath.row] readyForAllocation];
                for (NSIndexPath *selectedSplitCheckIndexPath in [self.myCollectionView indexPathsForSelectedItems]) {
                    [self.currentBill addToSplitCheck:selectedSplitCheckIndexPath.row fromItem:[self.currentBill.originalReceipt getReceiptItem:selectedReceiptItemIndexPath.row]];
                }
            }
            [currentBill calculateBill];
            
            //update display data
            for (int i = 0; i<self.displayData.count; i++) {
                if (((ReceiptItem *)[self.displayData objectAtIndex:i]).allocated == YES) {
                    [self.displayData removeObjectAtIndex:i];
                    i--;
                }
            }
            [((FullCheckCollectionCell *)[self.fullReceiptCollectionView.visibleCells objectAtIndex:0]).totalsTableView reloadData];
            [((FullCheckCollectionCell *)[self.fullReceiptCollectionView.visibleCells objectAtIndex:0]).receiptItemsTableView reloadData];
            [self.myCollectionView reloadData];
            self.isSplitting = NO;
        }
    }
*/
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
- (void)deleteSplitCheck:(id)sender{
    CheckCell *cellTapped = (CheckCell *)[[(UIButton *)sender superview] superview]; //find cell tapped
    NSIndexPath *indexPathOfCheckCellTapped = [self.myCollectionView indexPathForCell:cellTapped]; //get indexpath
    [self.myCollectionView deselectItemAtIndexPath:indexPathOfCheckCellTapped animated:NO]; //deselect it
    Receipt *receiptToBeDeleted = [self.currentBill getReceipt:indexPathOfCheckCellTapped.row]; // get the receipt that cell pertains to
    if (receiptToBeDeleted.grandTotalValue > 0) { //change splitAmongs
        for (ReceiptItem *receiptItemNeedingSplitAmongChange in [receiptToBeDeleted allReceiptItemsArray]) {
            if (receiptItemNeedingSplitAmongChange.splitAmong > 1) {
                receiptItemNeedingSplitAmongChange.splitAmong--;
            }
            else{//receiptItem is no longer allocated
                [(FullCheckCollectionCell *)[self.fullReceiptCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]] moveItemUp:receiptItemNeedingSplitAmongChange];
            }
        }
    } 
    [self.currentBill removeReceiptAtIndex:indexPathOfCheckCellTapped.row];
    [self.currentBill calculateBill];
    
    [self.myCollectionView performBatchUpdates:^{
        [self.myCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPathOfCheckCellTapped]];
    }completion:nil];
    [self.myCollectionView reloadData];
    [self.fullReceiptCollectionView reloadData];
}

//Override of UIResponder Method to disable cut,copy, paste in the tax and tip textfields
/*
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if ([sender isEqual:self.taxTextField] || [sender isEqual:self.tipTextField]) {
        if (action == @selector(paste:))
        {
            return NO;
        }
    }
    return YES;
}
 */


@end
