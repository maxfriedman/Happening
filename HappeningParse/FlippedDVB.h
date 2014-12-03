//
//  FlippedDVB.h
//  HappeningParse
//
//  Created by Max on 12/1/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DragViewController.h"

@interface FlippedDVB : UIView <MKMapViewDelegate, MKAnnotation>

@property (nonatomic, weak) DragViewController *viewController;

@property NSString *eventID;
@property NSString *eventTitle;
@property NSString *eventLocationTitle;
@property (nonatomic, strong) CLLocation *mapLocation;
@property (nonatomic, strong) UILabel *titleLabel;

@end
