//
//  movieLoginVC.h
//  Happening
//
//  Created by Max on 1/25/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import "FlatButton.h"

@interface movieLoginVC : UIViewController <FBSDKGraphRequestConnectionDelegate>

@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginView;

@property (strong, nonatomic) IBOutlet UIButton *questionButton;

@property (strong, nonatomic) NSString *eventIdFromNotification;

@property (strong, nonatomic) IBOutlet UIButton *noAccountButton;

@property (strong, nonatomic) IBOutlet UIButton *fbButton;

@end
