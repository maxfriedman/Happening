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
    NSArray *defaultsArray;
    UIView *selectionBar;
    
    NSInteger selectedIndex;
    
    BOOL categoryChanged;
    
}

@synthesize locationField,distanceLabel,dropdownImageView,todayButton,tomorrowButton,weekendButton,slider,categoryTableView,topLabel,dropdownView,delegate;


- (void) awakeFromNib
{
    //[super awakeFromNib];
    NSLog(@"------- Settings Opened -------");
    
    user = [PFUser currentUser];
    defaults = [NSUserDefaults standardUserDefaults];
    
    categoryChanged = NO;
    
    dropdownView.layer.borderWidth = 1.0;
    dropdownView.layer.borderColor = [UIColor colorWithRed:172.0/255 green:172.0/255 blue:172.0/255 alpha:1.0].CGColor;
    
    [locationField setTitle:[NSString stringWithFormat:@"        near %@", [defaults objectForKey:@"userLocTitle"]] forState:UIControlStateNormal];
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
    
    selectionBar = [[UIView alloc]init];

    selectionBar.backgroundColor = [UIColor cyanColor]; //%%% sbcolor
    selectionBar.alpha = 0.8; //%%% sbalpha

    if ([defaults boolForKey:@"today"]) {
        
        [todayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        selectionBar.frame = CGRectMake(32, 183, todayButton.frame.size.width + 6, 3);
        
    } else if ([defaults boolForKey:@"tomorrow"]) {
        
        [todayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        selectionBar.frame = CGRectMake(101, 183, tomorrowButton.frame.size.width + 6, 3);
        
    } else {
        
        [todayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        selectionBar.frame = CGRectMake(194, 183, weekendButton.frame.size.width + 6, 3);
    }
    
    [self addSubview:selectionBar];
    
    [todayButton addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [tomorrowButton addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [weekendButton addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    categoryArray = [[NSArray alloc] initWithObjects:@"Most popular", @"Best deals", @"Bars & Clubs", @"Food & Drink", @"Sports", @"Concerts & Shows", @"Free in the city", @"Charity & causes", @"Shopping", @"Film & Media", @"Meetups", nil];
    
    defaultsArray = [[NSArray alloc] initWithObjects:@"nightlife", @"entertainment", @"music", @"dining", @"happyHour", @"sports", @"shopping", @"fundraiser", @"meetup", @"freebies", @"other", nil];
    
    
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
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[defaults integerForKey:@"categoryIndex"] inSection:0];
    [categoryTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    //[categoryTableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    topLabel.text = [defaults valueForKey:@"categoryName"];
    
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
    
    NSNumber *rowNsNum = [NSNumber numberWithInteger:indexPath.row];
    if (indexPath.row == [defaults integerForKey:@"categoryIndex"] )
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
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
        
        [defaults setBool:YES forKey:@"today"];
        
        [defaults setBool:NO forKey:@"tomorrow"];
        [defaults setBool:NO forKey:@"thisWeekend"];
        
    } else if (tag == 2) {
        
        [todayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.2 animations:^{
            selectionBar.frame = CGRectMake(101, 183, tomorrowButton.frame.size.width + 6, 3);
        } completion:^(BOOL finished) {
        }];
        
        [defaults setBool:YES forKey:@"tomorrow"];
        
        [defaults setBool:NO forKey:@"today"];
        [defaults setBool:NO forKey:@"thisWeekend"];
        
    } else {
        
        [todayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        [UIView animateWithDuration:0.2 animations:^{
            selectionBar.frame = CGRectMake(194, 183, weekendButton.frame.size.width + 6, 3);
        } completion:^(BOOL finished) {
        }];
        
        [defaults setBool:YES forKey:@"thisWeekend"];
        
        [defaults setBool:NO forKey:@"today"];
        [defaults setBool:NO forKey:@"tomorrow"];
    }
    
    //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    categoryChanged = YES;
    [defaults synchronize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger num = indexPath.row;
    //selectedIndex = indexPath.row;
    [defaults setInteger:num forKey:@"categoryIndex"];
    
    //categoryArray = [[NSArray alloc] initWithObjects:@"Most popular", @"Best deals", @"Bars & Clubs", @"Food & Drink", @"Sports", @"Concerts & Shows", @"Free in the city", @"Charity & causes", @"Shopping", @"Film & Media", @"Meetups", nil];
    
    //defaultsArray = [[NSArray alloc] initWithObjects:@"nightlife", @"entertainment", @"music", @"dining", @"happyHour", @"sports", @"shopping", @"fundraiser", @"meetup", @"freebies", @"other", nil];
    
    for (NSString *string in defaultsArray) {
        [defaults setBool:NO forKey:string];
    }
    
    switch (num) {
        case 0: // Most popular
            NSLog(@"Selected Most Popular");
            
            [defaults setBool:YES forKey:@"mostPopular"];
            [defaults setValue:@"Most Popular" forKey:@"categoryName"];
            
            for (NSString *string in defaultsArray) {
                [defaults setBool:YES forKey:string];
            }

            break;
        case 1: // Best deals
            NSLog(@"Selected Best Deals");
            
            [defaults setBool:YES forKey:@"bestDeals"];
            [defaults setValue:@"Best Deals" forKey:@"categoryName"];
            
            [defaults setBool:YES forKey:@"freebies"];
            [defaults setBool:YES forKey:@"happyHour"];
            
            break;
        case 2: // Bars & Clubs
            NSLog(@"Selected Bars & Clubs");
            
            [defaults setValue:@"Bars & Clubs" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"happyHour"];
            [defaults setBool:YES forKey:@"nightlife"];
            
            break;
        case 3: // Food & Drink
            NSLog(@"Selected Food & Drink");
            
            [defaults setValue:@"Food & Drink" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"dining"];
            [defaults setBool:YES forKey:@"happyHour"];
            
            break;
        case 4: // Sports
            NSLog(@"Selected Sports");
            
            [defaults setValue:@"Sports" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"sports"];
            
            break;
        case 5: // Concerts & Shows
            NSLog(@"Selected Concerts & Shows");
            
            [defaults setValue:@"Concerts & Shows" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"entertainment"];
            [defaults setBool:YES forKey:@"music"];
            
            break;
        case 6: // Free in the City
            NSLog(@"Selected Free in the City");
            
            [defaults setValue:@"Free in the City" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"freebies"];
            
            break;
        case 7: // Charity & Causes
            NSLog(@"Selected Charity & Causes");
            
            [defaults setValue:@"Charity & Causes" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"fundraiser"];
            
            break;
        case 8: // Shopping
            NSLog(@"Selected Shopping");
            
            [defaults setValue:@"Shopping" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"shopping"];
            
            break;
        case 9: // Film & Media
            NSLog(@"Selected Film & Media");
            
            [defaults setValue:@"Film & Media" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"entertainment"];
            
            break;
        case 10: // Professional
            NSLog(@"Selected Professional");
            
            [defaults setValue:@"Professional" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"meetup"];
            
            break;
            
        default:
            break;
    }
    
    for (int i = 0; i < categoryArray.count; i++) {
        
        //if (i != indexPath.row) {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
            [tableView cellForRowAtIndexPath:ip].accessoryType = UITableViewCellAccessoryNone;
        //}
    }
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    [defaults synchronize];
    topLabel.text = [defaults valueForKey:@"categoryName"];
    
    [delegate dropdownPressed];
    [delegate refreshData];
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
// Only show checkmark for one cell at a time!
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"sjdfbksndf");
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}
 */

/*
- (IBAction)socialModeSwitched:(UISwitch *)sender {
    
    [defaults setBool:sender.on forKey:@"socialMode"];
    categoryChanged = YES;
    
}
*/

-(void)refreshSettings {
    
    [locationField setTitle:[NSString stringWithFormat:@"        near %@", [defaults objectForKey:@"userLocTitle"]] forState:UIControlStateNormal];
    categoryChanged = YES;
    
}


- (BOOL)didPreferencesChange {
    
    // Save user preferences if values were changed
    
    //NSLog(@"%ld ----------- %ld", (long)[defaults integerForKey:@"sliderValue"], (long)sliderVal);
    
    if ([defaults integerForKey:@"sliderValue"] != sliderVal || /*![[defaults objectForKey:@"userLocTitle"] isEqualToString:userLocationTitle] ||*/ categoryChanged) {
        
        categoryChanged = NO;
        [defaults setInteger:sliderVal forKey:@"sliderValue"];
        [defaults synchronize];
        
        return YES;
    } else {
        NSLog(@"No preferences were changed.");
        return NO;
    }
}

@end
