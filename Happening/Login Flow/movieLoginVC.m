//
//  movieLoginVC.m
//  Happening
//
//  Created by Max on 1/25/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "movieLoginVC.h"
#import "RKSwipeBetweenViewControllers.h"
#import "AppDelegate.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "webViewController.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_WIDESCREEN ( [ [ UIScreen mainScreen ] bounds ].size.height >= 568 )

@interface movieLoginVC () <TTTAttributedLabelDelegate, LoginButtonDelegate>

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
    
    [self.fbButton setButtonType:@"fb"];
    [self.noAccountButton setButtonType:@"anon"];
    self.fbButton.delegate = self;
    self.noAccountButton.delegate = self;
    
    self.fbButton.alpha = 0;
    self.questionButton.alpha = 0;
    self.noAccountButton.alpha = 0;
    
    self.fbButton.enabled = NO;
    self.noAccountButton.enabled = NO;
    
    //NSLog(@"%@", [PFUser currentUser]);
    
    if ([PFUser currentUser][@"firstName"] == nil) {
        
        self.fbButton.enabled = YES;
        self.noAccountButton.enabled = YES;
        
    } else {
        
        self.fbButton.userExists = YES;
        self.noAccountButton.userExists = YES;
        
        self.fbButton.enabled = YES;
        self.noAccountButton.enabled = NO;
        [self.noAccountButton removeFromSuperview];
    }
    
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

    if ([FBSDKAccessToken currentAccessToken] && [[PFUser currentUser][@"hasLoggedIn"] isEqualToNumber:@YES]  /* && (ReachableViaWiFi | ReachableViaWWAN) */) {

        PFUser *user = [PFUser currentUser];
        user[@"fbToken"] = [FBSDKAccessToken currentAccessToken].tokenString;
        if (user[@"matchCount"] == nil) { user[@"matchCount"] = @2;
            [PFInstallation currentInstallation][@"matchCount"] = @2;
            [[PFInstallation currentInstallation] saveEventually];
        }
        if (user[@"score"] == nil) user[@"score"] = @10;
        if (user[@"eventCount"] == nil || [user[@"eventCount"] intValue] == 0) [self checkAndUpdateCounts];
        [self checkAndUpdateCounts];
        [user saveEventually];
        [self loadFriends];

        [self performSegueWithIdentifier:@"toMainTabBar" sender:self];

    } else if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] && [[PFUser currentUser][@"hasLoggedIn"] isEqualToNumber:@YES]) {
        
        if ([PFUser currentUser][@"score"] == nil) [PFUser currentUser][@"score"] = @10;
        [self performSegueWithIdentifier:@"toMainTabBar" sender:self];
        
    } else {
    
        if (!player) {
        
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
            l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] CGColor], nil];
            
            //l.startPoint = CGPointMake(0.0, 0.7f);
            //l.endPoint = CGPointMake(0.0f, 1.0f);
            l.locations = [NSArray arrayWithObjects:
                           [NSNumber numberWithFloat:1.0],
                           [NSNumber numberWithFloat:0.8],
                           [NSNumber numberWithFloat:0.5],
                           //[NSNumber numberWithFloat:0.9],
                           [NSNumber numberWithFloat:0.0], nil];
            
            [maskView.layer insertSublayer:l atIndex:0];
            [imv addSubview:maskView];
        }
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    
    NSLog(@"%@", url);
    [self performSegueWithIdentifier:@"toTerms" sender:self];

}

- (void)yourNewFunction
{
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];    
    RKSwipeBetweenViewControllers *rk = [storyboard instantiateViewControllerWithIdentifier:@"rk"];
    [self presentViewController:rk animated:NO completion:nil];
     */
}

-(void)buttonPressStart {
    
    [activityView startAnimating];
    self.fbButton.enabled = NO;
    self.noAccountButton.enabled = NO;

}

-(void)buttonPressEnd {
    
    [activityView stopAnimating];
    self.fbButton.enabled = YES;
    self.noAccountButton.enabled = YES;
    [player play];
    
}

-(void)loginSuccessful {
    
    [self performSegueWithIdentifier:@"toMain" sender:self];
}

-(void)loginUnsuccessful {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong during the sign up process. Please email us at hello@happening.city. We apologize for the inconvenience." delegate:self cancelButtonTitle:@"Ugh" otherButtonTitles:nil, nil];
    [alert show];
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

- (void)checkAndUpdateCounts {
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *createdEventsQuery = [PFQuery queryWithClassName:@"Event"];
    [createdEventsQuery whereKey:@"CreatedBy" equalTo:currentUser.objectId];
    [createdEventsQuery orderByDescending:@"Date"];
    createdEventsQuery.limit = 1000;
    [createdEventsQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        
        if (!error) {
            
            currentUser[@"createdCount"] = [NSNumber numberWithInt:count];
            [currentUser saveEventually];
        }
    }];
    
    PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    [swipesQuery whereKey:@"UserID" equalTo:currentUser.objectId];
    [swipesQuery whereKey:@"swipedRight" equalTo:@YES];
    swipesQuery.limit = 1000;
    
    PFQuery *swipedRightEventQuery = [PFQuery queryWithClassName:@"Event"];
    [swipedRightEventQuery whereKey:@"objectId" matchesKey:@"EventID" inQuery:swipesQuery];
    [swipedRightEventQuery orderByAscending:@"Date"];
    swipedRightEventQuery.limit = 1000;
    
    [swipedRightEventQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        
        if (!error) {
            
            currentUser[@"eventCount"] = [NSNumber numberWithInt:count];
            [currentUser saveEventually];
        }
    }];
    
}

- (void)loadFriends {
    NSLog(@"made it");
    PFUser *currentUser = [PFUser currentUser];
    NSLog(@"%d", [FBSDKAccessToken currentAccessToken] && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]);
    if ([FBSDKAccessToken currentAccessToken] && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] /* && (ReachableViaWiFi | ReachableViaWWAN) */) {
        
        NSLog(@"testing");
        NSLog(@"%@", [FBSDKAccessToken currentAccessToken].tokenString);
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends?limit=1000" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            //code
            if (error)
                NSLog(@"FB GRAPH REQ ERROR ---- %@", error);
            
            NSArray* friends = [result objectForKey:@"data"];
            NSMutableArray *friendObjectIds = [NSMutableArray new];
            
            currentUser[@"friendCount"] = [NSNumber numberWithUnsignedLong:friends.count];
            
            for (int i = 0; i < friends.count; i ++) {
                [friendObjectIds addObject:[friends[i] objectForKey:@"id"]];
            }
            
            /*
            NSArray *friendsArray = currentUser[@"friends"];
            NSMutableArray *currentFriendIds = [NSMutableArray array];
            for (NSDictionary *dict in friendsArray) {
                [currentFriendIds addObject:[dict objectForKey:@"id"]];
            }
            
            
            NSMutableArray *friendIdsToQueryFor = [NSMutableArray array];
            for (NSString *fbid in friendObjectIds){
                if (![currentFriendIds containsObject:fbid])
                    [friendIdsToQueryFor addObject:fbid];
            } */
            
            //if (friendIdsToQueryFor.count > 0) {
                
                //NSLog(@"query for: %@", friendIdsToQueryFor);
                
                PFQuery *query = [PFUser query];
                [query whereKey:@"FBObjectID" containedIn:friendObjectIds];
                query.limit = 1000;
                
                [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
                    
                    NSMutableArray *array = [NSMutableArray array]; //currentUser[@"friends"];
                    if (array == nil) {
                        array = [NSMutableArray array];
                    }
                    
                    for (PFUser *user in users) {
                        
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        
                        [dict setObject:user.objectId forKey:@"parseId"];
                        [dict setObject:[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]] forKey:@"name"];
                        [dict setObject:user[@"FBObjectID"] forKey:@"id"];
                        
                        [array addObject:dict];
                    }
                    
                    [PFUser currentUser][@"friends"] = array;
                    [[PFUser currentUser] saveEventually:^(BOOL success, NSError *error){
                    }];
                    
                }];
            //}
        }];
        
        //});
        
    } else {
        
        NSLog(@"no token......");
    }
    
}


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
        
    } else if ([segue.identifier isEqualToString:@"toTerms"]) {
        
        webViewController *vc = (webViewController *)[segue.destinationViewController topViewController];
        vc.urlString = @"http://www.happening.city/terms";
        vc.titleString = @"Terms of Service";
        vc.shouldHideToolbar = YES;
        
    }
}


@end
