//
//  TestReceiptViewController.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/02/03.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "TestReceiptViewController.h"
#import "TestReceiptCell.h"

@interface TestReceiptViewController ()

@end

@implementation TestReceiptViewController

@synthesize myCollectionView,myCollectionViewFlowLayout,currentBill,displayReceipts,customTableCell,taxAndTotalCell,indexPathForInitialReceiptNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithBill:(Bill *)splitBill andShowInitialReceiptNumberAtIndexPath:(NSIndexPath *)initialReceiptIndexPath{
    self = [super initWithNibName:@"TestReceiptViewController" bundle:nil];
    if (self) {
        self.indexPathForInitialReceiptNumber = initialReceiptIndexPath;
        self.currentBill = [[Bill alloc] init];
        self.currentBill.splitReceiptsArray = [[NSMutableArray alloc] initWithArray:splitBill.splitReceiptsArray];
        self.currentBill.originalReceipt = splitBill.originalReceipt;
        for (int i=0; i<[self.currentBill numberOfReceipts]; i++) {
            if ([self.currentBill isEmptyAtReceiptNumber:i]) {
                [self.currentBill removeReceiptAtIndex:i];
                i--;
            }
        }
    }
    return self;
}

////View Setup Methods////
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.myCollectionView registerClass:[TestReceiptCell class] forCellWithReuseIdentifier:@"TestReceiptCell"];
    self.myCollectionView.pagingEnabled = YES;
    [self.myCollectionView scrollToItemAtIndexPath:self.indexPathForInitialReceiptNumber atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
	// Do any additional setup after loading the view.
    [((TestReceiptCell *)[self.myCollectionView cellForItemAtIndexPath:(NSIndexPath *)[[self.myCollectionView indexPathsForVisibleItems] objectAtIndex:0]]).myTableView reloadData];
}

////UICollectionView Data Source Methods////

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [currentBill numberOfReceipts];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TestReceiptCell";
    TestReceiptCell *cell = (TestReceiptCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.myTableView.dataSource = self;
    cell.myTableView.delegate = self;
    return cell;
}


////Table View Datasource Methods////
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [currentBill getNumberOfReceiptItemsFrom:[myCollectionView indexPathForCell:((FullReceiptCell *)tableView.superview.superview)].row];
        
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath section] == 0) {
        return 44;
    }
    else{
        return 87;
    }
}

//reuses or creates cells and loads them in to rows
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int receiptNumber = [myCollectionView indexPathForCell:((FullReceiptCell *)tableView.superview.superview)].row;
    //self.navigationItem.title = [NSString stringWithFormat:@"%@%i",checkNumberString,[segmentControl selectedSegmentIndex]+1];
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
        [cell.itemTextField setUserInteractionEnabled:NO];
        [cell.quantityTextField setUserInteractionEnabled:NO];
        [cell.priceTextField setUserInteractionEnabled:NO];
        cell.itemTextField.text = [currentBill getReceiptItemFrom:receiptNumber atItemIndex:[indexPath row]].itemName;
        cell.quantityTextField.text =[NSString stringWithFormat:@"%i",
                                      [currentBill getReceiptItemFrom:receiptNumber
                                                          atItemIndex:[indexPath row]].quantityValue];
        cell.priceTextField.text = [NSString stringWithFormat:@"%.02f",
                                    [currentBill getReceiptItemFrom:receiptNumber
                                                        atItemIndex:[indexPath row]].priceValue];
        return cell;
    }
    
    else {
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
        cell.subTotalTextField.text = [NSString stringWithFormat:@"%.02f",[[currentBill getReceipt:receiptNumber] subTotalValue]];
        cell.taxTextField.text = [NSString stringWithFormat:@"%.02f",[[currentBill getReceipt:receiptNumber] taxAmountValue]];
        cell.tipTextField.text = [NSString stringWithFormat:@"%.02f",[[currentBill getReceipt:receiptNumber] tipAmountValue]];
        cell.totalTextField.text = [NSString stringWithFormat:@"%.02f",[[currentBill getReceipt:receiptNumber] grandTotalValue]];
        
        //set action receivers for buttons within the cells and cell title
        [cell updateEditTax:[self.currentBill getReceipt:receiptNumber].taxPercentage OrTipButton:[self.currentBill getReceipt:receiptNumber].tipPercentage];
        [cell.editTaxOrTipButton addTarget:self action:@selector(editTaxOrTip) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

////User Response Actions////
- (void)editTaxOrTip{
    //ChangeTipOrTax *changeTipOrTaxPage = [[ChangeTipOrTax alloc] initWithReceipt:[currentBill getReceipt:[self numberofCurrentlyVisibleReceipt]]];
    //[self presentViewController:changeTipOrTaxPage animated:YES completion:NULL];
}


////Helper Method////

- (int)numberofCurrentlyVisibleReceipt{
    return ((NSIndexPath *)[[self.myCollectionView indexPathsForVisibleItems] objectAtIndex:0]).row;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
