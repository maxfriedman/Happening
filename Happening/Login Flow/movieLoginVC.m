//
//  movieLoginVC.m
//  Happening
//
//  Created by Max on 1/25/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "movieLoginVC.h"
#import "RKSwipeBetweenViewControllers.h"

#define IS_WIDESCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height >= 568 )

@interface movieLoginVC ()

@end

@implementation movieLoginVC {
    
    MPMoviePlayerController *player;
    PFUser *parseUser;
    UIActivityIndicatorView *activityView;
    
    UIImageView *imv;
    
}

/*
- (void)viewWillAppear:(BOOL)animated {
        
    if ([FBSDKAccessToken currentAccessToken]) {
     
        [self performSelector:@selector(yourNewFunction) withObject:nil afterDelay:0.0];
    }
    
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.fbButton.alpha = 0;
    self.questionButton.alpha = 0;
    
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
    
    if ([FBSDKAccessToken currentAccessToken]) {

        
        [self performSegueWithIdentifier:@"toMain" sender:self];
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
        
        parseUser = [PFUser user];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2));
        
        [self.view insertSubview:player.view belowSubview:imv];
        
        [UIView animateWithDuration:0.5 animations:^{
            imv.alpha = 0.1;
            self.fbButton.alpha = 1;
            self.questionButton.alpha = 1;
        } completion:^(BOOL finished) {
            //code
            [self.view bringSubviewToFront:self.fbButton];
            [self.view bringSubviewToFront:self.questionButton];
        }];
        
        [_fbLoginView setReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_location"]];
        [_fbLoginView setDelegate:self];
        
        [player play];
        
    }
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

    self.fbButton.alpha = 0.8;
    self.fbButton.userInteractionEnabled = NO;
    [activityView startAnimating];
    
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    loginManager.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    [loginManager logInWithReadPermissions:self.fbLoginView.readPermissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        
        NSLog(@"result:%@", result);
        __block NSSet *grantedPermissions = result.grantedPermissions;
        
        if (error) {
            // Process error
            NSLog(@"error");
            self.fbButton.alpha = 1.0;
            self.fbButton.userInteractionEnabled = YES;
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        
        } else if (result.isCancelled) {
            
            NSLog(@"fb login cancelled");
            self.fbButton.alpha = 1.0;
            self.fbButton.userInteractionEnabled = YES;
            
        } else { //success ?
            
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     NSLog(@"fetched user:%@", result);

                     NSDictionary *user = result;
                     
                     if ([grantedPermissions containsObject:@"email"]) {
                
                         parseUser.username = [user objectForKey:@"email"];
                         parseUser.email = [user objectForKey:@"email"];

                     } else {
                         NSLog(@"User disabled email permissions");
                         parseUser.username = [user objectForKey:@"link"];
                     }
                     parseUser.password = [user objectForKey:@"link"];
            
            
                     parseUser[@"FBObjectID"] = [user objectForKey:@"id"];
                     parseUser[@"link"] = [user objectForKey:@"link"];
            
            
                     if ([grantedPermissions containsObject:@"first_name"])
                         parseUser[@"firstName"] = [user objectForKey:@"first_name"];
                     
                     if ([grantedPermissions containsObject:@"last_name"])
                         parseUser[@"lastName"] = [user objectForKey:@"last_name"];
            
                     if ([grantedPermissions containsObject:@"gender"])
                         parseUser[@"gender"] = [user objectForKey:@"gender"];
            
                     if ([grantedPermissions containsObject:@"bio"])
                         parseUser[@"bio"] = [user objectForKey:@"bio"];
            
                     if ([grantedPermissions containsObject:@"birthday"])
                         parseUser[@"birthday"] = [user objectForKey:@"birthday"];
            
                     if ([grantedPermissions containsObject:@"location"]) {
                         NSDictionary *locationDict = [user objectForKey:@"location"];
                
                         if ([locationDict objectForKey:@"name"] != nil)
                             parseUser[@"fbLocationName"] = [locationDict objectForKey:@"name"];
            
                     }
            
                     // Defaults
                     parseUser[@"radius"] = @50;
                     parseUser[@"city"] = @"";
                     //parseUser[@"userLoc"] = [PFGeoPoint geoPointWithLatitude:38.907192 longitude:-77.036871];
            
                     [parseUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (!error) {
                             NSLog(@"New user successfully signed up.");
                    
                    // Hooray! Let them use the app now.
                    NSLog(@"New user: %@", parseUser.username);
                    
                    if (parseUser) {
                        
                        //self.fbButton.alpha = 1.0;
                        //self.fbButton.userInteractionEnabled = YES;
                        [activityView stopAnimating];
                        NSLog(@"2");
                        [self performSegueWithIdentifier:@"toMain" sender:self];
                    }
                } else {
                    
                    NSLog(@"User exists.");
                    
                    if (parseUser) {
                        
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
                    }
                }
            }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
