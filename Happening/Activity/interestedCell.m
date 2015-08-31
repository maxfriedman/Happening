
//
//  interestedCell.m
//  Happening
//
//  Created by Max on 7/20/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "interestedCell.h"

@implementation interestedCell

- (void)awakeFromNib {
    
    [self.eventImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.eventImageView.clipsToBounds = YES;
    self.eventImageView.autoresizingMask =
    ( UIViewAutoresizingFlexibleBottomMargin
     | UIViewAutoresizingFlexibleHeight
     | UIViewAutoresizingFlexibleLeftMargin
     | UIViewAutoresizingFlexibleRightMargin
     | UIViewAutoresizingFlexibleTopMargin
     | UIViewAutoresizingFlexibleWidth );
    
}

@end
