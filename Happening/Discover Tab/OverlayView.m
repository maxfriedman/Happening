//
//  OverlayView.m
//  Happening
//
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//


#import "OverlayView.h"
#import "FlippedDVB.h"
#import "DraggableView.h"

@implementation OverlayView {
    
    NSArray *yesArray;
    NSArray *noArray;
    NSArray *downArray;
    
}
@synthesize imageView, label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
                
        //self.backgroundColor = [UIColor whiteColor];
        /*
        imageView = [[UIImageView alloc]init];
        
        UIImage *image = [UIImage imageNamed:@"noButton"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        imageView.tintColor = [UIColor colorWithRed:0.7f green:0.0f blue:0.0f alpha:0.9];
        imageView.image = image;
        */
        //[self addSubview:imageView];
        
        yesArray = [[NSArray alloc]initWithObjects:@"I'm interested", @"Seems cool", @"Might be going", @"Interested", @"Maybe", @"Interesting", @"Not too shabby", @"Like", @":)", nil];
        noArray = [[NSArray alloc]initWithObjects:@"Nope", @"Nah", @"No thanks", @"Not interested", @"Nooo", @"Dislike", @"Meh", @"Skip", @"Naw", @":(", @"To the left to the left", nil];
        downArray = [[NSArray alloc]initWithObjects:@"I'm going", @"Going", @"Boom shakalaka", @"I'm down", @"Down to go", @"Leggooo", @"Swipe down for what", @"I'm down if you are", @"I'll be there", nil];
        
        
        label = [[UILabel alloc]init];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"OpenSans-Semibold" size:24.0];
        
        NSUInteger randomIndex = arc4random() % [noArray count];
        label.text = noArray[randomIndex];
        
        label.backgroundColor = [UIColor redColor];
        
        //label.alpha = 0;
        [self addSubview:label];
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
        /*
        UIImage *image = [UIImage imageNamed:@"noButton"];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        imageView.tintColor = [UIColor colorWithRed:0.7f green:0.0f blue:0.0f alpha:0.9];
        imageView.image = image;
        */
        NSUInteger randomIndex = arc4random() % [noArray count];
        label.text = noArray[randomIndex];
        
        label.backgroundColor = [UIColor redColor];
        
    } else if (mode == GGOverlayViewModeRight){
        //imageView.image = [UIImage imageNamed:@"yesButton"];
        
        NSUInteger randomIndex = arc4random() % [yesArray count];
        label.text = yesArray[randomIndex];
        
        label.backgroundColor = [UIColor greenColor];
        
    } else if (mode == GGOverlayViewModeDown) {
        
        NSUInteger randomIndex = arc4random() % [downArray count];
        label.text = downArray[randomIndex];
        label.backgroundColor = [UIColor cyanColor];
        
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.forFlippedDVB == YES) {
        //imageView.frame = CGRectMake(50, 50, 100, 100);
        label.frame = CGRectMake(0, 120, 284, 50);
    } else {
        //imageView.frame = CGRectMake(50, 50, 100, 100);
        label.frame = CGRectMake(0, 120, 284, 60);
    }
    
    
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
