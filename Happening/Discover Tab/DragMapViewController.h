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

@interface DragMapViewController : UIViewController

@property (assign) NSString *objectID;
@property (assign) NSString *locationTitle;
@property (assign) NSString *locationSubtitle;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *directionsButton;

@end
