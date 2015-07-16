//
//  DragMapViewController.h
//  Happening
//
//  Created by Max on 2/10/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface DragMapViewController : UIViewController

@property (assign) NSString *locationTitle;
@property (assign) NSString *locationSubtitle;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIButton *directionsButton;

@property (nonatomic, strong) PFObject *event;

@end
