//
//  SwipeableCardVC.h
//  Happening
//
//  Created by Max on 7/2/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "CupertinoYankee.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <EventKitUI/EventKitUI.h>
#import <EventKit/EventKit.h>
#import "AttendEvent.h"

@interface SwipeableCardVC : UIViewController <UIScrollViewDelegate, MKMapViewDelegate, MKAnnotation, EKEventEditViewDelegate>

@property NSString *eventID;
@property NSString *distanceString;
@property UIImage *image;
@property PFObject *event;

@end

#import "DraggableView.h"
@interface APActivityProvider5 : UIActivityItemProvider <UIActivityItemSource>
@property (nonatomic, strong)DraggableView *APdragView;
@end

@interface APActivityIcon5 : UIActivity
@end