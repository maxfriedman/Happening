//
//  ChoosingLocation.m
//  HappeningParse
//
//  Created by Max on 11/7/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "ChoosingLocation.h"

@interface ChoosingLocation ()

@end

@implementation ChoosingLocation {
    
    PFUser *user;
    
}

@synthesize locManager, continueButton, choosingLocButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    user = [PFUser currentUser];
    
    // Never show this again
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"hasLaunched"];
    [defaults synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    
}

- (IBAction)didChooseCurrentLoc:(id)sender {
    
    
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"Please turn on your location services! Go to Settings -> Privacy -> Location Services -> On" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else if(self.locManager==nil){
        locManager = [[CLLocationManager alloc] init];
        locManager.delegate=self;
        [locManager requestWhenInUseAuthorization];
        locManager.desiredAccuracy=kCLLocationAccuracyBest;
        locManager.distanceFilter=50;
        [locManager startUpdatingLocation];
    } else {
        // peace out
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    [self.locManager startUpdatingLocation];
    CLLocation *currentLocation = locManager.location;
    NSLog(@"Current Location is: %@", currentLocation);
    PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:locManager.location];
    user[@"userLoc"] = loc;
    user[@"userLocTitle"] = @"Current Location";
    [user saveInBackground];
    
    // Peace out!
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"hasLaunched"];
    [defaults setObject:@"Current Location" forKey:@"userLocTitle"];
    [defaults setObject:@"" forKey:@"userLocSubtitle"];
    [defaults synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)didClickContinue:(id)sender {
    
    // Peace out
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end