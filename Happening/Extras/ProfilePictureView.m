//
//  FBSDKProfilePictureView+Type.m
//  Happening
//
//  Created by Max on 8/10/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ProfilePictureView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation ProfilePictureView {
    
    UIView *containerView;
}

@synthesize cornerImv;

-(instancetype)initWithFrame:(CGRect)frame type:(NSString *)type fbid:(NSString *)fbid {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        
        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]; // initWithProfileID:user[@"FBObjectID"] pictureCropping:FBSDKProfilePictureModeSquare];
        profPicView.profileID = fbid;
        //profPicView.pictureMode = FBSDKProfilePictureModeSquare;
        
        profPicView.layer.cornerRadius = frame.size.height / 2;
        profPicView.layer.masksToBounds = YES;
        //profPicView.accessibilityIdentifier = object[@"UserID"];
        profPicView.userInteractionEnabled = YES;
        
        [self addSubview:profPicView];
        
        //[friendScrollView addSubview:profPicView];
        
        //UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(friendProfileTap:)];
        //[profPicView addGestureRecognizer:gr];
        
        containerView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width - 12, frame.size.height - 16, 16, 16)];
        containerView.clipsToBounds = YES;
        containerView.layer.cornerRadius = containerView.frame.size.height / 2;
        //containerView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        //containerView.layer.borderWidth = 2.0;
        cornerImv = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 8, 8)];
        [containerView addSubview:cornerImv];
        //[friendScrollView addSubview:containerView];
        [self addSubview:containerView];

        [self changeCornerImvToType:type];
        
    }
    
    return self;
}

-(void)changeCornerImvToType:(NSString *)type {
    
    if ([type isEqualToString:@"interested"]) {
        
        containerView.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:121.0/255 alpha:1.0];
        cornerImv.image = [UIImage imageNamed:@"timeline_swipeRight"];
        
    } else if ([type isEqualToString:@"going"]) {
        
        containerView.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:120.0/255 alpha:1.0];
        cornerImv.image = [UIImage imageNamed: @"timeline_going"];
        
    } else if ([type isEqualToString:@"create"]) {
        
        containerView.backgroundColor = [UIColor colorWithRed:245.0/255 green:184.0/255 blue:65.0/255 alpha:1.0];
        cornerImv.image = [UIImage imageNamed: @"timeline_create"];
    
    } else if ([type isEqualToString:@"notInterested"]) {
        
        containerView.backgroundColor = [UIColor redColor];
        cornerImv.image = [UIImage imageNamed:@"letter x"];
        
    }
    
}

- (void)addName:(NSString *)name {
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.font = [UIFont fontWithName:@"OpenSans" size:7];
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.frame = CGRectMake(5, 42, 30, 8);
    nameLabel.text = name;
    [self addSubview:nameLabel];
    
}

- (void)addChangeLabel {
    
    
    
}

@end
