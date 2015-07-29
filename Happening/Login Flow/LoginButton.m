//
//  LoginButton.m
//  Happening
//
//  Created by Max on 7/22/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#import "LoginButton.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import <math.h>

@implementation LoginButton {
    
    PFUser *currentUser;
}

-(instancetype)init {
    
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    
}

- (void)setButtonType:(NSString *)type {
    
    currentUser = [PFUser currentUser];
        
    if ([type isEqualToString:@"fb"]) {
        [self addTarget:self action:@selector(fbButton) forControlEvents:UIControlEventTouchUpInside];
    } else if ([type isEqualToString:@"anon"]) {
        [self addTarget:self action:@selector(noAccountButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    } else if ([type isEqualToString:@"fromAnon"]) {
        [self addTarget:self action:@selector(anonToNormal) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)fbButton {
    
    [self.delegate buttonPressStart];
     
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    loginManager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    [loginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_location", @"user_birthday"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        NSLog(@"result:%@", result);
        NSLog(@"granted permissions: %@", result.grantedPermissions);
        //__block NSSet *grantedPermissions = result.grantedPermissions;
        
        if (error) {
            // Process error
            NSLog(@"error");
            [self.delegate buttonPressEnd];
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            
            if([[[UIDevice currentDevice] systemVersion] floatValue]<8.0)
            {
                /*
                 UIAlertView* curr1=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location service" message:@"You can enable access in Settings->Privacy->Location->Location Services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 [curr1 show];
                 */
                [[[UIAlertView alloc] initWithTitle:@"Aw snap"
                                            message:@"We're having trouble connecting to Facebook. Please go to Settings -> Facebook -> Happening -> On"
                                           delegate:self
                                  cancelButtonTitle:@"I'm on it!"
                                  otherButtonTitles:nil, nil] show];
                
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Aw snap"
                                            message:@"We're having trouble connecting to Facebook. Please go to Settings -> Facebook -> Happening -> On"
                                           delegate:self
                                  cancelButtonTitle:@"I'm on it!"
                                  otherButtonTitles:nil, nil] show];
                
                /*  otherButtonTitles:@"Settings", nil] show]; */
            }
            
            
        } else if (result.isCancelled) {
            
            NSLog(@"fb login cancelled");
            [self.delegate buttonPressEnd];
            
        } else if (self.userExists == YES) {
         
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 
                 if (!error) {
                     
                     NSLog(@"fetched user:%@", result);
                     
                     NSDictionary *user = result;
                     
                     if ([user objectForKey:@"email"] != nil) {
                         
                         currentUser.username = [user objectForKey:@"email"];
                         currentUser.email = [user objectForKey:@"email"];
                         
                     } else {
                         NSLog(@"User disabled email permissions");
                         currentUser.username = [user objectForKey:@"link"];
                     }
                     currentUser.password = [user objectForKey:@"link"];
                     
                     
                     currentUser[@"FBObjectID"] = [user objectForKey:@"id"];
                     currentUser[@"link"] = [user objectForKey:@"link"];
                     
                     
                     if ([user objectForKey:@"first_name"] != nil)
                         currentUser[@"firstName"] = [user objectForKey:@"first_name"];
                     
                     if ([user objectForKey:@"last_name"] != nil)
                         currentUser[@"lastName"] = [user objectForKey:@"last_name"];
                     
                     if ([user objectForKey:@"gender"] != nil)
                         currentUser[@"gender"] = [user objectForKey:@"gender"];
                     
                     /*
                      if ([grantedPermissions containsObject:@"bio"])
                      parseUser[@"bio"] = [user objectForKey:@"bio"];
                      */
                     
                     if ([user objectForKey:@"birthday"] != nil)
                         currentUser[@"birthday"] = [user objectForKey:@"birthday"];
                     
                     if ([user objectForKey:@"location"] != nil) {
                         NSDictionary *locationDict = [user objectForKey:@"location"];
                         
                         if ([locationDict objectForKey:@"name"] != nil)
                             currentUser[@"fbLocationName"] = [locationDict objectForKey:@"name"];
                         currentUser[@"city"] = [locationDict objectForKey:@"name"];
                         
                     }
                     
                     // Defaults
                     currentUser[@"fbToken"] = [FBSDKAccessToken currentAccessToken].tokenString;
                     //parseUser[@"userLoc"] = [PFGeoPoint geoPointWithLatitude:38.907192 longitude:-77.036871];
            
                    if (currentUser) {
                        
                        [PFUser logInWithUsernameInBackground:currentUser.username password:currentUser.password block:^(PFUser *user, NSError *error) {
                            
                            if (user) {
                                // Do stuff after successful login.
                                [self setDefaultsForUser:user];
                                
                            } else {
                                // The login failed. Check error to see why.
                                [self.delegate buttonPressEnd];
                                [self.delegate loginUnsuccessful];
                                NSLog(@"%@", error);
                            }
                        }];
                    }
                     
                 } else {
                     [self.delegate buttonPressEnd];
                     [self.delegate loginUnsuccessful];
                     NSLog(@"%@", error);
                 }
                 
             }];
            
        } else {
        
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 
                 if (!error) {
                     
                     NSLog(@"fetched user:%@", result);
                     
                     NSDictionary *user = result;
                     
                     /*
                      NSLog(@"%@", [user allKeys]);
                      NSLog(@"%@", [user allValues]);
                      
                      NSArray *myArray = [grantedPermissions allObjects];
                      
                      NSLog(@" ~~~~~~~~ ~~~~~ ~~~~~~ %@", myArray[0]);
                      NSLog(@" ~~~~~~~~ ~~~~~ ~~~~~~ %@", myArray[1]);
                      NSLog(@" ~~~~~~~~ ~~~~~ ~~~~~~ %@", myArray[2]);
                      NSLog(@" ~~~~~~~~ ~~~~~ ~~~~~~ %@", myArray[3]);
                      NSLog(@" ~~~~~~~~ ~~~~~ ~~~~~~ %@", myArray[4]);
                      NSLog(@" ~~~~~~~~ ~~~~~ ~~~~~~ %@", myArray[5]);
                      NSLog(@" ~~~~~~~~ ~~~~~ ~~~~~~ %@", myArray[6]);
                      
                      NSLog(@"user_location ===> %d", [grantedPermissions containsObject:@"user_location"]);
                      NSLog(@"user_birthday ===> %d", [grantedPermissions containsObject:@"user_birthday"]);
                      NSLog(@"public_profile ===> %d", [grantedPermissions containsObject:@"public_profile"]);
                      NSLog(@"email ===> %d", [grantedPermissions containsObject:@"email"]);
                      NSLog(@"user_friends ===> %d", [grantedPermissions containsObject:@"user_friends"]);
                      NSLog(@"basic_info ===> %d", [grantedPermissions containsObject:@"basic_info"]);
                      NSLog(@"contact_email ===> %d", [grantedPermissions containsObject:@"contact_email"]);
                      
                      NSLog(@"user_location ===> %d", [grantedPermissions containsObject:@"user_location"]);
                      NSLog(@"user_birthday ===> %d", [grantedPermissions containsObject:@"user_birthday"]);
                      NSLog(@"public_profile ===> %d", [grantedPermissions containsObject:@"public_profile"]);
                      NSLog(@"email ===> %d", [grantedPermissions containsObject:@"email"]);
                      NSLog(@"user_friends ===> %d", [grantedPermissions containsObject:@"user_friends"]);
                      NSLog(@"basic_info ===> %d", [grantedPermissions containsObject:@"basic_info"]);
                      NSLog(@"contact_email ===> %d", [grantedPermissions containsObject:@"contact_email"]);
                      
                      NSLog(@"location ===> %@", [user valueForKey:@"location"]);
                      NSLog(@"birthday ===> %@", [user valueForKey:@"birthday"]);
                      NSLog(@"first_name ===> %@", [user valueForKey:@"first_name"]);
                      NSLog(@"last_name ===> %@", [user objectForKey:@"last_name"]);
                      NSLog(@"email ===> %@", [user valueForKey:@"email"]);
                      NSLog(@"gender ===> %@", [user valueForKey:@"gender"]);
                      NSLog(@"link ===> %@", [user valueForKey:@"link"]);
                      */
                    
                     PFUser *newUser = [PFUser user];
                     
                    NSString *username = [self randomStringWithLength:10];
                    //user.username = username;
                     
                     if ([user objectForKey:@"email"] != nil) {
                         
                         newUser.username = [user objectForKey:@"email"];
                         newUser.email = [user objectForKey:@"email"];
                         
                     } else {
                         NSLog(@"User disabled email permissions");
                         newUser.username = [user objectForKey:@"link"];
                     }
                     newUser.password = [user objectForKey:@"link"];
                     
                     
                     newUser[@"FBObjectID"] = [user objectForKey:@"id"];
                     newUser[@"link"] = [user objectForKey:@"link"];
                     
                     
                     if ([user objectForKey:@"first_name"] != nil)
                         newUser[@"firstName"] = [user objectForKey:@"first_name"];
                     
                     if ([user objectForKey:@"last_name"] != nil)
                         newUser[@"lastName"] = [user objectForKey:@"last_name"];
                     
                     if ([user objectForKey:@"gender"] != nil)
                         newUser[@"gender"] = [user objectForKey:@"gender"];
                     
                     /*
                      if ([grantedPermissions containsObject:@"bio"])
                      parseUser[@"bio"] = [user objectForKey:@"bio"];
                      */
                     
                     if ([user objectForKey:@"birthday"] != nil)
                         newUser[@"birthday"] = [user objectForKey:@"birthday"];
                     
                     if ([user objectForKey:@"location"] != nil) {
                         NSDictionary *locationDict = [user objectForKey:@"location"];
                         
                         if ([locationDict objectForKey:@"name"] != nil)
                             newUser[@"fbLocationName"] = [locationDict objectForKey:@"name"];
                         newUser[@"city"] = [locationDict objectForKey:@"name"];
                         
                     }
                     
                     // Defaults
                     newUser[@"fbToken"] = [FBSDKAccessToken currentAccessToken].tokenString;
                     //parseUser[@"userLoc"] = [PFGeoPoint geoPointWithLatitude:38.907192 longitude:-77.036871];
                     
                     NSLog(@"Sign up new user");
                     
                     [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         
                         if (!error) {
                             
                             NSLog(@"New user successfully signed up.");
                             
                             // Hooray! Let them use the app now.
                             NSLog(@"New user: %@", currentUser.username);
                             
                             if (newUser) {
                                 
                                 NSString *name = @"";
                                 if ([user objectForKey:@"first_name"] != nil)
                                     name = [user objectForKey:@"first_name"];
                                 
                                 if ([user objectForKey:@"last_name"] != nil)
                                     name = [NSString stringWithFormat:@"%@ %@", name, [user objectForKey:@"last_name"]];
                                 
                                 [PFCloud callFunctionInBackground:@"newUser"
                                                    withParameters:@{@"user":newUser.objectId, @"name":name, @"fbID":newUser[@"FBObjectID"], @"fbToken":[FBSDKAccessToken currentAccessToken].tokenString}
                                                             block:^(NSString *result, NSError *error) {
                                                                 if (!error) {
                                                                     // result is @"Hello world!"
                                                                     NSLog(@"%@", result);
                                                                 }
                                                             }];
                                 
                                 [self setDefaultsForUser:newUser];
                             }
                             
                         } else {
                                 
                             NSLog(@"User exists. Log them in!");
                             
                             if (newUser) {
                                 
                                 [PFUser logInWithUsernameInBackground:newUser.username password:newUser.password block:^(PFUser *user, NSError *error) {
                                     
                                     if (user) {
                                         // Do stuff after successful login.
                                         [self setDefaultsForUser:user];
                                         
                                     } else {
                                         // The login failed. Check error to see why.
                                         [self.delegate buttonPressEnd];
                                         [self.delegate loginUnsuccessful];
                                         NSLog(@"%@", error);
                                     }
                                }];
                             }
                         }
                     }];
                     
                 } else {
                     [self.delegate buttonPressEnd];
                     [self.delegate loginUnsuccessful];
                     NSLog(@"%@", error);
                 }
             }];
        }
    }];
    
}


-(NSString *) randomStringWithLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

- (void)noAccountButtonPressed {
    
    [self.delegate buttonPressStart];
    /*
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            NSLog(@"Anonymous login failed.");
            [self.delegate buttonPressEnd];
            [self.delegate loginUnsuccessful];
            [self anonLogin];
            
        } else {
            NSLog(@"Anonymous user logged in.");

            [self setDefaultsForUser:user];

        }
    }];*/
    
    [self setDefaultsForUser:currentUser];

    
}

- (void)anonToNormal {
    
    [self.delegate buttonPressStart];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    loginManager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    [loginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_location", @"user_birthday"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        NSLog(@"result:%@", result);
        NSLog(@"granted permissions: %@", result.grantedPermissions);
        //__block NSSet *grantedPermissions = result.grantedPermissions;
        
        if (error) {
            // Process error
            NSLog(@"error");
            [self.delegate buttonPressEnd];
            [self.delegate loginUnsuccessful];
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            
            if([[[UIDevice currentDevice] systemVersion] floatValue]<8.0)
            {
                /*
                 UIAlertView* curr1=[[UIAlertView alloc] initWithTitle:@"This app does not have access to Location service" message:@"You can enable access in Settings->Privacy->Location->Location Services" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 [curr1 show];
                 */
                [[[UIAlertView alloc] initWithTitle:@"Aw snap"
                                            message:@"We're having trouble connecting to Facebook. Please go to Settings -> Facebook -> Happening -> On"
                                           delegate:self
                                  cancelButtonTitle:@"I'm on it!"
                                  otherButtonTitles:nil, nil] show];
                
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Aw snap"
                                            message:@"We're having trouble connecting to Facebook. Please go to Settings -> Facebook -> Happening -> On"
                                           delegate:self
                                  cancelButtonTitle:@"I'm on it!"
                                  otherButtonTitles:nil, nil] show];
                
                /*  otherButtonTitles:@"Settings", nil] show]; */
            }
            
        } else if (result.isCancelled) {
            
            NSLog(@"fb login cancelled");
            [self.delegate buttonPressEnd];
            
        } else { //success ?
            
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     NSLog(@"fetched user:%@", result);
                     
                     NSDictionary *user = result;
                     
                     if ([user objectForKey:@"email"] != nil) {
                         
                         currentUser.username = [user objectForKey:@"email"];
                         currentUser.email = [user objectForKey:@"email"];
                         
                     } else {
                         NSLog(@"User disabled email permissions");
                         currentUser.username = [user objectForKey:@"link"];
                     }
                     currentUser.password = [user objectForKey:@"link"];
                     
                     
                     currentUser[@"FBObjectID"] = [user objectForKey:@"id"];
                     currentUser[@"link"] = [user objectForKey:@"link"];
                     
                     
                     if ([user objectForKey:@"first_name"] != nil)
                         currentUser[@"firstName"] = [user objectForKey:@"first_name"];
                     
                     if ([user objectForKey:@"last_name"] != nil)
                         currentUser[@"lastName"] = [user objectForKey:@"last_name"];
                     
                     if ([user objectForKey:@"gender"] != nil)
                         currentUser[@"gender"] = [user objectForKey:@"gender"];
                     
                     /*
                      if ([grantedPermissions containsObject:@"bio"])
                      parseUser[@"bio"] = [user objectForKey:@"bio"];
                      */
                     
                     if ([user objectForKey:@"birthday"] != nil)
                         currentUser[@"birthday"] = [user objectForKey:@"birthday"];
                     
                     if ([user objectForKey:@"location"] != nil) {
                         NSDictionary *locationDict = [user objectForKey:@"location"];
                         
                         if ([locationDict objectForKey:@"name"] != nil)
                             currentUser[@"fbLocationName"] = [locationDict objectForKey:@"name"];
                         currentUser[@"city"] = [locationDict objectForKey:@"name"];
                         
                     }
                     
                     // Defaults
                     currentUser[@"radius"] = @50;
                     currentUser[@"fbToken"] = [FBSDKAccessToken currentAccessToken].tokenString;
                     //parseUser[@"userLoc"] = [PFGeoPoint geoPointWithLatitude:38.907192 longitude:-77.036871];
                     
                     [currentUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (!error) {
                             NSLog(@"New user successfully signed up.");
                             
                             // Hooray! Let them use the app now.
                             NSLog(@"New user: %@", currentUser.username);
                             
                             if (currentUser) {
                                 
                                 NSString *name = @"";
                                 if ([user objectForKey:@"first_name"] != nil)
                                     name = [user objectForKey:@"first_name"];
                                 
                                 if ([user objectForKey:@"last_name"] != nil)
                                     name = [NSString stringWithFormat:@"%@ %@", name, [user objectForKey:@"last_name"]];
                                 
                                 [PFCloud callFunctionInBackground:@"newUser"
                                                    withParameters:@{@"user":currentUser.objectId, @"name":name, @"fbID":currentUser[@"FBObjectID"], @"fbToken":[FBSDKAccessToken currentAccessToken].tokenString}
                                                             block:^(NSString *result, NSError *error) {
                                                                 if (!error) {
                                                                     // result is @"Hello world!"
                                                                     NSLog(@"%@", result);
                                                                 }
                                                             }];
                                 
                                 [self setDefaultsForUser:currentUser];
                                 
                             }
                         } else {
                             
                             NSLog(@"User exists.");
                             
                             if (currentUser) {
                                 
                                 [PFUser logInWithUsernameInBackground:currentUser.username password:currentUser.password block:^(PFUser *user, NSError *error) {
                                     if (user) {
                                         // Do stuff after successful login.
                                         [self setDefaultsForUser:user];
                                         
                                     } else {
                                         // The login failed. Check error to see why.
                                         [self.delegate buttonPressEnd];
                                         [self.delegate loginUnsuccessful];
                                         NSLog(@"%@", error);
                                     }
                                 }];
                             }
                         }
                     }];
                 }
             }];
        }
    }];
    
}


- (void)setDefaultsForUser:(PFUser *)user {
    
    BOOL notisEnabled = NO;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        NSLog(@" ====== iOS 7 ====== ");
        UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (enabledTypes) {
            notisEnabled = YES;
        }
    } else {
        NSLog(@" ====== iOS 8 ====== ");
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
            notisEnabled = YES;
        }
    }
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    NSLog(@"Saving notification ID");
    
    // Associate the device with a user
    currentInstallation.channels = @[@"global", @"reminders", @"matches", @"friendJoined", @"popularEvents", @"allGroups", @"bestFriends"];
    currentInstallation[@"matchCount"] = @3;
    currentInstallation[@"userID"] = user.objectId;
    currentInstallation[@"enabled"] = @(notisEnabled);
    
    [currentInstallation saveEventually];
    
    if (user[@"firstVersion"] == nil) user[@"firstVersion"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    ///////////////////////////////////////////////
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"%@", user);
    
    [defaults setBool:NO forKey:@"refreshData"];
    [defaults setBool:NO forKey:@"noMoreEvents"];
    if (user[@"hasCreatedEvent"] == nil) user[@"hasCreatedEvent"] = @NO;
    if (user[@"hasLaunched"] == nil) user[@"hasLaunched"] = @NO;
    if (user[@"hasSwipedRight"] == nil) user[@"hasSwipedRight"] = @NO;
    if (user[@"locStatus"] == nil) user[@"locStatus"] = @"unknown";
    if (user[@"hasLoggedIn"] == nil) user[@"hasLoggedIn"] = @NO;
    
    if (notisEnabled) user[@"pushStatus"] = @"yes";
    else user[@"pushStatus"] = @"maybe";
    
    if (user[@"socialMode"] == nil) user[@"socialMode"] = @YES;
    
    if (user[@"userLocTitle"] == nil) user[@"userLocTitle"] = @"";
    if (user[@"userLocSubtitle"] == nil) user[@"userLocSubtitle"] = @"";
    if (user[@"radius"] == nil) user[@"radius"] = @50;
    
    NSArray *categories = [[NSArray alloc] initWithObjects:@"Nightlife", @"Entertainment", @"Music", @"Dining", @"Happy Hour", @"Sports", @"Shopping", @"Fundraiser", @"Meetup", @"Freebies", @"Other", nil];
    if (user[@"categories"] == nil) user[@"categories"] = categories;
    if (user[@"categoryName"] == nil) user[@"categoryName"] = @"Most Popular";
    if (user[@"time"] == nil) user[@"time"] = @"today";
        
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (self.wasUserAnonymous) {
        user[@"wasAnonymous"] = @YES;
        user[@"anonConversionDate"] = [NSDate date];
    
    } else {
        
        [appDelegate loadFriends];
    }
    
    [defaults synchronize];
    [user pinInBackground];
    [user saveEventually];
    
    [appDelegate.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
        
        // Once connected, authenticate user.
        // Check Authenticate step for authenticateLayerWithUserID source
        [appDelegate authenticateLayerWithUserID:user.objectId completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                [self.delegate buttonPressEnd];
                [self.delegate loginUnsuccessful];
            } else {
                [self.delegate buttonPressEnd];
                user[@"hasLoggedIn"] = @YES;
                [user saveEventually];
                [self.delegate loginSuccessful];
            }
        }];
        
    }];
    
}


@end
