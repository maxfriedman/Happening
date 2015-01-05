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
    NSArray *cityData;
    PFUser *parseUser;
    
}

@synthesize activityView, cityPicker;

-(void)viewDidLoad {
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [super viewDidLoad];
    NSLog(@"WasHandled: %d", appDelegate.wasHandled);
    
    parseUser = [PFUser user];
    // default city and location
    parseUser[@"city"] = @"Washington, DC";
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:38.907192 longitude:-77.036871];
    parseUser[@"userLoc"] = geoPoint;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"Washington, DC" forKey:@"userLocTitle"];
    [defaults setObject:@"" forKey:@"userLocSubtitle"];
    [defaults synchronize];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2));
    [activityView startAnimating];
    [self.view addSubview:activityView];

}
/*
- (void)fbButtonTap:(UIGestureRecognizer *)gestureRecognizer {
    
    [activityView startAnimating];
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"Made it!");
    cityPicker.alpha = 0;
    self.inLabel.alpha = 0;
    self.xButton.alpha = 0;
    _fbLoginView.alpha = 0;
}
*/
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    [activityView startAnimating];
    
    NSLog(@"Showing logged in user!");
    cityPicker.alpha = 0;
    self.inLabel.alpha = 0;
    self.xButton.alpha = 0;
    _fbLoginView.alpha = 0;
}


- (void)viewWillAppear:(BOOL)animated {
    
    _fbLoginView.alpha = 0;
    cityData = [[NSArray alloc]initWithObjects:@"Boston, MA", @"Washington, DC", @"My city isn't listed :(", nil];
    [cityPicker selectRow:1 inComponent:0 animated:NO];
    [[cityPicker.subviews objectAtIndex:1] setBackgroundColor:[UIColor whiteColor]];
    [[cityPicker.subviews objectAtIndex:2] setBackgroundColor:[UIColor whiteColor]];
    
    cityPicker.alpha = 0;
    self.inLabel.alpha = 0;
    self.xButton.alpha = 0;
    //_labelOne.alpha = 0;
    //_labelTwo.alpha = 0;
    //_whyFB.alpha = 0;
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [_fbLoginView setReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_events", @"user_about_me", @"rsvp_event", @"user_location"]];
    [_fbLoginView setDelegate:self];
    _objectID = nil;
    
    // Performs the fb login automatically, with no user action taken
    //[_fbLoginView.subviews[0] addTarget:self action:@selector(fbButtonTap:) forControlEvents:UIControlEventAllTouchEvents];
    [_fbLoginView.subviews[0] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        NSLog(@"Delaying a second...");
        _fbLoginView.alpha = 1;
        
        cityPicker.alpha = 1;
        self.inLabel.alpha = 1;
        self.xButton.alpha = 1;
        //_labelOne.alpha = 1;
        //_labelTwo.alpha = 1;
        //_whyFB.alpha = 1;
        [activityView stopAnimating];
        
    });
    
}


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    //NSLog(@"WasHandled: %d", appDelegate.wasHandled);
    [activityView startAnimating];
    _fbLoginView.alpha = 0;
    cityPicker.alpha = 0;
    self.inLabel.alpha = 0;
    self.xButton.alpha = 0;
    //_labelOne.alpha = 1;
    //_labelTwo.alpha = 1;
    //_whyFB.alpha = 1;

    
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
            
            /*
             PFACL *groupACL = [PFACL ACL];
             [groupACL setWriteAccess:YES forUserId:parseUser.objectId];
             [groupACL setReadAccess:YES forUserId:parseUser.objectId];
             parseUser.ACL = groupACL;
             */
            
            // Default radius
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
                        
                        [self performSegueWithIdentifier:@"toMainView" sender:self];
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
                                                                [activityView stopAnimating];
                                                                _fbLoginView.alpha = 1;
                                                                cityPicker.alpha = 1;
                                                                self.inLabel.alpha = 1;
                                                                self.xButton.alpha = 1;
                                                                NSLog(@"ERROR: %@", error);
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

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    
    return cityData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [cityData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"Selected Row %ld: %@", (long)row, [cityData objectAtIndex:row]);
    if (row == 0) {
        
        parseUser[@"city"] = [cityData objectAtIndex:row];
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:42.358431 longitude:-71.059773];
        parseUser[@"userLoc"] = geoPoint;
        [defaults setObject:@"Boston, MA" forKey:@"userLocTitle"];
        [defaults setObject:@"" forKey:@"userLocSubtitle"];
        [defaults synchronize];
        
    } else if (row == 1) {
        
        parseUser[@"city"] = [cityData objectAtIndex:row];
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:38.907192 longitude:-77.036871];
        parseUser[@"userLoc"] = geoPoint;
        [defaults setObject:@"Washington, DC" forKey:@"userLocTitle"];
        [defaults setObject:@"" forKey:@"userLocSubtitle"];
        [defaults synchronize];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@":(" message:@"Happening is working hard to bring you events from all over the world, but for now we're only featuring two cities. To continue, please choose one!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [cityPicker selectRow:1 inComponent:0 animated:NO];
        [alert show];
    }
    //Event[@"Hashtag"] = [self.cityData objectAtIndex:row];
    
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [cityData objectAtIndex:row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}

@end
