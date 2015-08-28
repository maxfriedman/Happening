//
//  ExpandedCardVC.h
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
#import <LayerKit/LayerKit.h>

@protocol ExpandedCardVCDelegate <NSObject>

- (void)didChangeRSVP;

@end

@interface ExpandedCardVC : UIViewController <UIScrollViewDelegate, MKMapViewDelegate, MKAnnotation, EKEventEditViewDelegate>

@property (weak) id <ExpandedCardVCDelegate> delegate;

@property (nonatomic, strong) NSString *eventID;
@property (nonatomic, strong) NSString *distanceString;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) PFObject *event;

@property BOOL isFromGroup;
@property (nonatomic, strong) PFObject *rsvpObject;
@property (nonatomic, strong) PFObject *groupObject;
@property (nonatomic, strong) PFObject *groupEventObject;
@property (nonatomic, strong) LYRConversation *convo;
@property (nonatomic, strong) NSArray *fbids;

@property BOOL presentedAsModal;

@end
