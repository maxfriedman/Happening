//
//  OverlayView.m
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening, LLC. All rights reserved.
//

#import "OverlayView.h"

@implementation OverlayView
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor whiteColor];
        imageView = [[UIImageView alloc]init];
        
        UIImage *image = [UIImage imageNamed:@"noButton"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        imageView.tintColor = [UIColor colorWithRed:0.7f green:0.0f blue:0.0f alpha:0.9];
        imageView.image = image;
        
        [self addSubview:imageView];
        
    }
    return self;
}

-(void)setMode:(GGOverlayViewMode)mode
{
    if (_mode == mode) {
        return;
    }
    
    _mode = mode;
    
    if(mode == GGOverlayViewModeLeft) {
        UIImage *image = [UIImage imageNamed:@"noButton"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        imageView.tintColor = [UIColor colorWithRed:0.7f green:0.0f blue:0.0f alpha:0.9];
        imageView.image = image;
    } else {
        imageView.image = [UIImage imageNamed:@"yesButton"];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    imageView.frame = CGRectMake(50, 50, 100, 100);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
