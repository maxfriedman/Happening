//
//  movieLoginVC.h
//  Happening
//
//  Created by Max on 1/25/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface movieLoginVC : UIViewController <FBLoginViewDelegate>

@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;

@property (strong, nonatomic) IBOutlet UIButton *fbButton;


@end
