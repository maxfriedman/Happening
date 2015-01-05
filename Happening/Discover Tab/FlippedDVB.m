//
//  FlippedDVB.m
//  Happening
//
//  Created by Max on 12/1/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#define ACTION_MARGIN 60 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle

#define SWIPE_DOWN_MARGIN 100 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called

#import "FlippedDVB.h"
#import <AddressBook/AddressBook.h>

@interface FlippedDVB ()

@property (nonatomic,strong) UIButton *wikipediaButton;

@end

@implementation FlippedDVB {
    
    CGFloat xFromCenter;
    CGFloat yFromCenter;
    UILabel *tapToReturnLabel;
    UILabel *orSwipeLabel;
    
}

@synthesize panGestureRecognizer, overlayView, delegate, swipeDownMargin, actionMargin;

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        swipeDownMargin = SWIPE_DOWN_MARGIN;
        actionMargin = ACTION_MARGIN;
        
        [self setAutoresizesSubviews:YES];
        [self setupUserInterface];
        
        self.backgroundColor=[UIColor whiteColor];
        
        // attach a tap gesture recognizer to this view so it can flip
        UITapGestureRecognizer *tapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;

    
}

-(void)didMoveToSuperview {
    
    self.userSwipedFromFlippedView = NO;
        
    UILabel *transpBackground = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    transpBackground.backgroundColor = [UIColor blackColor];
    transpBackground.backgroundColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:0 alpha:0.5];
    [self addSubview:transpBackground];
    
    NSLog(@"Card flipped: %@", self.dragView.title.text);
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 285, 50)];
    self.titleLabel.text = [NSString stringWithFormat:@"%@", self.eventTitle];
    
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:22];
    
    [self addSubview:self.titleLabel];

    NSArray *array = [[NSArray alloc]initWithObjects:@"Details", @"Map View", @"Tickets", nil];
    UISegmentedControl *segcontrol = [[UISegmentedControl alloc]initWithItems:array];
    segcontrol.frame = CGRectMake(0, 55, 290, 40);
    segcontrol.selectedSegmentIndex = 0;
    
    [segcontrol addTarget:self action:@selector(segAction:) forControlEvents: UIControlEventValueChanged];
    [self performSelector:@selector(segAction:) withObject:segcontrol];
    segcontrol.alpha = 0;
    [self addSubview:segcontrol];
    segcontrol.alpha = 1;
    
    overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(0, -120, self.frame.size.width, 50)];
    overlayView.label.frame = CGRectMake(0, 100, self.frame.size.width, 50);
    overlayView.alpha = 0;
    overlayView.forFlippedDVB = YES;
    [self addSubview:overlayView];

}

- (void)segAction:(UISegmentedControl *)segment {
    
    NSLog(@"Switched to segment %ld", (long)segment.selectedSegmentIndex);
    
    if (segment.selectedSegmentIndex == 0)
    {
        //self.titleLabel.text = @"One";
        
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, 290, 220)];
        scrollView.contentSize = CGSizeMake(290, 700);
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:scrollView];
        
    } else if (segment.selectedSegmentIndex == 1)
    {
        //self.titleLabel.text = @"Two";
        
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 100, 290, 220)];
        mapView.delegate = self;
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
        [annotation setCoordinate:self.mapLocation.coordinate];
        [annotation setTitle:self.eventLocationTitle];
        
        [[[CLGeocoder alloc]init] reverseGeocodeLocation:self.mapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = placemarks[0];
            
            NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
            NSString *addressString = [lines componentsJoinedByString:@" "];
            NSLog(@"Address: %@", addressString);
            
            NSString *streetName = placemark.addressDictionary[@"Street"];
            NSString *cityName = placemark.addressDictionary[@"City"];
            NSString *stateName = placemark.addressDictionary[@"State"];
            NSString *zipCode = placemark.addressDictionary[@"ZIP"];
            if (zipCode)
                annotation.subtitle = [NSString stringWithFormat:@"%@, %@ %@, %@", streetName, cityName, stateName, zipCode];
            else annotation.subtitle = [NSString stringWithFormat:@"%@, %@, %@", streetName, cityName, stateName];

        }];
        
        [mapView addAnnotation:annotation];
        [mapView viewForAnnotation:annotation];
        [mapView selectAnnotation:annotation animated:YES];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapLocation.coordinate, 750, 750);
        [mapView setRegion:region animated:NO];
        [mapView setUserTrackingMode:MKUserTrackingModeNone];
        [mapView regionThatFits:region];
        
        [self addSubview:mapView];
        
    } else if (segment.selectedSegmentIndex == 2)
    {
        //self.titleLabel.text = @"Three";
        
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, 290, 220)];
        scrollView.contentSize = CGSizeMake(290, 700);
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:scrollView];
    }
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"Made it 1");
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else  // use whatever annotation class you used when creating the annotation
    {
        NSLog(@"Made it 2");
        
        MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"tag"];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"Annotation"];
        annotationView.centerOffset = CGPointMake(0, -18);
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
}

- (void)setupUserInterface {
    
    //self.viewController = nil;
    
    self.layer.masksToBounds = YES;
    
    self.layer.cornerRadius = 10.0;
    //self.layer.shadowRadius = 0.1;
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowOffset = CGSizeMake(0, 5);
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 2.0;
    
    /*
    self.viewController.xButton.hidden = YES;
    self.viewController.checkButton.hidden = YES;
    */
    
    CGRect buttonFrame = CGRectMake(10.0, 209.0, 234.0, 37.0);
    
    panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
    
    [self addGestureRecognizer:panGestureRecognizer];
    
    /*
    UIImageView *cardBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cardBackground"]];
    cardBackground.frame = CGRectMake(10, 320, 270, cardBackground.image.size.height - 5);
    [self addSubview:cardBackground];
    */
    
}


- (void)addLabels {
    
    tapToReturnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, self.viewController.view.frame.size.width, 100)];
    tapToReturnLabel.textAlignment = NSTextAlignmentCenter;
    tapToReturnLabel.textColor = [UIColor darkTextColor];
    tapToReturnLabel.font = [UIFont fontWithName:@"OpenSans" size:18];
    tapToReturnLabel.text = @"Tap the card to return!";
    tapToReturnLabel.alpha = 0;
    [self.viewController.view addSubview:tapToReturnLabel];
    
    orSwipeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 420, self.viewController.view.frame.size.width, 100)];
    orSwipeLabel.textAlignment = NSTextAlignmentCenter;
    orSwipeLabel.textColor = [UIColor darkTextColor];
    orSwipeLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:12];
    orSwipeLabel.text = @"(you can also swipe right, left, or down)";
    orSwipeLabel.alpha = 0;
    [self.viewController.view addSubview:orSwipeLabel];
    
    [self.viewController.view sendSubviewToBack:tapToReturnLabel];
    [self.viewController.view sendSubviewToBack:orSwipeLabel];
    
    [UIView animateWithDuration:0.5 animations:^{
        tapToReturnLabel.alpha = 1;
        orSwipeLabel.alpha = 1;
    }];
    
}

-(void)removeLabels {
    [UIView animateWithDuration:0.4 animations:^{
        tapToReturnLabel.alpha = 0;
        orSwipeLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [tapToReturnLabel removeFromSuperview];
        [orSwipeLabel removeFromSuperview];
    }];
    
}

-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:self].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:self].y; //%%% positive for down, negative for up
    
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
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > actionMargin && yFromCenter < swipeDownMargin) {
        [self rightAction];
    } else if (xFromCenter < -actionMargin && yFromCenter < swipeDownMargin + 50) { //Higher on swipe left b/c of intent for left swipe
        [self leftAction];
    } else if (yFromCenter > swipeDownMargin) { //add to cal
        [self downAction];
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
    [self.dragView removeFromSuperview];

    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         //self.superview.superview.superview.userInteractionEnabled = YES;
                         [self removeFromSuperview];
                     }];
    
    self.userSwipedFromFlippedView = YES;
    [delegate cardSwipedRight:self.dragView fromFlippedView:YES];
    
    NSLog(@"YES");
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    [self.dragView removeFromSuperview];
    CGPoint finishPoint = CGPointMake(-500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    self.userSwipedFromFlippedView = YES;
    [delegate cardSwipedLeft:self.dragView fromFlippedView:YES];
    
    NSLog(@"NO");
}

-(void)downAction
{
    [self.dragView removeFromSuperview];
    CGPoint finishPoint = CGPointMake(self.frame.size.width / 2, 1000);
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.center = finishPoint;
                     }completion:^(BOOL complete){
                         [self removeFromSuperview];
                     }];
    
    self.userSwipedFromFlippedView = YES;
    [delegate checkEventStoreAccessForCalendar];
    [delegate cardSwipedRight:self.dragView fromFlippedView:YES];
    
    NSLog(@"DOWN");
}

-(void)rightClickAction
{
    [self.dragView removeFromSuperview];
    CGPoint finishPoint = CGPointMake(900, self.center.y);
    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.center = finishPoint;
        self.transform = CGAffineTransformMakeRotation(1);
    }completion:^(BOOL complete){
        [self removeFromSuperview];
    }];
    
    self.userSwipedFromFlippedView = YES;
    [delegate cardSwipedRight:self.dragView fromFlippedView:YES];
    
    NSLog(@"YES");
}

-(void)leftClickAction
{
    [self.dragView removeFromSuperview];
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.center = finishPoint;
        self.transform = CGAffineTransformMakeRotation(-1);
    }completion:^(BOOL complete){
        self.superview.superview.superview.userInteractionEnabled = YES;
        [self removeFromSuperview];
    }];
    
    self.userSwipedFromFlippedView = YES;
    [delegate cardSwipedLeft:self.dragView fromFlippedView:YES];
    
    NSLog(@"NO");
}





- (void)drawRect:(CGRect)rect {
    
    //UIImage *backgroundImage = [UIImage imageNamed:@"Nightlife"];
    //CGRect elementSymbolRectangle = CGRectMake(50, 100, [backgroundImage size].width, [backgroundImage size].height);
    //[backgroundImage drawInRect:elementSymbolRectangle];

    
}

- (void)tapAction:(UIGestureRecognizer *)gestureRecognizer {
    
    // when a tap gesture occurs tell the view controller to flip this view to the
    // back and show the AtomicElementFlippedView instead
    self.viewController.userSwipedFromFlippedView = NO;
    [self.viewController flipCurrentView];
}


@end
