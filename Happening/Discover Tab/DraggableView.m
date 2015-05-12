//
//  DraggableView.m
//  Happening
//
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#define ACTION_MARGIN 60 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle

#define SWIPE_DOWN_MARGIN 100 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called


#import "DraggableView.h"
#import "AppDelegate.h"
#import "UIImage+ImageEffects.h"
#import <CoreText/CoreText.h>
#import "UIButton+Extensions.h"


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

@synthesize locImage, userImage, shareButton;
@synthesize activityView, cardBackground, cardView, greyLocImageView, calImageView, calDayLabel, calDayOfWeekLabel, calMonthLabel, calTimeLabel, moreButton;

@synthesize xButton, checkButton, eventStore, blurEffectView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.actionMargin = ACTION_MARGIN;
        self.swipeDownMargin = SWIPE_DOWN_MARGIN;
        
        eventStore = [[EKEventStore alloc] init];
        
        cardBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cardBackground"]];
        cardBackground.frame = CGRectMake(7, 349, 270, cardBackground.image.size.height - 5);
        [self addSubview:cardBackground];
        
        [self setupView:frame];

        cardView.backgroundColor = [UIColor whiteColor];
        
        eventImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 284, 180)];
        //eventImage.layer.cornerRadius = 10.0;
        eventImage.layer.masksToBounds = YES;
        eventImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
        eventImage.layer.borderWidth = 1.0;
        //eventImage.alpha = 0.7;
        
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:eventImage.bounds
                                         byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                               cornerRadii:CGSizeMake(10.0, 10.0)];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        eventImage.layer.mask = maskLayer;
        
        
        //[self.Xinformation setContentMode:UIViewContentModeScaleAspectFit];
        
        panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
        
        [self.cardView addGestureRecognizer:panGestureRecognizer];
        
        
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
        
        title = [[UILabel alloc]initWithFrame:CGRectMake(15, 103, eventImage.frame.size.width - 30, 100)];
        
        subtitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 235, self.frame.size.width - 30, 33)];
        location = [[UILabel alloc]initWithFrame:CGRectMake(15, 150, self.frame.size.width - 30, 100)];
        
        date = [[UILabel alloc]initWithFrame:CGRectMake(15, 172, self.frame.size.width - 100, 100)];
        time = [[UILabel alloc]initWithFrame:CGRectMake(0, 309, self.frame.size.width - 30, 100)];
        
        //date = [[UILabel alloc]initWithFrame:CGRectMake(0, 285, self.frame.size.width, 100)];
        //time = [[UILabel alloc]initWithFrame:CGRectMake(0, 315, self.frame.size.width, 100)];

        //hashtag = [[UILabel alloc]initWithFrame:CGRectMake(15, 240, self.frame.size.width - 30, 100)];
        geoLoc = [[UILabel alloc]initWithFrame:CGRectMake(15, 172, self.frame.size.width - 30, 100)];
        swipesRight = [[UILabel alloc]initWithFrame:CGRectMake(204, 280, 65, 100)];
        createdBy = [[UILabel alloc]initWithFrame:CGRectMake(15, 322, 160, 30)];
        
        shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 45, 15, 30, 30)];
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        blurEffectView.frame = CGRectMake(0, 120, eventImage.frame.size.width, 60);
        //[eventImage addSubview:blurEffectView];
        
        //UIImage *blurredImage = [eventImage.image applyLightEffect];
        
        UIView *view = [[UIView alloc]initWithFrame:self.blurEffectView.bounds];
        view.backgroundColor = [UIColor clearColor];
        
    // %%%%%%%%%%%%%%%% CODE FOR 
        //UIImageView *imageView = [[UIImageView alloc]initWithImage: [self convertViewToImage:view]];
        //imageView.image = [imageView.image applyLightEffect];
        
        //[eventImage addSubview:imageView];

        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        vibrancyEffectView.frame = blurEffectView.bounds;
        
        [title setTextAlignment:NSTextAlignmentLeft];
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont fontWithName:@"OpenSans-Bold" size:21];
        title.minimumScaleFactor = 0.7;
        title.adjustsFontSizeToFitWidth = YES;
        
        [date setTextAlignment:NSTextAlignmentLeft];
        date.textColor = [UIColor colorWithHue:196.36/360.0 saturation:1.0 brightness:0.949 alpha:0.95];
        date.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12];
        date.minimumScaleFactor = 0.75;
        date.adjustsFontSizeToFitWidth = YES;
        //[vibrancyEffectView.contentView addSubview:date];
        
        //[time setTextAlignment:NSTextAlignmentCenter];
        //time.textColor = [UIColor blackColor];
        //time.font = [UIFont fontWithName:@"OpenSans-Italic" size:17.0];
        
        [blurEffectView.contentView addSubview:vibrancyEffectView];
        
        //[eventImage addSubview:blurEffectView];
        
        [cardView addSubview:eventImage];
        
        transpBackground = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, eventImage.frame.size.width, 60)];
        
        objectID = [[NSString alloc]init];
        geoPoint = [[PFGeoPoint alloc]init];
        
        locImage = [[UIImageView alloc]initWithFrame:CGRectMake(218, 215, 13, 15)];
        userImage = [[UIImageView alloc]initWithFrame:CGRectMake(183, 322, 18, 18)];
        
        greyLocImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locationGrey"]];
        greyLocImageView.frame = CGRectMake(216, 186, 14, 18);
        greyLocImageView.alpha = 0;
        [self.cardView addSubview:greyLocImageView];
        
        /*
        [title setTextAlignment:NSTextAlignmentCenter];
        title.textColor = [UIColor blackColor];
        title.font = [UIFont fontWithName:@"OpenSans-Semibold" size:22];
        */
         
        [subtitle setTextAlignment:NSTextAlignmentLeft];
        //subtitle.textColor = [UIColor darkGrayColor];
        subtitle.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.50 alpha:1.0];
        subtitle.font = [UIFont fontWithName:@"OpenSans" size:12];
        subtitle.numberOfLines = 3;
        [subtitle setLineBreakMode:NSLineBreakByTruncatingTail];
        subtitle.userInteractionEnabled = YES;
        
        [location setTextAlignment:NSTextAlignmentLeft];
        //location.textColor = [UIColor colorWithRed:70/255 green:70/255 blue:70/255 alpha:0.7];
        location.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.27 alpha:1.0];
        location.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
        location.minimumScaleFactor = 0.75;
        location.adjustsFontSizeToFitWidth = YES;
        //location.shadowColor = [UIColor blackColor];
        
        transpBackground.backgroundColor = [UIColor redColor];
        transpBackground.backgroundColor = [UIColor colorWithHue:196.36/360.0 saturation:1.0 brightness:0.949 alpha:0.95];
        //transpBackground.backgroundColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:0.7 alpha:0.9];
        //transpBackground. = 0.6
        
        /*
        [date setTextAlignment:NSTextAlignmentCenter];
        date.textColor = [UIColor blackColor];
        date.font = [UIFont fontWithName:@"OpenSans-Italic" size:17.0];
        
        [time setTextAlignment:NSTextAlignmentCenter];
        time.textColor = [UIColor blackColor];
        time.font = [UIFont fontWithName:@"OpenSans-Italic" size:17.0];
        */
         
        [hashtag setTextAlignment:NSTextAlignmentLeft];
        //hashtag.textColor = [UIColor grayColor];
        hashtag.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.50 alpha:1.0];
        hashtag.font = [UIFont fontWithName:@"OpenSans" size:11.0];
        //hashtag.font = [UIFont boldSystemFontOfSize:15];
        //hashtag.shadowColor = [UIColor blackColor];
        
        [geoLoc setTextAlignment:NSTextAlignmentRight];
        geoLoc.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.50 alpha:1.0];
        geoLoc.font = [UIFont fontWithName:@"OpenSans" size:12.0];
        
        [swipesRight setTextAlignment:NSTextAlignmentRight];
        //swipesRight.textColor = [UIColor grayColor];
        swipesRight.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.50 alpha:1.0];
        swipesRight.font = [UIFont fontWithName:@"OpenSans" size:11.0];
        swipesRight.minimumScaleFactor = 0.6;
        swipesRight.adjustsFontSizeToFitWidth = YES;
        
        [createdBy setUserInteractionEnabled:YES];
        [createdBy setTextAlignment:NSTextAlignmentLeft];
        createdBy.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.50 alpha:1.0];
        createdBy.font = [UIFont fontWithName:@"OpenSans" size:11.0];
        
        [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"share pressed"] forState:UIControlStateHighlighted];
        [shareButton setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
        [cardView addSubview:shareButton];
        
        //locImage.image = [UIImage imageNamed:@"locImage"];
        [cardView addSubview:locImage];
        //userImage.image = [UIImage imageNamed:@"userImage"];
        [cardView addSubview:userImage];
        
         activityView = [[MFActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width / 2) - 25, ((self.frame.size.height / 2) - 80), 50, 50)];
        [cardView addSubview:activityView];
        
        //[cardView addSubview:transpBackground];
        [cardView addSubview:title];
        [cardView addSubview:subtitle];
        [cardView addSubview:location];
        [cardView addSubview:date];
        //[cardView addSubview:time];
        //[cardView addSubview:hashtag];
        [cardView addSubview:geoLoc];
        [cardView addSubview:swipesRight];
        [cardView addSubview:createdBy];
        
        //overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 0, 100, 100)];
        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(0, 0, eventImage.frame.size.width, 70)];
        overlayView.alpha = 0;
        [cardView addSubview:overlayView];
        
        //[activityView stopAnimating];
        
        calImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 230, 25, 25)];
        calImageView.alpha = 0;
        calImageView.userInteractionEnabled = YES;
        [cardView addSubview:calImageView];
    
        UIColor *grayColor = [UIColor colorWithRed:(70.0/255.0) green:(70.0/255.0) blue:(70.0/255.0) alpha:1.0];
        UIColor *lightGrayColor = [UIColor colorWithRed:(164.0/255.0) green:(163.0/255.0) blue:(163.0/255.0) alpha:1.0];
        
        calMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 230, 20, 20)];
        calMonthLabel.textAlignment = NSTextAlignmentCenter;
        calMonthLabel.font = [UIFont fontWithName:@"OpenSans" size:8.0];
        calMonthLabel.textColor = grayColor;
        calMonthLabel.alpha = 0;
        calMonthLabel.userInteractionEnabled = YES;
        [cardView addSubview:calMonthLabel];
        
        calDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 238, 20, 20)];
        calDayLabel.textAlignment = NSTextAlignmentCenter;
        calDayLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:10.0];
        calDayLabel.textColor = grayColor;
        calDayLabel.minimumScaleFactor = 0.75;
        calDayLabel.adjustsFontSizeToFitWidth = YES;
        calDayLabel.alpha = 0;
        calDayLabel.userInteractionEnabled = YES;
        [cardView addSubview:calDayLabel];
        
        calDayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 231, 100, 20)];
        calDayOfWeekLabel.textAlignment = NSTextAlignmentLeft;
        calDayOfWeekLabel.font = [UIFont fontWithName:@"OpenSans" size:10.0];
        calDayOfWeekLabel.textColor = grayColor;
        calDayOfWeekLabel.alpha = 0;
        calDayOfWeekLabel.userInteractionEnabled = YES;
        [cardView addSubview:calDayOfWeekLabel];
        
        calTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 242, 62, 20)];
        calTimeLabel.textAlignment = NSTextAlignmentLeft;
        calTimeLabel.font = [UIFont fontWithName:@"OpenSans" size:8.0];
        calTimeLabel.textColor = grayColor;
        calTimeLabel.minimumScaleFactor = 0.75;
        calTimeLabel.adjustsFontSizeToFitWidth = YES;
        calTimeLabel.alpha = 0;
        calTimeLabel.userInteractionEnabled = YES;
        [cardView addSubview:calTimeLabel];
        
        
        moreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, 352, 35, 20)];
        [moreButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        moreButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:11.0];
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"more"];
        [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                          value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                          range:(NSRange){0,[attString length]}];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0] range:NSMakeRange(0, [attString length])];
        
        [moreButton setAttributedTitle:attString forState:UIControlStateNormal];
        
        
        NSMutableAttributedString *attString2 = [[NSMutableAttributedString alloc] initWithString:@"more"];
        [attString2 addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                          value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                          range:(NSRange){0,[attString2 length]}];
        [attString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] range:NSMakeRange(0, [attString2 length])];
        
        [moreButton setAttributedTitle:attString2 forState:UIControlStateHighlighted];

        
        moreButton.alpha = 0;
        
        [cardView addSubview:moreButton];

    }
    
    return self;
}

-(void)swipeLeft {
    NSLog(@"Made it");
}

-(void)setupView:(CGRect)frame
{
    cardView = [[UIView alloc]initWithFrame:frame];
    [self addSubview:cardView];
    cardView.layer.masksToBounds = NO;
    
    [cardView.layer setCornerRadius:10.0];
    [cardView.layer setShadowOpacity:0.05];
    [cardView.layer setShadowOffset:CGSizeMake(1, 1)];
    //UIColor *color = [UIColor colorWithRed:<#(CGFloat)#> green:<#(CGFloat)#> blue:<#(CGFloat)#> alpha:<#(CGFloat)#>]
    [cardView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [cardView.layer setBorderWidth:1.0];
    
    /*
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowOffset = CGSizeMake(0, 5);
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 2.0;
     */
}

-(UIImage *)convertViewToImage: (UIView *)view {
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:cardView].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:cardView].y; //%%% positive for down, negative for up
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = cardView.center;
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
            cardView.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            cardView.transform = scaleTransform;
            [self updateOverlay:xFromCenter :yFromCenter];
            
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
-(void)updateOverlay:(CGFloat)xDistance :(CGFloat)yDistance
{
    
    if (xDistance > 15 && yFromCenter < SWIPE_DOWN_MARGIN) {
        overlayView.mode = GGOverlayViewModeRight;
        overlayView.alpha = MIN(fabsf(xDistance)/100, 1.0); //based on x coordinate

    } else if (xDistance < -15 && yFromCenter < SWIPE_DOWN_MARGIN + 50) { //Higher on swipe left b/c of intent for left swipe
        overlayView.mode = GGOverlayViewModeLeft;
        overlayView.alpha = MIN(fabsf(xDistance)/100, 1.0); //based on x

    } else if (yDistance > 0 ){
        overlayView.mode = GGOverlayViewModeDown;
        overlayView.alpha = MIN(fabsf(yDistance)/100, 1.0); //based on y

    }
    /*
    else {
        overlayView.alpha = MIN(fabsf(xDistance)/100, 1.0); //based on x, fixes a bug and makes overlay view go away in middle
    }
     */
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > self.actionMargin && yFromCenter < self.swipeDownMargin) {
        [self rightAction];
    } else if (xFromCenter < -self.actionMargin && yFromCenter < self.swipeDownMargin + 50) { //Higher on swipe left b/c of intent for left swipe
        [self leftAction];
    } else if (yFromCenter > self.swipeDownMargin) { //add to cal
        [self downAction];
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                         animations:^{
                             cardView.center = self.originalPoint;
                             cardView.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];

    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         cardView.center = finishPoint;
                     }completion:^(BOOL complete){
                         self.superview.superview.superview.userInteractionEnabled = YES;
                         [self setEnabledSidewaysScrolling:YES];
                         [self removeFromSuperview];
                     }];
    
    [cardBackground removeFromSuperview];
    [delegate cardSwipedRight:self fromFlippedView:NO];
    
    NSLog(@"YES");
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];

    CGPoint finishPoint = CGPointMake(-300, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         cardView.center = finishPoint;
                     }completion:^(BOOL complete){
                         self.superview.superview.superview.userInteractionEnabled = YES;
                         [self setEnabledSidewaysScrolling:YES];
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self fromFlippedView:NO];
    
    NSLog(@"NO");
}

-(void)downAction
{
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];
    
    CGPoint finishPoint = CGPointMake(cardView.frame.size.width / 2, 1000);
    [UIView animateWithDuration:0.3
                     animations:^{
                         cardView.center = finishPoint;
                     }completion:^(BOOL complete){
                         self.superview.superview.superview.userInteractionEnabled = YES;
                         [self setEnabledSidewaysScrolling:YES];
                         [self removeFromSuperview];
                     }];
    
    [delegate checkEventStoreAccessForCalendar];
    [delegate cardSwipedRight:self fromFlippedView:NO];
    
    
    NSLog(@"DOWN");
}

-(void)rightClickAction
{

    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];

    
    
    CGPoint finishPoint = CGPointMake(900, self.center.y);
    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardView.center = finishPoint;
        cardView.transform = CGAffineTransformMakeRotation(1);
    }completion:^(BOOL complete){
        self.superview.superview.superview.userInteractionEnabled = YES;
        [self setEnabledSidewaysScrolling:YES];
        [self removeFromSuperview];
    }];

    
    [delegate cardSwipedRight:self fromFlippedView:NO];
    
    NSLog(@"YES");
}

-(void)leftClickAction
{
    
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];
    
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardView.center = finishPoint;
        cardView.transform = CGAffineTransformMakeRotation(-1);
    }completion:^(BOOL complete){
        self.superview.superview.superview.userInteractionEnabled = YES;
        [self setEnabledSidewaysScrolling:YES];
        [self removeFromSuperview];
    }];
    
    [delegate cardSwipedLeft:self fromFlippedView:NO];
    
    NSLog(@"NO");
}

-(void)cardExpanded:(BOOL)b
{
    NSLog(@"Drag view tapped");
    
    if (b) {
        panGestureRecognizer.enabled = NO;
    } else {
        panGestureRecognizer.enabled = YES;
    }
    
    
}

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okaaaay"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}


// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             
         }
     }];
}


// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    // Let's get the default calendar associated with our event store
    
}

- (void)setEnabledSidewaysScrolling:(BOOL)enabled {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    [rk scrolling:enabled];
    
}

/*
- (BOOL) colorOfPointIsWhite:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
    
    //UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    BOOL isWhite = false;
    
    if (pixel[0]/255.0 > 0.75 && pixel[1]/255.0 > 0.75 && pixel[2]/255.0 > 0.75) {
        isWhite = true;
    }
    
    return isWhite;
}
 */


@end
