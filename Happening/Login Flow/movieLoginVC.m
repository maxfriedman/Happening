//
//  movieLoginVC.m
//  Happening
//
//  Created by Max on 1/25/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "movieLoginVC.h"

@interface movieLoginVC ()

@end

@implementation movieLoginVC {
    
    MPMoviePlayerController *player;
    PFUser *parseUser;
    UIActivityIndicatorView *activityView;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *stringPath = [[NSBundle mainBundle] pathForResource:@"Happening Intro vid" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:stringPath];
    
    player = [[MPMoviePlayerController alloc] initWithContentURL:url];  //[NSURL fileURLWithPath:url]];
    player.view.frame = self.view.frame; //CGRectMake(184, 200, 400, 300);
    [self.view addSubview:player.view];
    [self.view sendSubviewToBack:player.view];
    
    // Configure the movie player controller
    player.controlStyle = MPMovieControlStyleNone;
    player.repeatMode = MPMovieRepeatModeOne;
    player.scalingMode = MPMovieScalingModeAspectFill;
    [player prepareToPlay];
    
    parseUser = [PFUser user];
    // default city and location
    parseUser[@"city"] = @"Washington, DC";
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:38.907192 longitude:-77.036871];
    parseUser[@"userLoc"] = geoPoint;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Washington, DC" forKey:@"userLocTitle"];
    [defaults setObject:@"" forKey:@"userLocSubtitle"];
    [defaults synchronize];
    
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2));
    [self.view addSubview:activityView];
    
    
    [_fbLoginView setReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_events", @"user_about_me", @"rsvp_event", @"user_location"]];
    [_fbLoginView setDelegate:self];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    [player play];
    
}

- (IBAction)fbButton:(id)sender {
   /*
    NSArray *permissions =
    [NSArray arrayWithObjects:@"email", @"user_birthday", nil];
    
    [FBSession openActiveSessionWithReadPermissions:permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                      /* handle success + failure in block */
                                 // }];
    
    [activityView startAnimating];
    
    FBSessionStateHandler completionHandler = ^(FBSession *session, FBSessionState status, NSError *error) {
        /* handle success + failure in block */
        //[self sessionStateChanged:session state:status error:error];
        
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
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
            }
        }];

        
    };
    
    /*
    if ([FBSession activeSession].state == FBSessionStateCreatedTokenLoaded) {
        // we have a cached token, so open the session
        [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                                  completionHandler:completionHandler];
    } else { */
        //[self clearAllUserInfo];
        // create a new facebook session
        FBSession *fbSession = [[FBSession alloc] initWithPermissions:@[@"public_profile", @"email", @"user_friends", @"user_events", @"user_about_me",/* @"rsvp_event",*/ @"user_birthday", @"user_location"]];
        [FBSession setActiveSession:fbSession];
        [fbSession openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                  completionHandler:completionHandler];
    //}
    
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
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
