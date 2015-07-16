//
//  inviteHomiesCell.m
//  Happening
//
//  Created by Max on 5/28/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "inviteHomiesCell.h"

@implementation inviteHomiesCell

@synthesize checkView;

- (void)awakeFromNib {
    // Initialization code
    
    checkView.layer.masksToBounds = YES;
    checkView.layer.cornerRadius = 15;
    checkView.layer.borderWidth = 2.0;
    checkView.layer.borderColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        //self.nameLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:17];
        
    }
}

@end
