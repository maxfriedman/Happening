//
//  LoginView.h
//  HappeningParse
//
//  Created by Max on 10/10/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "DragViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginView : UIViewController <FBLoginViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate>

@property (strong,nonatomic) UIActivityIndicatorView *activityView;

@property (strong, nonatomic) IBOutlet UIPickerView *cityPicker;

@property (strong, nonatomic) IBOutlet UILabel *inLabel;

@property (strong, nonatomic) IBOutlet UIButton *xButton;

@end
