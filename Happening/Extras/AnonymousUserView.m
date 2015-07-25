//
//  AnonymousUserView.m
//  Happening
//
//  Created by Max on 7/9/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "AnonymousUserView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <Parse/Parse.h>
#import "FlatButton.h"
#import "FXBlurView.h"
#import "LoginButton.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface AnonymousUserView () <LoginButtonDelegate>
@end

@implementation AnonymousUserView {
    UILabel *messageLabel;
    LoginButton *fbButton;
    UIActivityIndicatorView *activityView;
}

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        FXBlurView *blurEffectView = [[FXBlurView alloc] initWithFrame:self.bounds];
        blurEffectView.tintColor = [UIColor blackColor];
        blurEffectView.tag = 77;
        blurEffectView.blurRadius = 13;
        blurEffectView.dynamic = NO;
        
        /*
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = frame;
        */
        [self addSubview:blurEffectView];
        //self.tableView.scrollEnabled = NO;

        messageLabel = [[UILabel alloc] init];
        [messageLabel setText:[NSString stringWithFormat:@"Sign in to invite your friends!"]];
        [messageLabel setFont:[UIFont fontWithName:@"OpenSans" size:23.0]];
        messageLabel.textColor = [UIColor blackColor];
         
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setFrame:CGRectMake(40, 120, 240, 150)];
        messageLabel.numberOfLines = 0;
        
        [blurEffectView addSubview:messageLabel];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = CGRectMake(0, 0, 50, 50);
        activityView.backgroundColor = [UIColor blackColor];
        activityView.layer.cornerRadius = 5.0;
        activityView.layer.masksToBounds = YES;
        activityView.center = CGPointMake(self.frame.size.width / 2, (self.frame.size.height / 2) + 10);
        [self addSubview:activityView];
        
        fbButton = [[LoginButton alloc] initWithFrame:CGRectMake(56, 360, 208, 50)];
        [fbButton setImage:[UIImage imageNamed:@"Facebook Login"] forState:UIControlStateNormal];
        [fbButton setButtonType:@"fromAnon"];
        fbButton.delegate = self;
        fbButton.wasUserAnonymous = YES;
        [self addSubview:fbButton];
    }
    
    return self;
}

-(void)setMessage:(NSString *)message {
    messageLabel.text = message;
}

-(void)setImage:(UIImage *)image {
    
    UIImageView *imv = [[UIImageView alloc] initWithFrame:self.bounds];
    //imv.frame = CGRectMake(0, 64, 320, self.frame.size.height);
    imv.image = image;
    [self insertSubview:imv belowSubview:[self viewWithTag:77]];
}

-(void)buttonPressStart {
    
    [activityView startAnimating];
    fbButton.enabled = NO;
    
}

-(void)buttonPressEnd {
    
    [activityView stopAnimating];
    fbButton.enabled = YES;
}

-(void)loginSuccessful {
    
    //[self performSegueWithIdentifier:@"toMain" sender:self];
    [self success];
}

-(void)loginUnsuccessful {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong during the sign up process. Please email us at hello@happening.city. We apologize for the inconvenience." delegate:self cancelButtonTitle:@"Ugh" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)success {
    
    [UIView animateWithDuration:0.5 animations:^{
        messageLabel.alpha = 0;
        fbButton.alpha = 0;
        
    } completion:^(BOOL finished) {
        messageLabel.text = [NSString stringWithFormat:@"Welcome, %@!", [[PFUser currentUser] objectForKey:@"firstName"]];
        
        
        
        [UIView animateWithDuration:0.2 animations:^{
            messageLabel.alpha = 1;
        } completion:^(BOOL finished) {

            
            
            [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [self.delegate facebookSuccessfulSignup];
            }];
            
            
            
        }];
    }];
    
}

@end
