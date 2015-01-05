//
//  AttendTableCell.m
//  Happening
//
//  Created by Max on 10/8/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "AttendTableCell.h"

@implementation AttendTableCell

- (void)awakeFromNib {
        
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = CGRectMake(self.image.frame.origin.x, self.image.frame.origin.x, self.image.frame.size.width, self.image.frame.size.height);
    //blurEffectView.alpha = 0.95;

    [self.image addSubview:blurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.frame = blurEffectView.bounds;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = blurEffectView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    
    [blurEffectView.layer insertSublayer:gradient atIndex:0];
    
}

- (void)setupCell {
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
