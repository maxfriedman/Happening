//
//  MyEventsTVC.h
//  Happening
//
//  Created by Max on 10/27/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
//#import "CupertinoYankee.h"
#import "showMyEventVC.h"
#import "MyEventTableCell.h"
#import "AppDelegate.h"

@interface MyEventsTVC : UITableViewController <CLLocationManagerDelegate>

@property CLLocationManager *locManager;

@property (strong, nonatomic) IBOutlet UIRefreshControl *refreshControl;

@end