//
//  PermissionsView.m
//  Happening
//
//  Created by Max on 7/21/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#import "PermissionsView.h"

#define MCANIMATE_SHORTHAND
#import <POP+MCAnimate.h>
#import <LocationKit/LocationKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface PermissionsView () <CLLocationManagerDelegate>
@end

@implementation PermissionsView {
    
    UIImageView *rectImageView;
    UILabel *locSubLabel;
    UIButton *locButton;
    UILabel *notiSubLabel;
    UIButton *notiButton;
    UILabel *topLabel;
    
    BOOL notisEnabled;
    BOOL locEnabled;
    BOOL firstTime;
    
    CLLocationManager *manager;
}

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        /*
        UIImageView *circleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        circleImageView.image = [UIImage imageNamed:@"big_blue_circle"];
        [self addSubview:circleImageView];
        //circleImageView.layer.masksToBounds = YES;
        //circleImageView.layer.cornerRadius = 140;
        //circleImageView.layer.borderWidth = 2.0;
        //circleImageView.layer.borderColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
        
        circleImageView.springBounciness = 20;
        circleImageView.springSpeed = 15;
        
        circleImageView.center = self.center;
        circleImageView.spring.frame = CGRectMake(0, 0, 300, 300);
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        button.center = circleImageView.center;
        [button setTitle:@"Enable Push Notifications" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [circleImageView addSubview:button];
        */
        
        rectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        rectImageView.image = [UIImage imageNamed:@"blue_rect"];
        [self addSubview:rectImageView];
        //circleImageView.layer.masksToBounds = YES;
        //circleImageView.layer.cornerRadius = 140;
        //circleImageView.layer.borderWidth = 2.0;
        //circleImageView.layer.borderColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
        
        rectImageView.springBounciness = 10;
        rectImageView.springSpeed = 15;
        
        rectImageView.center = self.center;
        rectImageView.spring.frame = CGRectMake(0, 0, 300, 360);
        
        topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 300, 60)];
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:16.0];
        topLabel.text = @"Let Happening work for you.";
        topLabel.textColor = [UIColor whiteColor];
        topLabel.alpha = 0;
        [rectImageView addSubview:topLabel];
        
        notiButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        notiButton.center = rectImageView.center;
        notiButton.frame = CGRectMake(self.center.x - 115, self.center.y - 75, 230, 50);
        [notiButton setTitle:@"Enable Push Notifications" forState:UIControlStateNormal];
        notiButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0];
        [notiButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        notiButton.layer.masksToBounds = YES;
        notiButton.layer.cornerRadius = 8;
        notiButton.layer.borderColor = [UIColor whiteColor].CGColor;
        notiButton.layer.borderWidth = 1.5;
        [notiButton.titleLabel sizeToFit];
        notiButton.alpha = 0;
        [rectImageView addSubview:notiButton];
        
        notiSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.center.y - 50 + 25 + 5, 300, 20)];
        notiSubLabel.textAlignment = NSTextAlignmentCenter;
        notiSubLabel.font = [UIFont fontWithName:@"OpenSans" size:10.0];
        notiSubLabel.text = @"Event reminders, invites, and chat notifications.";
        notiSubLabel.textColor = [UIColor whiteColor];
        notiSubLabel.alpha = 0;
        [rectImageView addSubview:notiSubLabel];
        
        locButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        locButton.center = rectImageView.center;
        locButton.frame = CGRectMake(self.center.x - 115, self.center.y + 25, 230, 50);
        [locButton setTitle:@"Allow Location Services" forState:UIControlStateNormal];
        locButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0];
        [locButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        locButton.layer.masksToBounds = YES;
        locButton.layer.cornerRadius = 8;
        locButton.layer.borderColor = [UIColor whiteColor].CGColor;
        locButton.layer.borderWidth = 1.5;
        [locButton.titleLabel sizeToFit];
        locButton.alpha = 0;
        [rectImageView addSubview:locButton];
        
        locSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.center.y + 50 + 25 + 5, 260, 20)];
        locSubLabel.textAlignment = NSTextAlignmentCenter;
        locSubLabel.font = [UIFont fontWithName:@"OpenSans" size:10.0];
        locSubLabel.text = @"This helps us determine how close you are to an event.";
        locSubLabel.textColor = [UIColor whiteColor];
        locSubLabel.alpha = 0;
        [rectImageView addSubview:locSubLabel];
        
        UIButton *laterButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        laterButton.center = rectImageView.center;
        laterButton.frame = CGRectMake(self.center.x - 50, self.center.y - 15 + 150, 100, 30);
        [laterButton setTitle:@"maybe later" forState:UIControlStateNormal];
        laterButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:11.0];
        [laterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [laterButton.titleLabel sizeToFit];
        laterButton.alpha = 0;
        [rectImageView addSubview:laterButton];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            notiButton.alpha = 1;
            laterButton.alpha = 1;
            locButton.alpha = 1;
            topLabel.alpha = 1;
            notiSubLabel.alpha = 1;
            locSubLabel.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            notisEnabled = NO;
            locEnabled = NO;
            
            if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                NSLog(@" ====== iOS 7 ====== ");
                UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
                if (enabledTypes) notisEnabled = YES;
                if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) locEnabled = YES;
            } else {
                NSLog(@" ====== iOS 8 ====== ");
                if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) notisEnabled = YES;
                if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) locEnabled = YES;
            }
            
            firstTime = YES;
            [self updateLoc];
            [self updateNotis];
        
        }];
        
        self.userInteractionEnabled = YES;
        rectImageView.userInteractionEnabled = YES;
        
        [notiButton addTarget:self action:@selector(enableNotis) forControlEvents:UIControlEventTouchUpInside];
        [locButton addTarget:self action:@selector(enableLoc) forControlEvents:UIControlEventTouchUpInside];
        [laterButton addTarget:self action:@selector(maybeLater) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return self;
}

- (void)enableNotis {

    NSLog(@"enable notis!");
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        NSLog(@" ====== iOS 7 ====== ");
        
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        
    } else {
        
        NSLog(@" ====== iOS 8 ====== ");
        
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRegister)
                                                 name:@"didRegister"
                                               object:nil];
    
}

- (void)enableLoc {
    
    manager = [[CLLocationManager alloc] init];
    manager.delegate = self;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        NSLog(@" ====== iOS 7 ====== ");
        [manager startUpdatingLocation];
    } else {
        NSLog(@" ====== iOS 8 ====== ");
        [manager requestAlwaysAuthorization];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        NSLog(@" ====== iOS 7 ====== ");
        if (status == kCLAuthorizationStatusAuthorized) locEnabled = YES;
    } else {
        NSLog(@" ====== iOS 8 ====== ");
        if (status == kCLAuthorizationStatusAuthorizedAlways) locEnabled = YES;
    }
    
    [self updateLoc];
    
}

- (void)updateLoc {
    
    if (locEnabled) {
        
        NSLog(@"Initializing Location Kit...");
        AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [[LocationKit sharedInstance] startWithApiToken:@"48ced72017ecb03b" andDelegate:ad];
        
        locSubLabel.enabled = NO;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            locButton.alpha = 0;
            locSubLabel.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [locButton setTitle:@"Location Services" forState:UIControlStateNormal];
            locButton.layer.borderColor = [UIColor clearColor].CGColor;
            UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            imv.center = CGPointMake(locButton.center.x * 2 - 50, locButton.center.y);
            imv.image = [UIImage imageNamed:@"white_check"];
            imv.alpha = 0;
            [rectImageView addSubview:imv];
            
            [UIView animateWithDuration:0.3 animations:^{
                
                locButton.alpha = 1;
                imv.alpha = 1;
                
            } completion:^(BOOL finished) {
                
                if (notisEnabled && locEnabled) {
                    [self.delegate moveOn];
                }
                
            }];
            
        }];
        
    } else if (!firstTime) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            locSubLabel.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            locSubLabel.text = @"Error registering for location services.";
            
            [UIView animateWithDuration:0.3 animations:^{
                
                locSubLabel.alpha = 1;
                
            }];
            
        }];
        
    }
    
    firstTime = NO;
    
}

-(void)didRegister {
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        NSLog(@" ====== iOS 7 ====== ");
        UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (enabledTypes) notisEnabled = YES;
    } else {
        NSLog(@" ====== iOS 8 ====== ");
        if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) notisEnabled = YES;
    }
    
    [self updateNotis];
    
}

- (void)updateNotis {

    if (notisEnabled) {
    
        [UIView animateWithDuration:0.2 animations:^{
            
            notiButton.alpha = 0;
            notiSubLabel.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [notiButton setTitle:@"Push Notifications" forState:UIControlStateNormal];
            notiButton.layer.borderColor = [UIColor clearColor].CGColor;
            UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
            imv.center = CGPointMake(notiButton.center.x * 2 - 50, notiButton.center.y);
            imv.image = [UIImage imageNamed:@"white_check"];
            imv.alpha = 0;
            [rectImageView addSubview:imv];
            
            [UIView animateWithDuration:0.3 animations:^{
                
                notiButton.alpha = 1;
                imv.alpha = 1;
                
            } completion:^(BOOL finished) {

                if (notisEnabled && locEnabled) {
                    [self.delegate moveOn];
                }
                
            }];
            
        }];
        
        
    } else if (!firstTime) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            notiSubLabel.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            notiSubLabel.text = @"Error registering for push notifications";
            
            [UIView animateWithDuration:0.3 animations:^{
                
                notiSubLabel.alpha = 1;
                
            }];
            
        }];
        
    }
    
    firstTime = NO;
}

- (void)maybeLater {
    
    NSLog(@"maybs later :(");
    [self.delegate moveOn];
}

@end
