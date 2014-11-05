//
//  LoginView.m
//  HappeningParse
//
//  Created by Max on 10/10/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "LoginView.h"

#import "TabBarViewController.h"

@interface LoginView () <UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet FBLoginView *fbLoginView;
@property (strong, nonatomic) NSString *objectID;

@end

@implementation LoginView {
    
    AppDelegate *appDelegate;
}

@synthesize activityView;

-(void)viewDidLoad {
    
    [super viewDidLoad];
    _fbLoginView.alpha =0;
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - 100);
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
}


- (void)viewDidAppear:(BOOL)animated {
    
    [_fbLoginView setReadPermissions:@[@"public_profile", @"email", @"user_friends"]];
    [_fbLoginView setDelegate:self];
    _objectID = nil;
    
    _fbLoginView.alpha =0;
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFUser query];
    
    NSArray *users = [[NSArray alloc]init];
    users = [query findObjects];
    
    for (int i = 0; i < users.count; i++) {
        PFObject *userPF = users[i];
        //NSLog(@"1:%@ 2:%@",userPF[@"username"], currentUser.username);
        
        if ([userPF[@"username"] isEqualToString:currentUser.username]) {
            NSLog(@"User exists. LEGGO");
            
            // Reload user preferences from previous session
            int sliderVal = [userPF[@"radius"] intValue];
            NSLog(@"Loading preferences... slider value = %d", sliderVal);
            appDelegate.sliderValue = sliderVal;
            
            [self performSegueWithIdentifier:@"toMain" sender:self];
        }
    }

    [activityView stopAnimating];
    [self performSegueWithIdentifier:@"toSplash" sender:self];

    
}


- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFUser query];
    
    NSArray *users = [[NSArray alloc]init];
    users = [query findObjects];
    
    for (int i = 0; i < users.count; i++) {
        PFObject *userPF = users[i];
        //NSLog(@"1:%@ 2:%@",userPF[@"username"], currentUser.username);
        
        if ([userPF[@"username"] isEqualToString:currentUser.username]) {
            NSLog(@"User exists. LEGGO");
            [self performSegueWithIdentifier:@"toMain" sender:self];
            break;
        }
    }
    NSLog(@"User does not yet exist");
    [self performSegueWithIdentifier:@"toSplash" sender:self];

    
    //[self performSegueWithIdentifier:@"toSplash" sender:self];
    
    /*
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFUser query];
    NSArray *users = [[NSArray alloc]init];
    users = [query findObjects];
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
             NSString *email = [result objectForKey:@"email"];
            if ([users containsObject:email]) {
                NSLog(@"User exists. LEGGO");
                [self performSegueWithIdentifier:@"toMain" sender:self];
            } else {
                NSLog(@"User does not yet exist");
                _fbLoginView.alpha = 1.0;
                [self performSegueWithIdentifier:@"toSplash" sender:self];
            }
        }
        
    }];
        */

    
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


/*
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
