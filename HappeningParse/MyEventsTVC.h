//
//  MyEventsTVC.h
//  HappeningParse
//
//  Created by Max on 10/27/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NSDate+CupertinoYankee.h"
#import "showMyEventVC.h"
#import "AttendTableCell.h"
#import "AppDelegate.h"

@interface MyEventsTVC : UITableViewController <CLLocationManagerDelegate>

@property CLLocationManager *locManager;

@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;

@end
