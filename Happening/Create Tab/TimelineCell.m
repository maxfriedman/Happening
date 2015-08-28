//
//  TimelineCell.m
//  Happening
//
//  Created by Max on 7/31/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "TimelineCell.h"

@implementation TimelineCell

@synthesize imv, messageLabel, imageContainerView, lineView;

- (void)awakeFromNib {
    // Initialization code
    
    imageContainerView.clipsToBounds = YES;
    imageContainerView.layer.cornerRadius = imageContainerView.frame.size.height / 2;
    imageContainerView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    imageContainerView.layer.borderWidth = 2.0;
    
}

- (void)formatCellForObject:(PFObject *)object {
    
    NSString *type = object[@"type"];
    UIColor *color;
    
    if ([type isEqualToString:@"newUser"]) {
        
        color = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0];
        
        imv.image = [UIImage imageNamed: @"timeline_newUser"];
        
        messageLabel.text = [NSString stringWithFormat:@"Welcome to Happening! Earn points by swiping right/down, inviting friends & sharing events."];
        
    } else if ([type isEqualToString:@"swipeRight"]) {
        
        color = [UIColor colorWithRed:1.0 green:0 blue:121.0/255 alpha:1.0];
        
        imv.image = [UIImage imageNamed: @"timeline_swipeRight"];
        
        messageLabel.text = [NSString stringWithFormat:@"You swiped right on %@.", object[@"eventTitle"]];
        
    } else if ([type isEqualToString:@"eventInvite"]) {
        
        color = [UIColor colorWithRed:0/255 green:191.0/255 blue:216.0/255 alpha:1.0];
        
        imv.image = [UIImage imageNamed: @"timeline_eventInvite"];
        
        messageLabel.text = [NSString stringWithFormat:@"You invited friends to an event!"];
        
    } else if ([type isEqualToString:@"groupCreate"]) {
        
        color = [UIColor colorWithRed:0/255 green:184.0/255 blue:82.0/255 alpha:1.0];
        
        imv.image = [UIImage imageNamed: @"timeline_groupCreate"];
        
        messageLabel.text = [NSString stringWithFormat:@"You created a new group!"];
        
    } else if ([type isEqualToString:@"share"]) {
        
        color = [UIColor colorWithRed:112.0/255 green:82.0/255 blue:197.0/255 alpha:1.0];
        
        imv.image = [UIImage imageNamed: @"timeline_share"];
        
        messageLabel.text = [NSString stringWithFormat:@"You shared %@!", object[@"eventTitle"]];
        
    } else if ([type isEqualToString:@"going"]) {
        
        color = [UIColor colorWithRed:0.0 green:1.0 blue:120.0/255 alpha:1.0];
        
        imv.image = [UIImage imageNamed: @"timeline_going"];
        
        messageLabel.text = [NSString stringWithFormat:@"You are going to %@.", object[@"eventTitle"]];

        
    } else if ([type isEqualToString:@"went"]) {
        
        imv.image = [UIImage imageNamed: @"timeline_went"];

        
    } else if ([type isEqualToString:@"create"]) {
        
        color = [UIColor colorWithRed:245.0/255 green:184.0/255 blue:65.0/255 alpha:1.0];
        
        imv.image = [UIImage imageNamed: @"timeline_create"];
        
        messageLabel.text = [NSString stringWithFormat:@"You created %@!", object[@"eventTitle"]];
        
        
    }
    
    
    lineView.backgroundColor = color;
    imageContainerView.backgroundColor = color;
    imv.backgroundColor = color;
    imageContainerView.layer.borderColor = color.CGColor;
    
}

- (void)setImageForType:(NSString *)type {
    
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
