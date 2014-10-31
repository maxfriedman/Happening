//
//  AttendEvent.h
//  HappeningParse
//
//  Created by Max on 10/5/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "NSDate+CupertinoYankee.h"


@interface AttendEvent : UITableViewController <CLLocationManagerDelegate>

@property CLLocationManager *locManager;

@end
