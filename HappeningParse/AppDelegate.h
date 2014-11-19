//
//  AppDelegate.h
//  HappeningParse
//
//  Created by Max on 9/6/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <AddressBook/AddressBook.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) MKMapItem *item;

@property (strong, nonatomic) MKMapItem *userLocation;

@property int sliderValue;

@end

