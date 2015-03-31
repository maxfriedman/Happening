//
//  LoginView.m
//  HappeningParse
//
//  Created by Max on 10/10/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "LoginView.h"

#import "TabBarViewController.h"

@interface LoginView ()

@property (strong, nonatomic) IBOutlet FBSDKLoginButton *fbLoginView;
@property (strong, nonatomic) NSString *objectID;
@property (strong, nonatomic) IBOutlet UILabel *labelOne;
//@property (strong, nonatomic) IBOutlet UILabel *labelTwo;
@property (strong, nonatomic) IBOutlet UIButton *whyFB;

@end

@implementation LoginView {
    
    NSArray *cityData;
    PFUser *parseUser;
    BOOL animationFinished;
}

@synthesize activityView, cityPicker;

-(void)viewDidLoad {
    
    [super viewDidLoad];
    animationFinished = YES;
    
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
    [self.view addSubview:activityView];
    
    //self.xButton.imageView.image = [LoginView filledImageFrom:self.xButton.imageView.image withColor:[UIColor whiteColor]];

}

- (void)viewWillAppear:(BOOL)animated {
    
    // Loads the city names on the picker and sets
    cityData = [[NSArray alloc]initWithObjects:@"Boston, MA", @"Washington, DC", @"My city isn't listed :(", nil];
    [cityPicker selectRow:1 inComponent:0 animated:NO];
    [[cityPicker.subviews objectAtIndex:1] setBackgroundColor:[UIColor whiteColor]];
    [[cityPicker.subviews objectAtIndex:2] setBackgroundColor:[UIColor whiteColor]];
    
    //UIImage *image = [UIImage imageNamed:@"noButton"];
    //image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    //self.xButton.imageView.tintColor = [UIColor colorWithRed:0.7f green:0.0f blue:0.0f alpha:1];
    //self.xButton.imageView.image = image;
    
}

/*
- (void)viewDidAppear:(BOOL)animated {
    
    [_fbLoginView setReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_events", @"user_about_me", @"rsvp_event", @"user_location"]];
    [_fbLoginView setDelegate:self];
    _objectID = nil;
    
}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    
    [activityView startAnimating];
    
    NSLog(@"Showing logged in user!");
    _fbLoginView.alpha = 0;
    _labelOne.alpha = 0;
    //_labelTwo.alpha = 0;
    _whyFB.alpha = 0;
    cityPicker.alpha = 0;
    self.inLabel.alpha = 0;
    self.xButton.alpha = 0;
}


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    [activityView startAnimating];
    
    _fbLoginView.alpha = 0;
    _labelOne.alpha = 0;
    //_labelTwo.alpha = 0;
    _whyFB.alpha = 0;
    cityPicker.alpha = 0;
    self.inLabel.alpha = 0;
    self.xButton.alpha = 0;
    
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
                                                                
                                                                _fbLoginView.alpha = 1;
                                                                _labelOne.alpha = 1;
                                                                //_labelTwo.alpha = 0;
                                                                _whyFB.alpha = 1;
                                                                cityPicker.alpha = 1;
                                                                self.inLabel.alpha = 1;
                                                                self.xButton.alpha = 1;
                                                                [activityView stopAnimating];
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

+ (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color{
    
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
*/

@end
