//
//  GroupPageTVCTableViewController.h
//  Happening
//
//  Created by Max on 6/4/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Atlas/Atlas.h>
#import <Parse/Parse.h>

@interface GroupPageTVC : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *chatBubble;
@property (assign) NSString *groupId;
@property (assign) NSString *groupName;
@property (strong, nonatomic) PFObject *group;
@property CLLocationManager *locManager;
@property (nonatomic, strong) LYRConversation *conversation;
@property (assign) BOOL showDetails;
@property (assign) BOOL groupDidLoad;

@property (assign) BOOL loadTopView;

@property (nonatomic, strong) NSArray *userDicts;

@property (strong, nonatomic) IBOutlet UIView *containerView;

@end
