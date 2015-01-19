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

@interface DragViewController ()

@property (strong, nonatomic) DraggableViewBackground *draggableBackground;
@property (strong, nonatomic) FlippedDVB *flippedDVB;
@property (assign, nonatomic) CGRect mySensitiveRect;

@end

@implementation DragViewController {
    
}

@synthesize shareButton, draggableBackground, flippedDVB, xButton, checkButton, delegate, scrollView, mySensitiveRect, cardView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    scrollView.scrollEnabled = NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasLaunched = [defaults boolForKey:@"hasLaunched"];
    if (!hasLaunched) {
        [self performSegueWithIdentifier:@"toChooseLoc" sender:self];
    }
    
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(-100.5, 349, 244.5, 79)]; //413
    [xButton setImage:[UIImage imageNamed:@"NotInterestedButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeftDVC) forControlEvents:UIControlEventTouchUpInside];
    
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(177, 351, 244.5, 79)];  //415
    [checkButton setImage:[UIImage imageNamed:@"InterestedButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRightDVC) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView addSubview:checkButton];
    [self.scrollView addSubview:xButton];
    //[self.view sendSubviewToBack:checkButton]; //So that card is above buttons
    //[self.view sendSubviewToBack:xButton];
    [self.view bringSubviewToFront:scrollView];
    
    self.frontViewIsVisible = YES;
    self.userSwipedFromFlippedView = NO;
    
}

-(void)testing {
     NSLog(@"testing");
    [self viewWillAppear:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    
    //[super viewWillAppear:animated];
    NSLog(@"MAADEEE ITT!!!");
    NSLog(@"scroll view subviews: %@", scrollView.subviews);

    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Refresh only if there was a change in preferences or the app has loaded for the first time.
    if ([defaults boolForKey:@"refreshData"]) {
        
        NSLog(@"Refreshing data...");
        
        if (self.frontViewIsVisible == NO) {
            [self flipCurrentView]; // Makes blur view look weird and messes with seg control when flipping
        } else {
            //cardView = self.view.subviews[2]; //Card view is 3rd in hierarchy after sending button views to the back
            
            for (id viewToRemove in [cardView subviews]){
                [viewToRemove removeFromSuperview];
            }
            
            [scrollView bringSubviewToFront:cardView];
            
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
        [self.view addSubview:activityView];
        
        draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
        
        draggableBackground.myViewController = self;
        [cardView addSubview:draggableBackground];
        
        //UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardWasTapped)];
        //[draggableBackground addGestureRecognizer:singleFingerTap];
        
        //[self.view addSubview:flippedDVB];
        
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        
        [defaults setBool:NO forKey:@"refreshData"];
        [defaults synchronize];
        
        delegate = draggableBackground;
        
        self.mySensitiveRect = CGRectMake(0, 0, 0, 0);
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [scrollView addGestureRecognizer:gr];

        
        NSLog(@"scroll view subviews: %@", scrollView.subviews);
    }
}

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


- (IBAction)tap:(id)sender {
    
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
    
    
    
    if (self.frontViewIsVisible == YES) {
        
        scrollView.contentSize = CGSizeMake(320, 720);
        scrollView.scrollEnabled = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, cardView.frame.size.width, 320 + 300);
            draggableBackground.frame = CGRectMake(0, 0, cardView.frame.size.width, 320 + 300);
            draggableBackground.dragView.frame = CGRectMake(0, 0, cardView.frame.size.width, 320 + 300);
            draggableBackground.dragView.cardView.frame = CGRectMake(0, 0, cardView.frame.size.width, 620);
            
            CGRect frame = self.tabBarController.tabBar.frame;
            CGFloat offsetY = frame.origin.y;
            self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
            

            xButton.center = CGPointMake(-1000, xButton.center.y);;
            checkButton.center = CGPointMake(1300, checkButton.center.y);;
                //xButton.transform = CGAffineTransformMakeRotation(1);
            
           // draggableBackground.dragView.cardView.frame = CGRectMake(15, 72, cardView.frame.size.width, 620);
        } completion:^(BOOL finished) {
            
            self.mySensitiveRect = CGRectMake(18, 322, 284, 310);
            
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
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        scrollView.scrollEnabled = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, cardView.frame.size.width, 310);
            draggableBackground.frame = CGRectMake(0, 0, cardView.frame.size.width, 310);
            draggableBackground.dragView.frame = CGRectMake(0, 0, cardView.frame.size.width, 310);
            draggableBackground.dragView.cardView.frame = CGRectMake(0, 0, cardView.frame.size.width, 310);
            
            xButton.center = CGPointMake(21.75, xButton.center.y);
            checkButton.center = CGPointMake(302.25, checkButton.center.y);
            
            CGRect frame = self.tabBarController.tabBar.frame;
            self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, -519);
            
        } completion:^(BOOL finished) {
            
            self.mySensitiveRect = CGRectMake(0, 0, 0, 0);
            
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

- (void)myTransitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    // re-enable user interaction when the flip animation is completed
    self.view.userInteractionEnabled = YES;
    if (flippedDVB.userSwipedFromFlippedView == YES)
        [flippedDVB removeFromSuperview];
}

- (IBAction)shareAction:(id)sender {
    
    APActivityProvider *ActivityProvider = [[APActivityProvider alloc] init];
    ActivityProvider.APdragView = draggableBackground.dragView;
    
    NSURL *myWebsite = [NSURL URLWithString:@"http://www.gethappeningapp.com/"]; //Make this custom when Liran makes unique pages
    
    CustomCalendarActivity *addToCalendar = [[CustomCalendarActivity alloc]init];
    addToCalendar.draggableView = draggableBackground.dragView;
    
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
         if ( [act isEqualToString:UIActivityTypeMail] )           ServiceMsg = @"Mail sent!";
         if ( [act isEqualToString:UIActivityTypePostToTwitter] )  ServiceMsg = @"Your tweet has been posted!";
         if ( [act isEqualToString:UIActivityTypePostToFacebook] ) ServiceMsg = @"Your Facebook status has been updated!";
         if ( [act isEqualToString:UIActivityTypeMessage] )        ServiceMsg = @"Message sent!";
         if ( done )
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toSettings"]) {
        
        SettingsTVC *vc = (SettingsTVC *)[[segue destinationViewController] topViewController];
        vc.dragVC = self;
        
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
    NSString *subtitle = APdragView.subtitle.text;
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
    if ([subtitle isEqualToString:@""]) {
        shareText = [NSString stringWithFormat:@"Check out this awesome event: %@ at %@ on %@ %@", title, loc, dateString, eventTimeString];
    } else {
        shareText = [NSString stringWithFormat:@"Check out this awesome event: %@, %@ at %@ on %@ %@", title, subtitle, loc, dateString, eventTimeString];
    }
    
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


