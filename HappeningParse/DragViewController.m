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

@interface DragViewController ()

@property (assign) BOOL frontViewIsVisible;
@property (strong, nonatomic) DraggableViewBackground *draggableBackground;
@property (strong, nonatomic) FlippedDVB *flippedDVB;

@end

@implementation DragViewController {
    
    UIView *cardView;
}

@synthesize shareButton, draggableBackground, flippedDVB, xButton, checkButton, delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasLaunched = [defaults boolForKey:@"hasLaunched"];
    if (!hasLaunched) {
        [self performSegueWithIdentifier:@"toChooseLoc" sender:self];
    }
    
    
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(60, 440, 59, 59)];
    [xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeftDVC) forControlEvents:UIControlEventTouchUpInside];
    
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 440, 59, 59)];
    [checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRightDVC) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:checkButton];
    [self.view addSubview:xButton];
    [self.view sendSubviewToBack:checkButton]; //So that card is above buttons
    [self.view sendSubviewToBack:xButton];
    
    self.frontViewIsVisible = YES;
}

-(void)viewWillAppear:(BOOL)animated {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Refresh only if there was a change in preferences or the app has loaded for the first time.
    if ([defaults boolForKey:@"refreshData"]) {
        
        // Removes the previous content!!!!!! (when view was burned in behind the cards)
        NSLog(@"%lu", (unsigned long)[self.view.subviews count] );
        NSLog(@"%@", self.view.subviews );

        cardView = self.view.subviews[2]; //Card view is 3rd in hierarchy after sending button views to the back
        for (id viewToRemove in [cardView subviews]){
            [viewToRemove removeFromSuperview];
        }
        
        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.center=self.view.center;
        [activityView startAnimating];
        [self.view addSubview:activityView];
        
        draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
        
        draggableBackground.myViewController = self;
        [cardView addSubview:draggableBackground];
        
        //UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardWasTapped)];
        //[draggableBackground addGestureRecognizer:singleFingerTap];
        
        flippedDVB = [[FlippedDVB alloc]initWithFrame:CGRectMake(-1, -1, 291, 321)];
        flippedDVB.viewController = self;
        
        //[self.view addSubview:flippedDVB];
        
        [activityView stopAnimating];
        [activityView removeFromSuperview];
        
        [defaults setBool:NO forKey:@"refreshData"];
        [defaults synchronize];
        
        delegate = draggableBackground;
        
    }
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
    
    NSLog(@"VC CODE");
    // disable user interaction during the flip animation
    self.view.userInteractionEnabled = NO;
    
    // setup the animation group
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
    
    // swap the views and transition
    if (self.frontViewIsVisible == YES) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:cardView cache:YES];
        [self.draggableBackground removeFromSuperview];
        
        // %%%%% Pass variables to flipped card
        NSLog(@"Tapped Event: %@",self.title);
        flippedDVB.eventID = self.eventID;
        flippedDVB.mapLocation = self.mapLocation;
        flippedDVB.eventTitle = self.eventTitle;
        flippedDVB.eventLocationTitle = self.locationTitle;
        // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        [cardView addSubview:self.flippedDVB];
    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:cardView cache:YES];
        [self.flippedDVB removeFromSuperview];
        [cardView addSubview:self.draggableBackground];
    }
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
    
    [UIView commitAnimations];
    
    // invert the front view state
    self.frontViewIsVisible =! self.frontViewIsVisible;
}

- (void)myTransitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    // re-enable user interaction when the flip animation is completed
    self.view.userInteractionEnabled = YES;
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
             
         }
     }];
    
}

-(void)cardWasTapped {
    
    //[self performSegueWithIdentifier:@"moreDetail" sender:self];
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


