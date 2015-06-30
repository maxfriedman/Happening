//
//  AppDelegate.m
//  Happening
//
//  Created by Max on 9/6/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "TabBarViewController.h"
#import "ChoosingLocation.h"
#import "RKSwipeBetweenViewControllers.h"
#import <ParseCrashReporting/ParseCrashReporting.h>
#import "DragViewController.h"
#import "MyEventsTVC.h"
#import "movieLoginVC.h"
#import "moreDetailFromTable.h"
#import <AVFoundation/AVFoundation.h>
#import "RKDropdownAlert.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize locationManager = _locationManager, item, userLocation, locSubtitle, rk;

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    //Location timestamp is within the last 15.0 seconds, let's use it!
        if(newLocation.horizontalAccuracy < 35.0){
            //Location seems pretty accurate, let's use it!
            NSLog(@"latitude %+.6f, longitude %+.6f\n",
                  newLocation.coordinate.latitude,
                  newLocation.coordinate.longitude);
            NSLog(@"Horizontal Accuracy:%f", newLocation.horizontalAccuracy);
            
            //Optional: turn off location services once we've gotten a good location
            
            PFUser *user = [PFUser currentUser];
            PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:manager.location];
            user[@"userLoc"] = loc;
            
            [manager stopUpdatingLocation];
        }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSError *error;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&error];
    if (!success) {
        //Handle error
        NSLog(@"%@", [error localizedDescription]);
    } else {
        // Yay! It worked!
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    /*
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationController class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:18], NSFontAttributeName, nil] forState:UIControlStateNormal]; */
    
    //[UINavigationController setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"OpenSans-Semibold" size:18], NSFontAttributeName, nil] forState:UIControlStateNormal];

    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans-Semibold" size:18.0],
      NSFontAttributeName,
      nil]];
    
    /*
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans-Semibold" size:18],
      NSFontAttributeName, nil]];
    */
     
    /*
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSShadowAttributeName:shadow,
       NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0]
       }
     forState:UIControlStateNormal]; */
    
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"olSntgsT5uY3ZZbJtnjNz8yvol4CxwmArTsbkCZa"
                  clientKey:@"xwmrITvs8UaFBNfBupzXcUa6HN3sU515xp1TsGxu"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    NSUUID *appID = [[NSUUID alloc] initWithUUIDString:@"337f6c52-0eb7-11e5-b8c8-aa9e2d006589"];
    self.layerClient = [LYRClient clientWithAppID:appID];
    
    if (!self.layerClient.isConnected) {
        // LayerKit is connected, no need to call connectWithCompletion:
        [self.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Failed to connect to Layer: %@", error);
            } else {
                PFUser *currentUser = [PFUser currentUser];
                if (currentUser != nil) {
                    NSString *userIDString = currentUser.objectId;
                    // Once connected, authenticate user.
                    // Check Authenticate step for authenticateLayerWithUserID source
                    [self authenticateLayerWithUserID:userIDString completion:^(BOOL success, NSError *error) {
                        if (!success) {
                            NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                        }
                    }];
                }
            }
        }];
    }

    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        NSLog(@" ====== iOS 7 ====== ");
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        
    } else {
        
        NSLog(@" ====== iOS 8 ====== ");
        
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        
        //[self.dev]
        
        if(self.locationManager==nil){
            _locationManager=[[CLLocationManager alloc] init];
            
            _locationManager.delegate=self;
            _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
            _locationManager.distanceFilter=50;
            self.locationManager=_locationManager;
        }
        
        if([CLLocationManager locationServicesEnabled]){
            [self.locationManager startUpdatingLocation];
        }
        
    }
    
    [FBSDKLoginButton class];
    
    
    if ([FBSDKAccessToken currentAccessToken]) {
        // User is logged in, do work such as go to next view controller.
        //NSLog(@"User is already logged in!");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        //rk = [storyboard instantiateViewControllerWithIdentifier:@"rk"];
        //self.window.rootViewController = rk;
        //self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"MH"];;
        
    } else {
        
        //NSLog(@"User is not logged in!");
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        movieLoginVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"movieLogin"];
        self.window.rootViewController = vc;
    }

    
    PFUser *currentUser = [PFUser currentUser];
    //NSLog(@"current user: %@", currentUser);
    
    // Tells the ViewController.m to refresh the cards in DraggableViewBackground
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"hasLaunched"])
    {
        // app already launched
        // [defaults setBool:YES forKey:@"refreshData"];
    }
    else
    {
        NSLog(@"First launch ever!");
        
        // THIS IS CRUCIAL TO MAKE CHANGES DOWN THE ROAD
        [defaults setFloat:1.03 forKey:@"version"];
        ///////////////////////////////////////////////
        
        [defaults setBool:NO forKey:@"refreshData"];
        
        [defaults setBool:NO forKey:@"hasLaunched"];
        
        [defaults setBool:NO forKey:@"hasSwipedRight"];
        
        [defaults setBool:NO forKey:@"hasCreatedEvent"];
        
        [defaults setBool:YES forKey:@"socialMode"];
        
        [defaults setInteger:0 forKey:@"categoryIndex"];
        [defaults setValue:@"Most Popular" forKey:@"categoryName"];
        
        [defaults setObject:@"" forKey:@"userLocTitle"];
        [defaults setObject:@"" forKey:@"userLocSubtitle"];
        
        [defaults setBool:YES forKey:@"today"];
        [defaults setBool:NO forKey:@"tomorrow"];
        [defaults setBool:NO forKey:@"thisWeekend"];
        
        [defaults setInteger:50 forKey:@"sliderValue"];
        
        [defaults setBool:YES forKey:@"mostPopular"];
        [defaults setBool:NO forKey:@"bestDeals"];
        
        [defaults setBool:YES forKey:@"nightlife"];
        [defaults setBool:YES forKey:@"entertainment"];
        [defaults setBool:YES forKey:@"music"];
        [defaults setBool:YES forKey:@"dining"];
        [defaults setBool:YES forKey:@"happyHour"];
        [defaults setBool:YES forKey:@"sports"];
        [defaults setBool:YES forKey:@"shopping"];
        [defaults setBool:YES forKey:@"fundraiser"];
        [defaults setBool:YES forKey:@"meetup"];
        [defaults setBool:YES forKey:@"freebies"];
        [defaults setBool:YES forKey:@"other"];
        
        [defaults setBool:NO forKey:@"noMoreEvents"];
        [defaults setBool:YES forKey:@"today"];

        
        [defaults synchronize];
        // This is the first launch ever
    }
   
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    // Create a pointer to the Photo object
    if ([notificationPayload objectForKey:@"eventID"] != nil) {
        
        NSString *eventID = [notificationPayload objectForKey:@"eventID"];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Event"];
        [query getObjectInBackgroundWithId:eventID block:^(PFObject *event, NSError *error){
            
            if (!error) {
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                moreDetailFromTable *vc = [storyboard instantiateViewControllerWithIdentifier:@"detailView"];
                UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                nvc.navigationBar.tintColor = [UIColor whiteColor];
                nvc.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
                nvc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
                nvc.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
                
                // Pass data
                vc.eventID = eventID;
                vc.titleText = event[@"Title"];
                vc.distanceText = @"0.1 mi";
                vc.subtitleText = event[@"Description"];
                vc.locationText = event[@"Location"];
                
                vc.attendEventVC = nil;
                
                PFFile *file = event[@"Image"];
                
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    
                    vc.image = [UIImage imageWithData:data];
                    
                    [rk presentViewController:nvc animated:YES completion:^{
                        
                    }];
                    
                }];
                
            } else {
                
                NSLog(@"ERROR!!!!!!");
            }
            
            
        }];
        
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreEvents"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    [FBSDKAppEvents activateApp];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"hasLaunched"])
    {
        NSLog(@"not first launch");
        // app already launched
        //[defaults setBool:YES forKey:@"refreshData"];
        //[defaults synchronize];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"That's odd"
                      otherButtonTitles:nil] show];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    
    NSLog(@"User registered for push notifications!");
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global", @"reminders", @"matches", @"friendJoined", @"popularEvents", @"matchesInApp", @"friendPush"];
    
    // Associate the device with a user
    //PFUser *user = [PFUser currentUser];
    //currentInstallation[@"userID"] = user.objectId;
    [currentInstallation saveInBackground];
    
    NSError *error;
    BOOL success = [self.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (success) {
        NSLog(@"Application did register for remote notifications");
    } else {
        NSLog(@"Error updating Layer device token for push:%@", error);
    }
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    
    //[PFPush handlePush:userInfo];
    
    NSLog(@"PUSH NOTIFICATION");
    NSLog(@"Info from push: %@", userInfo);
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        
        if ([userInfo objectForKey:@"layer"] != nil) { // layer notification
            
            NSDictionary *dict = [userInfo objectForKey:@"layer"];
    
            LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
            query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:[dict objectForKey:@"conversation_identifier"]];
            LYRConversation *conversation = [[self.layerClient executeQuery:query error:nil] firstObject];
            
            PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
            [groupQuery getObjectInBackgroundWithId: [conversation.metadata objectForKey:@"groupId"] block:^(PFObject *group, NSError *error) {
               
                NSDictionary *pushDict = [userInfo objectForKey:@"aps"];
                
                if (!error) {
                    [RKDropdownAlert title:group[@"name"] message:[pushDict objectForKey:@"alert"] backgroundColor:[UIColor colorWithRed:28.0/255 green:73.0/255 blue:134.0/255 alpha:1.0] textColor:[UIColor whiteColor]];
                }
                
            }];
            
        }
        
        
        
    }
    else {
        // Push Notification received in the background
        
        if ([userInfo objectForKey:@"eventID"] != nil) {
        
            NSString *eventID = [userInfo objectForKey:@"eventID"];

            PFQuery *query = [PFQuery queryWithClassName:@"Event"];
            [query getObjectInBackgroundWithId:eventID block:^(PFObject *event, NSError *error){
        
                if (!error) {
            
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    moreDetailFromTable *vc = [storyboard instantiateViewControllerWithIdentifier:@"detailView"];
                    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
                    nvc.navigationBar.tintColor = [UIColor whiteColor];
                    nvc.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
                    nvc.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
                    nvc.modalPresentationStyle = UIModalTransitionStyleCrossDissolve;
                
                    // Pass data
                    vc.eventID = eventID;
                    vc.titleText = event[@"Title"];
                    vc.distanceText = @"0.1 mi";
                    vc.subtitleText = event[@"Description"];
                    vc.locationText = event[@"Location"];
                
                    vc.attendEventVC = nil;
                
                    PFFile *file = event[@"Image"];
                
                        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                    
                            vc.image = [UIImage imageWithData:data];
                    
                            [rk presentViewController:nvc animated:YES completion:^{
                        
                            }];
                    
                        }];
                
                } else {
                
                    NSLog(@"ERROR!!!!!!");
                }

            
            }];
        }
    }
}

- (void)authenticateLayerWithUserID:(NSString *)userID completion:(void (^)(BOOL success, NSError * error))completion
{
    // Check to see if the layerClient is already authenticated.
    if (self.layerClient.authenticatedUserID) {
        // If the layerClient is authenticated with the requested userID, complete the authentication process.
        if ([self.layerClient.authenticatedUserID isEqualToString:userID]){
            NSLog(@"Layer Authenticated as User %@", self.layerClient.authenticatedUserID);
            if (completion) completion(YES, nil);
            return;
        } else {
            //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
            [self.layerClient deauthenticateWithCompletion:^(BOOL success, NSError *error) {
                if (!error){
                    [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
                        if (completion){
                            completion(success, error);
                        }
                    }];
                } else {
                    if (completion){
                        completion(NO, error);
                    }
                }
            }];
        }
    } else {
        // If the layerClient isn't already authenticated, then authenticate.
        [self authenticationTokenWithUserId:userID completion:^(BOOL success, NSError *error) {
            if (completion){
                completion(success, error);
            }
        }];
    }
}

- (void)authenticationTokenWithUserId:(NSString *)userID completion:(void (^)(BOOL success, NSError* error))completion{
    
    /*
     * 1. Request an authentication Nonce from Layer
     */
    [self.layerClient requestAuthenticationNonceWithCompletion:^(NSString *nonce, NSError *error) {
        if (!nonce) {
            if (completion) {
                completion(NO, error);
            }
            return;
        }
        
        /*
         * 2. Acquire identity Token from Layer Identity Service
         */
        NSDictionary *parameters = @{@"nonce" : nonce, @"userID" : userID};

        [PFCloud callFunctionInBackground:@"generateToken" withParameters:parameters block:^(id object, NSError *error) {
            if (!error){
                
                NSString *identityToken = (NSString*)object;
                [self.layerClient authenticateWithIdentityToken:identityToken completion:^(NSString *authenticatedUserID, NSError *error) {
                    if (authenticatedUserID) {
                        if (completion) {
                            completion(YES, nil);
                        }
                        NSLog(@"Layer Authenticated as User: %@", authenticatedUserID);
                    } else {
                        completion(NO, error);
                    }
                }];
            } else {
                NSLog(@"Parse Cloud function failed to be called to generate token with error: %@", error);
            }
        }];
    }];
}

@end