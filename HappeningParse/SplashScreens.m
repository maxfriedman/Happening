//
//  SplashScreens.m
//  HappeningParse
//
//  Created by Max on 10/20/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "SplashScreens.h"

@interface SplashScreens ()

@end

@implementation SplashScreens

@synthesize locManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.locManager==nil){
        locManager = [[CLLocationManager alloc] init];
        locManager.delegate=self;
        [locManager requestAlwaysAuthorization];
        locManager.desiredAccuracy=kCLLocationAccuracyBest;
        locManager.distanceFilter=50;
        
    }
    
    // Might want to delete this-- If I do, if someone decides to turn location services off, they will continue to get a message every time they launch the app...
    if([CLLocationManager locationServicesEnabled]){
        [self.locManager startUpdatingLocation];
        CLLocation *currentLocation = locManager.location;
        NSLog(@"Current Location is: %@", currentLocation);
    }
    
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            [connection start];
            // Success! Include your code to handle the results here
            //_nameLabel = [result objectForKey:@"name"];
            _nameLabel.text = [NSString stringWithFormat:@"Hey, %@!",[result objectForKey:@"first_name"]];
            //PFQuery *query = [PFQuery queryWithClassName:@"User"];
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
            appDelegate.sliderValue = 50;
            
            
            [parseUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    NSLog(@"New user successfully signed up.");
                    // Hooray! Let them use the app now.
                } else {
                    [self performSegueWithIdentifier:@"main" sender:self];
                    NSLog(@"User exists.");
                    // Show the errorString somewhere and let the user try again.
                }
                
            }];
            NSLog(@"user info: %@", result);
        } else {
            NSLog(@"error");
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
