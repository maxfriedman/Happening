//
//  NewGroupCreatorVC.h
//  Happening
//
//  Created by Max on 6/4/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import "inviteHomies.h"
#import "InviteHomiesToGroup.h"

@interface NewGroupCreatorVC : UIViewController

@property (strong, nonatomic) IBOutlet UIView *avatarContainerView;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *bigProfPicView;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *smallTopProfPicView;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *smallBottomProfPicView;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *createButton;
@property PFObject *event;

@property (assign) NSString *eventId;
@property NSArray *userIdArray;
@property (assign) int memCount;
@property (assign) BOOL fromGroupsTab;

@property inviteHomies *inviteHomies;
@property InviteHomiesToGroup *inviteHomiesToGroup;

@end
