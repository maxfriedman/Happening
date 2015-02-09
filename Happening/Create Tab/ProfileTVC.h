//
//  ProfileTVC.h
//  Happening
//
//  Created by Max on 2/8/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ProfileTVC : UITableViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@property (strong, nonatomic) IBOutlet UITableView *myEventsTableView;

@property CLLocationManager *locManager;

@end
