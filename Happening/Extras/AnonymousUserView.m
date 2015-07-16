//
//  AnonymousUserView.m
//  Happening
//
//  Created by Max on 7/9/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "AnonymousUserView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import "FlatButton.h"
#import "FXBlurView.h"


#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation AnonymousUserView {
    UILabel *messageLabel;
    UIButton *fbButton;
    UIActivityIndicatorView *activityView;
}

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        FXBlurView *blurEffectView = [[FXBlurView alloc] initWithFrame:self.bounds];
        blurEffectView.tintColor = [UIColor blackColor];
        blurEffectView.tag = 77;
        blurEffectView.blurRadius = 13;
        blurEffectView.dynamic = NO;
        
        /*
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = frame;
        */
        [self addSubview:blurEffectView];
        //self.tableView.scrollEnabled = NO;

        messageLabel = [[UILabel alloc] init];
        [messageLabel setText:[NSString stringWithFormat:@"Sign in to invite your friends!"]];
        [messageLabel setFont:[UIFont fontWithName:@"OpenSans" size:23.0]];
        messageLabel.textColor = [UIColor blackColor];
         
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setFrame:CGRectMake(40, 120, 240, 150)];
        messageLabel.numberOfLines = 0;
        
        [blurEffectView addSubview:messageLabel];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = CGRectMake(0, 0, 50, 50);
        activityView.backgroundColor = [UIColor blackColor];
        activityView.layer.cornerRadius = 5.0;
        activityView.layer.masksToBounds = YES;
        activityView.center = CGPointMake(self.frame.size.width / 2, (self.frame.size.height / 2) + 10);
        [self addSubview:activityView];
        
        fbButton = [[UIButton alloc] initWithFrame:CGRectMake(56, 360, 208, 50)];
        [fbButton setImage:[UIImage imageNamed:@"Facebook Login"] forState:UIControlStateNormal];
        [fbButton addTarget:self action:@selector(fbButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:fbButton];
    }
    
    return self;
}

-(void)setMessage:(NSString *)message {
    messageLabel.text = message;
}

-(void)setImage:(UIImage *)image {
    
    UIImageView *imv = [[UIImageView alloc] initWithFrame:self.bounds];
    //imv.frame = CGRectMake(0, 64, 320, self.frame.size.height);
    imv.image = image;
    [self insertSubview:imv belowSubview:[self viewWithTag:77]];
}

- (void)fbButtonAction:(id)sender {
    
    fbButton.alpha = 0.8;
    fbButton.userInteractionEnabled = NO;
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
            fbButton.alpha = 1.0;
            fbButton.userInteractionEnabled = YES;
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
            
        } else if (result.isCancelled) {
            
            NSLog(@"fb login cancelled");
            [activityView stopAnimating];
            fbButton.alpha = 1.0;
            fbButton.userInteractionEnabled = YES;
            
        } else { //success ?
            
            PFUser *parseUser = [PFUser currentUser];
            
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                     NSLog(@"fetched user:%@", result);
                     
                     NSDictionary *user = result;

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
                                         currentInstallation.channels = @[@"global", @"reminders", @"matches", @"friendJoined", @"popularEvents", @"matchesInApp", @"friendPush"];
                                         currentInstallation[@"userID"] = parseUser.objectId;
                                         
                                         [currentInstallation saveEventually];
                                     }
                                 } else if ([PFInstallation currentInstallation] != nil) {
                                     
                                     PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                                     
                                     NSLog(@"Saving notification ID");
                                     
                                     // Associate the device with a user
                                     currentInstallation.channels = @[@"global", @"reminders", @"matches", @"friendJoined", @"popularEvents", @"matchesInApp", @"friendPush"];
                                     currentInstallation[@"userID"] = parseUser.objectId;
                                     
                                     [currentInstallation saveEventually];
                                     
                                 }
                                 
                                 [activityView stopAnimating];
                                 [self success];
                                 
                             }
                         } else {
                             
                             NSLog(@"User exists.");
                             
                             if (parseUser) {
                                 
                                 [PFUser logInWithUsernameInBackground:parseUser.username password:parseUser.password
                                                                 block:^(PFUser *user, NSError *error) {
                                                                     if (user) {
                                                                         // Do stuff after successful login.
                                                                         [user pinInBackground];
                                                                         [activityView stopAnimating];
                                                                         [self success];
                                                                         
                                                                     } else {
                                                                         // The login failed. Check error to see why.
                                                                         fbButton.alpha = 1.0;
                                                                         fbButton.userInteractionEnabled = YES;
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
    
}

- (void)success {
    
    [UIView animateWithDuration:0.5 animations:^{
        messageLabel.alpha = 0;
    } completion:^(BOOL finished) {
        messageLabel.text = [NSString stringWithFormat:@"Welcome, %@!", [[PFUser currentUser] objectForKey:@"firstName"]];
        
        
        
        [UIView animateWithDuration:0.2 animations:^{
            messageLabel.alpha = 1;
        } completion:^(BOOL finished) {

            
            
            [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [self.delegate facebookSuccessfulSignup];
            }];
            
            
            
        }];
    }];
    
}

@end
