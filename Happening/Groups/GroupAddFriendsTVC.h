//
//  GroupAddFriendsTVC.h
//  Happening
//
//  Created by Max on 6/24/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Atlas/Atlas.h>
#import <Parse/Parse.h>

@interface GroupAddFriendsTVC : UITableViewController

@property (nonatomic, retain) UIView *namesOnBottomView;
@property LYRConversation *convo;
@property PFObject *group;

@end
