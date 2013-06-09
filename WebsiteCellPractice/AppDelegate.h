//
//  AppDelegate.h
//  WebsiteCellPractice
//
//  Created by Zak Stern on 12/12/29.
//  Copyright (c) 2012年 Zak Stern. All rights reserved.
//

#import <UIKit/UIKit.h>
extern NSString *const SCSessionStateChangedNotification;

@class SetupViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SetupViewController *viewController;
@property (strong, nonatomic) UINavigationController *navController;

@end
