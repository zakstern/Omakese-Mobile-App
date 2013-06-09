//
//  UserProfileViewController.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 5/10/13.
//  Copyright (c) 2013 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *userProfilePictureImageView;
@property (weak, nonatomic) IBOutlet UITableView *userInfoTableView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

//Data
@property (strong, nonatomic) NSMutableDictionary *userData;
@property (strong, nonatomic) NSMutableArray *userDataArray, *usageHistoryArray;
@property (strong, nonatomic) NSMutableData *imageData;

@end
