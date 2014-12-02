//
//  FlippedDVB.m
//  HappeningParse
//
//  Created by Max on 12/1/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "FlippedDVB.h"



@interface FlippedDVB ()

@property (nonatomic,strong) UIButton *wikipediaButton;

@end

@implementation FlippedDVB

-(void)didMoveToSuperview {
    
    for (id viewToRemove in [self subviews]){
        [viewToRemove removeFromSuperview];
    }
    
    NSLog(@"Event ID: %@", self.eventID);
    self.eventIDLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 185, 200, 50)];
    self.eventIDLabel.text = [NSString stringWithFormat:@"%@", self.eventID];
    
    [self.eventIDLabel setTextAlignment:NSTextAlignmentCenter];
    self.eventIDLabel.textColor = [UIColor blackColor];
    self.eventIDLabel.font = [UIFont boldSystemFontOfSize:22];
    
    [self addSubview:self.eventIDLabel];
}

- (void)setupUserInterface {
    
    self.viewController = nil;
    
    CGRect buttonFrame = CGRectMake(10.0, 209.0, 234.0, 37.0);
    
    // create the button
    self.wikipediaButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.wikipediaButton.frame=buttonFrame;
    
    [self.wikipediaButton setTitle:@"Tickets on Eventbrite" forState:UIControlStateNormal];
    
    // Center the text on the button, considering the button's shadow
    self.wikipediaButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.wikipediaButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [self.wikipediaButton addTarget:self action:@selector(jumpToWikipedia:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.wikipediaButton];
}

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setAutoresizesSubviews:YES];
        [self setupUserInterface];
        
        // set the background color of the view to clearn
        self.backgroundColor=[UIColor whiteColor];
        
        // attach a tap gesture recognizer to this view so it can flip
        UITapGestureRecognizer *tapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)jumpToWikipedia:(id)sender {
    
    
}

- (void)drawRect:(CGRect)rect {
    
    //UIImage *backgroundImage = [UIImage imageNamed:@"Nightlife"];
    //CGRect elementSymbolRectangle = CGRectMake(50, 100, [backgroundImage size].width, [backgroundImage size].height);
    //[backgroundImage drawInRect:elementSymbolRectangle];

    
}

- (void)tapAction:(UIGestureRecognizer *)gestureRecognizer {
    
    // when a tap gesture occurs tell the view controller to flip this view to the
    // back and show the AtomicElementFlippedView instead
    [self.viewController flipCurrentView];
}


@end
