//
//  ViewController.m
//  Happening
//
//  Created by Max on 9/6/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "DragViewController.h"
#import "DraggableViewBackground.h"
#import "FlippedDVB.h"
#import "CustomCalendarActivity.h"
#import "RKDropdownAlert.h"
#import "SettingsTVC.h"
#import "dropdownSettingsView.h"
#import "TutorialDragView.h"
#import "ChoosingLocation.h"
#import "DragMapViewController.h"
#import "ExternalProfileTVC.h"
#import "SVProgressHUD.h"
#import "CupertinoYankee.h"
#import "webViewController.h"
#import "SettingsChoosingLoc.h"
#import "moreDetailFromCard.h"


@interface DragViewController () <ChoosingLocationDelegate, dropdownSettingsViewDelegate>

@property (strong, nonatomic) DraggableViewBackground *draggableBackground;
@property (strong, nonatomic) FlippedDVB *flippedDVB;
@property (assign, nonatomic) CGRect mySensitiveRect;
@property (strong, nonatomic) IBOutlet dropdownSettingsView *settingsView;

@end

@implementation DragViewController {
    
    MKMapView *mapView;
    BOOL mapViewExpanded;
    MKPointAnnotation *annotation;
    BOOL dropdownExpanded;
    NSUserDefaults *defaults;
    TutorialDragView *tutorialScreens;
    BOOL showTut;
    BOOL tutIsShown;
    NSString *friendObjectID;
    NSString *urlString;
    EKEvent *calEvent;
    EKEventStore *calEventStore;
    
    int friendScrollHeight;
    int ebTicketsHeight;
    int uberTicketsHeight;
    int descriptionHeight;
    
    UIButton *uberButton;
    UIButton *ticketsButton;
    
}

@synthesize shareButton, draggableBackground, flippedDVB, xButton, checkButton, delegate, scrollView, mySensitiveRect, cardView, settingsView;

- (void)viewDidLoad {
    [super viewDidLoad];

    
    defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"hasLaunched"]) {
        showTut = YES;
    }
    
    settingsView.delegate = self;
    settingsView.layer.masksToBounds = YES;
    [settingsView.dropdownButton addTarget:self action:@selector(dropdownPressed) forControlEvents:UIControlEventTouchUpInside];
    dropdownExpanded = NO;
    
    /*
    BOOL hasLaunched = [defaults boolForKey:@"hasLaunched"];
    if (!hasLaunched) {
        [self performSegueWithIdentifier:@"toChooseLoc" sender:self];
    }
    */
    
    [scrollView setCanCancelContentTouches:YES];
    [scrollView setDelaysContentTouches:NO];
    [scrollView setBouncesZoom:YES];
    
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(-100.5, 359, 244.5, 79)]; //413
    [xButton setImage:[UIImage imageNamed:@"NotInterestedButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeftDVC) forControlEvents:UIControlEventTouchUpInside];
    
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(177, 361, 244.5, 79)];  //415
    [checkButton setImage:[UIImage imageNamed:@"InterestedButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRightDVC) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:checkButton];
    [self.scrollView addSubview:xButton];
    //[self.view sendSubviewToBack:checkButton]; //So that card is above buttons
    //[self.view sendSubviewToBack:xButton];
    [self.view bringSubviewToFront:scrollView];
    
    self.frontViewIsVisible = YES;
    self.userSwipedFromFlippedView = NO;
    
    /*
    dropdownSettingsView *settingsView = [[dropdownSettingsView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    settingsView.layer.masksToBounds = YES;
    [self.view addSubview:settingsView];
    */
}



- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    NSLog(@"LHJBDVLSJKHBV");
    return NO;
}

-(void)testing {
     NSLog(@"testing");
    [self viewWillAppear:YES];
}

-(void)viewWillAppear:(BOOL)animated {

    //[super viewWillAppear:animated];
   // NSLog(@"MAADEEE ITT!!!");
    //NSLog(@"scroll view subviews: %@", scrollView.subviews);

    
    // Refresh only if there was a change in preferences or the app has loaded for the first time.
    
    if (![defaults boolForKey:@"hasLaunched"]) {
        
        if (showTut) {
            tutorialScreens = [[TutorialDragView alloc] initWithFrame:CGRectMake(18, 18, 284, 310)];
            tutorialScreens.myViewController = self;
            [scrollView addSubview:tutorialScreens];
    
            UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialCardTapped:)];
            singleFingerTap.cancelsTouchesInView = NO;
            [tutorialScreens addGestureRecognizer:singleFingerTap];
            
            settingsView.userInteractionEnabled = NO;
            tutIsShown = YES;
            showTut =! showTut;
        }

    }
    else if ([defaults boolForKey:@"refreshData"]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // time-consuming task
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                [SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
                [SVProgressHUD setStatus:@"Loading Happenings"];
            });
        });
        
        [self refreshData];
    }
}

/*
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
    if (CGRectContainsPoint(draggableBackground.dragView.cardView.bounds, location) && self.frontViewIsVisible)
        [self tap];
    else
        NSLog(@"outside bounds");
}
 */

-(void)refreshData {
    
    NSLog(@"Refreshing data...");
    
    [tutorialScreens removeFromSuperview];
    
    if (self.frontViewIsVisible == NO) {
        [self flipCurrentView]; // Makes blur view look weird and messes with seg control when flipping
        [draggableBackground removeFromSuperview];

        
    } else {
        //cardView = self.view.subviews[2]; //Card view is 3rd in hierarchy after sending button views to the back
        
        /*
         for (id viewToRemove in [cardView subviews]){
         [viewToRemove removeFromSuperview];
         } */
        [draggableBackground removeFromSuperview];
        //[scrollView bringSubviewToFront:cardView];
        
        //cardView.userInteractionEnabled = YES;
        //UITapGestureRecognizer *tapGestureRecognizer =
        //[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTap)];
        //[cardView addGestureRecognizer:tapGestureRecognizer];
        
    }
    self.frontViewIsVisible = YES;
    self.userSwipedFromFlippedView = NO;
    
    // Removes the previous content!!!!!! (when view was burned in behind the cards)
    //NSLog(@"%lu", (unsigned long)[self.view.subviews count] );
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center=self.view.center;
    [activityView startAnimating];
    //[self.view addSubview:activityView];
    
    
    draggableBackground = [[DraggableViewBackground alloc]initWithFrame:CGRectMake(18, 18, 284, 310)];
    
    [scrollView addSubview:draggableBackground];
    [scrollView bringSubviewToFront:draggableBackground];
    
    
    draggableBackground.myViewController = self;
    //[cardView addSubview:draggableBackground];
    
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    singleFingerTap.cancelsTouchesInView = YES;
    [draggableBackground addGestureRecognizer:singleFingerTap];
    
    //[self.view addSubview:flippedDVB];
    
    [activityView stopAnimating];
    [activityView removeFromSuperview];
    
    [defaults setBool:NO forKey:@"refreshData"];
    [defaults synchronize];
    
    delegate = draggableBackground;
    
    self.mySensitiveRect = CGRectMake(0, 0, 0, 0);
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    //[scrollView addGestureRecognizer:gr];
    
    //NSLog(@"card view subviews: %@", cardView.subviews);
    
}

- (void) setLocationSegue {
    
    [self performSegueWithIdentifier:@"toChooseLoc" sender:self];
    
}


// ADD RECTS AROUND SENSITIVE POINTS LIKE MAP VIEW WHERE I DISABLE ACTION
- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self.scrollView];
    if (CGRectContainsPoint(mySensitiveRect, p)) {
        NSLog(@"got a tap in the region i care about");
        [draggableBackground.dragView cardExpanded:self.frontViewIsVisible];
        [self flipCurrentView];
        
    } else {
        NSLog(@"got a tap, but not where i need it");
    }
}


- (void)tap:(id)sender {
    
    NSLog(@"Tap");
    
    [draggableBackground.dragView cardExpanded:self.frontViewIsVisible];
    [self flipCurrentView];
    
}

-(void)swipeLeftDVC
{
    NSLog(@"Left click");
    [delegate swipeLeft];
    //[draggableBackground cardSwipedLeft:draggableBackground.dragView];
}

-(void)swipeRightDVC
{
    NSLog(@"Right click");
    [delegate swipeRight];
    //[draggableBackground cardSwipedLeft:draggableBackground.dragView];
}

- (void)flipCurrentView {
    
    scrollView.delaysContentTouches = NO;
    
    CGRect titleFrame = draggableBackground.dragView.title.frame;
    CGRect timeFrame = draggableBackground.dragView.date.frame;
    CGRect geoLocFrame = draggableBackground.dragView.geoLoc.frame;
    CGRect locImageFrame = draggableBackground.dragView.locImage.frame;
    CGRect imageFrame = draggableBackground.dragView.eventImage.frame;
    CGRect locationFrame = draggableBackground.dragView.location.frame;
    CGRect subtitleFrame = draggableBackground.dragView.subtitle.frame;
    
    if (self.frontViewIsVisible == YES) {
        
        [self addSubviewsToCard:draggableBackground.dragView];
        
        [self setEnabledSidewaysScrolling:NO];
        
        scrollView.contentSize = CGSizeMake(320, 530);
        scrollView.scrollEnabled = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            for (UIView *view in draggableBackground.dragView.eventImage.subviews) {
                if ([view isKindOfClass:[FXBlurView class]]) {
                    view.alpha = 0;
                }
            }
            
            CAGradientLayer *l = [CAGradientLayer layer];
            
            l.frame = draggableBackground.dragView.eventImage.bounds;
            l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
            
            l.startPoint = CGPointMake(0.0, 0.8f);
            l.endPoint = CGPointMake(0.0f, 1.0f);
            
            UIView *view = [[UIView alloc] initWithFrame:draggableBackground.dragView.eventImage.bounds];
            [draggableBackground.dragView.eventImage addSubview:view];
            view.backgroundColor = [UIColor whiteColor];
            view.layer.mask = l;
            view.tag = 99;
            
            draggableBackground.dragView.eventImage.layer.borderWidth = 0.0;
            
            //draggableBackground.dragView.eventImage.maskView.layer.mask = l;
            
            NSLog(@"%@", draggableBackground.dragView.eventImage.layer.sublayers);
            
             //cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, cardView.frame.size.width, 320 + 300);
            draggableBackground.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y, draggableBackground.frame.size.width, 320 + 185);
            draggableBackground.dragView.frame = CGRectMake(draggableBackground.dragView.frame.origin.x, draggableBackground.dragView.frame.origin.y, draggableBackground.dragView.frame.size.width, 320 + 185);
            draggableBackground.dragView.cardView.frame = CGRectMake(draggableBackground.dragView.cardView.frame.origin.x, draggableBackground.dragView.cardView.frame.origin.y, draggableBackground.dragView.cardView.frame.size.width, 320 + 185);
            
            CGRect frame = self.tabBarController.tabBar.frame;
            CGFloat offsetY = frame.origin.y;
            self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
            

            xButton.center = CGPointMake(-1000, xButton.center.y);
            checkButton.center = CGPointMake(1300, checkButton.center.y);
            
            // %%% ANIMATES CARD ELEMENTS:
            
            
            //draggableBackground.blurView.dynamic = YES;
            //draggableBackground.blurView.frame = CGRectMake(0, 400, 100, 300);
            
            draggableBackground.dragView.title.frame = CGRectMake(titleFrame.origin.x, titleFrame.origin.y + 55, titleFrame.size.width, titleFrame.size.height);
        
            //draggableBackground.dragView.date.frame = CGRectMake(timeFrame.origin.x, timeFrame.origin.y + 75, 110, timeFrame.size.height);
            
            draggableBackground.dragView.geoLoc.frame = CGRectMake(geoLocFrame.origin.x, geoLocFrame.origin.y + 45, geoLocFrame.size.width, geoLocFrame.size.height);
            
            draggableBackground.dragView.createdBy.frame = CGRectMake(draggableBackground.dragView.createdBy.frame.origin.x, draggableBackground.dragView.createdBy.frame.origin.y - 76, 254, draggableBackground.dragView.createdBy.frame.size.height);
            [draggableBackground.dragView.createdBy sizeToFit];

            
            //draggableBackground.dragView.locImage.frame = CGRectMake(locImageFrame.origin.x, locImageFrame.origin.y + 50, locImageFrame.size.width, locImageFrame.size.height);
            draggableBackground.dragView.locImage.alpha = 0;
            draggableBackground.dragView.greyLocImageView.alpha = 1;
            
            draggableBackground.dragView.hashtag.alpha = 0;
            
            draggableBackground.dragView.calImageView.alpha = 1.0;
            draggableBackground.dragView.calMonthLabel.alpha = 1.0;
            draggableBackground.dragView.calDayLabel.alpha = 1.0;
            draggableBackground.dragView.calDayOfWeekLabel.alpha = 1.0;
            draggableBackground.dragView.calTimeLabel.alpha = 1.0;
            
            draggableBackground.dragView.date.alpha = 0.0;
            
            CGRect calTimeFrame = draggableBackground.dragView.calTimeLabel.frame;
            CGRect calDayOfWeekFrame = draggableBackground.dragView.calDayOfWeekLabel.frame;
            
            if (calTimeFrame.size.width > calDayOfWeekFrame.size.width) {
                draggableBackground.dragView.location.frame = CGRectMake(calTimeFrame.origin.x + calTimeFrame.size.width + 5, 232, 310 - 30 - 5 - calTimeFrame.origin.x - calTimeFrame.size.width, 21);
            } else {
                draggableBackground.dragView.location.frame = CGRectMake(calDayOfWeekFrame.origin.x + calDayOfWeekFrame.size.width + 5, 232, 310 - 30 - 5 - calDayOfWeekFrame.origin.x - calDayOfWeekFrame.size.width, 21);
            }
            
            draggableBackground.dragView.subtitle.frame = CGRectMake(subtitleFrame.origin.x, subtitleFrame.origin.y + 37, subtitleFrame.size.width, subtitleFrame.size.height);
            
            draggableBackground.dragView.swipesRight.center = CGPointMake(draggableBackground.dragView.swipesRight.center.x, draggableBackground.dragView.swipesRight.center.y + 10);
            draggableBackground.dragView.userImage.center = CGPointMake(draggableBackground.dragView.userImage.center.x, draggableBackground.dragView.userImage.center.y + 10);
            
            UIColor *blueColor = [UIColor colorWithRed:(128.0/255.0) green:(208.0/255.0) blue:(244.0/255.0) alpha:1.0];
            UIColor *grayColor = [UIColor colorWithRed:(70.0/255.0) green:(70.0/255.0) blue:(70.0/255.0) alpha:1.0];
            UIColor *lightGrayColor = [UIColor colorWithRed:(164.0/255.0) green:(163.0/255.0) blue:(163.0/255.0) alpha:1.0];
            
            [UIView transitionWithView:draggableBackground.dragView.date duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
                //[draggableBackground.dragView.date setTextColor:blueColor];
                
            } completion:nil];

            [UIView transitionWithView:draggableBackground.dragView.title duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
                [draggableBackground.dragView.title setTextColor:grayColor];
                
            } completion:nil];

            [UIView transitionWithView:draggableBackground.dragView.geoLoc duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
                [draggableBackground.dragView.geoLoc setTextColor:lightGrayColor];
                
            } completion:nil];
            
            
        } completion:^(BOOL finished) {
            
            draggableBackground.dragView.cardView.layer.masksToBounds = NO;
            
            //self.mySensitiveRect = CGRectMake(18, 322, 284, 310);
            
            //[self.view  addSubview:scrollView];
            //[self.view sendSubviewToBack:scrollView];
            //[cardView removeFromSuperview];
            //[scrollView addSubview:cardView];
            
            ///NSLog(@"Self: %@ ... cardView: %@  .... scrollView: %@", self.view.subviews, cardView.subviews, scrollView.subviews);
            
            //draggableBackground.dragView.cardView.userInteractionEnabled = YES;
            //UITapGestureRecognizer *tapGestureRecognizer =
            //[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTap)];
            //[draggableBackground.dragView.cardView addGestureRecognizer:tapGestureRecognizer];
            
        }];
    
    
    } else {
        
        draggableBackground.dragView.cardView.layer.masksToBounds = YES;
        
        [self setEnabledSidewaysScrolling:YES];
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        scrollView.scrollEnabled = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            for (UIView *view in draggableBackground.dragView.eventImage.subviews) {
                if ([view isKindOfClass:[FXBlurView class]]) {
                    view.alpha = 1;
                }
            }
            
            //cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, cardView.frame.size.width, 310);
            draggableBackground.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y, draggableBackground.frame.size.width, 310);
            draggableBackground.dragView.frame = CGRectMake(draggableBackground.dragView.frame.origin.x, draggableBackground.dragView.frame.origin.y, draggableBackground.dragView.frame.size.width, 310);
            draggableBackground.dragView.cardView.frame = CGRectMake(draggableBackground.dragView.cardView.frame.origin.x, draggableBackground.dragView.cardView.frame.origin.y, draggableBackground.dragView.cardView.frame.size.width, 310);
            
            xButton.center = CGPointMake(21.75, xButton.center.y);
            checkButton.center = CGPointMake(302.25, checkButton.center.y);
            
            CGRect frame = self.tabBarController.tabBar.frame;
            self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, -519);
            
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^{
                
                //draggableBackground.dragView.eventImage.layer.mask = nil;
                [[draggableBackground.dragView.eventImage viewWithTag:99] removeFromSuperview];
                draggableBackground.dragView.eventImage.layer.borderWidth = 1.0;
                
            });
            
            // %%% CONTRACTS CARD ELEMENTS:
            
            draggableBackground.dragView.title.frame = CGRectMake(titleFrame.origin.x, titleFrame.origin.y - 55, titleFrame.size.width, titleFrame.size.height);
            
            //draggableBackground.dragView.date.frame = CGRectMake(timeFrame.origin.x, timeFrame.origin.y - 75, timeFrame.size.width + 20, timeFrame.size.height);
            
            draggableBackground.dragView.geoLoc.frame = CGRectMake(geoLocFrame.origin.x, geoLocFrame.origin.y - 45, geoLocFrame.size.width, geoLocFrame.size.height);
            
            
            //draggableBackground.dragView.locImage.frame = CGRectMake(locImageFrame.origin.x, locImageFrame.origin.y - 50, locImageFrame.size.width, locImageFrame.size.height);
            draggableBackground.dragView.locImage.alpha = 1;
            draggableBackground.dragView.greyLocImageView.alpha = 0;
            
            draggableBackground.dragView.hashtag.alpha = 1;
            
            draggableBackground.dragView.calImageView.alpha = 0;
            draggableBackground.dragView.calMonthLabel.alpha = 0;
            draggableBackground.dragView.calDayLabel.alpha = 0;
            draggableBackground.dragView.calDayOfWeekLabel.alpha = 0;
            draggableBackground.dragView.calTimeLabel.alpha = 0;
            
            draggableBackground.dragView.date.alpha = 1.0;
            
            draggableBackground.dragView.location.frame = CGRectMake(15, 150, 254, 100);
            
            draggableBackground.dragView.subtitle.frame = CGRectMake(subtitleFrame.origin.x, subtitleFrame.origin.y - 37, subtitleFrame.size.width, subtitleFrame.size.height);
            
            draggableBackground.dragView.createdBy.frame = CGRectMake(draggableBackground.dragView.createdBy.frame.origin.x, draggableBackground.dragView.createdBy.frame.origin.y + 76, 160, draggableBackground.dragView.createdBy.frame.size.height);
            
            if (draggableBackground.dragView.createdBy.frame.size.width < 160) {
                [draggableBackground.dragView.createdBy sizeToFit];
            }
            
            
            draggableBackground.dragView.swipesRight.center = CGPointMake(draggableBackground.dragView.swipesRight.center.x, draggableBackground.dragView.swipesRight.center.y - 10);
            draggableBackground.dragView.userImage.center = CGPointMake(draggableBackground.dragView.userImage.center.x, draggableBackground.dragView.userImage.center.y - 10);
            
            [UIView transitionWithView:draggableBackground.dragView.date duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
                [draggableBackground.dragView.date setTextColor:[UIColor darkTextColor]];
                
            } completion:nil];
            
            [UIView transitionWithView:draggableBackground.dragView.title duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
                [draggableBackground.dragView.title setTextColor:[UIColor whiteColor]];
                
            } completion:nil];
            
            [UIView transitionWithView:draggableBackground.dragView.geoLoc duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
                [draggableBackground.dragView.geoLoc setTextColor:[UIColor whiteColor]];
                
            } completion:nil];
            
        } completion:^(BOOL finished) {
            
            self.mySensitiveRect = CGRectMake(0, 0, 0, 0);
            
            //[draggableBackground.dragView.createdBy sizeToFit];
            
            for (UIView *view in draggableBackground.dragView.cardView.subviews) {
                
                if (view.tag == 3)
                    [view removeFromSuperview];
            }
            
            draggableBackground.dragView.cardView.layer.masksToBounds = NO;
            
        }];

        
        
        
    }
    
    self.frontViewIsVisible =! self.frontViewIsVisible;
    
    /*
    NSLog(@"VC CODE");
    // disable user interaction during the flip animation
    self.view.userInteractionEnabled = NO;
    
    // setup the animation group
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
    
    // swap the views and transition
    if (self.frontViewIsVisible == YES) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:cardView cache:YES];
        [self.draggableBackground removeFromSuperview];
        
        // Create the flipped view
        flippedDVB = [[FlippedDVB alloc]initWithFrame:CGRectMake(-1, -1, 291, 321)];
        flippedDVB.viewController = self;
        flippedDVB.delegate = draggableBackground; // THE MISSING DELGATE CALL!!
        
        //Add tap to return label
        [flippedDVB addLabels];
        
        // %%%%% Pass variables to flipped card
        NSLog(@"Tapped Event: %@",self.title);
        flippedDVB.eventID = self.eventID;
        flippedDVB.mapLocation = self.mapLocation;
        flippedDVB.eventTitle = self.eventTitle;
        flippedDVB.eventLocationTitle = self.locationTitle;
        
        flippedDVB.dragView = self.draggableBackground.dragView;
        // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        CGPoint xButtonFinishPoint = CGPointMake(-600, xButton.center.y);
        CGPoint checkButtonFinishPoint = CGPointMake(900, checkButton.center.y);
        [UIView animateWithDuration:0.6 animations:^{
            xButton.center = xButtonFinishPoint;
            checkButton.center = checkButtonFinishPoint;
            //xButton.transform = CGAffineTransformMakeRotation(1);
        }];
     
        
        [cardView addSubview:self.flippedDVB];
    } else {
        
        if (self.userSwipedFromFlippedView == YES) {
            NSLog(@"User swiped from flipped view!");
            [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:cardView cache:YES];
        } else {
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cardView cache:YES];
            [self.flippedDVB removeFromSuperview];
            
        }
        
        [flippedDVB removeLabels];

        CGPoint xButtonFinishPoint = CGPointMake(21.75, xButton.center.y);
        CGPoint checkButtonFinishPoint = CGPointMake(302.25, checkButton.center.y);
        [UIView animateWithDuration:0.6 animations:^{
            xButton.center = xButtonFinishPoint;
            checkButton.center = checkButtonFinishPoint;
        }];


        [cardView addSubview:self.draggableBackground];
    }
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
    
    [UIView commitAnimations];
    
    // invert the front view state
    self.frontViewIsVisible =! self.frontViewIsVisible;

*/
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    NSLog(@"made it JSKDNLSJDNVLSJN");
    
    if ( CGRectContainsPoint(self.view.frame, point) )
        return YES;
    
    return [self.view pointInside:point withEvent:event];
}

- (void)addSubviewsToCard:(DraggableView *)card {
    
    scrollView.delaysContentTouches = NO;
    
    draggableBackground.dragView.cardView.userInteractionEnabled = YES;
    //draggableBackground.dragView.cardView.frame = CGRectMake(0, 0, cardView.frame.size.width, 620);
    draggableBackground.dragView.cardView.layer.masksToBounds = YES;
    
    NSLog(@"expand card");
        
    card.friendsInterested = [[UILabel alloc]initWithFrame:CGRectMake(170, 265, 99, 100)];
    card.friendsInterested.text = @"0 friends interested";
    [card.friendsInterested setTextAlignment:NSTextAlignmentRight];
    card.friendsInterested.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.64 alpha:1.0];
    card.friendsInterested.font = [UIFont fontWithName:@"OpenSans" size:11.0];
    card.friendsInterested.minimumScaleFactor = 0.75;
    card.friendsInterested.adjustsFontSizeToFitWidth = YES;
    card.friendsInterested.tag = 3;
    
    UIImageView *friendImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"friends"]];
    friendImageView.frame = CGRectMake(148, 306, 18, 18);
    friendImageView.tag = 3;
    
    friendScrollHeight = 0;
    UIScrollView *friendScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15, 330, 254, friendScrollHeight)];
    friendScrollView.scrollEnabled = YES;
    [self loadFBFriends:friendScrollView];
    friendScrollView.tag = 3;
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(15, 340, 254, 133)];
    [card.cardView addSubview:mapView];
    mapView.tag = 3;
    
    mapView.delegate = self;
    mapView.layer.masksToBounds = YES;
    
    mapView.layer.cornerRadius = 10.0;
    //self.layer.shadowRadius = 0.1;
    mapView.layer.shadowOpacity = 0.1;
    mapView.layer.shadowOffset = CGSizeMake(0, 5);
    mapView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    mapView.layer.borderWidth = 0.5;
    mapView.scrollEnabled = NO;
    mapView.zoomEnabled = YES; // Change???
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:draggableBackground.dragView.objectID block:^(PFObject *object, NSError *error) {
    
        PFGeoPoint *loc = object[@"GeoLoc"];
        CLLocation *mapLocation = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
    
        annotation = [[MKPointAnnotation alloc]init];
        [annotation setCoordinate:mapLocation.coordinate];
        [annotation setTitle:draggableBackground.dragView.location.text];
    
        [[[CLGeocoder alloc]init] reverseGeocodeLocation:mapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = placemarks[0];
        
            NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
            NSString *addressString = [lines componentsJoinedByString:@" "];
            NSLog(@"Address: %@", addressString);
        
            NSString *streetName = placemark.addressDictionary[@"Street"];
            NSString *cityName = placemark.addressDictionary[@"City"];
            NSString *stateName = placemark.addressDictionary[@"State"];
            NSString *zipCode = placemark.addressDictionary[@"ZIP"];
            
            if (streetName && zipCode && cityName) {
                annotation.subtitle = [NSString stringWithFormat:@"%@ %@, %@ %@", streetName, cityName, stateName, zipCode];
            } else if (zipCode && !streetName) {
                annotation.subtitle = [NSString stringWithFormat:@"%@, %@ %@", cityName, stateName, zipCode];;
            } else if (cityName && streetName) {
                annotation.subtitle = [NSString stringWithFormat:@"%@ %@, %@", streetName, cityName, stateName];
            } else
                annotation.subtitle = draggableBackground.dragView.location.text;
        
        }];
        
        [mapView setZoomEnabled:NO];
        [mapView addAnnotation:annotation];
        [mapView viewForAnnotation:annotation];
        [mapView selectAnnotation:annotation animated:YES];
    
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapLocation.coordinate, 750, 750);
        [mapView setRegion:region animated:NO];
        [mapView setUserTrackingMode:MKUserTrackingModeNone];
        [mapView regionThatFits:region];
        
        UITapGestureRecognizer *mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(mapViewTapped)];
        [mapView addGestureRecognizer:mapTap];
    
        /*
        UIButton *mapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 254, 133)];
        [mapButton addTarget:self action:@selector(mapViewTapped) forControlEvents:UIControlEventTouchUpInside];
        [mapView addSubview:mapButton];
        //[mapButton setBackgroundColor:[UIColor whiteColor]];
        */
        
        NSString *ticketLink = [NSString stringWithFormat:@"%@", object[@"TicketLink"]];
        int height = 0;
        
        if ([object objectForKey:@"TicketLink"]) {
            
            height += 20;
            
            
            NSLog(@"ticket link::: %@", ticketLink);
            
            ticketsButton = [[UIButton alloc] initWithFrame:CGRectMake(79, 490, 126, 20)];
            ticketsButton.enabled = YES;
            ticketsButton.userInteractionEnabled = YES;
            ticketsButton.tag = 3;
            
            if ([ticketLink containsString:@"eventbrite"]) {
    
                //ticketsButton = [[UIButton alloc] initWithFrame:CGRectMake(79, 500, 126, 20)];
                [ticketsButton setImage:[UIImage imageNamed:@"buy tickets"] forState:UIControlStateNormal];
                [ticketsButton setImage:[UIImage imageNamed:@"buy tickets pressed"] forState:UIControlStateSelected];
    
                //[self ticketsUpdateFrameBy:20];
                [card.cardView addSubview:ticketsButton];
                
            } else {
                
                //ticketsButton = [[UIButton alloc] initWithFrame:CGRectMake(79, 500, 126, 20)];
                [ticketsButton setImage:[UIImage imageNamed:@"buy tickets"] forState:UIControlStateNormal];
                [ticketsButton setImage:[UIImage imageNamed:@"buy tickets pressed"] forState:UIControlStateSelected];

                //[self ticketsUpdateFrameBy:20];
                [card.cardView addSubview:ticketsButton];
            }
            
            ticketsButton.accessibilityIdentifier = ticketLink;
            [ticketsButton addTarget:self action:@selector(ticketsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            
        }
        
        NSDate *startDate = object[@"Date"];
        //NSDate *endDate = object[@"EndTime"];
        
        // Show call uber button if the event is today or if the end date is later than now
        if ( /*[defaults boolForKey:@"today"] */ [startDate beginningOfDay] <= [[NSDate date] beginningOfDay] ) {
            
            height += 20;
            
            // adding "height" variable allows flexibility if there is no tickets button
            if (height == 20) {
                
                uberButton = [[UIButton alloc] initWithFrame:CGRectMake(86.5, 490, 111, 20)];
            
            } else {
                
                uberButton = [[UIButton alloc] initWithFrame:CGRectMake(86.5, 478 + height, 111, 20)];

            }
            
            [uberButton setImage:[UIImage imageNamed:@"call uber"] forState:UIControlStateNormal];
            [uberButton setImage:[UIImage imageNamed: @"call uber pressed"] forState:UIControlStateSelected];
            [uberButton addTarget:self action:@selector(grabAnUberButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            uberButton.tag = 3;
    
            [card.cardView addSubview:uberButton];
            //[self uberUpdateFrameBy:20];
            
        }
        
        [self ticketsAndUberUpdateFrameBy:height + 8];
        
        [card.cardView addSubview:card.friendsInterested];
        [card.cardView addSubview:friendImageView];
        [card.cardView addSubview:friendScrollView];
        [card.cardView bringSubviewToFront:mapView];
    
        mapViewExpanded = NO;
        
        
    }];
    
    /*
    for (UIView *view in card.cardView.subviews) {
        
        for (UITapGestureRecognizer *gr in view.gestureRecognizers) {
            
            gr.delegate = self;
            
        }
        
    }
    
    for (UIView *view in card.cardView.subviews) {
        
        for (UITapGestureRecognizer *gr in view.gestureRecognizers) {
            
            gr.delegate = self;
            
        }
        
    }
    */
}

- (void)loadFBFriends:(UIScrollView *)friendScrollView {
    
    NSLog(@"Loading FB Friends");
    
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_friends"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"That's odd"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              NSLog(@"Session open, recurse");
                                              
                                              [self loadFBFriends:friendScrollView];
                                          } else {
                                              NSLog(@"Made it");
                                          }
                                      }];
    }
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %lu friends", (unsigned long)friends.count);
        
        __block int friendCount = 0;
        
        for (int i = 0; i < friends.count; i ++) {
            
            NSDictionary<FBGraphUser>* friend = friends[i];
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.objectID);
            
            PFQuery *friendQuery = [PFQuery queryWithClassName:@"Swipes"];
            [friendQuery whereKey:@"FBObjectID" equalTo:friend.objectID];
            [friendQuery whereKey:@"EventID" equalTo:draggableBackground.dragView.objectID];
            [friendQuery whereKey:@"swipedRight" equalTo:@YES];
            [friendQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                NSLog(@"%@ with id %@", friend.name, friend.objectID);
                if (object != nil && !error) {
                    NSLog(@"LIKES THIS EVENT");
                    
                    /*
                    NSString *path = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", friend.objectID];
                    
                    NSURL *url = [NSURL URLWithString:path];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    
                    //CGSize size = img.size;
                    
                    NSLog(@"IMAGE %@", img);
                    
                    UIImageView *profPicImageView = [[UIImageView alloc] initWithImage:img];
                    profPicImageView.layer.cornerRadius = 20;
                    profPicImageView.layer.masksToBounds = YES;
                    profPicImageView.frame = CGRectMake(50 * friendCount, 0, 40, 40);
                    [friendScrollView addSubview:profPicImageView];
                    
                     */
                    
                    FBProfilePictureView *profPicView = [[FBProfilePictureView alloc] initWithProfileID:friend.objectID pictureCropping:FBProfilePictureCroppingSquare];
                    profPicView.layer.cornerRadius = 20;
                    profPicView.layer.masksToBounds = YES;
                    profPicView.frame = CGRectMake(50 * friendCount, 0, 40, 40);
                    profPicView.accessibilityIdentifier = object[@"UserID"];
                    profPicView.userInteractionEnabled = YES;
                    [friendScrollView addSubview:profPicView];
                    
                    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFriendProfile:)];
                    [profPicView addGestureRecognizer:gr];
                    
                    UILabel *nameLabel = [[UILabel alloc] init];
                    nameLabel.font = [UIFont fontWithName:@"OpenSans" size:7];
                    nameLabel.textColor = [UIColor blackColor];
                    nameLabel.textAlignment = NSTextAlignmentCenter;
                    nameLabel.text = friend.first_name;
                    nameLabel.frame = CGRectMake(5 + (50 * friendCount), 42, 30, 8);
                    [friendScrollView addSubview:nameLabel];
                    
                    friendScrollHeight = 50;
                    friendScrollView.frame = CGRectMake(15, 330, 254, friendScrollHeight);
                    friendScrollView.contentSize = CGSizeMake((50 * friendCount) + 40, 50);
                    
                    [self friendsUpdateFrameBy:50];
                    
                    friendCount++;
                    
                    if (friendCount == 1) {
                        draggableBackground.dragView.friendsInterested.text = [NSString stringWithFormat:@"%d friend interested", friendCount];
                    } else {
                        draggableBackground.dragView.friendsInterested.text = [NSString stringWithFormat:@"%d friends interested", friendCount];
                    }
                    
                }
                
            }];
            
            
            /*
             NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
             @"false", @"url",
             @"200", @"height",
             @"normal", @"type",
             @"200", @"width",
             nil
             ];
             
             [FBRequestConnection startWithGraphPath:@"/me/picture"
             parameters:params
             HTTPMethod:@"GET"
             completionHandler:^(
             FBRequestConnection *connection,
             id result,
             NSError *error
             ) {
             }];
             */
        }
        
    }];
    
    
}

- (void)friendsUpdateFrameBy:(int)height {
    
    if (!self.frontViewIsVisible) {
    
    [UIView animateWithDuration:0.2 animations:^{
        
        mapView.center = CGPointMake(mapView.center.x, mapView.center.y + height);
        uberButton.center = CGPointMake(uberButton.center.x, uberButton.center.y + height);
        ticketsButton.center = CGPointMake(ticketsButton.center.x, ticketsButton.center.y + height);
        
        draggableBackground.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y, draggableBackground.frame.size.width, draggableBackground.frame.size.height + height);
        draggableBackground.dragView.frame = CGRectMake(draggableBackground.dragView.frame.origin.x, draggableBackground.dragView.frame.origin.y, draggableBackground.dragView.frame.size.width, draggableBackground.dragView.frame.size.height + height);
        draggableBackground.dragView.cardView.frame = CGRectMake(draggableBackground.dragView.cardView.frame.origin.x, draggableBackground.dragView.cardView.frame.origin.y, draggableBackground.dragView.cardView.frame.size.width, draggableBackground.dragView.cardView.frame.size.height + height);
        
        scrollView.contentSize = CGSizeMake(320, scrollView.contentSize.height + height);

        
    } completion:^(BOOL finished) {
        
    }];
        
    }
    
}

- (void)descriptionUpdateFrameBy:(int)height {
    
    
}

- (void)ticketsAndUberUpdateFrameBy:(int)height {
    
    if (!self.frontViewIsVisible) {
    
    [UIView animateWithDuration:0.2 animations:^{
        
        //uberButton.center = CGPointMake(uberButton.center.x, uberButton.center.y + height);
        //ticketsButton.center = CGPointMake(ticketsButton.center.x, ticketsButton.center.y + height);
        
        draggableBackground.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y, draggableBackground.frame.size.width, draggableBackground.frame.size.height + height);
        draggableBackground.dragView.frame = CGRectMake(draggableBackground.dragView.frame.origin.x, draggableBackground.dragView.frame.origin.y, draggableBackground.dragView.frame.size.width, draggableBackground.dragView.frame.size.height + height);
        draggableBackground.dragView.cardView.frame = CGRectMake(draggableBackground.dragView.cardView.frame.origin.x, draggableBackground.dragView.cardView.frame.origin.y, draggableBackground.dragView.cardView.frame.size.width, draggableBackground.dragView.cardView.frame.size.height + height);
        
        scrollView.contentSize = CGSizeMake(320, scrollView.contentSize.height + height);
        
        
    } completion:^(BOOL finished) {
        
    }];
        
    }
    
}

- (void)uberUpdateFrameBy:(int)height {
    
    if (!self.frontViewIsVisible) {
    
    [UIView animateWithDuration:0.2 animations:^{
        
        draggableBackground.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y, draggableBackground.frame.size.width, draggableBackground.frame.size.height + height);
        draggableBackground.dragView.frame = CGRectMake(draggableBackground.dragView.frame.origin.x, draggableBackground.dragView.frame.origin.y, draggableBackground.dragView.frame.size.width, draggableBackground.dragView.frame.size.height + height);
        draggableBackground.dragView.cardView.frame = CGRectMake(draggableBackground.dragView.cardView.frame.origin.x, draggableBackground.dragView.cardView.frame.origin.y, draggableBackground.dragView.cardView.frame.size.width, draggableBackground.dragView.cardView.frame.size.height + height);
        
        scrollView.contentSize = CGSizeMake(320, scrollView.contentSize.height + height);
        
        
    } completion:^(BOOL finished) {
        
    }];
        
    }
    
}

- (void)mapViewTapped {
    
    [self performSegueWithIdentifier:@"toMapView" sender:self];
    
    /*
    
    if (!mapViewExpanded) {
        
        scrollView.scrollEnabled = NO;
        
        [draggableBackground.dragView.cardView bringSubviewToFront:mapView];
        
        draggableBackground.dragView.cardView.layer.masksToBounds = NO;
        
        mapView.scrollEnabled = YES;
        mapView.zoomEnabled = YES;
        
        
        //mapView.layer.masksToBounds = NO;
        UIButton *xMapButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 100, 50, 50)];
        [xMapButton setImage:[UIImage imageNamed:@"noButton"] forState:UIControlStateNormal];
        xMapButton.tag = 99;
        [xMapButton addTarget:self action:@selector(mapViewTapped) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *directionsButton = [[UIButton alloc] initWithFrame:CGRectMake(85, 400, 150, 30)];
        //[directionsButton setImage:[UIImage imageNamed:@"noButton"] forState:UIControlStateNormal];
        [directionsButton setTitle:@"Get Directions" forState:UIControlStateNormal];
        [directionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        directionsButton.backgroundColor = [UIColor blueColor];
        directionsButton.layer.cornerRadius = 5.0;
        directionsButton.reversesTitleShadowWhenHighlighted = YES;
        directionsButton.layer.masksToBounds = YES;
        directionsButton.tag = 99;
        [directionsButton addTarget:self action:@selector(redirectToMaps) forControlEvents:UIControlEventTouchUpInside];
        
        
        [UIView animateWithDuration:0.05 animations:^{
            
            mapView.frame = CGRectMake(-18, mapView.frame.origin.y, draggableBackground.dragView.cardView.frame.size.width + 36, mapView.frame.size.height);
            
            settingsView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.2 animations:^{
                
                [settingsView removeFromSuperview];
                
                mapView.frame = CGRectMake(-18, -53, draggableBackground.dragView.cardView.frame.size.width + 36, scrollView.frame.size.height + 53);
                
            } completion:^(BOOL finished) {
                
                [mapView selectAnnotation:annotation animated:YES];
                [self.view addSubview:xMapButton];
                [self.view addSubview:directionsButton];
                
                mapViewExpanded = YES;
                
            }];
            
            
        }];
        
    } else {
        
        
        for (UIView *view in self.view.subviews) {
            
            if (view.tag == 99) {
                [view removeFromSuperview];
            }
        }
        
        scrollView.scrollEnabled = YES;
        
        mapView.scrollEnabled = NO;
        mapView.zoomEnabled = NO;
        
        [scrollView.superview addSubview:settingsView];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            mapView.frame = CGRectMake(-18, 390, 320, 133);
            
            settingsView.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            [settingsView.superview bringSubviewToFront:settingsView];
            
            [UIView animateWithDuration:0.1 animations:^{
                
                mapView.frame = CGRectMake(15, 376, 254, 133);
                
            } completion:^(BOOL finished) {
                
                [mapView selectAnnotation:annotation animated:YES];
                mapViewExpanded = NO;
                draggableBackground.dragView.cardView.layer.masksToBounds = YES;
                
            }];
            
        }];
        
    }
    
    */
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)anno
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

- (void)grabAnUberButtonTapped:(id)sender {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        // Do something awesome - the app is installed! Launch App.
        NSLog(@"Uber button tapped- app exists! Opening app...");
        
        PFQuery *query = [PFQuery queryWithClassName:@"Event"];
        [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *object, NSError *error) {
            
            PFGeoPoint *loc = object[@"GeoPoint"];
            NSString *locationName = object[@"Location"];
            
            CLLocation *location = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
            [[[CLGeocoder alloc]init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = placemarks[0];
                NSString *destinationAddress = [[NSString alloc]init];
                
                NSString *streetName = placemark.addressDictionary[@"Street"];
                NSString *cityName = placemark.addressDictionary[@"City"];
                NSString *stateName = placemark.addressDictionary[@"State"];
                NSString *zipCode = placemark.addressDictionary[@"ZIP"];
                NSString *country = placemark.addressDictionary[@"Country"];
                
                if (streetName && zipCode && cityName) {
                    destinationAddress = [NSString stringWithFormat:@"%@ %@, %@, %@ %@", streetName, cityName, stateName, zipCode, country];
                } else if (zipCode && !streetName) {
                    destinationAddress = [NSString stringWithFormat:@"%@, %@ %@ %@", cityName, stateName, zipCode, country];
                } else if (cityName && streetName) {
                    destinationAddress = [NSString stringWithFormat:@"%@, %@, %@ %@", streetName, cityName, stateName, country];
                } else
                    destinationAddress = draggableBackground.dragView.location.text;
                
                
                destinationAddress = [destinationAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                
                
                NSString *urlStringUber = [NSString stringWithFormat:@"uber://?client_id=Vmks1LNIHQiiaUYd8Z3FaMNkvD-7s53V&action=setPickup&pickup=my_location&dropoff[latitude]=%f&dropoff[longitude]=%f&dropoff[nickname]=%@&dropoff[formatted_address]=%@", loc.latitude, loc.longitude, locationName, destinationAddress ];
                
                urlStringUber = [urlStringUber stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlStringUber]];
                
            }];
            
        }];
    }
    else {
        // No Uber app! Open Mobile Website.
        NSLog(@"Uber button tapped- app does not exist! Opening mobile website...");
        
        PFUser *currentUser = [PFUser currentUser];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Event"];
        [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *object, NSError *error) {
            
            PFGeoPoint *loc = object[@"GeoPoint"];
            NSString *locationName = object[@"Location"];
            
            NSString *firstName = currentUser[@"firstName"];
            NSString *lastName = currentUser[@"lastName"];
            NSString *userEmail = currentUser.email;
            if (!userEmail) {
                userEmail = @"";
            }
            
            
            CLLocation *location = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
            [[[CLGeocoder alloc]init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = placemarks[0];
                NSString *destinationAddress = [[NSString alloc]init];
                
                NSString *streetName = placemark.addressDictionary[@"Street"];
                NSString *cityName = placemark.addressDictionary[@"City"];
                NSString *stateName = placemark.addressDictionary[@"State"];
                NSString *zipCode = placemark.addressDictionary[@"ZIP"];
                NSString *country = placemark.addressDictionary[@"Country"];
                
                
                if (streetName && zipCode && cityName) {
                    destinationAddress = [NSString stringWithFormat:@"%@ %@, %@, %@ %@", streetName, cityName, stateName, zipCode, country];
                } else if (zipCode && !streetName) {
                    destinationAddress = [NSString stringWithFormat:@"%@, %@ %@ %@", cityName, stateName, zipCode, country];
                } else if (cityName && streetName) {
                    destinationAddress = [NSString stringWithFormat:@"%@, %@, %@ %@", streetName, cityName, stateName, country];
                } else
                    destinationAddress = draggableBackground.dragView.location.text;
                
                [destinationAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

                
                NSLog(@"%@", destinationAddress);
                
                NSString *urlStringUber = [NSString stringWithFormat:@"https://m.uber.com/sign-up?client_id=Vmks1LNIHQiiaUYd8Z3FaMNkvD-7s53V&first_name=%@&last_name=%@&email=%@&country_code=us&&dropoff_latitude=%f&dropoff_longitude=%f&dropoff_nickname=%@", firstName, lastName, userEmail, loc.latitude, loc.longitude, locationName ];
                
                //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlStringUber]];
                
            }];
            
        }];
        
    }
    
    
    /* https://m.uber.com/sign-up?client_id=YOUR_CLIENT_ID
     &first_name=myFirstName&last_name=myLastName&email=test@example.com
     &country_code=us&mobile_country_code=%2B1&mobile_phone=123-456-7890
     &zipcode=94111&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d&pickup_latitude=37.775818
     &pickup_longitude=-122.418028&pickup_nickname=Uber%20HQ
     &pickup_address=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103
     &dropoff_latitude=37.802374&dropoff_longitude=-122.405818
     &dropoff_nickname=Coit%20Tower
     &dropoff_address=1%20Telegraph%20Hill%20Blvd%2C%20San%20Francisco%2C%20CA%2094133
     */
    
}

- (void)redirectToMaps {
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:draggableBackground.dragView.geoPoint.latitude longitude:draggableBackground.dragView.geoPoint.longitude];
    
    [[[CLGeocoder alloc]init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = placemarks[0];
        
        MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary: placemark.addressDictionary];
        
        MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
        destination.name = draggableBackground.dragView.location.text;
        NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
        NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 MKLaunchOptionsDirectionsModeWalking,
                                 MKLaunchOptionsDirectionsModeKey, nil];
        [MKMapItem openMapsWithItems: items launchOptions: options];
    }];
    
}

- (void)ticketsButtonTapped:(UIButton *)button {
    
    urlString = button.accessibilityIdentifier;
    
    [self performSegueWithIdentifier:@"toWebView" sender:self];
    
    // IN APP EXPERIENCE
    
    /*
     UIWebView *webView = [[UIWebView alloc] init];
     [webView setFrame:CGRectMake(0, 0, 320, 460)];
     [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gethappeningapp.com"]]];
     [[self view] addSubview:webView];
     */
    
    // OPENS IN SAFARI
    
    //NSURL *url = [[NSURL alloc] initWithString:urlString];
    //[[UIApplication sharedApplication] openURL:url];
    
}

-(void)dropdownPressed {
    
    if (!dropdownExpanded) {
        
        NSLog(@"expanding dropdown menu...");
        
        [self setEnabledSidewaysScrolling:NO];
        
        CABasicAnimation *rotation;
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        
        rotation.removedOnCompletion = NO;
        rotation.fromValue = [NSNumber numberWithFloat:0];
        rotation.toValue = [NSNumber numberWithFloat:(3*M_PI)];
        rotation.duration = 0.5; // Speed
        rotation.repeatCount = 1; //HUGE_VALF; // Repeat forever. Can be a finite number.
        rotation.fillMode = kCAFillModeForwards;
        [settingsView.cogImageView.layer addAnimation:rotation forKey:@"Spin"];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[defaults integerForKey:@"categoryIndex"] inSection:0];
        [settingsView.categoryTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        
        [UIView animateWithDuration:0.5 animations:^{
            settingsView.frame = CGRectMake(0, 0, self.view.frame.size.width, 502);
        } completion:^(BOOL finished) {
            dropdownExpanded = YES;
            
            if (tutIsShown) {
                [settingsView tutViewAction];
            }
            
        }];
        
    } else {
        
        if (!tutIsShown) {
        
        NSLog(@"contracting dropdown menu...");
        
            [self setEnabledSidewaysScrolling:YES];
        
            CABasicAnimation *rotation;
            rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        
            rotation.removedOnCompletion = NO;
            rotation.fromValue = [NSNumber numberWithFloat:M_PI];
            rotation.toValue = [NSNumber numberWithFloat:-(2*M_PI)];
            rotation.duration = 0.5; // Speed
            rotation.repeatCount = 1; //HUGE_VALF; // Repeat forever. Can be a finite number.
            rotation.fillMode = kCAFillModeForwards;
            [settingsView.cogImageView.layer addAnimation:rotation forKey:@"Spin"];
        
            [UIView animateWithDuration:0.5 animations:^{
                settingsView.frame = CGRectMake(0, 0, self.view.frame.size.width, 35);
            
                if ([settingsView didPreferencesChange]) {
                
                    [self refreshData];
                }
            
            } completion:^(BOOL finished) {
                dropdownExpanded = NO;
            }];
        }
    }
}

-(void)dropdownPressedFromTut:(BOOL)var {
    
    tutIsShown = var;
    //[self dropdownPressed];
    [defaults setBool:!var forKey:@"hasLaunched"];
    [defaults synchronize];
    
    settingsView.userInteractionEnabled = YES;
}

- (void)setEnabledSidewaysScrolling:(BOOL)enabled {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    [rk scrolling:enabled];
    
}

- (void) stopPanning {
    
    NSLog(@"Stopping panning");
    for (UIPanGestureRecognizer *pgr in [self.parentViewController.view gestureRecognizers]) {
        pgr.enabled = NO;
    }
}


- (void)myTransitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    // re-enable user interaction when the flip animation is completed
    self.view.userInteractionEnabled = YES;
    if (flippedDVB.userSwipedFromFlippedView == YES)
        [flippedDVB removeFromSuperview];
}

- (void)shareAction {
    
    APActivityProvider *ActivityProvider = [[APActivityProvider alloc] init];
    ActivityProvider.APdragView = draggableBackground.dragView;
    
    NSURL *myWebsite = [NSURL URLWithString:draggableBackground.dragView.URL]; //Make this custom when Liran makes unique pages
    
    CustomCalendarActivity *addToCalendar = [[CustomCalendarActivity alloc]init];
    addToCalendar.draggableView = draggableBackground.dragView;
    addToCalendar.myViewController = self;
    
    NSArray *itemsToShare = @[ActivityProvider, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:itemsToShare applicationActivities:[NSArray arrayWithObject:addToCalendar]];

    activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                         UIActivityTypePrint,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypeCopyToPasteboard,
                                         ];
    
    
    [self presentViewController:activityVC animated:YES completion:nil];
  
    [activityVC setCompletionHandler:^(NSString *act, BOOL done)
     {
         NSString *ServiceMsg = @"Done!";
         BOOL calendarAction = NO;
         
         if ( [act isEqualToString:UIActivityTypeMail] ) {
             ServiceMsg = @"Mail sent!";
         }
         else if ( [act isEqualToString:UIActivityTypePostToTwitter] ) {
             ServiceMsg = @"Your tweet has been posted!";
         }
         else if ( [act isEqualToString:UIActivityTypePostToFacebook] ){
             ServiceMsg = @"Your Facebook status has been updated!";
         }
         else if ( [act isEqualToString:UIActivityTypeMessage] ) {
             ServiceMsg = @"Message sent!";
         } else {
             calendarAction = YES;
         }
         if ( done && (calendarAction == NO) )
         {
             
             // Custom action for other activity types...
             [RKDropdownAlert title:ServiceMsg backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
             
         }
     }];
    
}

-(void)cardTap {
    
    NSLog(@"Made it");
    [draggableBackground.dragView cardExpanded:self.frontViewIsVisible];
    [self flipCurrentView];
    //[draggableBackground.dragView tapAction];
    
}

-(void)showCreatedByProfile {
    [self performSegueWithIdentifier:@"showProfile" sender:self];
}

-(void)showFriendProfile:(UITapGestureRecognizer *)gr {
    UIView *view = gr.view;
    friendObjectID = view.accessibilityIdentifier;
    [self performSegueWithIdentifier:@"showFriendProfile" sender:self];
}

-(void)showMoreDetail {
    [self performSegueWithIdentifier:@"toMoreDetail" sender:self];
}

-(void)showEditEventVCWithEvent:(EKEvent *)event eventStore:(EKEventStore *)es {
    calEvent = event;
    calEventStore = es;
    //[self performSegueWithIdentifier:@"toEKEventEdit" sender:self];
    
    EKEventEditViewController *vc = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    vc.eventStore = calEventStore;
    vc.event = event;
    
    vc.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [vc.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    vc.navigationBar.translucent = NO;
    vc.navigationBar.barStyle = UIBarStyleBlack;
    vc.navigationBar.tintColor =[UIColor whiteColor];
    vc.navigationItem.title = @"Add to Calendar";

    [self presentViewController:vc animated:YES completion:nil];
    vc.editViewDelegate = self;
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    
    if (action == EKEventEditViewActionCancelled || action == EKEventEditViewActionCanceled) {
        NSLog(@"Clicked Cancel");
    } else if (action == EKEventEditViewActionSaved) {
        NSLog(@"Clicked Add -- event saved to calendar");
        [RKDropdownAlert title:@"Event added to your main calendar!" backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
    }
        [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)tutorialCardTapped:(UITapGestureRecognizer *)gr {
    
    NSLog(@"tap");
    
    //TutorialDragView *view = gr.view;
    
    scrollView.delaysContentTouches = NO;
    tutorialScreens.dragView.userInteractionEnabled = YES;
    
    if ((tutorialScreens.dragView.tag == 3) || (tutorialScreens.dragView.tag == 50)) {
    
    if (!tutorialScreens.cardExpanded) {
        
        NSLog(@"expand tut card");
        
        //[self addSubviewsToCard:draggableBackground.dragView];
        
        scrollView.contentSize = CGSizeMake(320, 650);
        scrollView.scrollEnabled = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            tutorialScreens.dragView.layer.masksToBounds = YES;
            tutorialScreens.dragView.frame = CGRectMake(tutorialScreens.dragView.frame.origin.x, tutorialScreens.dragView.frame.origin.y, tutorialScreens.dragView.frame.size.width, 620);
            tutorialScreens.frame = CGRectMake(tutorialScreens.frame.origin.x, tutorialScreens.frame.origin.y, tutorialScreens.frame.size.width, 620);
            
        } completion:^(BOOL finished) {
            
            tutorialScreens.dragView.layer.masksToBounds = NO;
            //tutorialScreens.dragView.tag = 1;
            
            for (UIPanGestureRecognizer *pgr in [tutorialScreens.dragView gestureRecognizers]) {
                pgr.enabled = NO;
            }
            
        }];
        
        
    } else {
        
        NSLog(@"contract tut card");
        
        tutorialScreens.dragView.layer.masksToBounds = YES;
        tutorialScreens.allowCardSwipe = YES;
        tutorialScreens.dragView.tag = 50;
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        scrollView.scrollEnabled = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            tutorialScreens.dragView.frame = CGRectMake(tutorialScreens.dragView.frame.origin.x, tutorialScreens.dragView.frame.origin.y, tutorialScreens.dragView.frame.size.width, 310);
            tutorialScreens.frame = CGRectMake(tutorialScreens.frame.origin.x, tutorialScreens.frame.origin.y, tutorialScreens.frame.size.width, 310);
            
        } completion:^(BOOL finished) {
            
            tutorialScreens.dragView.layer.masksToBounds = NO;
            //tutorialScreens.dragView.tag = 0;
            
            for (UIPanGestureRecognizer *pgr in [tutorialScreens.dragView gestureRecognizers]) {
                pgr.enabled = YES;
            }
            
        }];
        
    
        }
        
        tutorialScreens.cardExpanded =! tutorialScreens.cardExpanded;
    }

    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toSettings"]) {
        
        SettingsTVC *vc = (SettingsTVC *)[[segue destinationViewController] topViewController];
        vc.dragVC = self;
        
    }
    else if ([segue.identifier isEqualToString:@"toChooseLoc"]) {
        
        ChoosingLocation *vc = (ChoosingLocation *)[segue destinationViewController];
        vc.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"toMapView"]) {
        
        DragMapViewController *vc = (DragMapViewController *)[segue destinationViewController];
        //vc.mapView = mapView;
        vc.objectID = draggableBackground.dragView.objectID;
        vc.locationTitle = annotation.title;
        vc.locationSubtitle = annotation.subtitle;
        
    } else if ([segue.identifier isEqualToString:@"showProfile"]) {
        
        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.eventID = draggableBackground.dragView.objectID;
        
    } else if ([segue.identifier isEqualToString:@"showFriendProfile"]) {
        
        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.userID = friendObjectID;
        NSLog(@"friend oID = %@", friendObjectID);
        
    } else if ([segue.identifier isEqualToString:@"toWebView"]) {
        
        webViewController *vc = (webViewController *)[[segue destinationViewController] topViewController];
        vc.urlString = urlString;
        vc.titleString = draggableBackground.dragView.title.text;
        
    } else if ([segue.identifier isEqualToString:@"toSettingsLoc"]) {
        
        SettingsChoosingLoc *vc = (SettingsChoosingLoc *)[[segue destinationViewController] topViewController];
        vc.delegate = settingsView;
        
    } else if ([segue.identifier isEqualToString:@"toEKEventEdit"]) {
        
        EKEventEditViewController *vc = (EKEventEditViewController *)[segue destinationViewController];
        vc.delegate = self;
        vc.event = calEvent;
        vc.eventStore = calEventStore;
        
    } else if ([segue.identifier isEqualToString:@"toMoreDetail"]) {
        
        moreDetailFromCard *vc = (moreDetailFromCard *)[[segue destinationViewController] topViewController];
        vc.eventID = self.eventID;
        vc.titleText = draggableBackground.dragView.title.text;
        vc.subtitleText = draggableBackground.dragView.subtitle.text;
        vc.locationText = draggableBackground.dragView.location.text;
    }
    
    /*
    if ([segue.identifier isEqualToString: @"toSettings"]) {
    
        UINavigationController *navController = [segue destinationViewController];
        SettingsTVC *vc = (SettingsTVC *)([navController topViewController]);
        
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        vc.tableView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        vc.tableView.backgroundView = blurEffectView;
        
        
        
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        vibrancyEffectView.frame = blurEffectView.bounds;
        
        //if you want translucent vibrant table view separator lines

        vc.tableView.separatorEffect = vibrancyEffect;
    }
    }
    */
}

@end

@implementation APActivityProvider

@synthesize APdragView;

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    
    PFUser *user = [PFUser currentUser];
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    PFObject *eventObject = [eventQuery getObjectWithId:APdragView.objectID];

    NSString *title = APdragView.title.text;
    NSString *description = APdragView.subtitle.text;
    NSString* loc = APdragView.location.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM d"];
    NSDate *eventDate = [[NSDate alloc]init];
    eventDate = eventObject[@"Date"];
    NSString *dateString = [formatter stringFromDate:eventDate];
    
    [formatter setDateFormat:@"h:mm a"];
    NSString *startTimeString = [formatter stringFromDate:eventObject[@"Date"]];
    NSString *endTimeString = [formatter stringFromDate:eventObject[@"EndTime"]];
    NSString *eventTimeString = [[NSString alloc]init];
    if (endTimeString) {
        eventTimeString = [NSString stringWithFormat:@"from %@ to %@",startTimeString, endTimeString];
    } else {
        eventTimeString = [NSString stringWithFormat:@"at %@", startTimeString];
    }
    
    NSString *shareText = [[NSString alloc]init];
    //if ([description isEqualToString:@""] || description == nil) {
        shareText = [NSString stringWithFormat:@"Check out this awesome event: %@ at %@ on %@ %@", title, loc, dateString, eventTimeString];
    /*
    } else {
        shareText = [NSString stringWithFormat:@"Check out this awesome event: %@, %@ at %@ on %@ %@", title, description, loc, dateString, eventTimeString];
    } */
    
    NSLog(@"%@", shareText);
    
    [user addObject:eventObject.objectId forKey:@"sharedEvents"];
    [user saveInBackground];
    
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] ) {
        shareText = [NSString stringWithFormat:@"Check this out: %@ at %@ on %@ %@", title, loc, dateString, eventTimeString];
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypeMessage] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypeMail] ) {
        return shareText;
    } else
        return shareText;
    //if ( [activityType isEqualToString:@"it.albertopasca.myApp"] )
        //return @"OpenMyapp custom text";
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @"Testing"; }
@end


