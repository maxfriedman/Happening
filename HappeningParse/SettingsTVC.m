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
    PFUser *user;
    NSInteger sliderVal;
    NSString *userLocationTitle;
}

@synthesize locTitle, locSubtitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"------- Settings Opened -------");
    
    user = [PFUser currentUser];
    [self.delegate didPreferencesChange];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    sliderVal = [defaults integerForKey:@"sliderValue"];
    userLocationTitle = [defaults objectForKey:@"userLocTitle"];
    
    //appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *distanceString = [NSString stringWithFormat:@"%ld mi.", (long)sliderVal];
    self.distanceLabel.text = distanceString;
    self.distanceSlider.value = (float)sliderVal / 5;
}

- (void)viewWillAppear:(BOOL)animated {
    
    //if ([appDelegate.userLocation.name isEqualToString:@"Unknown Location"] || [appDelegate.userLocation.name isEqualToString:@""]) {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([[defaults objectForKey:@"userLocSubtitle"] isEqualToString:@""]) {
     
        locSubtitle.text = nil;
        locTitle.text = [defaults objectForKey:@"userLocTitle"];
        
    } else {
        
        locTitle.text = [defaults objectForKey:@"userLocTitle"];
        locSubtitle.text = [defaults objectForKey:@"userLocSubtitle"];
        
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    
    // Save user preferences if values were changed
    if ([self didPreferencesChange]) {
      
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:sliderVal forKey:@"sliderValue"];
        [defaults setBool:YES forKey:@"refreshData"];
        [defaults synchronize];
        NSLog(@"Preferences saved successfully to NSUserDefaults");
        NSLog(@"Slider value saved: %ld", (long)sliderVal);
        
        NSNumber *sliderValueNum = [NSNumber numberWithInteger:sliderVal];
        [user setValue:sliderValueNum forKey:@"radius"];
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // The currentUser saved successfully.
            } else {
                // There was an error saving the currentUser.
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"Parse error: %@", errorString);
            }
        }];

    }
    
    
    // Peace out
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)sliderValueChanged:(id)sender {
    
    NSString *distanceString = [[NSString alloc]init];
    
    if (self.distanceSlider.value > 1) {
        
        sliderVal = (int)self.distanceSlider.value * 5;
        distanceString = [NSString stringWithFormat:@"%ld mi.", (long)sliderVal];
        self.distanceLabel.text = distanceString;
        
    } else if (self.distanceSlider.value > 0.2) {
        
        sliderVal = self.distanceSlider.value * 5;
        distanceString = [NSString stringWithFormat:@"%ld mi.", (long)sliderVal];
        self.distanceLabel.text = distanceString;
        
    } else {
        
        sliderVal = 1;
        distanceString = @"1 mi.";
        self.distanceLabel.text = distanceString;
        
    }
    
}

- (BOOL)didPreferencesChange {
    
    // Save user preferences if values were changed
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults integerForKey:@"sliderValue"] != sliderVal || ![[defaults objectForKey:@"userLocTitle"] isEqualToString:userLocationTitle] ) {
        return YES;
    } else {
        NSLog(@"No preferences were changed.");
        return NO;
    }
}


@end