//
//  UserProfileViewController.m
//  WebsiteCellPractice
//
//  Created by Zak Stern on 5/10/13.
//  Copyright (c) 2013 Zak Stern. All rights reserved.
//

#import "UserProfileViewController.h"
#import "SetupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface UserProfileViewController ()

@end

@implementation UserProfileViewController
@synthesize userProfilePictureImageView,userInfoTableView,userData,imageData,userDataArray,userNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.usageHistoryArray = [[NSMutableArray alloc] init];
    self.userDataArray = [[NSMutableArray alloc] init];
    //load this user's usage history
    [self.usageHistoryArray addObject:@"Bills Split:"];
    [self.usageHistoryArray addObject:@"Favorite Restaurant:"];
    [self.usageHistoryArray addObject:@"Favorite Meal:"];
    [self.usageHistoryArray addObject:@"Favorite Drink:"];
    [self.userDataArray addObject:@"Bills Split:"];
    [self.userDataArray addObject:@"Favorite Restaurant:"];
    [self.userDataArray addObject:@"Favorite Meal:"];
    [self.userDataArray addObject:@"Favorite Drink:"];
    
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            userData = (NSMutableDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            NSString *location = userData[@"location"][@"name"];
            [self.userDataArray addObject:location];
            NSString *birthday = userData[@"birthday"];
            [self.userDataArray addObject:birthday];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            // Download the user's facebook profile picture
            imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
            
            // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
            
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:2.0f];
            // Run network request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            
            //set name
            self.userNameLabel.text = name;
        }
    }];
    [self.userInfoTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//UITableViewDataSource Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"UserInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = (NSString *)[self.userDataArray objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = (NSString *)[self.usageHistoryArray objectAtIndex:indexPath.row];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"User Info";
    } else {
        return @"Usage History";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    } else {
        return 4;
    }
}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [imageData appendData:data]; // Build the image
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
    self.userProfilePictureImageView.image = [UIImage imageWithData:imageData];
    
    //Set up image border and corners
    CALayer * l = [self.userProfilePictureImageView layer];
    [l setMasksToBounds:YES];
    float dim = MIN(self.userProfilePictureImageView.bounds.size.width, self.userProfilePictureImageView.bounds.size.height);
    [l setCornerRadius:dim/8];
    self.userProfilePictureImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userProfilePictureImageView.layer.borderWidth = 3.0f;
    
    //Add gesture recognizer on image
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc]
                                                      initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGesture.minimumPressDuration = 1.2;
    [self.userProfilePictureImageView addGestureRecognizer:longPressGesture];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender{
    //change picture
}

@end
