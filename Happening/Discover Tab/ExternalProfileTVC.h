//
//  ExternalProfileTVC.h
//  Happening
//
//  Created by Max on 2/14/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ExternalProfileTVC : UITableViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UITableView *myEventsTableView;
@property (strong, nonatomic) IBOutlet UILabel *nameEventsLabel;
@property (strong, nonatomic) IBOutlet UIButton *starButton;

@property CLLocationManager *locManager;

@property (assign) NSString *eventID;
@property (assign) NSString *userID;


@end
