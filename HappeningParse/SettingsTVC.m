//
//  SettingsTVC.m
//  HappeningParse
//
//  Created by Max on 10/29/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "SettingsTVC.h"

@interface SettingsTVC ()

@end

@implementation SettingsTVC {
    
    AppDelegate *appDelegate;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *distanceString = [NSString stringWithFormat:@"%d mi.", appDelegate.sliderValue];
    self.distanceLabel.text = distanceString;
    self.distanceSlider.value = (float)appDelegate.sliderValue / 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    
    // Save user preferences
    PFUser *user = [PFUser currentUser];
    
    NSNumber *sliderVal = [NSNumber numberWithInt:appDelegate.sliderValue];
    
    //[user setObject:sliderVal forKey:@"radius"];
    [user setValue:sliderVal forKey:@"radius"];

    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The currentUser saved successfully.
        } else {
            // There was an error saving the currentUser.
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"%@", errorString);
        }
    }];

    NSLog(@"Slider value saved: %@", sliderVal);

    NSLog(@"Preferences saved successfully");
    
    // Peace out
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)sliderValueChanged:(id)sender {
    
    NSString *distanceString = [[NSString alloc]init];
    
    if (self.distanceSlider.value > 1) {
        
        appDelegate.sliderValue = (int)self.distanceSlider.value * 5;
        distanceString = [NSString stringWithFormat:@"%d mi.", appDelegate.sliderValue];
        self.distanceLabel.text = distanceString;
        
    } else if (self.distanceSlider.value > 0.2) {
        
        appDelegate.sliderValue = self.distanceSlider.value * 5;
        distanceString = [NSString stringWithFormat:@"%d mi.", appDelegate.sliderValue];
        self.distanceLabel.text = distanceString;
        
    } else {
        
        appDelegate.sliderValue = 1;
        distanceString = @"1 mi.";
        self.distanceLabel.text = distanceString;
        
    }
    
}


@end