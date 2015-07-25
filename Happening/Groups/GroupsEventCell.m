//
//  GroupsEventCell.m
//  Happening
//
//  Created by Max on 6/4/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupsEventCell.h"
#import "UIButton+Extensions.h"

@implementation GroupsEventCell

@synthesize blurView, myProfPicView, cornerImageView, checkButton, xButton;

- (void)awakeFromNib {
    // Initialization code
    
    //self.layer.masksToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.eventImageView.bounds;
    
    //[self.eventImageView addSubview:blurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.frame = blurEffectView.bounds;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.eventImageView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    
    //[self.eventImageView.layer insertSublayer:gradient atIndex:0];
    //[blurEffectView.layer insertSublayer:gradient atIndex:2];
    
    CAGradientLayer *l = [CAGradientLayer layer];
    l.frame = self.eventImageView.bounds;
    l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    l.startPoint = CGPointMake(0.0, 1.00f);
    l.endPoint = CGPointMake(0.0f, 0.0f);
    
    
    [blurView setUpdateInterval:0.1];
    blurView.blurRadius = 30; //14
    blurView.tintColor = [UIColor blackColor];
    //blurView.dynamic = NO;
    [self.eventImageView addSubview:blurView];
    
    self.eventImageView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.eventImageView.layer.borderWidth = 2.0;
    
    //self.eventImageView.layer.mask = l;
    //blurEffectView.layer.mask = l;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    UIView *whiteRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(18,5,284,138)];
    whiteRoundedCornerView.backgroundColor = [UIColor whiteColor];
    whiteRoundedCornerView.layer.masksToBounds = YES;
    whiteRoundedCornerView.layer.cornerRadius = 8.0;
    whiteRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
    whiteRoundedCornerView.layer.shadowOpacity = 1.0;
    whiteRoundedCornerView.layer.borderColor = [UIColor grayColor].CGColor;
    whiteRoundedCornerView.layer.borderWidth = 1.0;
    
    [self.contentView addSubview:whiteRoundedCornerView];
    [whiteRoundedCornerView addSubview:self.eventImageView];
    //[self.eventImageView addSubview:blurView];
    //[whiteRoundedCornerView addSubview:blurView];
    
    UIView *internalShadowView = [[UIView alloc] initWithFrame:CGRectMake(0,135.5,284,2)];
    internalShadowView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //internalShadowView.alpha = 0.8;
    [whiteRoundedCornerView addSubview:internalShadowView];
    
    
    UIView *externalShadowView = [[UIView alloc] initWithFrame:CGRectMake(19,135,282,10)];
    externalShadowView.layer.cornerRadius = 8.0;
    externalShadowView.backgroundColor = [UIColor lightGrayColor];
    externalShadowView.alpha = 0.3;
    [self.contentView addSubview:externalShadowView];
    
    
    [self.contentView sendSubviewToBack:whiteRoundedCornerView];
    
    
    [self.contentView sendSubviewToBack:externalShadowView];
    
    /*
     self.layer.borderWidth = 20.0;
     self.layer.cornerRadius = 10.0;
     self.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
     
     self.layer.masksToBounds = YES;
     */
    FBSDKProfilePictureView *profPic = [[FBSDKProfilePictureView alloc] initWithFrame:self.myProfPicView.bounds];
    [myProfPicView addSubview:profPic];
    
    profPic.layer.cornerRadius = 20.0;
    //profPic.layer.borderColor = [UIColor clearColor].CGColor;
    profPic.layer.masksToBounds = YES;
    
    cornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
    cornerImageView.image = [UIImage imageNamed:@"question"];
    cornerImageView.layer.cornerRadius = 7.5;
    cornerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cornerImageView.layer.borderWidth = 1.0;
    
    profPic.alpha = 0.8;
    
    [myProfPicView addSubview:cornerImageView];
    
    self.distanceLabel.minimumScaleFactor = 0.5;
    
    [self.rsvpButton setHitTestEdgeInsets:UIEdgeInsetsMake(-5, -10, -5, -5)];
    
}

- (IBAction)goingButtonPressed:(id)sender {
    
    if (checkButton.tag == 0) {
        
        [checkButton setImage:[UIImage imageNamed:@"checked6green"] forState:UIControlStateNormal];
        checkButton.tag = 1;
        
        [xButton setImage:[UIImage imageNamed:@"close7"] forState:UIControlStateNormal];
        xButton.tag = 0;
        
        cornerImageView.image = [UIImage imageNamed:@"check75"];
        
    } else {
        
        [checkButton setImage:[UIImage imageNamed:@"checked6"] forState:UIControlStateNormal];
        checkButton.tag = 0;
        
        cornerImageView.image = [UIImage imageNamed:@"question"];
        
    }
    
}

- (IBAction)NOTgoingButtonPressed:(id)sender {
    
    if (xButton.tag == 0) {
        
        [xButton setImage:[UIImage imageNamed:@"close7red"] forState:UIControlStateNormal];
        xButton.tag = 1;
        
        [checkButton setImage:[UIImage imageNamed:@"checked6"] forState:UIControlStateNormal];
        checkButton.tag = 0;
        
        cornerImageView.image = [UIImage imageNamed:@"X"];
        
    } else {
        
        [xButton setImage:[UIImage imageNamed:@"close7"] forState:UIControlStateNormal];
        xButton.tag = 0;
        
        cornerImageView.image = [UIImage imageNamed:@"question"];
        
    }
    
}

- (void)setFrame:(CGRect)frame {
    
    [super setFrame:frame];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
