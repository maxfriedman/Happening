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
    UILabel *DCLabel;
    UILabel *bostonLabel;
    UISlider *slider;
    
}

@synthesize locManager, continueButton, currentLocButton, delegate, sliderLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    user = [PFUser currentUser];
    
    /*
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    //blurEffectView.alpha = 0.8;
    [self.view addSubview:blurEffectView];
    [self.view sendSubviewToBack:blurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.frame = self.view.bounds;
    
    UILabel *DCLabel = [[UILabel alloc] init]; //WithFrame:CGRectMake(50, 150, 220, 50)];
    [DCLabel setText:@"Washington DC"];
    [DCLabel setFont:[UIFont fontWithName:@"OpenSans" size:19.0]];
    [DCLabel sizeToFit];
    [DCLabel setCenter: CGPointMake(160, 300)];
    
    UILabel *BostonLabel = [[UILabel alloc] init]; //WithFrame:CGRectMake(50, 150, 220, 50)];
    [BostonLabel setText:@"Boston"];
    [BostonLabel setFont:[UIFont fontWithName:@"OpenSans" size:19.0]];
    [BostonLabel sizeToFit];
    [BostonLabel setCenter: CGPointMake(160, 260)];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(36, 403, 238, 30)];

    [[vibrancyEffectView contentView] addSubview:DCLabel];
    [[vibrancyEffectView contentView] addSubview:BostonLabel];
    [[vibrancyEffectView contentView] addSubview:slider];
    
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
    */
    
    DCLabel = [[UILabel alloc] init]; //WithFrame:CGRectMake(50, 150, 220, 50)];
    [DCLabel setText:@"Washington DC"];
    [DCLabel setTextColor:[UIColor darkGrayColor]];
    [DCLabel setFont:[UIFont fontWithName:@"OpenSans" size:20.0]];
    [DCLabel sizeToFit];
    [DCLabel setCenter: CGPointMake(160, 290)];
    [DCLabel setUserInteractionEnabled:YES];
    DCLabel.alpha = 0.7;
    DCLabel.tag = 1;
    
    
    bostonLabel = [[UILabel alloc] init]; //WithFrame:CGRectMake(50, 150, 220, 50)];
    [bostonLabel setText:@"Boston"];
    [bostonLabel setFont:[UIFont fontWithName:@"OpenSans" size:20.0]];
    [bostonLabel setTextColor:[UIColor darkGrayColor]];
    [bostonLabel sizeToFit];
    [bostonLabel setCenter: CGPointMake(160, 320)];
    [bostonLabel setUserInteractionEnabled:YES];
    bostonLabel.alpha = 0.7;
    bostonLabel.tag = 2;
    
    
    UITapGestureRecognizer *DCGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cityTapped:)];
    [DCLabel addGestureRecognizer:DCGR];
    UITapGestureRecognizer *BostonGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cityTapped:)];
    [bostonLabel addGestureRecognizer:BostonGR];
    
    [self.view addSubview:DCLabel];
    [self.view addSubview:bostonLabel];
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:53.0/255 green:182.0/255 blue:252.0/255 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:57.0/255 green:222.0/255 blue:253.0/255 alpha:1.0] CGColor], nil];
    /*
    CAGradientLayer *l = [CAGradientLayer layer];
    l.frame = self.view.bounds;
    l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    */
    
    gradient.startPoint = CGPointMake(0.0, 0.00f);
    gradient.endPoint = CGPointMake(0.0f, 1.0f);
    
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(36, 380, 248, 30)];
    slider.maximumTrackTintColor = [UIColor whiteColor];
    slider.minimumTrackTintColor = [UIColor colorWithRed:9.0/255 green:80.0/255 blue:208.0/255 alpha:1.0];
    [self.view addSubview:slider];
    slider.minimumValue = 0;
    slider.maximumValue = 10.0;
    slider.value = 5.0;
    [slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    
     
    continueButton.layer.masksToBounds = YES;
    continueButton.layer.cornerRadius = 3.0;
    continueButton.layer.borderColor = [UIColor clearColor].CGColor;
    continueButton.layer.borderWidth = 2.0;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    animated = NO;
    
}

- (void)cityTapped:(UITapGestureRecognizer *)gr {
    
    UILabel *label = (UILabel *)gr.view;
    
    if (label.tag == 1) {
        NSLog(@"Washington DC selected");
        
        DCLabel.textColor = [UIColor darkTextColor];
        bostonLabel.textColor = [UIColor darkGrayColor];
        
        DCLabel.font = [UIFont fontWithName:@"OpenSans" size:22.0];
        bostonLabel.font = [UIFont fontWithName:@"OpenSans" size:20.0];
        
        DCLabel.alpha = 1.0;
        bostonLabel.alpha = 0.7;
        
    } else if (label.tag == 2) {
        NSLog(@"Boston selected");
        
        DCLabel.textColor = [UIColor darkGrayColor];
        bostonLabel.textColor = [UIColor darkTextColor];
        
        DCLabel.font = [UIFont fontWithName:@"OpenSans" size:20.0];
        bostonLabel.font = [UIFont fontWithName:@"OpenSans" size:22.0];
        
        DCLabel.alpha = 0.7;
        bostonLabel.alpha = 1.0;
    }
    
    [DCLabel sizeToFit];
    [DCLabel setCenter: CGPointMake(160, 290)];
    [bostonLabel sizeToFit];
    [bostonLabel setCenter: CGPointMake(160, 320)];
    
    continueButton.alpha = 1.0;
    [continueButton setTitleColor:[UIColor colorWithRed:9.0/255 green:80.0/255 blue:208.0/255 alpha:1.0] forState:UIControlStateNormal];
    
}

- (void)sliderValueChanged {
    
    NSString *distanceString = [[NSString alloc]init];
    float sliderVal = 0;
    
    if (slider.value > 1) {
        
        sliderVal = (int)slider.value * 5;
        distanceString = [NSString stringWithFormat:@"%ld mi. away", (long)sliderVal];
        self.sliderLabel.text = distanceString;
        
    } else if (slider.value > 0.2) {
        
        sliderVal = slider.value * 5;
        distanceString = [NSString stringWithFormat:@"%ld mi. away", (long)sliderVal];
        self.sliderLabel.text = distanceString;
        
    } else {
        
        sliderVal = 1;
        distanceString = @"1 mi. away";
        self.sliderLabel.text = distanceString;
        
    }
    
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
        // Never show this again
        user[@"hasLaunched"] = @YES;
        [user saveEventually];
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
    [user saveEventually];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)didClickContinue:(id)sender {
    
    // Never show this again
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunched"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshData"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Peace out
    [delegate refreshData];
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
