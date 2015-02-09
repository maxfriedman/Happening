//
//  dropdownSettingsView.m
//  Happening
//
//  Created by Max on 1/26/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "dropdownSettingsView.h"
#import <Parse/Parse.h>

@implementation dropdownSettingsView {
    
    NSUserDefaults *defaults;
    PFUser *user;
    NSInteger sliderVal;
    NSArray *categoryArray;
    NSArray *imageArray;
    UIView *selectionBar;
    
}

@synthesize locationField,distanceLabel,dropdownImageView,todayButton,tomorrowButton,weekendButton,slider,categoryTableView;

-(void)didMoveToSuperview {
    
    locationField.text = @"lsdfbvskjdfb";

}




-(id)initWithFrame:(CGRect)frame {
    
    
    
    self = [super initWithFrame:frame];
    
    if (self) {
    
    locationField.text = @"lsdfbvskjdfb";
    
        NSLog(@"cjhsdbfv");
    }
    
    return self;
}

- (void) awakeFromNib
{
    //[super awakeFromNib];
    NSLog(@"------- Settings Opened -------");
    
    user = [PFUser currentUser];
    defaults = [NSUserDefaults standardUserDefaults];
    
    locationField.layer.masksToBounds = YES;
    locationField.layer.cornerRadius = 10.0;
    locationField.layer.borderColor = [UIColor whiteColor].CGColor;
    locationField.layer.borderWidth = 4.0;
    
    sliderVal = [defaults integerForKey:@"sliderValue"];
    
    //appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *distanceString = [NSString stringWithFormat:@"%ld mi. away", (long)sliderVal];
    self.distanceLabel.text = distanceString;
    self.slider.value = (float)sliderVal / 5;

    
    /*
    if ([[defaults objectForKey:@"userLocSubtitle"] isEqualToString:@""]) {
        
        locSubtitle.text = nil;
        locTitle.text = [defaults objectForKey:@"userLocTitle"];
        
    } else {
        
        locTitle.text = [defaults objectForKey:@"userLocTitle"];
        locSubtitle.text = [defaults objectForKey:@"userLocSubtitle"];
        
    }
    
    self.socialSwitch.on = [defaults boolForKey:@"socialMode"];
    */
    
    locationField.text = [NSString stringWithFormat:@"near %@", [defaults objectForKey:@"userLocTitle"]];
    
    selectionBar = [[UIView alloc]init];

    selectionBar.backgroundColor = [UIColor cyanColor]; //%%% sbcolor
    selectionBar.alpha = 0.8; //%%% sbalpha

    if ([defaults boolForKey:@"today"]) {
        
        [todayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];        [tomorrowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        selectionBar.frame = CGRectMake(32, 183, todayButton.frame.size.width + 6, 3);
        [self addSubview:selectionBar];
        
    } else if ([defaults boolForKey:@"tomorrow"]) {
        
        [todayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        selectionBar.frame = CGRectMake(101, 183, tomorrowButton.frame.size.width + 6, 3);
        [self addSubview:selectionBar];
        
    } else {
        
        [todayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        selectionBar.frame = CGRectMake(194, 183, weekendButton.frame.size.width + 6, 3);
        [self addSubview:selectionBar];
    }
    
    [todayButton addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [tomorrowButton addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [weekendButton addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    categoryArray = [[NSArray alloc] initWithObjects:@"Most popular", @"Best deals", @"Bars & Clubs", @"Food & Drink", @"Sports", @"Concerts & Shows", @"Free in the city", @"Charity & causes", @"Shopping", @"Film & Media", @"Meetups", nil];
    
    UIImage *popularImage = [UIImage imageNamed:@"interested_face"];
    UIImage *dealsImage = [UIImage imageNamed:@"interested_face"];
    UIImage *barsAndClubsImage = [UIImage imageNamed:@"interested_face"];
    UIImage *foodAndDrinkImage = [UIImage imageNamed:@"interested_face"];
    UIImage *sportsImage = [UIImage imageNamed:@"interested_face"];
    UIImage *concertsAndShowsImage = [UIImage imageNamed:@"interested_face"];
    UIImage *freeImage = [UIImage imageNamed:@"interested_face"];
    UIImage *charityImage = [UIImage imageNamed:@"interested_face"];
    UIImage *shoppingImage = [UIImage imageNamed:@"interested_face"];
    UIImage *filmAndMediaImage = [UIImage imageNamed:@"interested_face"];
    UIImage *meetupsImage = [UIImage imageNamed:@"interested_face"];
    
    imageArray = [[NSArray alloc] initWithObjects:popularImage, dealsImage, barsAndClubsImage, foodAndDrinkImage, sportsImage, concertsAndShowsImage, freeImage, charityImage, shoppingImage, filmAndMediaImage, meetupsImage, nil];
    
    //"Nightlife",@"Sports",@"Music", @"Shopping", @"Freebies", @"Happy Hour", @"Dining", @"Entertainment", @"Fundraiser", @"Meetup", @"Other"
    
    
}

/*
- (IBAction)doneButtonPressed:(id)sender {
    
    // Save user preferences if values were changed
    if ([self didPreferencesChange]) {
        
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
    
    //DragViewController* vc = (DragViewController*)self.parentViewController.presentingViewController;
    // Peace out
    [self.dragVC testing];
    [self dismissViewControllerAnimated:YES completion: ^{
        
        // call your completion method:
        
    }];
    
}
*/
 
- (IBAction)sliderValueChanged:(id)sender {
    
    NSString *distanceString = [[NSString alloc]init];
    
    if (self.slider.value > 1) {
        
        sliderVal = (int)self.slider.value * 5;
        distanceString = [NSString stringWithFormat:@"%ld mi. away", (long)sliderVal];
        self.distanceLabel.text = distanceString;
        
    } else if (self.slider.value > 0.2) {
        
        sliderVal = self.slider.value * 5;
        distanceString = [NSString stringWithFormat:@"%ld mi. away", (long)sliderVal];
        self.distanceLabel.text = distanceString;
        
    } else {
        
        sliderVal = 1;
        distanceString = @"1 mi. away";
        self.distanceLabel.text = distanceString;
        
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return categoryArray.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [categoryTableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];
    
    cell.textLabel.text = categoryArray[indexPath.row];
    cell.imageView.image = imageArray[indexPath.row];
    
    return cell;
}

- (void)timeButtonTapped:(UIButton *)button {
    
    NSInteger tag = button.tag;
    
    if (tag == 1) {
        [todayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
        [UIView animateWithDuration:0.2 animations:^{
            selectionBar.frame = CGRectMake(32, 183, todayButton.frame.size.width + 6, 3);
        } completion:^(BOOL finished) {
        }];
        
    } else if (tag == 2) {
        
        [todayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.2 animations:^{
            selectionBar.frame = CGRectMake(101, 183, tomorrowButton.frame.size.width + 6, 3);
        } completion:^(BOOL finished) {
        }];
        
    } else {
        
        [todayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.2 animations:^{
            selectionBar.frame = CGRectMake(194, 183, weekendButton.frame.size.width + 6, 3);
        } completion:^(BOOL finished) {
        }];
    }    
}

/*
- (IBAction)socialModeSwitched:(UISwitch *)sender {
    
    [defaults setBool:sender.on forKey:@"socialMode"];
    categoryChanged = YES;
    
}
*/

/*
- (BOOL)didPreferencesChange {
    
    // Save user preferences if values were changed
    
    if ([defaults integerForKey:@"sliderValue"] != sliderVal || ![[defaults objectForKey:@"userLocTitle"] isEqualToString:userLocationTitle] || categoryChanged) {
        return YES;
    } else {
        NSLog(@"No preferences were changed.");
        return NO;
    }
}
*/



@end
