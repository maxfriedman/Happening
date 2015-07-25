//
//  GroupRSVP.h
//  Happening
//
//  Created by Max on 6/8/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import <Atlas/Atlas.h>

@interface GroupRSVP : UITableViewController

@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *myProfPicView;
@property (strong, nonatomic) IBOutlet UIButton *goingButton;
@property (strong, nonatomic) IBOutlet UIButton *notGoingButton;

@property (strong, nonatomic) NSMutableArray *yesUsers;
@property (strong, nonatomic) NSMutableArray *noUsers;
@property (strong, nonatomic) NSMutableArray *maybeUsers;

@property PFObject *group;
@property PFObject *groupEventObject;
@property PFObject *eventObject;

@property NSString *titleString;
@property LYRConversation *convo;

@property (assign) NSArray *userDicts;

@end
