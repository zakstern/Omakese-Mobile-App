//
//  TestSubViewController.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 13/01/10.
//  Copyright (c) 2013年 Zak Stern. All rights reserved.
//

#import "TestSubViewController.h"
#import <Parse/Parse.h>

@interface TestSubViewController ()

@end

@implementation TestSubViewController
@synthesize segmentControl, displayTableView, currentBill, checkNumberString,displayReceipts,initialReceiptNumber,collectionView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithBill:(Bill *)splitBill{
    self = [super initWithNibName:@"TestSubViewController" bundle:nil];
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
    return self;
}

- (id)initWithBill:(Bill *)splitBill onCurrentReceipt:(int)currentReceiptNumber{
    self = [super initWithNibName:@"TestSubViewController" bundle:nil];
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
    initialReceiptNumber = currentReceiptNumber;
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Back"
                                   style: UIBarButtonItemStyleBordered
                                   target: nil action: nil];    
    [self.navigationItem setBackBarButtonItem: backButton];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Save"
                                   style: UIBarButtonItemStylePlain
                                   target: self action:@selector(saveBill)];
    
    [self.navigationItem setBackBarButtonItem: backButton];
    [self.navigationItem setRightBarButtonItem: saveButton];
    [self setupSegmentControl:[currentBill numberOfNonEmptyReceipts]];
    checkNumberString = @"Check #";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSegmentControl:(int)numberOfSegments{
    [segmentControl removeAllSegments];
    for (int i = 0; i<numberOfSegments; i++) {
        [segmentControl insertSegmentWithTitle:[NSString stringWithFormat:@"%i",i+1] atIndex:i animated:NO];
    }
    [segmentControl setSelectedSegmentIndex:initialReceiptNumber];
}

//USER RESPONSE ACTIONS

- (IBAction)switchReceipt:(id)sender {
    [self.displayTableView reloadData];
}

//TABLEVIEW DELEGATE METHODS

//sets the number of sections in a table view
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

//sets the number of rows in a section of the tableview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return [currentBill getNumberOfReceiptItemsFrom:[segmentControl selectedSegmentIndex]];
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
    int receiptNumber = [segmentControl selectedSegmentIndex];
    self.navigationItem.title = [NSString stringWithFormat:@"%@%i",checkNumberString,[segmentControl selectedSegmentIndex]+1];
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

-(void)saveBill{
    SplitCheckViewCollection *test = [[SplitCheckViewCollection alloc] init];
    //test.title = @"Review";
    [self.navigationController pushViewController:test animated:YES];
    
    /*
    NSNumber *test = [[NSNumber alloc] initWithInt:[currentBill numberOfChecks]];
    PFObject *bill = [PFObject objectWithClassName:@"Bill"];
    [bill setObject:test forKey:@"numberOfChecks"];
    [bill setObject:[currentBill originalReceipt] forKey:@"originalReceipt"];
    [bill setObject:[currentBill splitReceiptsArray] forKey:@"splitReceiptsArray"];
    [bill save];
    */
}

@end
