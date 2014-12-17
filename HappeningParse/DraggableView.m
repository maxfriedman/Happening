//
//  DraggableView.m
//  testing swiping
//
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening, LLC. All rights reserved.
//

#define ACTION_MARGIN 60 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle


#import "DraggableView.h"
#import "AppDelegate.h"

@implementation DraggableView {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize overlayView;

@synthesize eventImage;

@synthesize title;
@synthesize subtitle;
@synthesize location;
@synthesize date;
@synthesize time;
@synthesize hashtag;
@synthesize objectID;
@synthesize createdBy;

@synthesize transpBackground;

@synthesize eventDate;

@synthesize geoLoc;
@synthesize geoPoint;
@synthesize swipesRight;

@synthesize locImage, userImage;
@synthesize activityView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        /*
         UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
         activityView.center = self.center;
         [activityView startAnimating];
         [self addSubview:activityView];
         */
        self.backgroundColor = [UIColor whiteColor];
        
        eventImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 290, 190)];
        //eventImage.alpha = 0.7;
        
        //[self.Xinformation setContentMode:UIViewContentModeScaleAspectFit];
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        
        [self addGestureRecognizer:panGestureRecognizer];
        
        
        /*
        // Label for vibrant text
        UILabel *vibrantLabel = [[UILabel alloc] init];
        [vibrantLabel setText:@"Vibrant"];
        [vibrantLabel setFont:[UIFont systemFontOfSize:72.0f]];
        [vibrantLabel sizeToFit];
        [vibrantLabel setCenter: self.view.center];
        
        // Add label to the vibrancy view
        [[vibrancyEffectView contentView] addSubview:vibrantLabel];
        
        // Add the vibrancy view to the blur view
        [[blurEffectView contentView] addSubview:vibrancyEffectView];
        */
        
        title = [[UILabel alloc]initWithFrame:CGRectMake(5, 95, self.frame.size.width, 100)];
        
        subtitle = [[UILabel alloc]initWithFrame:CGRectMake(5, 185, self.frame.size.width, 100)];
        location = [[UILabel alloc]initWithFrame:CGRectMake(5, 160, self.frame.size.width, 100)];
        
        date = [[UILabel alloc]initWithFrame:CGRectMake(5, 120, self.frame.size.width, 100)];
        time = [[UILabel alloc]initWithFrame:CGRectMake(0, 315, self.frame.size.width, 100)];
        
        //date = [[UILabel alloc]initWithFrame:CGRectMake(0, 285, self.frame.size.width, 100)];
        //time = [[UILabel alloc]initWithFrame:CGRectMake(0, 315, self.frame.size.width, 100)];

        hashtag = [[UILabel alloc]initWithFrame:CGRectMake(5, 255, self.frame.size.width, 100)];
        geoLoc = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, self.frame.size.width - 5, 100)];
        swipesRight = [[UILabel alloc]initWithFrame:CGRectMake(-10, 255, self.frame.size.width, 100)];
        //createdBy = [[UILabel alloc]initWithFrame:CGRectMake(0, 380, self.frame.size.width, 100)];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = CGRectMake(0, 120, eventImage.frame.size.width, 70);
        [eventImage addSubview:blurEffectView];

        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        vibrancyEffectView.frame = blurEffectView.bounds;
        
        [title setTextAlignment:NSTextAlignmentLeft];
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont fontWithName:@"OpenSans-ExtraBold" size:21];
        
        [date setTextAlignment:NSTextAlignmentLeft];
        date.textColor = [UIColor darkTextColor];
        date.font = [UIFont fontWithName:@"OpenSans-Semibold" size:14.0];
        //[vibrancyEffectView.contentView addSubview:date];
        
        //[time setTextAlignment:NSTextAlignmentCenter];
        //time.textColor = [UIColor blackColor];
        //time.font = [UIFont fontWithName:@"OpenSans-Italic" size:17.0];
        
        [blurEffectView.contentView addSubview:vibrancyEffectView];
        
        //[eventImage addSubview:blurEffectView];
        
        [self addSubview:eventImage];
        
        //transpBackground = [[UILabel alloc]initWithFrame:CGRectMake(0, 93, self.frame.size.width, 70)];
        
        objectID = [[NSString alloc]init];
        geoPoint = [[PFGeoPoint alloc]init];
        
        locImage = [[UIImageView alloc]initWithFrame:CGRectMake(216, 160, 15, 20)];
        userImage = [[UIImageView alloc]initWithFrame:CGRectMake(185, 293, 25, 25)];
        
        /*
        [title setTextAlignment:NSTextAlignmentCenter];
        title.textColor = [UIColor blackColor];
        title.font = [UIFont fontWithName:@"OpenSans-Semibold" size:22];
        */
         
        [subtitle setTextAlignment:NSTextAlignmentLeft];
        subtitle.textColor = [UIColor darkGrayColor];
        subtitle.font = [UIFont fontWithName:@"OpenSans-Light" size:17];
        
        [location setTextAlignment:NSTextAlignmentLeft];
        location.textColor = [UIColor darkTextColor];
        location.font = [UIFont fontWithName:@"OpenSans" size:22];
        //location.shadowColor = [UIColor blackColor];
        
        //transpBackground.backgroundColor = [UIColor blackColor];
        //transpBackground.backgroundColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:0 alpha:0.5];
        
        /*
        [date setTextAlignment:NSTextAlignmentCenter];
        date.textColor = [UIColor blackColor];
        date.font = [UIFont fontWithName:@"OpenSans-Italic" size:17.0];
        
        [time setTextAlignment:NSTextAlignmentCenter];
        time.textColor = [UIColor blackColor];
        time.font = [UIFont fontWithName:@"OpenSans-Italic" size:17.0];
        */
         
        [hashtag setTextAlignment:NSTextAlignmentLeft];
        hashtag.textColor = [UIColor grayColor];
        hashtag.font = [UIFont fontWithName:@"OpenSans-Light" size:11.0];
        //hashtag.font = [UIFont boldSystemFontOfSize:15];
        //hashtag.shadowColor = [UIColor blackColor];
        
        [geoLoc setTextAlignment:NSTextAlignmentRight];
        geoLoc.textColor = [UIColor whiteColor];
        geoLoc.font = [UIFont fontWithName:@"OpenSans-Semibold" size:14.0];
        
        [swipesRight setTextAlignment:NSTextAlignmentRight];
        swipesRight.textColor = [UIColor grayColor];
        swipesRight.font = [UIFont fontWithName:@"OpenSans-Light" size:11.0];
        
        [createdBy setTextAlignment:NSTextAlignmentLeft];
        createdBy.textColor = [UIColor blackColor];
        createdBy.font = [UIFont fontWithName:@"OpenSans-Light" size:12.0];
        
        //locImage.image = [UIImage imageNamed:@"locImage"];
        [self addSubview:locImage];
        //userImage.image = [UIImage imageNamed:@"userImage"];
        [self addSubview:userImage];
        
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.center = CGPointMake(self.frame.size.width / 2, (self.frame.size.height / 2) - 30);
        [self addSubview:activityView];
        
        //[self addSubview:transpBackground];
        [self addSubview:title];
        [self addSubview:subtitle];
        [self addSubview:location];
        [self addSubview:date];
        [self addSubview:time];
        [self addSubview:hashtag];
        [self addSubview:geoLoc];
        [self addSubview:swipesRight];
        [self addSubview:createdBy];
        
        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 0, 100, 100)];
        overlayView.alpha = 0;
        [self addSubview:overlayView];
        
        //[activityView stopAnimating];
    }
    
    return self;
}

-(void)setupView
{
    self.layer.cornerRadius = 6;
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(3, 3);
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for up, negative for down
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            self.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            self.transform = scaleTransform;
            [self updateOverlay:xFromCenter];
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        overlayView.mode = GGOverlayViewModeRight;
    } else {
        overlayView.mode = GGOverlayViewModeLeft;
    }
    
    overlayView.alpha = MIN(fabsf(distance)/100, 0.4);
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > ACTION_MARGIN) {
        [self rightAction];
    } else if (xFromCenter < -ACTION_MARGIN) {
        [self leftAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = self.originalPoint;
                             self.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}

-(void)rightClickAction
{
    CGPoint finishPoint = CGPointMake(600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self];
    
    NSLog(@"YES");
}

-(void)leftClickAction
{
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                         self.transform = CGAffineTransformMakeRotation(-1);
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self];
    
    NSLog(@"NO");
}

-(void)tapAction
{
    //NSLog(@"Card tapped");
    
}



@end
