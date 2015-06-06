//
//  AttendEvent.h
//  Happening
//
//  Created by Max on 10/5/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CupertinoYankee.h"


@interface AttendEvent : UITableViewController <CLLocationManagerDelegate>

@property CLLocationManager *locManager;
@property (strong, nonatomic) IBOutlet UIButton *locationField;

-(void)showNavTitle;
-(void)loadData;

@end
