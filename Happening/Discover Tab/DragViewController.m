//
//  DragViewController.m
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
#import "AMPopTip.h"
#import "tempProfile.h"
#import "inviteHomies.h"
#import <Button/Button.h>
#import "CustomAPActivityProvider.h"
#import <Hoko/Hoko.h>
#import "ChecklistModalVC.h"
#import "UIImage+ImageEffects.h"
#import "CreateHappeningView.h"
#import "InviteFromCreateView.h"

#define MCANIMATE_SHORTHAND
#import <POP+MCAnimate.h>

@interface DragViewController () <ChoosingLocationDelegate, dropdownSettingsViewDelegate, inviteHomiesDelegate , ModalPopupDelegate, CreateHappeningViewDelegate>

@property (strong, nonatomic) DraggableViewBackground *draggableBackground;
@property (strong, nonatomic) CreateHappeningView *createHappeningView;
@property (assign, nonatomic) CGRect mySensitiveRect;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet dropdownSettingsView *settingsView;

@end

@implementation DragViewController {
    
    BOOL mapViewExpanded;
    NSUserDefaults *defaults;
    TutorialDragView *tutorialScreens;
    BOOL showTut;
    NSString *urlString;
    EKEvent *calEvent;
    EKEventStore *calEventStore;
    
    int friendScrollHeight;
    int ebTicketsHeight;
    int uberTicketsHeight;
    int descriptionHeight;
    
    UIButton *uberButton;
    UIButton *ticketsButton;
    UIButton *mainTixButton;
    
    MKPointAnnotation *annotation;
    
    CGFloat extraDescHeight;
    
    BOOL refreshingData;
    BOOL isReachable;
    
    RKSwipeBetweenViewControllers *rk;
}

@synthesize shareButton, draggableBackground, createHappeningView, xButton, checkButton, delegate, scrollView, mySensitiveRect, cardView, settingsView, dropdownExpanded, tutIsShown, backgroundImageView, lastRefresh;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"TESTING" message: @"123" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];

    [PFCloud callFunctionInBackground:@"modifyUser"
                       withParameters:@{}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"## %@", result);
                                    }
                                }];
    */
     
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(checkBeforeRefresh)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    UIView *navigationView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.navigationController.navigationBar.frame.size.height)];
    NSInteger width = 304/3;
    UIButton *middleButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 8, 153, 25)];

    // if you need to resize the image to fit the UIImageView frame
    middleButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    // no extension name needed for image_name

    //middleButton.center = self.navigationController.navigationBar.topItem.titleView.center;
    [middleButton setImage:[UIImage imageNamed:@"happening text logo"] forState:UIControlStateNormal];
    UIView *logoView = [[UIView alloc] initWithFrame:CGRectMake(25, 2, middleButton.frame.size.width, middleButton.frame.size.height)];
    [logoView addSubview:middleButton];
    middleButton.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0];;
    [navigationView addSubview:logoView];
    [middleButton addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    self.navigationController.navigationBar.topItem.titleView = navigationView;
        
    //[defaults setBool:YES forKey:@"hasLaunched"];
    //[defaults synchronize];
    
    /*
    [PFCloud callFunctionInBackground:@"reminders"
                       withParameters:@{}
                                block:^(NSString *result, NSError *error) {
                                    
                                    if (!error) {

                                        NSLog(@"RESULTS: %@", result);
                                        
                                    } else {
                                        
                                        NSLog(@"ERROR: %@", error);

                                    }
                                }];
    */
    
    backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -40, self.view.frame.size.width, self.view.frame.size.height)];
    UIImage *im = [[UIImage imageNamed:@"party"] applyBlurWithRadius:10.0 tintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2] saturationDeltaFactor:1.6 maskImage:nil];
    backgroundImageView.image = im; //[[UIImage imageNamed:@"party"] applyLightEffect];
    
    [[self.view viewWithTag:32] insertSubview:backgroundImageView belowSubview:scrollView];
    
    if ([[PFUser currentUser][@"hasLaunched"] boolValue] == NO) {
        showTut = YES;
    }
    
    settingsView.delegate = self;
    settingsView.layer.masksToBounds = YES;
    [settingsView.dropdownButton addTarget:self action:@selector(dropdownPressed) forControlEvents:UIControlEventTouchUpInside];
    dropdownExpanded = NO;
    
    isReachable = YES;
    
    /*
    BOOL hasLaunched = [defaults boolForKey:@"hasLaunched"];
    if (!hasLaunched) {
        [self performSegueWithIdentifier:@"toChooseLoc" sender:self];
    }
    */
    
    [scrollView setCanCancelContentTouches:YES];
    [scrollView setDelaysContentTouches:YES];
    [scrollView setBouncesZoom:YES];
    
    xButton = [[UIButton alloc]initWithFrame:CGRectMake(-1000, 359 + 5, 244.5, 79)]; //413... CGRectMake(-100.5, 359, 244.5, 79)
    xButton.center = CGPointMake(-1000, xButton.center.y);
    [xButton setImage:[UIImage imageNamed:@"NotInterestedButton"] forState:UIControlStateNormal];
    [xButton addTarget:self action:@selector(swipeLeftDVC) forControlEvents:UIControlEventTouchUpInside];
    
    checkButton = [[UIButton alloc]initWithFrame:CGRectMake(1300, 361 + 5, 244.5, 79)];  //415... CGRectMake(177, 361, 244.5, 79)
    checkButton.center = CGPointMake(1300, checkButton.center.y);
    [checkButton setImage:[UIImage imageNamed:@"InterestedButton"] forState:UIControlStateNormal];
    [checkButton addTarget:self action:@selector(swipeRightDVC) forControlEvents:UIControlEventTouchUpInside];
    
    
    //[self.scrollView addSubview:mainTixButton];

    /*
    
    UIButton *inviteButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 410, 80, 40)];
    [inviteButton setTitle:@"Share" forState:UIControlStateNormal];
    [inviteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [inviteButton setBackgroundColor:[UIColor colorWithHue:196.36/360.0 saturation:1.0 brightness:0.949 alpha:0.95]];
    inviteButton.layer.masksToBounds = YES;
    inviteButton.layer.cornerRadius = 10.0;
    [scrollView addSubview:inviteButton];
    
    UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 410, 130, 40)];
    [actionButton setTitle:@"Buy tickets" forState:UIControlStateNormal];
    [actionButton setTitleColor:[UIColor colorWithHue:196.36/360.0 saturation:1.0 brightness:0.949 alpha:0.95] forState:UIControlStateNormal];
    [actionButton setBackgroundColor:[UIColor whiteColor]];
    actionButton.layer.masksToBounds = YES;
    actionButton.layer.cornerRadius = 10.0;
    actionButton.layer.borderColor = [UIColor colorWithHue:196.36/360.0 saturation:1.0 brightness:0.949 alpha:0.95].CGColor;
    actionButton.layer.borderWidth = 2.0;
    [scrollView addSubview:actionButton];
    
    */
     
    // :(
    //[self.scrollView addSubview:checkButton];
    //[self.scrollView addSubview:xButton];
    
    
    
    //[self.view sendSubviewToBack:checkButton]; //So that card is above buttons
    //[self.view sendSubviewToBack:xButton];
    [self.view bringSubviewToFront:scrollView];
    
    self.isCardExpanded = NO;
    self.userSwipedFromExpandedView = NO;
    self.isCreatingHappening = NO;
    
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

    [super viewWillAppear:animated];
    
   // NSLog(@"MAADEEE ITT!!!");
    //NSLog(@"scroll view subviews: %@", scrollView.subviews);

    //[defaults setBool:YES forKey:@"hasLaunched"];
    //[defaults synchronize];
    // Refresh only if there was a change in preferences or the app has loaded for the first time.
    if ([[PFUser currentUser][@"hasLaunched"] boolValue] == NO) {
        
        if (showTut) {
            tutorialScreens = [[TutorialDragView alloc] initWithFrame:CGRectMake(18, 18 + 8 + 45, 284, 350)];
            tutorialScreens.myViewController = self;
            [scrollView addSubview:tutorialScreens];
            
            self.filterButton.enabled = NO;
            self.createButton.enabled = NO;
    
            /*
            UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tutorialCardTapped:)];
            singleFingerTap.cancelsTouchesInView = NO;
            [tutorialScreens addGestureRecognizer:singleFingerTap];
            */
            
            settingsView.userInteractionEnabled = NO;
            tutIsShown = YES;
            showTut =! showTut;
            
        }

    }
    else if ([defaults boolForKey:@"refreshData"]) {
        
        self.filterButton.enabled = YES;
        tutIsShown = NO;
        [self refreshData];
        
    } else if (self.isCardExpanded) {
        draggableBackground.dragView.panGestureRecognizer.enabled = NO;
    }
    
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        self.createButton.enabled = NO;
    } else {
        self.createButton.enabled = YES;
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

- (void)checkBeforeRefresh {
    
    NSLog(@"$$ %f", [[NSDate date] timeIntervalSinceDate:lastRefresh]);
    
    // Refresh if > 5 mins since last refresh
    if ([[NSDate date] timeIntervalSinceDate:lastRefresh] > 5*60) {
        [self refreshData];
    }
    
}

-(void)refreshData {
    
    // Double-check :)
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    rk = appDelegate.rk;
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //rk = [storyboard instantiateViewControllerWithIdentifier:@"rk"];
    
   // NSLog(@"===> %d, %lu", [[PFUser currentUser][@"hasLaunched"] isEqualToNumber:@NO]/*,rk.currentPageIndex */);
    
    if ([[PFUser currentUser][@"hasLaunched"] boolValue] == YES && !self.isCreatingHappening && appDelegate.mh.selectedIndex == 0 /* && isReachable */) {
        
        if (self.dropdownExpanded) {
            [self dropdownPressed];
        }
        
        xButton.center = CGPointMake(-1000, xButton.center.y);
        checkButton.center = CGPointMake(1300, checkButton.center.y);
    
        NSLog(@"Refreshing data...");

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // time-consuming task
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD setViewForExtension:self.view];
                [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -66)];
                [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
                [SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
                [SVProgressHUD setStatus:@"Loading Happenings"];
            });
        });
        
        
        [[scrollView viewWithTag:999] removeFromSuperview];
        [tutorialScreens removeFromSuperview];
    
        if (self.isCardExpanded == YES) {
            [self expandCurrentView]; // Makes blur view look weird and messes with seg control when flipping
            [draggableBackground removeFromSuperview];

        
        } else {
            //cardView = self.view.subviews[2]; //Card view is 3rd in hierarchy after sending button views to the back
        
            /*
             for (id viewToRemove in [cardView subviews]){
             [viewToRemove removeFromSuperview];
             } */
        
            [draggableBackground removeFromSuperview];
        
            [UIView animateWithDuration:1.0 animations:^{
            
                xButton.center = CGPointMake(21.75, xButton.center.y);
                checkButton.center = CGPointMake(302.25, checkButton.center.y);
                
            } completion:^(BOOL finished) {
                //code
            }];
        
        }
        self.isCardExpanded = NO;
        self.dropdownExpanded = NO;
        self.userSwipedFromExpandedView = NO;
    
        // Removes the previous content!!!!!! (when view was burned in behind the cards)
        //NSLog(@"%lu", (unsigned long)[self.view.subviews count] );
    
        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.center=self.view.center;
        [activityView startAnimating];
        //[self.view addSubview:activityView];
    
    
        //draggableBackground = [[DraggableViewBackground alloc]initWithFrame:CGRectMake(18, 18 + 8 + 45, 284, 350)];
        draggableBackground = [[DraggableViewBackground alloc]initWithFrame:CGRectMake(18, 18 + 8, 284, 400)];
        //settingsView.alpha = 0;
        
        
        [scrollView addSubview:draggableBackground];
        [scrollView bringSubviewToFront:draggableBackground];
        
        draggableBackground.myViewController = self;
        //[cardView addSubview:draggableBackground];
    
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        singleFingerTap.cancelsTouchesInView = YES;
        singleFingerTap.delegate = self;
        [draggableBackground addGestureRecognizer:singleFingerTap];
    
        //[self.view addSubview:flippedDVB];
    
        [activityView stopAnimating];
        [activityView removeFromSuperview];
    
        [defaults setBool:NO forKey:@"refreshData"];
        [defaults synchronize];
    
        delegate = draggableBackground;
        
        lastRefresh = [NSDate date];
        
        self.mySensitiveRect = CGRectMake(0, 0, 0, 0);
        //UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        //[scrollView addGestureRecognizer:gr];
    
        //NSLog(@"card view subviews: %@", cardView.subviews);
        
        
    }/* else if (!isReachable && [defaults boolForKey:@"hasLaunched"] && rk.currentPageIndex == 1) {
        
        //[RKDropdownAlert title:@"Something went wrong :(" message:@"Please check your internet connection\nand try again" backgroundColor:[UIColor redColor] textColor:[UIColor whiteColor]];
    }*/
    
    //refreshingData = NO;
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModalPopup *controller = [storyboard instantiateViewControllerWithIdentifier:@"ModalPopup"];
    //controller.event = c.eventObject;
    //[self mh_presentSemiModalViewController:controller animated:YES];

}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // test if our control subview is on-screen
    if (draggableBackground.dragView.uberBTN.superview != nil) {
        if ([touch.view isDescendantOfView:self.draggableBackground.dragView.uberBTN]) {
            // we touched our control surface
            return NO; // ignore the touch
        }
    }
    return YES; // handle the touch
}

- (void) updateMainTixButton {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        mainTixButton.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        NSString *ticketLink = [NSString stringWithFormat:@"%@", draggableBackground.dragView.ticketLink];
        
        if (ticketLink != nil && (![ticketLink isEqualToString:@""] || ![ticketLink isEqualToString:@"$0"])) {
            
            NSLog(@"ticket link::: %@", ticketLink);
            
            mainTixButton = [[UIButton alloc] initWithFrame:CGRectMake(79, 410, 162, 40)];
            mainTixButton.alpha = 0;
            [self.scrollView addSubview:mainTixButton];
            mainTixButton.enabled = YES;
            mainTixButton.userInteractionEnabled = YES;
            mainTixButton.tag = 3;
            
            if ([self doesString:ticketLink contain:@"eventbrite"]) {  //[ticketLink containsString:@"eventbrite"]) {
                
                [mainTixButton setImage:[UIImage imageNamed:@"buy tickets"] forState:UIControlStateNormal];
                [mainTixButton setImage:[UIImage imageNamed:@"buy tickets pressed"] forState:UIControlStateHighlighted];
                
            } else if ([self doesString:ticketLink contain:@"facebook"]) {  //[ticketLink containsString:@"eventbrite"]) {
                
                mainTixButton.frame = CGRectMake(50.5, 410, 219, 40);
                [mainTixButton setImage:[UIImage imageNamed:@"join facebook"] forState:UIControlStateNormal];
                [mainTixButton setImage:[UIImage imageNamed:@"join facebook pressed"] forState:UIControlStateHighlighted];
                
            } else if ([self doesString:ticketLink contain:@"meetup"]) {  //[ticketLink containsString:@"eventbrite"]) {
                
                mainTixButton.frame = CGRectMake(15, 410, 290, 40);
                [mainTixButton setImage:[UIImage imageNamed:@"rsvp to meetup"] forState:UIControlStateNormal];
                [mainTixButton setImage:[UIImage imageNamed:@"rsvp to meetup pressed"] forState:UIControlStateHighlighted];
                
            } else {
                UIButton *actionButton = [[UIButton alloc] initWithFrame:CGRectMake(160, 410, 130, 40)];
                
                mainTixButton.frame = CGRectMake(63, 410, 194, 40);
                [mainTixButton setImage:[UIImage imageNamed:@"get tickets"] forState:UIControlStateNormal];
                [mainTixButton setImage:[UIImage imageNamed:@"get tickets pressed"] forState:UIControlStateHighlighted];
                
            }
            
            mainTixButton.accessibilityIdentifier = ticketLink;
            //[mainTixButton addTarget:self action:@selector(ticketsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            
            [UIView animateWithDuration:0.3 animations:^{
                
                mainTixButton.alpha = 1.0;
                
            } completion:^(BOOL finished) {

            
            }];
            
        }
        
    }];
    
}

- (void) setLocationSegue {
    
    [self performSegueWithIdentifier:@"toChooseLoc" sender:self];
    
}

- (void)tap:(id)sender {
    
    NSLog(@"Tap");
    
    [draggableBackground.dragView cardExpanded:!self.isCardExpanded]; // !is.. because its not expanded just yet...
    [self expandCurrentView];
    
}

-(void)swipeLeftDVC
{
    xButton.userInteractionEnabled = NO;
    checkButton.userInteractionEnabled = NO;
    
    NSLog(@"Left click");
    [delegate swipeLeft];
    //[draggableBackground cardSwipedLeft:draggableBackground.dragView];
    
    [self performSelector:@selector(turnOnButtonInteraction) withObject:nil afterDelay:0.4];

}

-(void)swipeRightDVC
{
    checkButton.userInteractionEnabled = NO;
    xButton.userInteractionEnabled = NO;
    
    NSLog(@"Right click");
    [delegate swipeRight];
    //[draggableBackground cardSwipedLeft:draggableBackground.dragView];
    
    [self performSelector:@selector(turnOnButtonInteraction) withObject:nil afterDelay:0.4];
    
}

- (void)swipeDown:(UIView *)card {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModalPopup *popup = [storyboard instantiateViewControllerWithIdentifier:@"ModalPopup"];
    popup.eventObject = draggableBackground.dragView.eventObject;
    popup.eventDateString = draggableBackground.dragView.date.text;
    popup.eventImage = draggableBackground.dragView.eventImage.image;
    popup.type = @"going";
    [self showModalPopup:popup];
    /*
    DraggableView *c = (DraggableView *)card;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChecklistModalVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"checklist"];
    controller.event = c.eventObject;
    [self mh_presentSemiModalViewController:controller animated:YES];
    */
}

- (void)turnOnButtonInteraction {
    
    xButton.userInteractionEnabled = YES;
    checkButton.userInteractionEnabled = YES;
}

- (void)expandCurrentView {
    
    //scrollView.delaysContentTouches = NO;
    
    if (self.isCardExpanded == NO && draggableBackground.isLoaded) {
        
        extraDescHeight = draggableBackground.dragView.extraDescHeight;
        
        [self addSubviewsToCard:draggableBackground.dragView];
        
        [self setEnabledSidewaysScrolling:NO];
        
        //[draggableBackground.dragView.eventImage setContentMode:UIViewContentModeScaleAspectFill];
        draggableBackground.dragView.eventImage.autoresizingMask = UIViewAutoresizingNone;
        
        
        NSLog(@"EXTRA DESC HEIGHT ==== %f", extraDescHeight);
        
        scrollView.scrollEnabled = YES;
        
        [UIView animateWithDuration:0.2 animations:^{
            
            settingsView.frame = CGRectMake(0, 0 - settingsView.frame.size.height - 45, 320, settingsView.frame.size.height);
            //scrollView.frame = CGRectMake(0, -8, 320, scrollView.frame.size.height);
            
        }];
        
        draggableBackground.spring.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y, draggableBackground.frame.size.width, 320 + 235 + 16 + 60 + extraDescHeight);
        draggableBackground.springBounciness = 15;
        draggableBackground.springSpeed = 15;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            //draggableBackground.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y - 45, draggableBackground.frame.size.width, 320 + 235 + extraDescHeight);
            
            draggableBackground.dragView.frame = CGRectMake(draggableBackground.dragView.frame.origin.x, draggableBackground.dragView.frame.origin.y, draggableBackground.dragView.frame.size.width, 320 + 235 + 16 + 60 + extraDescHeight);
            draggableBackground.dragView.cardView.frame = CGRectMake(draggableBackground.dragView.cardView.frame.origin.x, draggableBackground.dragView.cardView.frame.origin.y, draggableBackground.dragView.cardView.frame.size.width, 320 + 235 + 16 + 60 + extraDescHeight);
            

            xButton.center = CGPointMake(-1000, xButton.center.y);
            checkButton.center = CGPointMake(1300, checkButton.center.y);
            
            draggableBackground.dragView.subtitle.alpha = 1;
            
            /*
            if (extraDescHeight > 85) {
                draggableBackground.dragView.subtitle.frame = CGRectMake(subtitleFrame.origin.x, subtitleFrame.origin.y + 37, 254, subtitleFrame.size.height + 66); //6 lines
                draggableBackground.dragView.moreButton.alpha = 1;

            } else {
                draggableBackground.dragView.subtitle.frame = CGRectMake(subtitleFrame.origin.x, subtitleFrame.origin.y + 37, 254, subtitleFrame.size.height + extraDescHeight);
            } */
            
        } completion:^(BOOL finished) {
            
            //draggableBackground.dragView.cardView.layer.masksToBounds = NO;
            
        }];
        
        self.isCardExpanded =! self.isCardExpanded;

        
    } else if (draggableBackground.isLoaded) {
        
        [UIView animate:^{
            [scrollView viewWithTag:90].alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
        
        draggableBackground.dragView.cardView.layer.masksToBounds = YES;
        
        [self setEnabledSidewaysScrolling:YES];
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        scrollView.scrollEnabled = NO;
        
        //[UIView animateWithDuration:0.3 animations:^{
           
        settingsView.frame = CGRectMake(0, -45, 320, settingsView.frame.size.height);
        settingsView.springBounciness = 10;
        settingsView.springSpeed = 10;
            //scrollView.frame = CGRectMake(0, 45, 320, scrollView.frame.size.height);
            
        //}];
        
        draggableBackground.spring.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y, draggableBackground.frame.size.width, 390);
        draggableBackground.springBounciness = 10;
        draggableBackground.springSpeed = 10;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            //cardView.frame = CGRectMake(cardView.frame.origin.x, cardView.frame.origin.y, cardView.frame.size.width, 310);
            //draggableBackground.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y + 45, draggableBackground.frame.size.width, 350);
            draggableBackground.dragView.frame = CGRectMake(draggableBackground.dragView.frame.origin.x, draggableBackground.dragView.frame.origin.y, draggableBackground.dragView.frame.size.width, 390);
            draggableBackground.dragView.cardView.frame = CGRectMake(draggableBackground.dragView.cardView.frame.origin.x, draggableBackground.dragView.cardView.frame.origin.y, draggableBackground.dragView.cardView.frame.size.width, 390);
            
            xButton.center = CGPointMake(21.75, xButton.center.y);
            checkButton.center = CGPointMake(302.25, checkButton.center.y);
            
            //draggableBackground.dragView.moreButton.alpha = 0;

        } completion:^(BOOL finished) {
            
            //[[draggableBackground.dragView.cardView viewWithTag:0] removeFromSuperview];
            //[[draggableBackground.dragView.cardView viewWithTag:1] removeFromSuperview];
            //[[draggableBackground.dragView.cardView viewWithTag:2] removeFromSuperview];
            
            draggableBackground.dragView.subtitle.alpha = 0;
            //draggableBackground.dragView.cardView.layer.masksToBounds = NO;
            
            draggableBackground.dragView.eventImage.autoresizingMask =
            ( UIViewAutoresizingFlexibleBottomMargin
             | UIViewAutoresizingFlexibleHeight
             | UIViewAutoresizingFlexibleLeftMargin
             | UIViewAutoresizingFlexibleRightMargin
             | UIViewAutoresizingFlexibleTopMargin
             | UIViewAutoresizingFlexibleWidth );
            
        }];

        
        self.isCardExpanded =! self.isCardExpanded;

    }
}


- (IBAction)createButtonPressed:(id)sender {
    
    // disable user interaction during the flip animation
    //self.view.userInteractionEnabled = NO;


    // swap the views and transition
    if (self.isCreatingHappening == NO) {
        
        NSLog(@"Creating Happening!");
        
        [SVProgressHUD dismiss];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.8];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        [UIView commitAnimations];
        
        [self.draggableBackground removeFromSuperview];
        self.view.userInteractionEnabled = NO;
        self.createButton.userInteractionEnabled = NO;
        self.view.backgroundColor = [UIColor whiteColor];
        [self.backgroundImageView removeFromSuperview];

        // Create the flipped view
        
        createHappeningView = [[CreateHappeningView alloc]initWithFrame:self.view.bounds];
        [createHappeningView addDragView];
        createHappeningView.vc = self;
        createHappeningView.delegate = self;
        [self.view addSubview:createHappeningView];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.filterButton.alpha = 0;
            self.createButton.alpha = 0;
        } completion:^(BOOL finished) {
            [self.filterButton setImage:[UIImage imageNamed:@"x_white"] forState:UIControlStateNormal];
            [self.filterButton removeTarget:self action:@selector(dropdownPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.filterButton addTarget:self action:@selector(createButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [UIView animateWithDuration:0.4 animations:^{
                self.filterButton.alpha = 1.0;
            } completion:nil];
        }];
     
     
    } else {

        NSLog(@"Going back from creating Happening. Did user create one??");
        
        [createHappeningView.fastCamera stopRunning];
        [self fastttRemoveChildViewController:createHappeningView.fastCamera];
        [createHappeningView resignAllResponders];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.8];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        [UIView commitAnimations];
        
        [self.scrollView addSubview:draggableBackground];
        [[self.view viewWithTag:32] insertSubview:backgroundImageView belowSubview:scrollView];
        [createHappeningView removeFromSuperview];
        
        [UIView animateWithDuration:0.4 animations:^{
            self.filterButton.alpha = 0;
        } completion:^(BOOL finished) {
            [self.filterButton setImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
            [self.filterButton removeTarget:self action:@selector(createButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.filterButton addTarget:self action:@selector(dropdownPressed) forControlEvents:UIControlEventTouchUpInside];
            [UIView animateWithDuration:0.4 animations:^{
                self.filterButton.alpha = 1.0;
                self.createButton.alpha = 1.0;
            } completion:nil];
        }];

    }
    
     // invert the front view state
    self.isCreatingHappening =! self.isCreatingHappening;
    if (!self.isCreatingHappening)
        [self refreshData];

    
}

- (void)myTransitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    // re-enable user interaction when the flip animation is completed
    self.view.userInteractionEnabled = YES;
    self.createButton.userInteractionEnabled = YES;
    [createHappeningView performSelector:@selector(animatingDidStop)];
    
}

- (void)inviteFromCreateViewTapped {
    
    [self performSegueWithIdentifier:@"toCreateInvite" sender:self];
}

- (void)addSubviewsToCard:(DraggableView *)card {
    
    scrollView.contentSize = CGSizeMake(320, 600 + 17 + 60 + extraDescHeight);
    
    scrollView.delaysContentTouches = YES;
    
    draggableBackground.dragView.cardView.userInteractionEnabled = YES;
    
    NSLog(@"expand card");
    
    draggableBackground.dragView.mapView.delegate = self;
    
    PFGeoPoint *loc = draggableBackground.dragView.geoPoint;
    CLLocation *mapLocation = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
    
    annotation = [[MKPointAnnotation alloc]init];
    [annotation setCoordinate:mapLocation.coordinate];
    [annotation setTitle:[draggableBackground.dragView.location.text stringByReplacingOccurrencesOfString:@"at " withString:@""]];
    
    [draggableBackground.dragView.mapView addAnnotation:annotation];
    [draggableBackground.dragView.mapView viewForAnnotation:annotation];
    [draggableBackground.dragView.mapView selectAnnotation:annotation animated:YES];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapLocation.coordinate, 750, 750);
    [draggableBackground.dragView.mapView setRegion:region animated:NO];
    [draggableBackground.dragView.mapView setUserTrackingMode:MKUserTrackingModeNone];
    [draggableBackground.dragView.mapView regionThatFits:region];
    
    [[[CLGeocoder alloc]init] reverseGeocodeLocation:mapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks[0];
        
        NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
        NSString *addressString = [lines componentsJoinedByString:@" "];
        //NSLog(@"Address: %@", addressString);
        
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
    
    [self ticketsAndUberUpdateFrameBy:28 + 8];

    mapViewExpanded = NO;
        
}

- (void)expandedButtonTapped:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    [self tap:nil];
    
    if (button.tag == -1) { // not interested
        
        NSLog(@"swipe left from expanded view");
        [self performSelector:@selector(swipeLeftDVC) withObject:nil afterDelay:0.5];
        
    } else if (button.tag == 1) { // interested
        
        NSLog(@"swipe right from expanded view");
        [self performSelector:@selector(swipeRightDVC) withObject:nil afterDelay:0.5];
        
    } else { // go back
        
        NSLog(@"go back up from expanded view");
        
    }
    
}

-(BOOL)doesString:(NSString *)first contain:(NSString*)other {
    NSRange range = [first rangeOfString:other];
    return range.length != 0;
}

- (void)loadFBFriends:(UIScrollView *)friendScrollView {
    
    
}
     
- (void)noFriendsAddButton:(UIScrollView *)friendScrollView {

    friendScrollView.scrollEnabled = NO;
    
    UIButton *noFriendsButton = [[UIButton alloc] initWithFrame:CGRectMake(35, 5, 184, 40)];
    [noFriendsButton setTitle:@"Invite your friends" forState:UIControlStateNormal];
    noFriendsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
    [noFriendsButton setTitleColor:[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [noFriendsButton setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateHighlighted];
    noFriendsButton.layer.masksToBounds = YES;
    noFriendsButton.layer.borderColor = [UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0].CGColor;
    noFriendsButton.layer.borderWidth = 2.0;
    noFriendsButton.layer.cornerRadius = 5.0;
    
    [noFriendsButton setReversesTitleShadowWhenHighlighted:YES];
    [noFriendsButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    
    noFriendsButton.tag = 99; // so we don't show calendar on sharesheet
    
    [friendScrollView addSubview:noFriendsButton];
    
}

- (void)ticketsAndUberUpdateFrameBy:(int)height {
    
    if (self.isCardExpanded) {
    
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

- (void)mapViewTap {
    
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
    if ([anno isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else  // use whatever annotation class you used when creating the annotation
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:anno reuseIdentifier:@"tag"];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"Annotation"];
        annotationView.frame = CGRectMake(0, 0, 20, 25);
        annotationView.centerOffset = CGPointMake(0, -5);
        //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
}

- (void)grabAnUberButtonTapped:(id)sender {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        // Do something awesome - the app is installed! Launch App.
        NSLog(@"Uber button tapped- app exists! Opening app...");
        
        PFQuery *query = [PFQuery queryWithClassName:@"Event"];
        [query getObjectInBackgroundWithId:draggableBackground.dragView.objectID block:^(PFObject *object, NSError *error) {
            
            PFGeoPoint *loc = object[@"GeoLoc"];
            
            NSString *locationName = @"";
            if (object[@"Location"] != nil) {
                locationName = object[@"Location"];
            }
            
            if (!error) {
                
                NSString *myLocationString = @"My%20Location";
                
                NSString *urlStringUber = [NSString stringWithFormat:@"uber://?client_id=Vmks1LNIHQiiaUYd8Z3FaMNkvD-7s53V&action=setPickup&pickup=my_location&pickup[nickname]=%@&dropoff[latitude]=%f&dropoff[longitude]=%f&dropoff[nickname]=%@", myLocationString, loc.latitude, loc.longitude, locationName];
                
                urlStringUber = [urlStringUber stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                urlStringUber = [urlStringUber stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlStringUber]];

            }
            
        }];
    }
    else {
        // No Uber app! Open Mobile Website.
        NSLog(@"Uber button tapped- app does not exist! Opening mobile website...");
        
        PFUser *currentUser = [PFUser currentUser];
        
        NSString *firstName = currentUser[@"firstName"];
        NSString *lastName = currentUser[@"lastName"];
        NSString *userEmail = currentUser.email;
        
        if (!userEmail) {
            userEmail = @"";
        }
            
        PFQuery *query = [PFQuery queryWithClassName:@"Event"];
        [query getObjectInBackgroundWithId:draggableBackground.dragView.objectID block:^(PFObject *object, NSError *error) {
            
            PFGeoPoint *loc = object[@"GeoLoc"];
            
            NSString *locationName = @"";
            if (object[@"Location"] != nil)
                locationName = object[@"Location"];
            
            if (!error) {
                    
                NSString *urlStringUber = [NSString stringWithFormat:@"https://m.uber.com/sign-up?client_id=Vmks1LNIHQiiaUYd8Z3FaMNkvD-7s53V&first_name=%@&last_name=%@&email=%@&country_code=us&&dropoff_latitude=%f&dropoff_longitude=%f&dropoff_nickname=%@", firstName, lastName, userEmail, loc.latitude, loc.longitude, locationName ];
                    
                urlStringUber = [urlStringUber stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                urlStringUber = [urlStringUber stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
                    
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlStringUber]];
                    
            }
            
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
        
        [settingsView showTapToGoBack:YES];
        
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
            settingsView.frame = CGRectMake(0, -45, self.view.frame.size.width, 502 + 45);
        } completion:^(BOOL finished) {
            dropdownExpanded = YES;
            
            if (tutIsShown) {
                [settingsView tutViewAction];
            }
            
        }];
        
    } else {
        
        [settingsView showTapToGoBack:NO];
        
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
                settingsView.frame = CGRectMake(0, -45, self.view.frame.size.width, 45);
            

                if ([settingsView didPreferencesChange]) {
                    //NSLog(@"CPI +++ %lu", rk.currentPageIndex);

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
    
    BOOL hasLaunched = !var;
    [PFUser currentUser][@"hasLaunched"] = @(hasLaunched);
    [[PFUser currentUser] saveEventually];
    
    settingsView.userInteractionEnabled = YES;
    self.filterButton.enabled = YES;
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]])
        self.createButton.enabled = YES;
    
    if (!var) {
        dropdownExpanded = YES;
        [self dropdownPressed];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        rk = appDelegate.rk;
        [rk updateCurrentPageIndex:1];
        
        //NSLog(@"CPI +++ %lu", rk.currentPageIndex);
        //[self refreshData];
    }
    
    
}

- (void)setEnabledSidewaysScrolling:(BOOL)enabled {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    rk = appDelegate.rk;
    [rk scrolling:enabled];
    
}

- (void)shareAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModalPopup *popup = [storyboard instantiateViewControllerWithIdentifier:@"ModalPopup"];
    popup.eventObject = draggableBackground.dragView.eventObject;
    popup.eventDateString = draggableBackground.dragView.date.text;
    popup.eventImage = draggableBackground.dragView.eventImage.image;
    popup.type = @"share";
    [self showModalPopup:popup];
}

-(void)showCreatedByProfile {
    /*
    [self performSegueWithIdentifier:@"showProfile" sender:self];
     */
}

-(void)showFriendProfile:(NSString *)friendId {
    
    self.friendObjectID = friendId;
    [self performSegueWithIdentifier:@"showFriendProfile" sender:self];
     
    /*
    UIView *view = gr.view;
    friendObjectID = view.accessibilityIdentifier;
    [self performSegueWithIdentifier:@"toTemp" sender:self];
     */
}

-(void)inviteHomies {
    
    [self performSegueWithIdentifier:@"inviteHomies" sender:self];
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
    
    //scrollView.delaysContentTouches = NO;
    tutorialScreens.dragView.userInteractionEnabled = YES;
    
    if (((tutorialScreens.dragView.tag == 3) || (tutorialScreens.dragView.tag == 50)) && tutorialScreens.allowCardExpand) {
    
        if (!tutorialScreens.cardExpanded) {
            
            NSLog(@"expand tut card");
            
            //[self addSubviewsToCard:draggableBackground.dragView];
            
            scrollView.contentSize = CGSizeMake(320, 665);
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
                
                [tutorialScreens nowScrollDown];
                
            }];
            
            
        } else {
            
            NSLog(@"contract tut card");
            
            tutorialScreens.dragView.layer.masksToBounds = YES;
            //tutorialScreens.allowCardSwipe = YES;
            tutorialScreens.allowCardExpand = NO;
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
                
                [tutorialScreens tapButtons];
                
            }];
            
        
            }
        
        tutorialScreens.cardExpanded =! tutorialScreens.cardExpanded;
    }
}

-(void)updateTopLabel {
    [self.settingsView setTimeString];
}

-(void)buttonNormal:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setBackgroundColor:[UIColor whiteColor]];
}

-(void)buttonHighlight:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setBackgroundColor:[UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0]];
}


//%%% color of the status bar
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
    
    //    return UIStatusBarStyleDefault;
}

/*
- (void)reachabilityChanged:(NSNotification *)note
{
    
    NSLog(@"Reachability changed");
    
    Reachability *reach = [note object];
    isReachable = reach.isReachable;
    
    if (![reach isReachable]) {
    
        [RKDropdownAlert title:@"Something went wrong :(" message:@"It appears you are not connected to the internet..." backgroundColor:[UIColor redColor] textColor:[UIColor whiteColor]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // time-consuming task
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"Houston, we have a problem." maskType:SVProgressHUDMaskTypeGradient];
            });
        });
        
        [UIView animateWithDuration:0.4 animations:^{
            
            draggableBackground.alpha = 0;
            
            xButton.center = CGPointMake(-1000, xButton.center.y);
            checkButton.center = CGPointMake(1300, checkButton.center.y);
            
            UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
            refreshButton.center = self.view.center;
            [refreshButton setTitle:@"Refresh Happenings" forState:UIControlStateNormal];
            [refreshButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
            [refreshButton addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
            //[self.view addSubview:refreshButton];
            
        } completion:^(BOOL finished) {
            //code
        }];
        
    } else {
        
        //[self refreshData];
    }

}
*/

- (void)showModalPopup:(ModalPopup *)popup {
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //ModalPopup *controller = [storyboard instantiateViewControllerWithIdentifier:@"ModalPopup"];
    //controller.event = c.eventObject;
    NSLog(@"Presenting popup...");
    popup.delegate = self;
    [self mh_presentSemiModalViewController:popup animated:YES];
    
}

- (void)userFinishedAction:(BOOL)wasSuccessful type:(NSString *)t {
    
    if ([t isEqualToString:@"create"]) {
        
        [self createButtonPressed:nil];
        
    }
    
}

-(void)showBoom {
    
    NSLog(@"Boom");
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -66)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
            [SVProgressHUD showSuccessWithStatus:@"Boom"];
            [SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
        });
    });
    
}

-(void)showError:(NSString *)message {
    
    NSLog(@"Error");
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -66)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
            [SVProgressHUD showErrorWithStatus:message];
            [SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
        });
    });
    
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
        vc.event = draggableBackground.dragView.eventObject;
        vc.locationTitle = annotation.title;
        vc.locationSubtitle = annotation.subtitle;
        
    } else if ([segue.identifier isEqualToString:@"showProfile"]) {
        
        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.eventID = draggableBackground.dragView.objectID;
        
    } else if ([segue.identifier isEqualToString:@"showFriendProfile"]) {
        
        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.userID = self.friendObjectID;
        
    } else if ([segue.identifier isEqualToString:@"inviteHomies"]) {
        
        inviteHomies *vc = (inviteHomies *)[[segue destinationViewController] topViewController];
        vc.objectID = draggableBackground.dragView.objectID;
        vc.eventTitle = draggableBackground.dragView.title.text;
        vc.eventLocation = draggableBackground.dragView.location.text;
        vc.event = draggableBackground.dragView.eventObject;
        vc.interestedNames = draggableBackground.dragView.interestedNames;
        vc.interestedIds = draggableBackground.dragView.interestedIds;
        vc.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"toTemp"]) {
        
        tempProfile *vc = (tempProfile *)[segue destinationViewController];
        vc.userID = self.friendObjectID;
        vc.eventID = self.draggableBackground.dragView.objectID;
        
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
        vc.eventID = draggableBackground.dragView.objectID;
        vc.titleText = draggableBackground.dragView.title.text;
        vc.subtitleText = draggableBackground.dragView.subtitle.text;
        vc.locationText = draggableBackground.dragView.location.text;
        
    } else if ([segue.identifier isEqualToString:@"toCreateInvite"]) {
        
        InviteFromCreateView *vc = (InviteFromCreateView *)[[segue destinationViewController] topViewController];
        vc.delegate = createHappeningView;
        //vc.convo = self.convo;
        //vc.group = self.group;
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

