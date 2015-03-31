//
//  NotificationsTVC.h
//  Happening
//
//  Created by Max on 3/19/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationsTVC : UITableViewController

@property (strong, nonatomic) IBOutlet UISwitch *inAppMatches;
@property (strong, nonatomic) IBOutlet UISwitch *popular;
@property (strong, nonatomic) IBOutlet UISwitch *pushMatches;
@property (strong, nonatomic) IBOutlet UISwitch *reminders;
@property (strong, nonatomic) IBOutlet UISwitch *friendJoined;

@end
