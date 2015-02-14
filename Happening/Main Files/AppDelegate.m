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
            //[manager stopUpdatingLocation];
        }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"olSntgsT5uY3ZZbJtnjNz8yvol4CxwmArTsbkCZa"
                  clientKey:@"xwmrITvs8UaFBNfBupzXcUa6HN3sU515xp1TsGxu"];
    //[PFFacebookUtils initializeFacebook];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //[ParseCrashReporting enable];
    
    [FBLoginView class];
    
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
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TabBarViewController *tabBar = [storyboard instantiateViewControllerWithIdentifier:@"TabBar"];
    //ChoosingLocation *choosingLoc = [storyboard instantiateViewControllerWithIdentifier:@"ChoosingLoc"];
    
    PFUser *currentUser = [PFUser currentUser];
    NSLog(@"current user: %@", currentUser);
    
    // Tells the ViewController.m to refresh the cards in DraggableViewBackground
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"refreshData"];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunched"])
    {
        // app already launched
        [defaults setBool:YES forKey:@"refreshData"];
    }
    else
    {
        NSLog(@"First launch ever!");
        [defaults setBool:NO forKey:@"refreshData"];
        
        [defaults setBool:NO forKey:@"hasLaunched"];
        
        [defaults setBool:YES forKey:@"socialMode"];
        
        [defaults setInteger:0 forKey:@"categoryIndex"];
        [defaults setValue:@"Most Popular" forKey:@"categoryName"];
        
        [defaults setBool:@"YES" forKey:@"today"];
        [defaults setBool:@"NO" forKey:@"tomorrow"];
        [defaults setBool:@"NO" forKey:@"thisWeekend"];
        
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
        
        [defaults synchronize];
        // This is the first launch ever
    }
    
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded && currentUser) {
        NSLog(@"Found a cached session");
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_events", @"user_about_me", @"rsvp_event", @"user_location"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        //self.window.rootViewController = tabBar;
        
        
        rk = [storyboard instantiateViewControllerWithIdentifier:@"rk"];
        
        self.window.rootViewController = rk;
        
        
        // If there's no cached session, view goes to first screen (splash screens) which is set in storyboard
    } else {
        //UIButton *loginButton = [self.customLoginViewController loginButton];
        //[loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    }
    
    //self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ChoosingLocation"];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    self.wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    /*
    if (self.wasHandled) {
        NSLog(@"WasHandled = true!");
    } else
        NSLog(@"WasHandled = FALSE");
    */
    return self.wasHandled;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    [FBAppCall handleDidBecomeActive];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"hasLaunched"])
    {
        // app already launched
        [defaults setBool:YES forKey:@"refreshData"];
        [defaults synchronize];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        //[self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        NSLog(@"Session closed");
        // Show the user the logged-out UI
        //[self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        //[self userLoggedOut];
    }
}

- (void)userLoggedIn
{
    // Set the button title as "Log out"
    
    
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!s"
                      otherButtonTitles:nil] show];
}


@end
