//
//  LogInExistingUser.m
//  HappeningParse
//
//  Created by Max on 11/10/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "LogInExistingUser.h"

@interface LogInExistingUser ()

@property (strong, nonatomic) NSString *objectID;

@end

@implementation LogInExistingUser {
    
    AppDelegate *appDelegate;
    
}

@synthesize activityView;

-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - 100);
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    
    _fbLoginView.alpha = 0;
    
    //_labelOne.alpha = 0;
    //_labelTwo.alpha = 0;
    //_whyFB.alpha = 0;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [_fbLoginView setReadPermissions:@[@"public_profile", @"email", @"user_friends"]];
    [_fbLoginView setDelegate:self];
    _objectID = nil;
    
    // Performs the fb login automatically, with no user action taken
    [_fbLoginView.subviews[0] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    NSLog(@"1");
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        NSLog(@"Delaying a second...");
        _fbLoginView.alpha = 1;
        //_labelOne.alpha = 1;
        //_labelTwo.alpha = 1;
        //_whyFB.alpha = 1;
        [activityView stopAnimating];
        
    });
    NSLog(@"2");
    
}


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
            PFUser *parseUser = [PFUser user];
            
            parseUser.username = [result objectForKey:@"email"];
            parseUser.password = [result objectForKey:@"link"];
            parseUser.email = [result objectForKey:@"email"];
            
            parseUser[@"firstName"] = [result objectForKey:@"first_name"];
            parseUser[@"lastName"] = [result objectForKey:@"last_name"];
            parseUser[@"gender"] = [result objectForKey:@"gender"];
            parseUser[@"link"] = [result objectForKey:@"link"];
            
            /*
             PFACL *groupACL = [PFACL ACL];
             [groupACL setWriteAccess:YES forUserId:parseUser.objectId];
             [groupACL setReadAccess:YES forUserId:parseUser.objectId];
             parseUser.ACL = groupACL;
             */
            
            // Default radius
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSNumber *fifty = [NSNumber numberWithInt:50];
            parseUser[@"radius"] = fifty;
            //appDelegate.sliderValue = 50;
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:50 forKey:@"sliderValue"];
            [defaults synchronize];
            
            [parseUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"New user successfully signed up.");
                    // Hooray! Let them use the app now.
                    NSLog(@"CU2: %@", parseUser.username);

                    if (parseUser && (parseUser[@"userLoc"]==nil)) {
                        NSLog(@"CU3: %@", parseUser.username);
                        
                        [self performSegueWithIdentifier:@"toChooseLoc2" sender:self];
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
                                                                PFGeoPoint *userLoc = parseUser[@"userLoc"];
                                                                double latitude = userLoc.latitude;
                                                                double longitude = userLoc.longitude;
                                                                MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
                                                                MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                                                                appDelegate.userLocation = mapItem;
                                                                
                                                                [self performSegueWithIdentifier:@"toMainView" sender:self];
                                                            } else {
                                                                // The login failed. Check error to see why.
                                                                NSLog(@"%@", error);
                                                            }
                                                        }];
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

@end
