//
//  AppDelegate.h
//  Happening
//
//  Created by Max on 9/6/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "RKSwipeBetweenViewControllers.h"
#import "MHCustomTabBarController.h"
#import <LayerKit/LayerKit.h>
#import <LocationKit/LocationKit.h>
#import <Rdio/Rdio.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, LocationKitDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) MKMapItem *item;

@property (strong, nonatomic) MKMapItem *userLocation;

@property (strong, nonatomic) NSString *locSubtitle;

@property int sliderValue;

@property BOOL wasHandled;

@property (strong, nonatomic) RKSwipeBetweenViewControllers *rk;
@property (strong, nonatomic) MHCustomTabBarController *mh;

@property (nonatomic) LYRClient *layerClient;

- (void)authenticateLayerWithUserID:(NSString *)userID completion:(void (^)(BOOL success, NSError * error))completion;
- (void)loadGroups;
- (void)loadEvents;

+ (Rdio *)sharedRdio;

@end

