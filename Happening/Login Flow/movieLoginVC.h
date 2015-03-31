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

@interface movieLoginVC : UIViewController <FBSDKGraphRequestConnectionDelegate>

@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginView;

@property (strong, nonatomic) IBOutlet UIButton *fbButton;
@property (strong, nonatomic) IBOutlet UIButton *questionButton;


@end
