//
//  LogInExistingUser.h
//  HappeningParse
//
//  Created by Max on 11/10/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "AppDelegate.h"

@interface LogInExistingUser : UIViewController <UINavigationControllerDelegate, FBSDKGraphRequestConnectionDelegate, FBSDKLoginButtonDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *fbLoginView;

@property (strong,nonatomic) UIActivityIndicatorView *activityView;

@property (strong, nonatomic) IBOutlet UIPickerView *cityPicker;

@property (strong, nonatomic) IBOutlet UILabel *inLabel;

@property (strong, nonatomic) IBOutlet UIButton *xButton;

@end
