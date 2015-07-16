//
//  GroupsCell.m
//  Happening
//
//  Created by Max on 6/2/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupsCell.h"

@implementation GroupsCell

@synthesize checkView;

- (void)awakeFromNib {
    // Initialization code
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 30;
    
    checkView.layer.masksToBounds = YES;
    checkView.layer.cornerRadius = 15;
    checkView.layer.borderWidth = 2.0;
    checkView.layer.borderColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
