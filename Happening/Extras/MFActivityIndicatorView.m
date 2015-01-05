//
//  MFActivityIndicatorView.m
//  Happening
//
//  Created by Max on 12/28/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "MFActivityIndicatorView.h"

@implementation MFActivityIndicatorView

-(void)didMoveToSuperview {
    
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    self.backgroundColor = [UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0];
    //self.frame = CGRectMake(-25, -25, 50, 50);
    self.layer.cornerRadius = 5.0;
    self.alpha = 0.9;
    
}

@end
