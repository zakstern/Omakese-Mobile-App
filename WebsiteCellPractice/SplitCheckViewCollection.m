//
//  SplitCheckViewCollection.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/28.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "SplitCheckViewCollection.h"
#import "SplitCheckCollectionCell.h"
#import "ItemDisplayCell.h"
#import "Receipt.h"
#import "ReceiptItem.h"
#import "Bill.h"
#import "TestReceiptViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SplitCheckViewCollection ()

@end

@implementation SplitCheckViewCollection

@synthesize myCollectionView,myTableView,itemCell,currentBill,currentItemNumber,indexPathArrays,currentReceiptItem,lastItem,myCollectionViewFlowLayout,quantityTracker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithReceipt:(Receipt *)currentReceipt andNumberInParty:(int)numberInParty{
    self = [super initWithNibName:@"SplitCheckViewCollection" bundle:nil];
    if (self) {
        currentBill = [[Bill alloc] initWithReceipt:currentReceipt andNumberInParty:numberInParty];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.myCollectionView registerClass:[SplitCheckCollectionCell class] forCellWithReuseIdentifier:@"ReceiptCellIdentifier"];
    
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Review" style:UIBarButtonItemStylePlain target:self action:@selector(reviewChecks:)]];
    
    self.indexPathArrays = [NSArray arrayWithObject:
                       [NSIndexPath indexPathForRow:0 inSection:0]];
    self.lastItem = NO;
    self.quantityTracker = 0;
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPressGesture:)];
    
    // Setup flowlayout
    longPressGesture.minimumPressDuration = 1.5;
    [self.myCollectionView addGestureRecognizer:longPressGesture];
    myCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [myCollectionViewFlowLayout setItemSize:CGSizeMake(90, 95)];
    [myCollectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(6, 6, 6, 6)];
    [myCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.myCollectionView setCollectionViewLayout:myCollectionViewFlowLayout];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:NO];
    //work on loading the correct tax/tip data
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


////UICollectionView DataSource Methods////

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [currentBill numberOfReceipts];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ReceiptCellIdentifier";
    SplitCheckCollectionCell *cell = (SplitCheckCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.cellName.text = [NSString stringWithFormat:@"%@%i",@"#",indexPath.row+1];
    
    return cell;
}

////UICollectionView Delegate Methods////

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (lastItem) {
        return NO;
    } else {
        return YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (![self isCurrentlySplitting] && ![self isQuivering:indexPath]) {
        //[currentBill addToSplitCheck:indexPath.row fromItem:currentItemNumber];
        [currentBill calculateBill];
        [self moveToNextItemOrEnd];

        NSString *lineOne = [NSString stringWithFormat:@"Sub:   $%.02f",
                             [currentBill getReceipt:indexPath.row].subTotalValue];
        NSString *lineTwo = [NSString stringWithFormat:@"Tax:   $%.02f",
                             [currentBill getReceipt:indexPath.row].taxAmountValue];
        NSString *lineThree = [NSString stringWithFormat:@"Tip:    $%.02f",
                             [currentBill getReceipt:indexPath.row].tipAmountValue];
        NSString *lineFour = [NSString stringWithFormat:@"Total: $%.02f",
                             [currentBill getReceipt:indexPath.row].grandTotalValue];
       
        NSMutableAttributedString *currentAttributedTitle = [[NSMutableAttributedString alloc]initWithAttributedString:[((SplitCheckCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath]).totalsDisplayButton attributedTitleForState:UIControlStateNormal]];
        [currentAttributedTitle replaceCharactersInRange:(NSRange){0,[currentAttributedTitle length]} withString:[NSString stringWithFormat:@"%@ \n %@ \n %@ \n %@",lineOne,lineTwo,lineThree,lineFour]];
        [((SplitCheckCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath]).totalsDisplayButton setAttributedTitle:currentAttributedTitle forState:UIControlStateNormal];
        
        
        ((SplitCheckCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath]).selected = NO;
    }
    else if ([self isCurrentlySplitting] && ![self isQuivering:indexPath]){
        ((SplitCheckCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath]).contentView.backgroundColor = [UIColor cyanColor];
    }
    else if ([self isQuivering:indexPath]){
        [(SplitCheckCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath] stopQuivering];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!lastItem && [self isCurrentlySplitting]) {
        ((SplitCheckCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath]).contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!lastItem && ![self isCurrentlySplitting]) {
        ((SplitCheckCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath]).contentView.backgroundColor = [UIColor cyanColor];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if (!lastItem && ![self isCurrentlySplitting]) {
        ((SplitCheckCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath]).contentView.backgroundColor = [UIColor whiteColor];
    }
}

////UITableView Data Source Methods////

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Current Item";
}

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
    
    if (lastItem) {
        cell.itemNameDisplay.text = @"DONE!";
        cell.itemPriceDisplay.text = @"";
        
        //set action receivers for buttons within the cells
        [cell.splitButton setHidden:YES];
        [cell.doneButton setHidden:YES];
        return cell;
    } else {
        self.currentReceiptItem = [self.currentBill.originalReceipt getReceiptItem:currentItemNumber];
        cell.itemNameDisplay.text = currentReceiptItem.itemName;
        cell.itemPriceDisplay.text = [NSString stringWithFormat:@"%.02f",currentReceiptItem.priceValue];
        if (quantityTracker == 0) {
            quantityTracker = self.currentReceiptItem.quantityValue;
        }
        //set action receivers for buttons within the cells
        [cell.splitButton addTarget:self action:@selector(splitBetweenParties) forControlEvents:UIControlEventTouchUpInside];
        [cell.doneButton addTarget:self action:@selector(endSplitting) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

////Helper Methods////
- (void)moveToNextItemOrEnd{
    if ([self.currentBill.originalReceipt getReceiptItem:currentItemNumber].quantityValue > 1 && self.quantityTracker > 1) {
        quantityTracker--;
    } else {
        currentItemNumber++;
        if([self.currentBill.originalReceipt getReceiptItem:currentItemNumber].totalPriceValue == 0){
            lastItem = YES;
        }
        quantityTracker = 0;
    }
    [myTableView reloadRowsAtIndexPaths:indexPathArrays withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (BOOL)isCurrentlySplitting{
    ItemDisplayCell *temp = (ItemDisplayCell *)[myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (temp.splitButton.hidden == YES) {
        return YES;
    } else {
        return NO;
    }
}

- (void)splitBetweenParties{
    ItemDisplayCell *temp = (ItemDisplayCell *)[myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    temp.splitButton.hidden = YES;
    temp.doneButton.hidden = NO;
    temp.doneButton.highlighted = YES;
    for(NSIndexPath *indexPath in myCollectionView.indexPathsForSelectedItems) {
        [myCollectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
    myCollectionView.allowsMultipleSelection = YES;
}

- (void)endSplitting{
    
    //Change cell appearance
    ItemDisplayCell *temp = (ItemDisplayCell *)[myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    temp.splitButton.hidden = NO;
    temp.doneButton.hidden = YES;
    
    //determine the number of selected items
    NSArray *selectedItemsIndexPaths = [myCollectionView indexPathsForSelectedItems];
    
    for (int i = 0; i<selectedItemsIndexPaths.count; i++) {
        [[currentBill getReceipt:((NSIndexPath *)[selectedItemsIndexPaths objectAtIndex:i]).row] addReceiptItem:[currentBill.originalReceipt splitItem:currentItemNumber among:selectedItemsIndexPaths.count]];
    }

    //update totals and view after splits
    if (selectedItemsIndexPaths.count > 0) {
        [currentBill calculateBill];
        for (int i = 0; i<selectedItemsIndexPaths.count; i++) {
            
            NSString *lineOne = [NSString stringWithFormat:@"Sub:   $%.02f",
                                 [currentBill getReceipt:((NSIndexPath *)[selectedItemsIndexPaths objectAtIndex:i]).row].subTotalValue];
            NSString *lineTwo = [NSString stringWithFormat:@"Tax:   $%.02f",
                                 [currentBill getReceipt:((NSIndexPath *)[selectedItemsIndexPaths objectAtIndex:i]).row].taxAmountValue];
            NSString *lineThree = [NSString stringWithFormat:@"Tip:    $%.02f",
                                   [currentBill getReceipt:((NSIndexPath *)[selectedItemsIndexPaths objectAtIndex:i]).row].tipAmountValue];
            NSString *lineFour = [NSString stringWithFormat:@"Total: $%.02f",
                                  [currentBill getReceipt:((NSIndexPath *)[selectedItemsIndexPaths objectAtIndex:i]).row].grandTotalValue];
            
            NSMutableAttributedString *currentAttributedTitle = [[NSMutableAttributedString alloc]initWithAttributedString:[((SplitCheckCollectionCell *)[self.myCollectionView cellForItemAtIndexPath:[selectedItemsIndexPaths objectAtIndex:i]]).totalsDisplayButton attributedTitleForState:UIControlStateNormal]];
            
            [currentAttributedTitle replaceCharactersInRange:(NSRange){0,[currentAttributedTitle length]} withString:[NSString stringWithFormat:@"%@ \n %@ \n %@ \n %@",lineOne,lineTwo,lineThree,lineFour]];
            [((SplitCheckCollectionCell *)[self.myCollectionView cellForItemAtIndexPath:[selectedItemsIndexPaths objectAtIndex:i]]).totalsDisplayButton setAttributedTitle:currentAttributedTitle forState:UIControlStateNormal];

            ((SplitCheckCollectionCell *)[myCollectionView cellForItemAtIndexPath:(NSIndexPath *)[selectedItemsIndexPaths objectAtIndex:i]]).contentView.backgroundColor = [UIColor whiteColor];
        }
        for(NSIndexPath *indexPath in myCollectionView.indexPathsForSelectedItems) {
            [myCollectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        [self moveToNextItemOrEnd];
    myCollectionView.allowsMultipleSelection = NO;
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan && !lastItem) {
        CGPoint gesturePosition = [sender locationInView:self.myCollectionView];
        NSIndexPath *selectedIndexPath = [self.myCollectionView indexPathForItemAtPoint:gesturePosition];
        [(SplitCheckCollectionCell *)[myCollectionView cellForItemAtIndexPath:selectedIndexPath] startQuivering];
        
        /*
        if (![currentBill isEmpty]) {
            TestSubViewController *test = [[TestSubViewController alloc] initWithBill:currentBill onCurrentReceipt:selectedIndexPath.row];
            test.title = @"Review";
            [self.navigationController pushViewController:test animated:YES];
        
        }
         */
    }    
}

- (BOOL)isQuivering:(NSIndexPath *)indexPath{
    return((SplitCheckCollectionCell *)[myCollectionView cellForItemAtIndexPath:indexPath]).isQuivering;
}

- (void)reviewChecks:(id)sender{
    if (![currentBill isEmpty]) {
        //TestReceiptViewController *test = [[TestReceiptViewController alloc] initWithBill:currentBill];
        //test.title = @"Review";
        //[self.navigationController pushViewController:test animated:YES];
    }
}




@end
