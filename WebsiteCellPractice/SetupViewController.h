//
//  SetupViewController.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 5/10/13.
//  Copyright (c) 2013 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SetupViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, NSURLConnectionDelegate>

//UIElements
@property (weak, nonatomic) IBOutlet UIImageView *omakaseLogo;
@property (weak, nonatomic) IBOutlet UITableView *createOrJoinTableView;
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

//Data
@property (strong, nonatomic) NSMutableData *imageData;

@end
