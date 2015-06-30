//
//  GroupsCell.m
//  Happening
//
//  Created by Max on 6/2/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupsCell.h"

@implementation GroupsCell

- (void)awakeFromNib {
    // Initialization code
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 30;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
