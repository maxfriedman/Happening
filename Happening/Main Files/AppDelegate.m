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
#import <Rdio/Rdio.h>
#import "NSData+Base64.h"
#import "GroupChatVC.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface AppDelegate () <NSURLConnectionDataDelegate, RKDropdownAlertDelegate>

@end

static Rdio * _rdioInstance;

@implementation AppDelegate {
    
    PFObject *groupFromPush;
    LYRConversation *convoFromPush;
}

@synthesize locationManager = _locationManager, item, userLocation, locSubtitle, rk;

+ (Rdio *)sharedRdio
{
    if (_rdioInstance == nil) {
        
        
        NSString *post = [NSString stringWithFormat:@"Username=%@&Password=%@",@"nwb2guio6nh6dnc4nko7qdyfye",@"LtKsfB3aZQhrOyk6rpthCg"];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://www.services.rdio.com/oauth2/token/"]];
        [request setHTTPMethod:@"POST"];
        //[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        //[request setHTTPBody:postData];
        
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", @"nwb2guio6nh6dnc4nko7qdyfye", @"LtKsfB3aZQhrOyk6rpthCg"];
        NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            if (data){
                //do something with data
                NSLog(@"data: %@", data);
            }
            else if (error)
                NSLog(@"error: %@",error);
        }];
        
        
        /*
        NSURLConnection *conn = [[NSURLConnection alloc]
                                        initWithRequest:request
                                        delegate:self startImmediately:NO];
        
        [conn scheduleInRunLoop:[NSRunLoop mainRunLoop]
                              forMode:NSDefaultRunLoopMode];
        [conn start];
        
        if(conn) {
            NSLog(@"Connection Successful");
        } else {
            NSLog(@"Connection could not be made");
        }*/
        
        
        _rdioInstance = [[Rdio alloc] initWithClientId:@"nwb2guio6nh6dnc4nko7qdyfye"
                                             andSecret:@"LtKsfB3aZQhrOyk6rpthCg"
                                              delegate:nil];
    }

    return _rdioInstance;
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    NSLog(@"data: %@", data);
}

// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"error:%@", error);

}

/*
// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connection: %@", connection);
}*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"Loading Happening!");
          
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
    
    if ([PFUser currentUser] == nil) {
        NSLog(@"ENABLE AUTOMATIC USER");
        [PFAnonymousUtils logInInBackground];
        /*
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL success, NSError *error){
            NSLog(@"current user: %@ - %@", [PFUser currentUser].objectId, [PFUser currentUser]);
        }];*/
    }
    
    self.groupDict = [NSMutableDictionary dictionary];
    
    NSURL *appID = [NSURL URLWithString:@"layer:///apps/production/337f70da-0eb7-11e5-9a48-aa9e2d006589"];
    self.layerClient = [LYRClient clientWithAppID:appID];
    self.layerClient.autodownloadMIMETypes = nil;
    
    //[Hoko setVerbose:YES];
    [Hoko setupWithToken:@"b649dec47382a7b855b46077d2cfbb6968e7e81b" customDomains:@[@"hap.ng"]];
    
    BOOL locEnabled = NO;
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        NSLog(@" ====== iOS 7 ====== ");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            locEnabled = YES;
        }
    } else {
        NSLog(@" ====== iOS 8 ====== ");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) locEnabled = YES;
    }
    
    if (locEnabled) {
        //NSLog(@"Initializing Location Kit...");
        //[[LocationKit sharedInstance] startWithApiToken:@"48ced72017ecb03b" delegate:self];
        [PFUser currentUser][@"locStatus"] = @"yes";
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [PFUser currentUser][@"locStatus"] = @"no";
    }
    
    //_rdioInstance = [AppDelegate sharedRdio]; //initialize
    /*
    [_rdioInstance preparePlayerWithDelegate:nil];
    [_rdioInstance callAPIMethod:@"access_token" withParameters:@{@"access_token":@"mF_9.B5f-4.1JqM"} success:^(NSDictionary *result) {
        NSLog(@"lala %@", result);
    } failure:^(NSError *error) {
        NSLog(@"lala %@", error);
    }];*/
    
    //[rdio preparePlayerWithDelegate:nil];
    //[rdio.player performSelector:@selector(play:) withObject:@"t1" afterDelay:2.0];
    
    [[Button sharedButton] configureWithApplicationId:@"app-070dce57d47ec28b" completion:^(NSError *error){
        if (!error) {
            NSLog(@"Yay! Button is initialized.");
        } else {
            NSLog(@"Womp womp. Button failed to initialize with error: %@", error);
        }
    }];
    
    [BTNLocationManager allowButtonToRequestLocationPermission:YES];

    //[[BTNDropinButton appearance] setContentInsets:UIEdgeInsetsMake(0, -1, 0.0, 0)];
    [[BTNDropinButton appearance] setContentInsets:UIEdgeInsetsMake(0, 6, 0.0, 0)];
    [[BTNDropinButton appearance] setIconSize:20.0];
    [[BTNDropinButton appearance] setIconLabelSpacing:8.0];
    [[BTNDropinButton appearance] setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:14.0]];
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
        currentUser[@"time"] = @"today";
        
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
    
    NSLog(@"@#$ %@", launchOptions);
    
    NSLog(@"^&* %@", launchOptions[UIApplicationLaunchOptionsURLKey]);
    
    /*
    if (launchOptions[UIApplicationLaunchOptionsURLKey] == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Announcement" message: @"NIL" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Announcement" message: launchOptions[UIApplicationLaunchOptionsURLKey] delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }*/
    
    //self.mh.eventIdForSegue = eventID;
    //[self.mh performSegueWithIdentifier:@"toSwipeVC" sender:self.mh];
    
    [PFUser currentUser][@"latestVersion"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    //NSLog(@"User is not logged in!");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    movieLoginVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"movieLogin"];
    self.window.rootViewController = vc;
    //vc.eventIdFromNotification = @"wKhr50fk50";
    
    
    NSURL *hokoLink = launchOptions[UIApplicationLaunchOptionsURLKey];
    
    
    
    if (hokoLink != nil && [self doesString:hokoLink.absoluteString contain:@"happening://events/"]) {
        
        UINavigationController *nvc = [storyboard instantiateViewControllerWithIdentifier:@"SwipeVCNav"];
        SwipeableCardVC *vc = (SwipeableCardVC *)[nvc topViewController];
        
        NSString *urlString = hokoLink.absoluteString;
        NSString *eventId = [urlString stringByReplacingOccurrencesOfString:@"happening://events/" withString:@""];
        if ([self doesString:eventId contain:@"?"]) {
            NSString *substring = nil;
            NSRange newlineRange = [eventId rangeOfString:@"?"];
            if(newlineRange.location != NSNotFound) {
                substring = [eventId substringFromIndex:newlineRange.location];
            }
            eventId = [eventId stringByReplacingOccurrencesOfString:substring withString:@""];
        }
            
        vc.eventID = eventId;
        [HOKNavigation presentViewController:nvc animated:YES];
    }
    
    [[Hoko deeplinking] mapRoute:@"events/:EventID"
                        toTarget:^(HOKDeeplink *deeplink) {
                            // Do something when deeplink is opened
                            
                            NSLog(@"HOKO LINK");
                            NSLog(@"%@", deeplink);
                            
                            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Announcement" message: @"Route was triggered" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            //[alert show];
                            
                            UINavigationController *nvc = [storyboard instantiateViewControllerWithIdentifier:@"SwipeVCNav"];
                            SwipeableCardVC *vc = (SwipeableCardVC *)[nvc topViewController];
                            vc.eventID = deeplink.routeParameters[@"EventID"];
                            [HOKNavigation presentViewController:nvc animated:YES];
                        }];
    
    [[Hoko deeplinking] addHandlerBlock:^(HOKDeeplink *deeplink) {
        NSLog(@"Handler is working %@", deeplink);
    }];
    
    
    // Extract the notification data
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload != nil) {
    
        NSLog(@"Launching with notification");
        
        if ([notificationPayload objectForKey:@"eventID"] != nil) {
            
            NSLog(@"&& %@", notificationPayload);
            
            NSString *eventID = [notificationPayload objectForKey:@"eventID"];
            vc.eventIdFromNotification = eventID;
            
        } else if ([notificationPayload objectForKey:@"layer"] != nil) { // layer notification
            
            NSDictionary *dict = [notificationPayload objectForKey:@"layer"];
            
            LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
            query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:[dict objectForKey:@"conversation_identifier"]];
            LYRConversation *conversation = [[self.layerClient executeQuery:query error:nil] firstObject];
            
            PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
            [groupQuery fromLocalDatastore];
            [groupQuery getObjectInBackgroundWithId: [conversation.metadata objectForKey:@"groupId"] block:^(PFObject *group1, NSError *error) {
                
                NSDictionary *pushDict = [notificationPayload objectForKey:@"aps"];
                
                if (!error && group1 && [pushDict objectForKey:@"alert"] != nil && ![[pushDict objectForKey:@"alert"] isEqualToString:@""]) {
                    groupFromPush = group1;
                    convoFromPush = conversation;
                    [self.mh.groupHub increment];
                    [self showChatVC];
                    
                } else {
                    
                    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
                    [groupQuery getObjectInBackgroundWithId: [conversation.metadata objectForKey:@"groupId"] block:^(PFObject *group2, NSError *error) {
                        
                        [group2 pinInBackground];
                        NSDictionary *pushDict = [notificationPayload objectForKey:@"aps"];
                        
                        if (!error && group2 && [pushDict objectForKey:@"alert"] != nil && ![[pushDict objectForKey:@"alert"] isEqualToString:@""]) {
                            groupFromPush = group1;
                            convoFromPush = conversation;
                            [self.mh.groupHub increment];
                            [self showChatVC];
                        }
                        
                    }];
                    
                    
                }
                
            }];
            
        }

        
    }
    
    UILocalNotification *localNotification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if ([[Button sharedButton] handleLocalNotification:localNotification]) {
        [[Button sharedButton] handleLocalNotification:localNotification];
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

-(BOOL)doesString:(NSString *)first contain:(NSString*)other {
    NSRange range = [first rangeOfString:other];
    return range.length != 0;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSLog(@"$$$$ %@", url);
    //[[Hoko deeplinking] openURL:url sourceApplication:sourceApplication annotation:annotation];
    
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
    
    /*
    PFQuery *activityQuery = [PFQuery queryWithClassName:@"Activity"];
    [activityQuery fromLocalDatastore];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *activities, NSError *error) {
        
        if (!error) {
            
            [PFObject unpinAllInBackground:activities];
        }
        
    }];*/
    
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
    
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0;
            [currentInstallation saveEventually];
        }
        
        [self loadEvents];
        
        [self loadGroups];
        
        [self checkForActivityObjects];
        
        if (self.mh.groupHub != nil) {
            
            // Fetches the count of all unread messages for the authenticated user
            LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
            
            // Messages must be unread
            LYRPredicate *unreadPredicate =[LYRPredicate predicateWithProperty:@"isUnread" predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
            
            // Messages must not be sent by the authenticated user
            LYRPredicate *userPredicate = [LYRPredicate predicateWithProperty:@"sender.userID" predicateOperator:LYRPredicateOperatorIsNotEqualTo value:self.layerClient.authenticatedUserID];
            
            query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[unreadPredicate, userPredicate]];
            query.resultType = LYRQueryResultTypeCount;
            NSError *error = nil;
            NSUInteger unreadMessageCount = [self.layerClient countForQuery:query error:&error];
            
            if (unreadMessageCount > 0) {
                NSLog(@"%lu unread messages", unreadMessageCount);
                
                if (unreadMessageCount > 100) {
                    unreadMessageCount = 1;
                }
                
                [self.mh.groupHub setCount:unreadMessageCount];
                [self.mh.groupHub bump];
            
            }
        }
        
        [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if (!error){
                [object pinInBackground];
                //[self performSelector:@selector(loadFriends) withObject:nil afterDelay:5.0];
            }
        }];
        
    }
    
}


-(void)loadEvents {
    
    NSLog(@"Loading events...");
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery fromLocalDatastore];
    [eventQuery whereKey:@"Date" lessThan:[NSDate dateWithTimeInterval:-60*60*24 sinceDate:[NSDate date]]];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events1, NSError *error){
        [PFObject unpinAllInBackground:events1 block:^(BOOL success, NSError *error){
            if (success) {
                NSLog(@"successfully unpinned %lu events", events1.count);
                
                PFQuery *localEventQuery = [PFQuery queryWithClassName:@"Event"];
                //[localEventQuery whereKey:@"Date" greaterThan:[NSDate dateWithTimeInterval:-60*60*24 sinceDate:[NSDate date]]];
                [localEventQuery fromLocalDatastore];
                
                [localEventQuery findObjectsInBackgroundWithBlock:^(NSArray *events2, NSError *error){

                    NSLog(@"Fetched %lu events", events2.count);
                    
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
            
            if ([convo.metadata valueForKey:@"groupId"] != nil)
                [array addObject: [convo.metadata valueForKey:@"groupId"]];
        }
        
    } else {
        
        NSLog(@"Query failed with error %@", error);
    }
    
    NSLog(@"Loading %lu groups...", array.count);
    
    if (array.count > 0) {
        
        PFQuery *localQuery = [PFQuery queryWithClassName:@"Group"];
        [localQuery fromLocalDatastore];
        [localQuery findObjectsInBackgroundWithBlock:^(NSArray *groups1, NSError *error) {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Group"];
            [query whereKey:@"objectId" containedIn:array];
            [query findObjectsInBackgroundWithBlock:^(NSArray *groups2, NSError *error) {
                
                if (!error) {
                    
                    [PFObject unpinAllInBackground:groups1];
                    
                    [PFObject pinAllInBackground:groups2 block:^(BOOL success, NSError *error){
                        
                        if (success) {
                            NSLog(@"successfully updated and pinned %lu groups", groups2.count);
                        } else {
                            NSLog(@"failed to update and pin groups with error: %@", error);
                            
                        }
                        
                    }];
                    
                    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
                    
                    NSError *error = nil;
                    NSOrderedSet *conversations = [self.layerClient executeQuery:query error:&error];
                    if (!error) {
                        for (PFObject *group in groups2) {
                            for (LYRConversation *convo in conversations) {
                                if ([[convo.metadata valueForKey:@"groupId"] isEqualToString:group.objectId]) {
                                    [convo.metadata setValue:group[@"name"] forKeyPath:@"title"];
                                    break;
                                }
                            }
                        }
                    }
                    
                    NSMutableArray *groupIds = [NSMutableArray array];
                    for (PFObject *group in groups2) {
                        [groupIds addObject:group.objectId];
                        [self.groupDict setObject:group forKey:group.objectId];
                    }
                    
                    PFQuery *groupEventQuery = [PFQuery queryWithClassName:@"Group_Event"];
                    //[groupEventQuery fromLocalDatastore];
                    [groupEventQuery whereKey:@"GroupID" containedIn:groupIds];
                    //[groupEventQuery includeKey:@"eventObject"];
                    [groupEventQuery findObjectsInBackgroundWithBlock:^(NSArray *groupEvents, NSError *error){
                    
                        if (!error) {
                            
                            [PFObject pinAllInBackground:groupEvents block:^(BOOL success, NSError *error){
                                
                                if (success) {
                                    NSLog(@"successfully updated and pinned %lu group events", groupEvents.count);
                                } else {
                                    NSLog(@"failed to update and pin group events with error: %@", error);
                                    
                                }
                            
                            }];
                            
                            NSMutableArray *eventIds = [NSMutableArray array];
                            for (PFObject *groupEvent in groupEvents) {
                                [eventIds addObject:groupEvent[@"EventID"]];
                            }
                            
                            PFQuery *localEventQuery = [PFQuery queryWithClassName:@"Event"];
                            [localEventQuery fromLocalDatastore];
                            localEventQuery.limit = 1000;
                            [localEventQuery whereKey:@"objectId" containedIn:eventIds];
                            [localEventQuery selectKeys:@[@"objectId"]];
                            [localEventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
                                
                                if (!error) {
                                    
                                    for (PFObject *event in events) {
                                        
                                        [eventIds removeObject:event.objectId];
                                    }
                                    
                                    if (eventIds.count > 0) {
                                        
                                        PFQuery *eventQuery = [[PFQuery alloc] initWithClassName:@"Event"];
                                        [eventQuery whereKey:@"objectId" containedIn:eventIds];
                                        [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
                                        
                                            if (!error) {
                                                 [PFObject pinAllInBackground:events block:^(BOOL success, NSError *error){
                                                     if (success) {
                                                        NSLog(@"successfully updated and pinned %lu events", events.count);
                                                     } else {
                                                         NSLog(@"failed to update and pin group events with error: %@", error);
                                                     }
                                                 }];
                                            }
                                        }];
                                    }
                                }
                            }];

                            /*
                            PFObject *ob = [eventsArray lastObject];
                            NSLog(@"1. %@", ob);

                            [ob pinWithName:@"test"];
                            
                            PFQuery *q = [PFQuery queryWithClassName:@"Event"];
                            [q fromPinWithName:@"test"];
                            PFObject *test = [q getFirstObject];
                            
                            NSLog(@"2. %@", test);
                            */

                        } else {
                            
                            NSLog(@"failed to update and pin group events with error: %@", error);
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

- (void)checkForActivityObjects {
    
    NSArray *friends = [[PFUser currentUser] objectForKey:@"friends"];
    NSMutableArray *friendIds = [NSMutableArray new];
    for (NSDictionary *dict in friends) {
        [friendIds addObject:[dict valueForKey:@"id"]];
    }

    PFQuery *finalQuery = [PFQuery queryWithClassName:@"Activity"];
    
    PFQuery *interestedQuery = [PFQuery queryWithClassName:@"Activity"];
    [interestedQuery whereKey:@"type" containedIn:@[@"interested", @"going", @"create"]];
    [interestedQuery whereKey:@"userFBId" containedIn:friendIds];
    
    PFQuery *reminderQuery = [PFQuery queryWithClassName:@"Activity"];
    [reminderQuery whereKey:@"type" equalTo:@"reminder"];
    [reminderQuery whereKey:@"userParseId" equalTo:[PFUser currentUser].objectId];
    
    PFQuery *friendJoinedQuery = [PFQuery queryWithClassName:@"Activity"];
    [friendJoinedQuery whereKey:@"type" equalTo:@"friendJoined"];
    [friendJoinedQuery whereKey:@"userFBId" containedIn:friendIds];
    
    finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:interestedQuery, reminderQuery, friendJoinedQuery, nil]];
    [finalQuery orderByDescending:@"createdAt"];
    
    [finalQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
       
        if (!error) {
            
            NSLog(@"%@", object);
            
            PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
            //[query fromPinWithName:@"friends"];
            [query fromLocalDatastore];
            [query getObjectInBackgroundWithId:object.objectId block:^(PFObject *ob, NSError *error) {
                
                if (!ob || error) {
                
                    NSLog(@"New activities");
                    [self.mh.activityHub increment];
                    [self.mh.activityHub bump];
                    
                } else {
                    
                    NSLog(@"No new activities");

                }
                
            }];
            
            /*
            PFQuery *meQuery = [PFQuery queryWithClassName:@"Activity"];
            [meQuery orderByDescending:@"createdDate"]; // required bc of limit, need most recent results. Enumerate array backwards.
    
            PFQuery *reminderQuery = [PFQuery queryWithClassName:@"Activity"];
            [reminderQuery whereKey:@"type" equalTo:@"reminder"];
            [reminderQuery whereKey:@"userParseId" equalTo:[PFUser currentUser].objectId];
            
            PFQuery *friendJoinedQuery = [PFQuery queryWithClassName:@"Activity"];
            [friendJoinedQuery whereKey:@"type" equalTo:@"friendJoined"];
            [friendJoinedQuery whereKey:@"userFBId" containedIn:friendIds];
            
            meQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:reminderQuery, friendJoinedQuery, nil]];
            */
            
        }
        
    }];
        

    
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
            currentInstallation[@"matchCount"] = @2;
            [PFUser currentUser][@"matchCount"] = @2;
            [[PFUser currentUser] saveEventually];
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

-(BOOL)dropdownAlertWasDismissed {
    
    return true;
}

- (BOOL)dropdownAlertWasTapped:(RKDropdownAlert *)alert {
    
    if (!self.conversationOpen) {
        
        [self showChatVC];
    
    }
    
    return true;
}

- (void)showChatVC {
    
    self.conversationOpen = YES;
    [self.mh.groupHub decrement];
    
    GroupChatVC *controller = [GroupChatVC conversationViewControllerWithLayerClient:self.layerClient];
    
    NSString *title = [[convoFromPush metadata] objectForKey:@"title"];
    if ([title isEqualToString:@"_indy_"]) {
        //vc.title = [NSString stringWithFormat:@"%@ and %@", [self.dataSource conversationListViewController:self titleForConversation:selectedConvo], currentUser[@"firstName"]];
        //vc.showDetails = NO;
    } else {
        //vc.title = title;
        //vc.showDetails = YES;
    }
    
    controller.groupObject = groupFromPush;
    
    if (controller.groupObject.isDataAvailable) {
        
        controller.userDicts = controller.groupObject[@"user_dicts"];
        
        NSMutableArray *fbids =[NSMutableArray new];
        for (NSDictionary *dict in controller.userDicts) {
            [fbids addObject:[dict valueForKey:@"id"]];
        }
        
        controller.fbids = fbids;
        
    }
    
    //vc.loadTopView = YES;
    
    if (!controller.groupObject) {
        
        NSLog(@"Group hasn't loaded yet. Load in next VC");
    }
    
    controller.conversation = convoFromPush;
    
    controller.isModal = YES;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:controller];
    nvc.navigationBar.tintColor = [UIColor whiteColor];
    nvc.navigationBar.translucent = NO;
    nvc.navigationBar.barStyle = UIBarStyleBlack;
    nvc.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [nvc.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    
    [HOKNavigation presentViewController:nvc animated:YES];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    
    //[PFPush handlePush:userInfo];
    
    NSLog(@"PUSH NOTIFICATION");
    NSLog(@"Info from push: %@", userInfo);
    
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive)
    {
        
        if ([userInfo objectForKey:@"layer"] != nil && !self.conversationOpen) { // layer notification
            
            NSDictionary *dict = [userInfo objectForKey:@"layer"];
    
            LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
            query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:[dict objectForKey:@"conversation_identifier"]];
            LYRConversation *conversation = [[self.layerClient executeQuery:query error:nil] firstObject];
            
            PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
            [groupQuery fromLocalDatastore];
            [groupQuery getObjectInBackgroundWithId: [conversation.metadata objectForKey:@"groupId"] block:^(PFObject *group1, NSError *error) {
               
                NSDictionary *pushDict = [userInfo objectForKey:@"aps"];
                
                if (!error && group1 && [pushDict objectForKey:@"alert"] != nil && ![[pushDict objectForKey:@"alert"] isEqualToString:@""]) {
                    groupFromPush = group1;
                    convoFromPush = conversation;
                    [RKDropdownAlert title:group1[@"name"] message:[pushDict objectForKey:@"alert"] backgroundColor:[UIColor colorWithRed:28.0/255 green:73.0/255 blue:134.0/255 alpha:1.0] textColor:[UIColor whiteColor] delegate:self];
                    [self.mh.groupHub increment];
                
                } else {
                    
                    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
                    [groupQuery getObjectInBackgroundWithId: [conversation.metadata objectForKey:@"groupId"] block:^(PFObject *group2, NSError *error) {
                        
                        [group2 pinInBackground];
                        NSDictionary *pushDict = [userInfo objectForKey:@"aps"];
                        
                        if (!error && group2 && [pushDict objectForKey:@"alert"] != nil && ![[pushDict objectForKey:@"alert"] isEqualToString:@""]) {
                            groupFromPush = group2;
                            convoFromPush = conversation;
                            [RKDropdownAlert title:group2[@"name"] message:[pushDict objectForKey:@"alert"] backgroundColor:[UIColor colorWithRed:28.0/255 green:73.0/255 blue:134.0/255 alpha:1.0] textColor:[UIColor whiteColor] delegate:self];
                            [self.mh.groupHub increment];
                        }
                        
                    }];

                    
                }
                
            }];
            
        }
        
        
    }
    else {
        // Push Notification received in the background
        
        if ([userInfo objectForKey:@"layer"] != nil && !self.conversationOpen) { // layer notification
            NSDictionary *dict = [userInfo objectForKey:@"layer"];
            
            LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
            query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:[dict objectForKey:@"conversation_identifier"]];
            LYRConversation *conversation = [[self.layerClient executeQuery:query error:nil] firstObject];
            
            PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
            [groupQuery fromLocalDatastore];
            [groupQuery getObjectInBackgroundWithId: [conversation.metadata objectForKey:@"groupId"] block:^(PFObject *group1, NSError *error) {
                
                NSDictionary *pushDict = [userInfo objectForKey:@"aps"];
                
                if (!error && group1 && ![[pushDict objectForKey:@"alert"] isEqualToString:@""]) {
                    groupFromPush = group1;
                    convoFromPush = conversation;
                    [self.mh.groupHub increment];
                    [self showChatVC];
                    
                } else {
                    
                    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
                    [groupQuery getObjectInBackgroundWithId: [conversation.metadata objectForKey:@"groupId"] block:^(PFObject *group2, NSError *error) {
                        
                        [group2 pinInBackground];
                        NSDictionary *pushDict = [userInfo objectForKey:@"aps"];
                        
                        if (!error && group2 && ![[pushDict objectForKey:@"alert"] isEqualToString:@""]) {
                            groupFromPush = group1;
                            convoFromPush = conversation;
                            [self.mh.groupHub increment];
                            [self showChatVC];
                        }
                        
                    }];
                    
                    
                }
                
            }];
            
        }
        
        else if ([userInfo objectForKey:@"eventID"] != nil) {
        
            NSString *eventID = [userInfo objectForKey:@"eventID"];
            //vc.eventIdFromNotification = eventID;
            
            UINavigationController *nvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SwipeVCNav"];
            SwipeableCardVC *vc = (SwipeableCardVC *)[nvc topViewController];
            vc.eventID = eventID;
            [HOKNavigation presentViewController:nvc animated:YES];
            
            /*
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

            
            }]; */
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
    NSLog(@"The user has moved and their location is now (%.6f, %.6f)", location.coordinate.latitude, location.coordinate.longitude);
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"userLoc"] = [PFGeoPoint geoPointWithLocation:location];
    [currentUser pinInBackground];
}

- (void)locationKit:(LocationKit *)locationKit didStartVisit:(LKVisit *)visit {
    
    NSLog(@"User started a visit at %@", visit.place.venue.name);
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery fromLocalDatastore];
    [eventQuery whereKey:@"GeoLoc" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:visit.place.address.coordinate.latitude longitude:visit.place.address.coordinate.longitude] withinMiles:50];
    [eventQuery whereKey:@"Date" lessThan:[NSDate dateWithTimeIntervalSinceNow:3600]];
    [eventQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-3600]];
    [eventQuery getFirstObjectInBackgroundWithBlock:^(PFObject *event, NSError *error) {
       
        if (!error && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
            
            NSLog(@"User is at an actual event!");
            
            PFUser *currentUser = [PFUser currentUser];
            NSString *name = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstName"], currentUser[@"lastName"]];
            
            [PFCloud callFunctionInBackground:@"userIsAtEvent"
                               withParameters:@{@"user":currentUser.objectId, @"event":event.objectId, @"fbID":currentUser[@"FBObjectID"], @"fbToken":[FBSDKAccessToken currentAccessToken].tokenString, @"title":event[@"Title"], @"loc":event[@"Location"], @"name":name, @"eventDate":event[@"Date"]}
                                        block:^(NSString *result, NSError *error) {
                                            if (!error) {
                                                //NSLog(@"%@", result);
                                            }
                                        }];
            
        } else {
            
            NSLog(@"False alarm.");
            
        }
        
    }];
    
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