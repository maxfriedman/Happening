//
//  ExternalProfileTVC.h
//  Happening
//
//  Created by Max on 2/8/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ExternalProfileTVC : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *segContainerView;
@property (strong, nonatomic) IBOutlet UIButton *scoreButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

@property CLLocationManager *locManager;

@property (strong, nonatomic) NSString *eventID;
@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *fbID;

@end
