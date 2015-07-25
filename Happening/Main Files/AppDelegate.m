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
#import <Hoko/Hoko.h>
#import <Hoko/HOKNavigation.h>
#import <Button/Button.h>
#import "SwipeableCardVC.h"
#import <Bolts/Bolts.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize locationManager = _locationManager, item, userLocation, locSubtitle, rk;

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
    
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans-Semibold" size:18.0],
      NSFontAttributeName,
      nil]];
    
    /*
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSShadowAttributeName:shadow,
       NSFontAttributeName:[UIFont boldSystemFontOfSize:12.0]
       }
     forState:UIControlStateNormal]; */
    
    [ParseCrashReporting enable];
    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"olSntgsT5uY3ZZbJtnjNz8yvol4CxwmArTsbkCZa"
                  clientKey:@"xwmrITvs8UaFBNfBupzXcUa6HN3sU515xp1TsGxu"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFUser enableAutomaticUser];
    
    NSURL *appID = [NSURL URLWithString:@"layer:///apps/staging/337f6c52-0eb7-11e5-b8c8-aa9e2d006589"];
    self.layerClient = [LYRClient clientWithAppID:appID];
    
    [Hoko setupWithToken:@"b649dec47382a7b855b46077d2cfbb6968e7e81b"];
    
    BOOL locEnabled = NO;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        NSLog(@" ====== iOS 7 ====== ");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) locEnabled = YES;
    } else {
        NSLog(@" ====== iOS 8 ====== ");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) locEnabled = YES;
    }
    
    if (locEnabled) {
        NSLog(@"Initializing Location Kit...");
        [[LocationKit sharedInstance] startWithApiToken:@"48ced72017ecb03b" andDelegate:self];
    }
    
    [[Button sharedButton] configureWithApplicationId:@"app-070dce57d47ec28b" completion:NULL];
    [BTNLocationManager allowButtonToRequestLocationPermission:YES];

    //[[BTNDropinButton appearance] setContentInsets:UIEdgeInsetsMake(0, -1, 0.0, 0)];
    [[BTNDropinButton appearance] setContentInsets:UIEdgeInsetsMake(0, 6, 0.0, 0)];
    [[BTNDropinButton appearance] setIconSize:20.0];
    [[BTNDropinButton appearance] setIconLabelSpacing:8.0];
    [[BTNDropinButton appearance] setFont:[UIFont fontWithName:@"OpenSans" size:14.0]];
    [[BTNDropinButton appearance] setTextColor:[UIColor darkTextColor]];
    
    [[BTNDropinButton appearance] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    //[[BTNDropinButton appearance] setIconColor:[UIColor blackColor] ];
    
    [[BTNDropinButton appearance] setCornerRadius:7.0];
    [[BTNDropinButton appearance] setBorderColor:[UIColor groupTableViewBackgroundColor]];
    [[BTNDropinButton appearance] setBorderWidth:1.0];
    
    [[BTNDropinButton appearance] setHighlightedBackgroundColor:[UIColor grayColor]];
    [[BTNDropinButton appearance] setNormalBackgroundColor:[UIColor groupTableViewBackgroundColor]];

    PFUser *currentUser = [PFUser currentUser];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        NSLog(@" ====== iOS 7 ====== ");
        
        UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        
        if (enabledTypes) {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        }
        
    } else {
        
        NSLog(@" ====== iOS 8 ====== ");
        
        if ([application isRegisteredForRemoteNotifications]) {

            UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                            UIUserNotificationTypeBadge |
                                                            UIUserNotificationTypeSound);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                     categories:nil];
            [application registerUserNotificationSettings:settings];
            [application registerForRemoteNotifications];
        }
        
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
    
    //[PFObject unpinAllObjects];

    [FBSDKLoginButton class];
    
    // Tells the ViewController.m to refresh the cards in DraggableViewBackground
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([currentUser[@"hasLoggedIn"] boolValue] == YES && currentUser.isAuthenticated)
    {
        // app already launched
        // [defaults setBool:YES forKey:@"refreshData"];
        
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

    } else {
        
        //[PFObject unpinAllObjects];
        
        // This is the first launch ever
    }

    //self.mh.eventIdForSegue = eventID;
    //[self.mh performSegueWithIdentifier:@"toSwipeVC" sender:self.mh];
    
    [PFUser currentUser][@"latestVersion"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //NSLog(@"User is not logged in!");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    movieLoginVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"movieLogin"];
    self.window.rootViewController = vc;
    //vc.eventIdFromNotification = @"wKhr50fk50";
    
    [[Hoko deeplinking] mapRoute:@"events/:EventID"
                        toTarget:^(HOKDeeplink *deeplink) {
                            // Do something when deeplink is opened
                            
                            NSLog(@"%@", deeplink);
                            UINavigationController *nvc = [storyboard instantiateViewControllerWithIdentifier:@"SwipeVCNav"];
                            SwipeableCardVC *vc = (SwipeableCardVC *)[nvc topViewController];
                            vc.eventID = deeplink.routeParameters[@"EventID"];
                            [HOKNavigation presentViewController:nvc animated:YES];
                        }];
    
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload != nil) {
    
        NSLog(@"Launching with notification");
        
        if ([notificationPayload objectForKey:@"eventID"] != nil) {
            
            NSString *eventID = [notificationPayload objectForKey:@"eventID"];
            vc.eventIdFromNotification = eventID;
            
        }
        
    }
    
    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if ([[Button sharedButton] handleLocalNotification:localNotification]) {
        [[Button sharedButton] handleLocalNotification:localNotification];
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
    
    [[PFUser currentUser] saveEventually];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    [FBSDKAppEvents activateApp];
    
    //[PFObject unpinAllObjects];
    
    if ([[PFUser currentUser][@"hasLoggedIn"] boolValue] == YES)
    {
        NSLog(@"not first launch");
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            if (currentInstallation.badge != 0) {
                currentInstallation.badge = 0;
                [currentInstallation saveEventually];
            }
            
            [self loadFriends];
            
            [self loadEvents];
            
            [self loadGroups];
            
            /*
            PFQuery *localUserQuery = [PFUser query];
            [localUserQuery fromLocalDatastore];
            [localUserQuery findObjectsInBackgroundWithBlock:^(NSArray *users1, NSError *error){
                
                for (PFUser *user in users1) {
                    NSLog(@"%@", user.objectId);
                }
                
                [PFObject fetchAllInBackground:users1 block:^(NSArray *users2, NSError *error) {
                    
                    if (!error) {
                        
                        [PFObject pinAllInBackground:users2 block:^(BOOL success, NSError *error){
                            
                            if (success) {
                                NSLog(@"successfully updated and pinned %lu users", users2.count);
                            } else {
                                NSLog(@"failed to update and pin users with error: %@", error);
                                
                            }
                            
                        }];
                    } else {
                        NSLog(@"No objects to update or ERROR");
                    }
                    
                }];
                
            }]; */
            
        });
    }
    
}

- (void)loadFriends {
    
    if ([FBSDKAccessToken currentAccessToken] && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] /* && (ReachableViaWiFi | ReachableViaWWAN) */) {
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends?limit=1000" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            //code
            
            NSArray* friends = [result objectForKey:@"data"];
            NSMutableArray *friendObjectIds = [NSMutableArray new];
            
            for (int i = 0; i < friends.count; i ++) {
                [friendObjectIds addObject:[friends[i] objectForKey:@"id"]];
            }
            
            PFQuery *query = [PFUser query];
            [query whereKey:@"FBObjectID" containedIn:friendObjectIds];
            query.limit = 1000;
            [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                
                NSMutableArray *array = [NSMutableArray array];
                
                for (PFUser *user in users) {
                    
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    
                    [dict setObject:user.objectId forKey:@"parseId"];
                    [dict setObject:[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]] forKey:@"name"];
                    [dict setObject:user[@"FBObjectID"] forKey:@"id"];
                    
                    [array addObject:dict];
                }
                
                [PFUser currentUser][@"friends"] = array;
                [[PFUser currentUser] saveEventually];
            }];
            
        }];
        
    } else {
        
        NSLog(@"no token......");
    }
        
}

-(void)loadEvents {
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery fromLocalDatastore];
    [eventQuery whereKey:@"Date" lessThan:[NSDate dateWithTimeInterval:-604800 sinceDate:[NSDate date]]];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events1, NSError *error){
        [PFObject unpinAllInBackground:events1 withName:@"Event" block:^(BOOL success, NSError *error){
            if (success) {
                NSLog(@"successfully unpinned %lu events", events1.count);
                
                PFQuery *localEventQuery = [PFQuery queryWithClassName:@"Event"];
                [localEventQuery fromLocalDatastore];
                
                [localEventQuery findObjectsInBackgroundWithBlock:^(NSArray *events2, NSError *error){
                    
                    if (events2.count > 0 && !error) {
                        
                        [PFObject fetchAllInBackground:events2 block:^(NSArray *events3, NSError *error) {
                            
                            if (!error) {
                                
                                [PFObject pinAllInBackground:events3 block:^(BOOL success, NSError *error){
                                    
                                    if (success) {
                                        NSLog(@"successfully updated and pinned %lu events", events3.count);
                                    } else {
                                        NSLog(@"failed to update and pin events with error: %@", error);
                                        
                                    }
                                    
                                }];
                            } else {
                                
                                NSLog(@"No objects to update or ERROR: %@", error);
                            }
                            
                        }];
                    }
                }];
                
            } else {
                
                NSLog(@"failed to unpin events with error: %@", error);
                
            }
        }];
    }];
    
}

- (void)loadGroups {
    
    NSMutableArray *array = [NSMutableArray array];
    
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    NSError *error;
    NSOrderedSet *conversations = [self.layerClient executeQuery:query error:&error];
    if (!error) {
        
        for (LYRConversation *convo in conversations) {
            
            [array addObject: [convo.metadata valueForKey:@"groupId"]];
        }
        
    } else {
        
        NSLog(@"Query failed with error %@", error);
    }
    
    NSLog(@"Loading %lu groups...", array.count);
    
    if (array.count > 0) {
        
        PFQuery *localQuery = [PFQuery queryWithClassName:@"Group"];
        [localQuery fromLocalDatastore];
        [localQuery includeKey:@"user_objects"];
        [localQuery findObjectsInBackgroundWithBlock:^(NSArray *groups1, NSError *error) {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Group"];
            [query whereKey:@"objectId" containedIn:array];
            [query includeKey:@"user_objects"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *groups2, NSError *error) {
                
                if (!error) {
                    
                    //NSLog(@"%@", groups1);
                    
                   // NSLog(@"&&&&&&&&&&&&&&&&&&&&&&&");
                    
                    //NSLog(@"%@", groups2);
                    
                    [PFObject unpinAllInBackground:groups1];
                    
                    [PFObject pinAllInBackground:groups2 block:^(BOOL success, NSError *error){
                        
                        if (success) {
                            NSLog(@"successfully updated and pinned %lu groups", groups2.count);
                        } else {
                            NSLog(@"failed to update and pin groups with error: %@", error);
                            
                        }
                        
                    }];
                    
                    /*
                    [PFObject fetchAllInBackground:users block:^(NSArray *users, NSError *error) {
                        
                        if (!error) {
                            
                            [PFObject pinAllInBackground:users block:^(BOOL success, NSError *error){
                                if (success) {
                                    NSLog(@"successfully updated and pinned %lu users in groups", users.count);
                                } else {
                                    NSLog(@"failed to update and pin users with error: %@", error);
                                    
                                }
                            }];
                            
                        } else {
                            NSLog(@"No users from group to update or ERROR: %@", error);
                        }
                    }];*/
                    
                } else {
                    NSLog(@"No objects to update or ERROR: %@", error);
                }
                
            }];
        }];
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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([PFInstallation currentInstallation] == nil) {
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation setDeviceTokenFromData:deviceToken];
            currentInstallation.channels = @[@"global", @"reminders", @"matches", @"friendJoined", @"popularEvents", @"allGroups", @"bestFriends"];
            currentInstallation[@"userID"] = [PFUser currentUser].objectId;
            currentInstallation[@"matchCount"] = @3;
            [currentInstallation saveEventually];
            
        } else {
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation setDeviceTokenFromData:deviceToken];
            [currentInstallation saveEventually];
        }
    });

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"didRegister"
     object:nil];
    
    NSError *error;
    BOOL success = [self.layerClient updateRemoteNotificationDeviceToken:deviceToken error:&error];
    if (success) {
        NSLog(@"Application did register for remote notifications");
    } else {
        NSLog(@"Error updating Layer device token for push:%@", error);
    }
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Error registering for push notifications: %@", error);

    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"didRegister"
     object:nil];
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
                
                if (!error && ![[pushDict objectForKey:@"alert"] isEqualToString:@""]) {
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

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if ([[Button sharedButton] handleLocalNotification:notification]) {
        [[Button sharedButton] handleLocalNotification:notification];
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

- (void)locationKit:(LocationKit *)locationKit didUpdateLocation:(CLLocation *)location {
    NSLog(@"The user has moved and their location is now (%.6f, %.6f)",
          location.coordinate.latitude,
          location.coordinate.longitude);
    [PFUser currentUser][@"userLoc"] = [PFGeoPoint geoPointWithLocation:location];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs((int)howRecent) < 15.0) {
        //Location timestamp is within the last 15.0 seconds, let's use it!
        if(newLocation.horizontalAccuracy < 35.0){
            
            PFUser *user = [PFUser currentUser];
            PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:manager.location];
            user[@"userLoc"] = loc;
            [user saveEventually];
            
            [manager stopUpdatingLocation];
        }
    }
}

@end