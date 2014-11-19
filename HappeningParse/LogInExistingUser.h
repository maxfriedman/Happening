//
//  LogInExistingUser.h
//  HappeningParse
//
//  Created by Max on 11/10/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

@interface LogInExistingUser : UIViewController <UINavigationControllerDelegate, FBLoginViewDelegate>

@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;

@property (strong,nonatomic) UIActivityIndicatorView *activityView;

@end
