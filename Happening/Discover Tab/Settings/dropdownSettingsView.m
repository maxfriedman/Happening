//
//  dropdownSettingsView.m
//  Happening
//
//  Created by Max on 1/26/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "dropdownSettingsView.h"
#import "FBShimmeringView.h"
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
    NSString *timeString;
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
    
    [locationField setTitle:[NSString stringWithFormat:@"         Near %@", [defaults objectForKey:@"userLocTitle"]] forState:UIControlStateNormal];
    
    /*
    locationField.layer.masksToBounds = YES;
    locationField.layer.cornerRadius = 10.0;
    locationField.layer.borderColor = [UIColor whiteColor].CGColor;
    locationField.layer.borderWidth = 4.0;
    */
     
     
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

    selectionBar.backgroundColor = [UIColor colorWithRed:0 green:183.0/255.0 blue:238.0/255.0 alpha:1.0]; //%%% sbcolor
    selectionBar.alpha = 0.8; //%%% sbalpha

    if ([defaults boolForKey:@"today"]) {
        
        [todayButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        selectionBar.frame = CGRectMake(32, 183, todayButton.frame.size.width + 6, 3);
        timeString = @"Today";
        
    } else if ([defaults boolForKey:@"tomorrow"]) {
        
        [todayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        selectionBar.frame = CGRectMake(101, 183, tomorrowButton.frame.size.width + 6, 3);
        timeString = @"Tomorrow";
        
    } else {
        
        [todayButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [tomorrowButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [weekendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        selectionBar.frame = CGRectMake(194, 183, weekendButton.frame.size.width + 6, 3);
        timeString = @"This weekend";
    }
    
    [self addSubview:selectionBar];
    
    [todayButton addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [tomorrowButton addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [weekendButton addTarget:self action:@selector(timeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    categoryArray = [[NSArray alloc] initWithObjects:@"Most popular", @"Best deals", @"Bars & Clubs", @"Food & Drink", @"Sports & Fitness", @"Concerts & Shows", /*@"Free in the city",*/ @"Charity & Causes", @"Shopping", /*@"Film & Media",*/ @"Meetups", nil];
    
    defaultsArray = [[NSArray alloc] initWithObjects:@"nightlife", @"entertainment", @"music", @"dining", @"happyHour", @"sports", @"shopping", @"fundraiser", @"meetup", @"freebies", @"other", nil];
    
    
    UIImage *popularImage = [UIImage imageNamed:@"popular"];
    UIImage *dealsImage = [UIImage imageNamed:@"deals"];
    UIImage *barsAndClubsImage = [UIImage imageNamed:@"club"];
    UIImage *foodAndDrinkImage = [UIImage imageNamed:@"dining"];
    UIImage *sportsImage = [UIImage imageNamed:@"sports"];
    UIImage *concertsAndShowsImage = [UIImage imageNamed:@"entertain"];
    //UIImage *freeImage = [UIImage imageNamed:@"fundraiser"];
    UIImage *charityImage = [UIImage imageNamed:@"fundraiser"];
    UIImage *shoppingImage = [UIImage imageNamed:@"shopping"];
    //UIImage *filmAndMediaImage = [UIImage imageNamed:@"interested_face"];
    UIImage *meetupsImage = [UIImage imageNamed:@"meetup"];
    
    imageArray = [[NSArray alloc] initWithObjects:popularImage, dealsImage, barsAndClubsImage, foodAndDrinkImage, sportsImage, concertsAndShowsImage, /*freeImage,*/ charityImage, shoppingImage, /*filmAndMediaImage,*/ meetupsImage, nil];
    
    /*
    for (UIImage *im in imageArray) {
        im.size = CGSizeMake(40, 40);
    } */
    
    //"Nightlife",@"Sports",@"Music", @"Shopping", @"Freebies", @"Happy Hour", @"Dining", @"Entertainment", @"Fundraiser", @"Meetup", @"Other"
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[defaults integerForKey:@"categoryIndex"] inSection:0];
    [categoryTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    //[categoryTableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self setTopLabelText];
}

- (void)setTopLabelText {
    
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, ", [defaults valueForKey:@"categoryName"]]];
    
    UIFont *font = [UIFont fontWithName:@"OpenSans" size:14.0];
    NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    [attrsDictionary setObject:[UIColor colorWithRed:0.0/255 green:176.0/255 blue:242.0/255 alpha:1.0] forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:timeString attributes:attrsDictionary];
    //[[NSMutableAttributedString alloc] initWithString:@"Profile" attributes: arialDict2];
    
    [aAttrString1 appendAttributedString:aAttrString2];
    
    topLabel.attributedText = aAttrString1;
}

- (void)setTimeString {
    timeString = @"Any time";
    [self setTopLabelText];
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
    
    /*
    if (indexPath.row == 0) {
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
    } */
    
    cell.textLabel.text = categoryArray[indexPath.row];
    cell.imageView.image = imageArray[indexPath.row];
    
    if (indexPath.row == [defaults integerForKey:@"categoryIndex"] )
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:16.0];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16.0];
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
        timeString = @"Today";
        
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
        timeString = @"Tomorrow";
        
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
        timeString = @"This weekend";
    }
    
    //NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);

    categoryChanged = YES;
    [defaults synchronize];
    [self setTopLabelText];
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
            NSLog(@"Selected Sports & Fitness");
            
            [defaults setValue:@"Sports" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"sports"];
            
            break;
        case 5: // Concerts & Shows
            NSLog(@"Selected Concerts & Shows");
            
            [defaults setValue:@"Concerts & Shows" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"entertainment"];
            [defaults setBool:YES forKey:@"music"];
            
            break;
            /*
        case 6: // Free in the City
            NSLog(@"Selected Free in the City");
            
            [defaults setValue:@"Free in the City" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"freebies"];
            
            break;
             */
        case 6: // Charity & Causes
            NSLog(@"Selected Charity & Causes");
            
            [defaults setValue:@"Charity & Causes" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"fundraiser"];
            
            break;
        case 7: // Shopping
            NSLog(@"Selected Shopping");
            
            [defaults setValue:@"Shopping" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"shopping"];
            
            break;
            /*
        case 9: // Film & Media
            NSLog(@"Selected Film & Media");
            
            [defaults setValue:@"Film & Media" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"entertainment"];
            
            break;
             */
        case 8: // Professional
            NSLog(@"Selected Meetups");
            
            [defaults setValue:@"Meetups" forKey:@"categoryName"];
            [defaults setBool:YES forKey:@"meetup"];
            
            break;
            
        default:
            break;
    }
    
    for (int i = 0; i < categoryArray.count; i++) {
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:ip];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16.0];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.textLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:16.0];
    
    
    [defaults synchronize];
    [self setTopLabelText];
    [delegate dropdownPressed];
    [delegate refreshData];
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showTapToGoBack:(BOOL)shouldShow {
    
    if (shouldShow) {
    
        [[self viewWithTag:99] removeFromSuperview];
        
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.tag = 99;
    blurEffectView.frame = CGRectMake(0, 0, 320, 45);
        blurEffectView.alpha = 0;
        
        [self addSubview:blurEffectView];
        
        FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:blurEffectView.bounds];
        [blurEffectView addSubview:shimmeringView];
        
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:shimmeringView.bounds];
        loadingLabel.textAlignment = NSTextAlignmentCenter;
        loadingLabel.text = NSLocalizedString(@"Tap to go back", nil);
        loadingLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:15.0];
        loadingLabel.textColor = [UIColor darkGrayColor];
        shimmeringView.contentView = loadingLabel;
        shimmeringView.shimmeringSpeed = 200;
        shimmeringView.opaque = 1.0;
        
        // Start shimmering.
        shimmeringView.shimmering = YES;
        
        [UIView animateWithDuration:1.0 animations:^{
            blurEffectView.alpha = 1.0;
        }];
    
    } else {
        
        UIVisualEffectView *view = (UIVisualEffectView *)[self viewWithTag:99];
        [UIView animateWithDuration:1.0 animations:^{
            view.alpha = 0.0;
        }];
        
    }
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

-(void)tutViewAction {
    
    locationField.showsTouchWhenHighlighted = YES;
    [locationField sendActionsForControlEvents:UIControlEventTouchUpInside];

}

-(void)refreshSettings {
    
    [locationField setTitle:[NSString stringWithFormat:@"         Near %@", [defaults objectForKey:@"userLocTitle"]] forState:UIControlStateNormal];
    categoryChanged = YES;
    
    if (![defaults boolForKey:@"hasLaunched"]) {
        NSLog(@"First time-- Loc selected.");
        [delegate dropdownPressedFromTut:NO];
    }
    
}

-(void)iOS7Touch {
    
    //[delegate dropdownPressed];
    [delegate refreshData];
}

- (BOOL)didPreferencesChange {
    
    // Save user preferences if values were changed
    NSLog(@"Refresh settings");

    //NSLog(@"%ld ----------- %ld", (long)[defaults integerForKey:@"sliderValue"], (long)sliderVal);
    
    if ([defaults integerForKey:@"sliderValue"] != sliderVal || /*![[defaults objectForKey:@"userLocTitle"] isEqualToString:userLocationTitle] ||*/ categoryChanged) {
        NSLog(@"Settings changed");

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
