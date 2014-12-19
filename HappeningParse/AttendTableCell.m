//
//  AttendTableCell.m
//  HappeningParse
//
//  Created by Max on 10/8/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "AttendTableCell.h"

@implementation AttendTableCell

- (void)awakeFromNib {
    
    NSLog(@"Made it");
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = CGRectMake(self.image.frame.origin.x, self.image.frame.origin.x, self.image.frame.size.width, self.image.frame.size.height);
    blurEffectView.alpha = 0.95;
    [self.image addSubview:blurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.frame = blurEffectView.bounds;
}

- (void)setupCell {
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
