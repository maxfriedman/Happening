//
//  GroupPageTVCTableViewController.h
//  Happening
//
//  Created by Max on 6/4/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GroupPageTVC : UITableViewController <CLLocationManagerDelegate>

@property (assign) NSString *groupId;
@property (assign) NSString *groupName;
@property CLLocationManager *locManager;

@end
