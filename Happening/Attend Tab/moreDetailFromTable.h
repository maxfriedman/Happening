//
//  moreDetailFromTable.h
//  Happening
//
//  Created by Max on 12/1/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "CupertinoYankee.h"
#import <FacebookSDK/FacebookSDK.h>

@interface moreDetailFromTable : UIViewController <UIScrollViewDelegate, MKMapViewDelegate, MKAnnotation>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (strong, nonatomic) IBOutlet UILabel *eventIDLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIImageView *locationImageView;

@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

@property (strong, nonatomic) IBOutlet UILabel *interestedLabel;
@property (strong, nonatomic) IBOutlet UILabel *friendsInterestedLabel;

@property (strong, nonatomic) IBOutlet UIView *cardView;

@property (strong, nonatomic) IBOutlet UIScrollView *friendScrollView;

@property NSString *eventID;
@property NSString *titleText;
@property NSString *subtitleText;
@property NSString *timeText;
@property NSString *distanceText;
@property NSString *locationText;
@property UIImage *image;

@end

#import "DraggableView.h"
@interface APActivityProvider2 : UIActivityItemProvider <UIActivityItemSource>
@property (nonatomic, strong)DraggableView *APdragView;
@end

@interface APActivityIcon2 : UIActivity
@end

