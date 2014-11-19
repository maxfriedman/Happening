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

@synthesize locManager, continueButton, checkButton, choosingLocButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    user = [PFUser currentUser];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (user[@"userLoc"]) {
        checkButton.alpha = 1.0;
        continueButton.userInteractionEnabled = YES;
        [continueButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
}

- (IBAction)didChooseCurrentLoc:(id)sender {
    
    if(self.locManager==nil){
        locManager = [[CLLocationManager alloc] init];
        locManager.delegate=self;
        [locManager requestAlwaysAuthorization];
        locManager.desiredAccuracy=kCLLocationAccuracyBest;
        locManager.distanceFilter=50;
    }
        
    checkButton.alpha = 1.0;
        
    continueButton.userInteractionEnabled = YES;
    [continueButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"Please turn on your location services! Go to Settings -> Privacy -> Location Services -> On" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
}

- (IBAction)didChooseUserSetLocButton:(id)sender {
}


- (IBAction)didClickContinue:(id)sender {

    if (locManager.location) {
            
        [self.locManager startUpdatingLocation];
        CLLocation *currentLocation = locManager.location;
        NSLog(@"Current Location is: %@", currentLocation);
        PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:locManager.location];
        user[@"userLoc"] = loc;
        user[@"userLocTitle"] = @"Current Location";
        user[@"userLocSubtitle"] = @"";

        [user saveInBackground];

        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(locManager.location.coordinate.latitude, locManager.location.coordinate.longitude) addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.userLocation = mapItem;
        
        [self performSegueWithIdentifier:@"locToMain" sender:self];
    }
    
    PFGeoPoint *geoPoint = user[@"userLoc"];
    // Ensures that a location was selected before continuing
    if (geoPoint.latitude == 0 || user[@"userLoc"] == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"We were unable to save a location, please ensure that you have an internet connection. If you chose to not allow access to your current location, you can choose a location instead." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        NSLog(@"Made it!");

        [self performSegueWithIdentifier:@"locToMain" sender:self];
    }

}

@end
