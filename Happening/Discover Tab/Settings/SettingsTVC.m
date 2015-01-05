//
//  SettingsTVC.m
//  Happening
//
//  Created by Max on 10/29/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "SettingsTVC.h"

@interface SettingsTVC ()

@property (strong, nonatomic) IBOutlet UIImageView *nightlifeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *entertainmentImageView;
@property (strong, nonatomic) IBOutlet UIImageView *musicImageView;
@property (strong, nonatomic) IBOutlet UIImageView *diningImageView;
@property (strong, nonatomic) IBOutlet UIImageView *happyHourImageView;
@property (strong, nonatomic) IBOutlet UIImageView *sportsImageView;
@property (strong, nonatomic) IBOutlet UIImageView *shoppingImageView;
@property (strong, nonatomic) IBOutlet UIImageView *fundraiserImageView;
@property (strong, nonatomic) IBOutlet UIImageView *meetupImageView;
@property (strong, nonatomic) IBOutlet UIImageView *freebiesImageView;
@property (strong, nonatomic) IBOutlet UIImageView *otherImageView;

@end

@implementation SettingsTVC {
    
    AppDelegate *appDelegate;
    PFUser *user;
    NSInteger sliderVal;
    NSString *userLocationTitle;
    
    NSUserDefaults *defaults;
    
    UIImageView *checkButton;
    UIImageView *xButton;
    
    BOOL categoryChanged;
}

@synthesize locTitle, locSubtitle;
@synthesize nightlifeImageView, entertainmentImageView, musicImageView, diningImageView, happyHourImageView, sportsImageView, shoppingImageView, fundraiserImageView, meetupImageView, freebiesImageView, otherImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    defaults = [NSUserDefaults standardUserDefaults];
    categoryChanged = NO;
    
    NSLog(@"------- Settings Opened -------");
    
    user = [PFUser currentUser];
    [self.delegate didPreferencesChange];
    
    checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    checkButton.image = [UIImage imageNamed:@"yesButton"];
    checkButton.alpha = 0.5;
    
    xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    xButton.image = [UIImage imageNamed:@"noButton"];
    xButton.alpha = 0.5;
    
    [self setupCategories];
    
    sliderVal = [defaults integerForKey:@"sliderValue"];
    userLocationTitle = [defaults objectForKey:@"userLocTitle"];
    
    //appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *distanceString = [NSString stringWithFormat:@"%ld mi.", (long)sliderVal];
    self.distanceLabel.text = distanceString;
    self.distanceSlider.value = (float)sliderVal / 5;
}

- (void)viewWillAppear:(BOOL)animated {
    
    //if ([appDelegate.userLocation.name isEqualToString:@"Unknown Location"] || [appDelegate.userLocation.name isEqualToString:@""]) {
    
    if ([[defaults objectForKey:@"userLocSubtitle"] isEqualToString:@""]) {
     
        locSubtitle.text = nil;
        locTitle.text = [defaults objectForKey:@"userLocTitle"];
        
    } else {
        
        locTitle.text = [defaults objectForKey:@"userLocTitle"];
        locSubtitle.text = [defaults objectForKey:@"userLocSubtitle"];
        
    }
}

- (void)setupCategories {
    
    [self formatImage:nightlifeImageView];      //1
    [self formatImage:entertainmentImageView];  //2
    [self formatImage:musicImageView];          //3
    [self formatImage:diningImageView];         //4
    [self formatImage:happyHourImageView];      //5
    [self formatImage:sportsImageView];         //6
    [self formatImage:shoppingImageView];       //7
    [self formatImage:fundraiserImageView];     //8
    [self formatImage:meetupImageView];         //9
    [self formatImage:freebiesImageView];       //10
    [self formatImage:otherImageView];          //11
    
}

- (UIImageView *) formatImage:(UIImageView *)imageView {
    
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    imageView.layer.cornerRadius = 10.0;
    imageView.layer.borderWidth = 2.0;
    imageView.userInteractionEnabled = YES;
    
    NSInteger tag = imageView.tag;
    NSString *name = [[NSString alloc]init];
    
    switch (tag) {
        case 1:
            name = @"nightlife";
            break;
        case 2:
            name = @"entertainment";
            break;
        case 3:
            name = @"music";
            break;
        case 4:
            name = @"dining";
            break;
        case 5:
            name = @"happyHour";
            break;
        case 6:
            name = @"sports";
            break;
        case 7:
            name = @"shopping";
            break;
        case 8:
            name = @"fundraiser";
            break;
        case 9:
            name = @"meetup";
            break;
        case 10:
            name = @"freebies";
            break;
        case 11:
            name = @"other";
            break;
    }
    
    if ([defaults boolForKey:name]) {
        [[imageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [imageView addSubview:checkButton];
        
    } else {
        [[imageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [imageView addSubview:xButton];
    }

    return imageView;
}



- (IBAction)nightlifeTap:(id)sender {
    
    if (![defaults boolForKey:@"nightlife"]) {
        [[nightlifeImageView.subviews lastObject] removeFromSuperview];
        
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [nightlifeImageView addSubview:checkButton];
        
        [defaults setBool:YES forKey:@"nightlife"];
    } else {
        [[nightlifeImageView.subviews lastObject] removeFromSuperview];
        
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [nightlifeImageView addSubview:xButton];
        
        [defaults setBool:NO forKey:@"nightlife"];
    }
    [defaults synchronize];
    categoryChanged = YES;
    
}
- (IBAction)entertainmentTap:(id)sender {
    if (![defaults boolForKey:@"entertainment"]) {
        [[entertainmentImageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [entertainmentImageView addSubview:checkButton];
        [defaults setBool:YES forKey:@"entertainment"];
    } else {
        [[entertainmentImageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [entertainmentImageView addSubview:xButton];
        [defaults setBool:NO forKey:@"entertainment"];
    }
    [defaults synchronize];
    categoryChanged = YES;
}
- (IBAction)musicTap:(id)sender {
    if (![defaults boolForKey:@"music"]) {
        [[musicImageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [musicImageView addSubview:checkButton];
        [defaults setBool:YES forKey:@"music"];
    } else {
        [[musicImageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [musicImageView addSubview:xButton];
        [defaults setBool:NO forKey:@"music"];
    }
    [defaults synchronize];
    categoryChanged = YES;
}
- (IBAction)diningTap:(id)sender {
    if (![defaults boolForKey:@"dining"]) {
        [[diningImageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [diningImageView addSubview:checkButton];
        [defaults setBool:YES forKey:@"dining"];
    } else {
        [[diningImageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [diningImageView addSubview:xButton];
        [defaults setBool:NO forKey:@"dining"];
    }
    [defaults synchronize];
    categoryChanged = YES;
}
- (IBAction)happyHourTap:(id)sender {
    if (![defaults boolForKey:@"happyHour"]) {
        [[happyHourImageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [happyHourImageView addSubview:checkButton];
        [defaults setBool:YES forKey:@"happyHour"];
    } else {
        [[happyHourImageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [happyHourImageView addSubview:xButton];
        [defaults setBool:NO forKey:@"happyHour"];
    }
    [defaults synchronize];
    categoryChanged = YES;
}
- (IBAction)sportsTap:(id)sender {
    if (![defaults boolForKey:@"sports"]) {
        [[sportsImageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [sportsImageView addSubview:checkButton];
        [defaults setBool:YES forKey:@"sports"];
    } else {
        [[sportsImageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [sportsImageView addSubview:xButton];
        [defaults setBool:NO forKey:@"sports"];
    }
    [defaults synchronize];
    categoryChanged = YES;
}
- (IBAction)shoppingTap:(id)sender {
    if (![defaults boolForKey:@"shopping"]) {
        [[shoppingImageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [shoppingImageView addSubview:checkButton];
        [defaults setBool:YES forKey:@"shopping"];
    } else {
        [[shoppingImageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [shoppingImageView addSubview:xButton];
        [defaults setBool:NO forKey:@"shopping"];
    }
    [defaults synchronize];
    categoryChanged = YES;
}
- (IBAction)fundraiserTap:(id)sender {
    if (![defaults boolForKey:@"fundraiser"]) {
        [[fundraiserImageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [fundraiserImageView addSubview:checkButton];
        [defaults setBool:YES forKey:@"fundraiser"];
    } else {
        [[fundraiserImageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        [fundraiserImageView addSubview:xButton];
        [defaults setBool:NO forKey:@"fundraiser"];
    }
    [defaults synchronize];
    categoryChanged = YES;
}
- (IBAction)meetupTap:(id)sender {
    if (![defaults boolForKey:@"meetup"]) {
        [[meetupImageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [meetupImageView addSubview:checkButton];
        [defaults setBool:YES forKey:@"meetup"];
    } else {
        [[meetupImageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [meetupImageView addSubview:xButton];
        [defaults setBool:NO forKey:@"meetup"];
    }
    [defaults synchronize];
    categoryChanged = YES;
}
- (IBAction)freebiesTap:(id)sender {
    if (![defaults boolForKey:@"freebies"]) {
        [[freebiesImageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [freebiesImageView addSubview:checkButton];
        [defaults setBool:YES forKey:@"freebies"];
    } else {
        [[freebiesImageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [freebiesImageView addSubview:xButton];
        [defaults setBool:NO forKey:@"freebies"];
    }
    [defaults synchronize];
    categoryChanged = YES;
}
- (IBAction)otherTap:(id)sender {
    if (![defaults boolForKey:@"other"]) {
        [[otherImageView.subviews lastObject] removeFromSuperview];
        checkButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        checkButton.image = [UIImage imageNamed:@"yesButton"];
        checkButton.alpha = 0.8;
        [otherImageView addSubview:checkButton];
        [defaults setBool:YES forKey:@"other"];
    } else {
        [[otherImageView.subviews lastObject] removeFromSuperview];
        xButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        xButton.image = [UIImage imageNamed:@"noButton"];
        xButton.alpha = 0.8;
        [otherImageView addSubview:xButton];
        [defaults setBool:NO forKey:@"other"];
    }
    [defaults synchronize];
    categoryChanged = YES;
}

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
    
    if ([defaults integerForKey:@"sliderValue"] != sliderVal || ![[defaults objectForKey:@"userLocTitle"] isEqualToString:userLocationTitle] || categoryChanged) {
        return YES;
    } else {
        NSLog(@"No preferences were changed.");
        return NO;
    }
}


@end