//
//  FullReceiptViewController.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/02/01.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "FullReceiptViewController.h"

@interface FullReceiptViewController ()

@end

@implementation FullReceiptViewController

@synthesize myCollectionView,myCollectionViewFlowLayout,currentBill,checkNumberString,initialReceiptNumber,customTableCell,taxAndTotalCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithBill:(Bill *)splitBill{
    self = [super initWithNibName:@"FullReceiptViewController" bundle:nil];
    if (self) {
        currentBill = [[Bill alloc] init];
        currentBill.splitReceiptsArray = [[NSMutableArray alloc] initWithArray:splitBill.splitReceiptsArray];
        currentBill.originalReceipt = splitBill.originalReceipt;
        for (int i=0; i<[currentBill.splitReceiptsArray count]; i++) {
            if ([currentBill isEmptyAtReceiptNumber:i]) {
                [currentBill removeReceiptAtIndex:i];
                i--;
            }
        }
        
    }
    return self;
}
/*
- (id)initWithBill:(Bill *)splitBill onCurrentReceipt:(int)currentReceiptNumber{
    self = [super initWithNibName:@"FullReceiptViewController" bundle:nil];
    if (self) {
        currentBill = [[Bill alloc] init];
        currentBill.splitReceiptsArray = [[NSMutableArray alloc] initWithArray:splitBill.splitReceiptsArray];
        currentBill.numberOfChecks = splitBill.numberOfChecks;
        currentBill.originalReceipt = splitBill.originalReceipt;
        for (int i=0; i<[currentBill.splitReceiptsArray count]; i++) {
            if ([currentBill isEmptyAtReceiptNumber:i]) {
                [currentBill removeReceiptAtIndex:i];
                i--;
            }
        }
    }
    self.initialReceiptNumber = currentReceiptNumber;
    return self;
}
*/



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.myCollectionView registerClass:[FullReceiptCell class] forCellWithReuseIdentifier:@"FullReceipt"];
    //[self.myCollectionView registerNib:[UINib nibWithNibName:@"FullReceiptCell" bundle:nil]  forCellWithReuseIdentifier:@"FullReceipt"];
    
    self.myCollectionView.pagingEnabled = YES;
    // Setup flowlayout
    
    self.myCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.myCollectionViewFlowLayout setItemSize:CGSizeMake(310, 410)];
    [self.myCollectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.myCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.myCollectionViewFlowLayout.minimumLineSpacing = 0;
    self.myCollectionViewFlowLayout.minimumInteritemSpacing = 0;
    [self.myCollectionView setCollectionViewLayout:myCollectionViewFlowLayout];
    //testing to see if the collection view is loading
    self.myCollectionView.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    /*
    self.myCollectionView.pagingEnabled = YES;
    // Setup flowlayout
    self.myCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.myCollectionViewFlowLayout setItemSize:CGSizeMake(320, 548)];
    [self.myCollectionViewFlowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.myCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.myCollectionViewFlowLayout.minimumLineSpacing = 0;
    self.myCollectionViewFlowLayout.minimumInteritemSpacing = 0;
    [self.myCollectionView setCollectionViewLayout:myCollectionViewFlowLayout];
     */
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
    static NSString *cellIdentifier = @"FullReceipt";
    FullReceiptCell *cell = (FullReceiptCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    //FullReceiptCell *cell = [NSBundle.mainBundle loadNibNamed:@"FullReceiptCell" owner:self options:nil][0];
    return cell;
}


////Table View Delegate and Datasource Methods////

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

//sets the number of rows in a section of the tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [currentBill getNumberOfReceiptItemsFrom:[myCollectionView indexPathForCell:((FullReceiptCell *)tableView.superview)].row];
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
    int receiptNumber = [myCollectionView indexPathForCell:((FullReceiptCell *)tableView.superview)].row;
    NSLog(@"at item:%i",receiptNumber);
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
        
        //load data into item cells
        /*
         while ([currentBill isEmptyAtReceiptNumber:receiptNumber]) {
         receiptNumber++;
         }
         */
        
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
        
        return cell;
    }
}


@end
