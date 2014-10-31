//
//  SplashScreens.h
//  HappeningParse
//
//  Created by Max on 10/20/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface SplashScreens : UIViewController <CLLocationManagerDelegate>

@property (retain,nonatomic)CLLocationManager* locManager;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@end
