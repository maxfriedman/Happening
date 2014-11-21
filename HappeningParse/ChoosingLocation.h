//
//  ChoosingLocation.h
//  HappeningParse
//
//  Created by Max on 11/7/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface ChoosingLocation : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *currentLocButton;
@property (strong, nonatomic) IBOutlet UIButton *choosingLocButton;

@property (strong, nonatomic)CLLocationManager* locManager;

@property (strong, nonatomic) IBOutlet UIButton *continueButton;

@end
