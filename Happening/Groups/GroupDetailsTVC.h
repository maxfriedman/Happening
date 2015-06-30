//
//  GroupDetailsTVC.h
//  Happening
//
//  Created by Max on 6/15/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Atlas/Atlas.h>

@interface GroupDetailsTVC : UITableViewController

@property PFObject *group;
@property (strong, nonatomic) IBOutlet UIImageView *groupImageView;
@property (strong, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (assign) NSString *groupNameString;
@property NSMutableArray *users;
@property LYRConversation *convo;

@end
