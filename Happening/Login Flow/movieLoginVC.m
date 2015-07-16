//
//  movieLoginVC.m
//  Happening
//
//  Created by Max on 1/25/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "movieLoginVC.h"
#import "RKSwipeBetweenViewControllers.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_WIDESCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height >= 568 )

@interface movieLoginVC () <TTTAttributedLabelDelegate>

@end

@implementation movieLoginVC {
    
    MPMoviePlayerController *player;
    PFUser *parseUser;
    UIActivityIndicatorView *activityView;
    
    UIImageView *imv;
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fbButton.alpha = 0;
    self.questionButton.alpha = 0;
    self.noAccountButton.alpha = 0;
    
    imv = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    if (IS_WIDESCREEN) {
        
        imv.image = [UIImage imageNamed:@"postLaunchBig"];
        
    } else {
        
        imv.image = [UIImage imageNamed:@"postLaunchSmall"];
    }
    
    [self.view addSubview:imv];

    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    if ([FBSDKAccessToken currentAccessToken] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasLoggedIn"]  /* && (ReachableViaWiFi | ReachableViaWWAN) */) {

        PFUser *user = [PFUser currentUser];
        user[@"fbToken"] = [FBSDKAccessToken currentAccessToken].tokenString;
        [user saveEventually];

        [self performSegueWithIdentifier:@"toMainTabBar" sender:self];

    } else if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] && [[NSUserDefaults standardUserDefaults] boolForKey:@"hasLoggedIn"]) {
                
        [self performSegueWithIdentifier:@"toMainTabBar" sender:self];
        
    } else {
    
        NSString *stringPath = [[NSBundle mainBundle] pathForResource:@"Happening Intro vid" ofType:@"mp4"];
        NSURL *url = [NSURL fileURLWithPath:stringPath];
        
        player = [[MPMoviePlayerController alloc] initWithContentURL:url];  //[NSURL fileURLWithPath:url]];
        player.view.frame = self.view.frame; //CGRectMake(184, 200, 400, 300);
        
        //[imv removeFromSuperview];
        
        [self.view addSubview:player.view];
        [self.view sendSubviewToBack:player.view];
        
        // Configure the movie player controller
        player.controlStyle = MPMovieControlStyleNone;
        player.repeatMode = MPMovieRepeatModeOne;
        player.scalingMode = MPMovieScalingModeAspectFill;
        [player prepareToPlay];
        
        parseUser = [PFUser currentUser];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = CGRectMake(0, 0, 50, 50);
        activityView.backgroundColor = [UIColor blackColor];
        activityView.layer.cornerRadius = 5.0;
        activityView.layer.masksToBounds = YES;
        activityView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - 150);
        [self.view addSubview:activityView];
        
        [self.view insertSubview:player.view belowSubview:imv];
        
        TTTAttributedLabel *label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, 470, 280, 45)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"OpenSans" size:9.0];
        label.textColor = [UIColor whiteColor];
        label.numberOfLines = 2;
        label.alpha = 0;
        
        // If you're using a simple `NSString` for your text,
        // assign to the `text` property last so it can inherit other label properties.
        NSString *text = @"We will never post without your permission.\nBy signing in you agree to our terms of service.";
        [label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
            NSRange underlinedRange = [[mutableAttributedString string] rangeOfString:@"terms of service." options:NSCaseInsensitiveSearch];
            
            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
            UIColor *blueColor = [UIColor colorWithRed:0 green:102.0/255 blue:1.0 alpha:1.0];
            [mutableAttributedString addAttribute:(NSString *)NSForegroundColorAttributeName value:blueColor range:underlinedRange];
            
            return mutableAttributedString;
        }];
        
        label.enabledTextCheckingTypes = NSTextCheckingTypeLink; // Automatically detect links when the label text is subsequently changed
        label.delegate = self; // Delegate methods are called when the user taps on a link (see `TTTAttributedLabelDelegate` protocol)
        
        label.linkAttributes = @{ (id)kCTForegroundColorAttributeName: [UIColor colorWithRed:0 green:102.0/255 blue:1.0 alpha:1.0], (id)kCTUnderlineStyleAttributeName : [NSNumber numberWithInt:NSUnderlineStyleSingle]};
        
        NSRange range = [label.text rangeOfString:@"terms of service"];
        [label addLinkToURL:[NSURL URLWithString:@"http://www.happening.city/terms"] withRange:range]; // Embedding a custom link in a substring
        
        [UIView animateWithDuration:0.5 animations:^{
            imv.alpha = 0.2;
            self.fbButton.alpha = 1;
            self.noAccountButton.alpha = 1;
            label.alpha = 1;
            //self.questionButton.alpha = 1;
        } completion:^(BOOL finished) {
            //code
            [self.view bringSubviewToFront:self.fbButton];
            [self.view bringSubviewToFront:self.questionButton];
            [self.view addSubview:label];
            [self.view bringSubviewToFront:label];
            [self.view bringSubviewToFront:self.noAccountButton];
            [self.view sendSubviewToBack:player.view];
        }];
        
        //[_fbLoginView setReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_location", @"user_birthday"]];
        //[_fbLoginView setDelegate:self];
        
        [player play];
        
        UIView *maskView = [[UIView alloc] initWithFrame:self.view.frame];
        maskView.backgroundColor = [UIColor clearColor];
        
        CAGradientLayer *l = [CAGradientLayer layer];
        l.frame = player.view.bounds;
        l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9] CGColor], nil];
        
        //l.startPoint = CGPointMake(0.0, 0.7f);
        //l.endPoint = CGPointMake(0.0f, 1.0f);
        l.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.2],
                       [NSNumber numberWithFloat:0.5],
                       //[NSNumber numberWithFloat:0.9],
                       [NSNumber numberWithFloat:1.0], nil];
        
        [maskView.layer insertSublayer:l atIndex:0];
        [player.view addSubview:maskView];
        
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    NSLog(@"%@", url);
}

- (void)yourNewFunction
{
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];    
    RKSwipeBetweenViewControllers *rk = [storyboard instantiateViewControllerWithIdentifier:@"rk"];
    [self presentViewController:rk animated:NO completion:nil];
     */
}

- (IBAction)fbButtonAction:(id)sender {

    [self enableButtons:NO];
    [activityView startAnimating];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    loginManager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    [loginManager logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_location", @"user_birthday"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        NSLog(@"result:%@", result);
        NSLog(@"granted permissions: %@", result.grantedPermissions);
        //__block NSSet *grantedPermissions = result.grantedPermissions;
        
        if (error) {
            // Process error
            NSLog(@"error");
            [self enableButtons:YES];
            [activityView stopAnimating];
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
        
            
            [player play];
        
        } else if (result.isCancelled) {
            
            NSLog(@"fb login cancelled");
            [activityView stopAnimating];
            [self enableButtons:YES];
            [player play];
            
        } else { //success ?
            
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
                     
                     if ([user objectForKey:@"email"] != nil) {
                
                         parseUser.username = [user objectForKey:@"email"];
                         parseUser.email = [user objectForKey:@"email"];

                     } else {
                         NSLog(@"User disabled email permissions");
                         parseUser.username = [user objectForKey:@"link"];
                     }
                     parseUser.password = [user objectForKey:@"link"];
            
            
                     parseUser[@"FBObjectID"] = [user objectForKey:@"id"];
                     parseUser[@"link"] = [user objectForKey:@"link"];
            
            
                     if ([user objectForKey:@"first_name"] != nil)
                         parseUser[@"firstName"] = [user objectForKey:@"first_name"];
            
                     if ([user objectForKey:@"last_name"] != nil)
                         parseUser[@"lastName"] = [user objectForKey:@"last_name"];

                     if ([user objectForKey:@"gender"] != nil)
                         parseUser[@"gender"] = [user objectForKey:@"gender"];
            
                     /*
                     if ([grantedPermissions containsObject:@"bio"])
                         parseUser[@"bio"] = [user objectForKey:@"bio"];
                      */
                      
                     if ([user objectForKey:@"birthday"] != nil)
                         parseUser[@"birthday"] = [user objectForKey:@"birthday"];
            
                     if ([user objectForKey:@"location"] != nil) {
                         NSDictionary *locationDict = [user objectForKey:@"location"];
                
                         if ([locationDict objectForKey:@"name"] != nil)
                             parseUser[@"fbLocationName"] = [locationDict objectForKey:@"name"];
                             parseUser[@"city"] = [locationDict objectForKey:@"name"];

                     }
            
                     // Defaults
                     parseUser[@"radius"] = @50;
                     parseUser[@"fbToken"] = [FBSDKAccessToken currentAccessToken].tokenString;
                     //parseUser[@"userLoc"] = [PFGeoPoint geoPointWithLatitude:38.907192 longitude:-77.036871];
                     
                     if ([PFUser currentUser].isAuthenticated) {
                        
                         [parseUser saveEventually];
                         
                         [PFUser logInWithUsernameInBackground:parseUser.username password:parseUser.password block:^(PFUser *user, NSError *error) {
                             
                             if (user) {
                                 // Do stuff after successful login.
                                 [user pinInBackground];
                                 
                                 AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                 
                                 [appDelegate.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
                                     
                                     // Once connected, authenticate user.
                                     // Check Authenticate step for authenticateLayerWithUserID source
                                     [appDelegate authenticateLayerWithUserID:user.objectId completion:^(BOOL success, NSError *error) {
                                         if (!success) {
                                             NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                                         } else {
                                             [activityView stopAnimating];
                                             [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLoggedIn"];
                                             [[NSUserDefaults standardUserDefaults] synchronize];
                                             [self performSegueWithIdentifier:@"toMain" sender:self];
                                         }
                                     }];
                                     
                                 }];
                                 
                             } else {
                                 // The login failed. Check error to see why.
                                 [self enableButtons:YES];
                                 [activityView stopAnimating];
                                 NSLog(@"%@", error);
                                 [player play];
                             }
                         }];
                     
                     } else {
                     
                         [parseUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                             if (!error) {
                                 NSLog(@"New user successfully signed up.");
                        
                                 // Hooray! Let them use the app now.
                                 NSLog(@"New user: %@", parseUser.username);
                        
                                 if (parseUser) {
                                     
                                     [parseUser pinInBackground];
                                     
                                     NSString *name = @"";
                                     if ([user objectForKey:@"first_name"] != nil)
                                         name = [user objectForKey:@"first_name"];
                                     
                                     if ([user objectForKey:@"last_name"] != nil)
                                         name = [NSString stringWithFormat:@"%@ %@", name, [user objectForKey:@"last_name"]];
                                     
                                     NSLog(@"%@", name);
                                     
                                     [PFCloud callFunctionInBackground:@"newUser"
                                                        withParameters:@{@"user":parseUser.objectId, @"name":name, @"fbID":parseUser[@"FBObjectID"], @"fbToken":[FBSDKAccessToken currentAccessToken].tokenString}
                                                                 block:^(NSString *result, NSError *error) {
                                                                     if (!error) {
                                                                         // result is @"Hello world!"
                                                                         NSLog(@"%@", result);
                                                                     }
                                                                 }];
                            
                                     if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                                     
                                         UIRemoteNotificationType types = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];

                                         if (types) {

                                             PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                                     
                                             NSLog(@"Saving notification ID");
                                         
                                             // Associate the device with a user
                                             currentInstallation.channels = @[@"global", @"reminders", @"matches", @"friendJoined", @"popularEvents", @"allGroups", @"bestFriends"];
                                             currentInstallation[@"matchCount"] = @5;
                                             currentInstallation[@"userID"] = parseUser.objectId;
                                         
                                             [currentInstallation saveEventually];
                                         }
                                     } else if ([PFInstallation currentInstallation] != nil) {
                                         
                                         PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                                         
                                         NSLog(@"Saving notification ID");
                                         
                                         // Associate the device with a user
                                         currentInstallation.channels = @[@"global", @"reminders", @"matches", @"friendJoined", @"popularEvents", @"allGroups", @"bestFriends"];
                                         currentInstallation[@"matchCount"] = @5;
                                         currentInstallation[@"userID"] = parseUser.objectId;
                                         
                                         [currentInstallation saveEventually];
                                         
                                     }
                                     
                                     AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                     
                                     [appDelegate.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
                                         if (!success) {
                                             NSLog(@"Failed to connect to Layer: %@", error);
                                         } else {
                                             // Once connected, authenticate user.
                                             // Check Authenticate step for authenticateLayerWithUserID source
                                             [appDelegate authenticateLayerWithUserID:parseUser.objectId completion:^(BOOL success, NSError *error) {
                                                 if (!success) {
                                                     NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                                                 } else {
                                                     [activityView stopAnimating];
                                                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLoggedIn"];
                                                     [[NSUserDefaults standardUserDefaults] synchronize];
                                                     [self performSegueWithIdentifier:@"toMain" sender:self];
                                                 }
                                             }];
                                         }
                                     }];
                                 }
                                 
                             } else {
                        
                                 NSLog(@"User exists.");
                        
                                 if (parseUser) {
                            
                                     [PFUser logInWithUsernameInBackground:parseUser.username password:parseUser.password
                                                            block:^(PFUser *user, NSError *error) {
                                                                if (user) {
                                                                    // Do stuff after successful login.
                                                                    [user pinInBackground];
                                                                    
                                                                    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                                                    
                                                                    [appDelegate.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
                                                                        
                                                                        // Once connected, authenticate user.
                                                                        // Check Authenticate step for authenticateLayerWithUserID source
                                                                        [appDelegate authenticateLayerWithUserID:user.objectId completion:^(BOOL success, NSError *error) {
                                                                            if (!success) {
                                                                                NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                                                                            } else {
                                                                                [activityView stopAnimating];
                                                                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLoggedIn"];
                                                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                [self performSegueWithIdentifier:@"toMain" sender:self];
                                                                            }
                                                                        }];
                                                                        
                                                                    }];
                                                                    
                                                                } else {
                                                                    // The login failed. Check error to see why.
                                                                    [self enableButtons:YES];
                                                                    [activityView stopAnimating];
                                                                    NSLog(@"%@", error);
                                                                    [player play];
                                                                }
                                                           }];
                                 }
                             }
                         }];
                     }
                 }
             }];
        }
    }];
    
    /*
        
        PFUser *currentUser = [PFUser currentUser];
        
        PFQuery *query = [PFUser query];
        
        NSArray *users = [[NSArray alloc]init];
        users = [query findObjects];
        
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                //[connection start];
                // Success! Include your code to handle the results here
                
                //_nameLabel.text = [NSString stringWithFormat:@"Hey, %@!",[result objectForKey:@"first_name"]];
                
                if ([result objectForKey:@"email"] != nil) {
                    parseUser.username = [result objectForKey:@"email"];
                    parseUser.email = [result objectForKey:@"email"];
                } else {
                    NSLog(@"User disabled email permissions");
                    parseUser.username = [result objectForKey:@"link"];
                }
                parseUser.password = [result objectForKey:@"link"];
                
                
                parseUser[@"FBObjectID"] = [result objectForKey:@"id"];
                parseUser[@"link"] = [result objectForKey:@"link"];
                
                
                if ([result objectForKey:@"first_name"] != nil)
                    parseUser[@"firstName"] = [result objectForKey:@"first_name"];
                
                if ([result objectForKey:@"last_name"] != nil)
                    parseUser[@"lastName"] = [result objectForKey:@"last_name"];
                
                if ([result objectForKey:@"gender"] != nil)
                    parseUser[@"gender"] = [result objectForKey:@"gender"];

                if ([result objectForKey:@"bio"] != nil)
                    parseUser[@"bio"] = [result objectForKey:@"bio"];

                if ([result objectForKey:@"birthday"] != nil)
                    parseUser[@"birthday"] = [result objectForKey:@"birthday"];

                if ([result objectForKey:@"location"] != nil) {
                    NSDictionary *locationDict = [result objectForKey:@"location"];
                    
                    if ([locationDict objectForKey:@"name"] != nil)
                        parseUser[@"fbLocationName"] = [locationDict objectForKey:@"name"];
                    
                }

                // Default radius
                NSNumber *fifty = [NSNumber numberWithInt:50];
                parseUser[@"radius"] = fifty;

                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:50 forKey:@"sliderValue"];
                [defaults synchronize];
                
                
                [parseUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        NSLog(@"New user successfully signed up.");
                        // Hooray! Let them use the app now.
                        NSLog(@"CU2: %@", parseUser.username);
                        
                        if (parseUser) {
                            NSLog(@"CU3: %@", parseUser.username);
                            
                            self.fbButton.alpha = 1.0;
                            self.fbButton.userInteractionEnabled = YES;
                            [activityView stopAnimating];
                            [self performSegueWithIdentifier:@"toMain" sender:self];
                        }
                    } else {
                        NSLog(@"User exists.");
                        // Show the errorString somewhere and let the user try again.
                        NSLog(@"CU4: %@", parseUser.username);
                        
                        if (parseUser) {
                            NSLog(@"CU5: %@", parseUser.username);
                            
                            [PFUser logInWithUsernameInBackground:parseUser.username password:parseUser.password
                                                            block:^(PFUser *user, NSError *error) {
                                                                if (user) {
                                                                    // Do stuff after successful login.
                                                                    [activityView stopAnimating];
                                                                    [self performSegueWithIdentifier:@"toMain" sender:self];
                                                                } else {
                                                                    // The login failed. Check error to see why.
                                                                    self.fbButton.alpha = 1.0;
                                                                    self.fbButton.userInteractionEnabled = YES;
                                                                    [activityView stopAnimating];
                                                                    NSLog(@"%@", error);
                                                                    
                                                                }
                                                            }];
                            
                            //[self performSegueWithIdentifier:@"toChooseLoc" sender:self];
                        }
                    }
                    
                }];
                
                NSLog(@"Parse info: %@, %@, %@", parseUser.username, parseUser.email, parseUser.password);
                
                NSLog(@"user info: %@", result);
                
                
            } else {
                NSLog(@"error");
                self.fbButton.alpha = 1.0;
                self.fbButton.userInteractionEnabled = YES;
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
            }
        }];

        
    };
    
     */
    
}

-(void)enableButtons: (BOOL)shouldEnable {
    
    self.fbButton.enabled = shouldEnable;
    self.noAccountButton.enabled = shouldEnable;
    
}

- (IBAction)noAccountButtonPressed:(id)sender {
    
    [self enableButtons:NO];
    [activityView startAnimating];
    
    // Defaults
    //[PFUser enableAutomaticUser];
    
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            NSLog(@"Anonymous login failed.");
            [self enableButtons:YES];
            
        } else {
            NSLog(@"Anonymous user logged in.");
            user[@"radius"] = @50;
            [user pinInBackground];
            
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
                
                UIRemoteNotificationType types = [[UIApplication sharedApplication] isRegisteredForRemoteNotifications];
                
                if (types) {
                    
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    
                    NSLog(@"Saving notification ID");
                    
                    // Associate the device with a user
                    currentInstallation.channels = @[@"global", @"reminders", @"matches", @"friendJoined", @"popularEvents", @"allGroups", @"bestFriends"];
                    currentInstallation[@"matchCount"] = @5;
                    currentInstallation[@"userID"] = user.objectId;
                    
                    [currentInstallation saveEventually];
                }
            } else if ([PFInstallation currentInstallation] != nil) {
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                
                NSLog(@"Saving notification ID");
                
                // Associate the device with a user
                currentInstallation.channels = @[@"global", @"reminders", @"matches", @"friendJoined", @"popularEvents", @"allGroups", @"bestFriends"];
                currentInstallation[@"matchCount"] = @5;
                currentInstallation[@"userID"] = user.objectId;
                
                [currentInstallation saveEventually];
                
            }
            
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            [appDelegate.layerClient connectWithCompletion:^(BOOL success, NSError *error) {
                if (!success) {
                    NSLog(@"Failed to connect to Layer: %@", error);
                    [self enableButtons:YES];

                } else {
                    // Once connected, authenticate user.
                    // Check Authenticate step for authenticateLayerWithUserID source
                    [appDelegate authenticateLayerWithUserID:user.objectId completion:^(BOOL success, NSError *error) {
                        if (!success) {
                            NSLog(@"Failed Authenticating Layer Client with error:%@", error);
                        } else {
                            [activityView stopAnimating];
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLoggedIn"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            [self performSegueWithIdentifier:@"toMain" sender:self];
                        }
                        [self enableButtons:YES];

                    }];
                }
            }];
        }
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        //code for opening settings app in iOS 8
        /*
        NSURL*url=[NSURL URLWithString:@"prefs:root=WIFI"];
        [[UIApplication sharedApplication] openURL:url];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=General"]];
        */
        //UIApplicationOpenSettingsURLString
    }
}

/*
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    

    PFUser *currentUser = [PFUser currentUser];
    
    NSLog(@"CU1: %@", currentUser.username);
    
    PFQuery *query = [PFUser query];
    
    NSArray *users = [[NSArray alloc]init];
    users = [query findObjects];
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            //[connection start];
            // Success! Include your code to handle the results here
            
            //_nameLabel.text = [NSString stringWithFormat:@"Hey, %@!",[result objectForKey:@"first_name"]];
            
            if ([result objectForKey:@"email"] != nil) {
                parseUser.username = [result objectForKey:@"email"];
                parseUser.email = [result objectForKey:@"email"];
            } else {
                NSLog(@"User disabled email permissions");
                parseUser.username = [result objectForKey:@"link"];
            }
            
            parseUser.password = [result objectForKey:@"link"];
            
            parseUser[@"firstName"] = [result objectForKey:@"first_name"];
            parseUser[@"lastName"] = [result objectForKey:@"last_name"];
            parseUser[@"gender"] = [result objectForKey:@"gender"];
            parseUser[@"link"] = [result objectForKey:@"link"];
            
            parseUser[@"bio"] = [result objectForKey:@"bio"];
            parseUser[@"birthday"] = [result objectForKey:@"birthday"];
            
            NSDictionary *locationDict = [result objectForKey:@"location"];
            parseUser[@"fbLocationName"] = [locationDict objectForKey:@"name"];
            
            parseUser[@"FBObjectID"] = [result objectForKey:@"id"];
            
            // Default radius
            NSNumber *fifty = [NSNumber numberWithInt:50];
            parseUser[@"radius"] = fifty;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:50 forKey:@"sliderValue"];
            [defaults synchronize];
            
            
            [parseUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"New user successfully signed up.");
                    // Hooray! Let them use the app now.
                    NSLog(@"CU2: %@", parseUser.username);
                    
                    if (parseUser) {
                        NSLog(@"CU3: %@", parseUser.username);
                        
                        [self performSegueWithIdentifier:@"toMain" sender:self];
                    }
                } else {
                    NSLog(@"User exists.");
                    // Show the errorString somewhere and let the user try again.
                    NSLog(@"CU4: %@", parseUser.username);
                    
                    if (parseUser) {
                        NSLog(@"CU5: %@", parseUser.username);
                        
                        [PFUser logInWithUsernameInBackground:parseUser.username password:parseUser.password
                                                        block:^(PFUser *user, NSError *error) {
                                                            if (user) {
                                                                // Do stuff after successful login.
                                                                [self performSegueWithIdentifier:@"toMain" sender:self];
                                                            } else {
                                                                // The login failed. Check error to see why.
                                                                NSLog(@"%@", error);
 
                                                            }
                                                        }];
                        
                        //[self performSegueWithIdentifier:@"toChooseLoc" sender:self];
                    }
                }
                
            }];
            
            NSLog(@"Parse info: %@, %@, %@", parseUser.username, parseUser.email, parseUser.password);
            
            NSLog(@"user info: %@", result);
            
            
        } else {
            NSLog(@"error");
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
    
}
 */

/*
-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    
}

- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"That's odd"
                          otherButtonTitles:nil] show];
    }
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"toMainTabBar"]) {
        
        MHCustomTabBarController *mh = [segue destinationViewController];
        if (self.eventIdFromNotification != nil) {
            mh.eventIdForSegue = self.eventIdFromNotification;
        }
    }
}


@end
