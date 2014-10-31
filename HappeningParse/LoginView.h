//
//  LoginView.h
//  HappeningParse
//
//  Created by Max on 10/10/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

@interface LoginView : UIViewController <FBLoginViewDelegate>

@property (strong,nonatomic) UIActivityIndicatorView *activityView;

@end
