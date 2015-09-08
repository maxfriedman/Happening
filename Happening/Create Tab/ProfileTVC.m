//
//  ProfileTVC.m
//  Happening
//
//  Created by Max on 2/8/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ProfileTVC.h"
#import "AttendTableCell.h"
#import "CupertinoYankee.h"
#import "showMyEventVC.h"
#import "EventTVC.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import "ProfileSettingsTVC.h"
#import "ExpandedCardVC.h"
#import "UIButton+Extensions.h"
#import "FXBlurView.h"
#import "UIImage+ImageEffects.h"
#import "TimelineCell.h"
#import "inviteHomiesCell.h"
#import "ExternalProfileTVC.h"
#import "CustomAPActivityProvider.h"
#import "RKDropdownAlert.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface ProfileTVC () <EventTVCDelegate, ExpandedCardVCDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;
@property (strong, nonatomic) NSArray *eventsArray;

@property (strong, nonatomic) NSMutableDictionary *createdSections;
@property (strong, nonatomic) NSArray *createdSortedDays;
@property (strong, nonatomic) NSArray *createdEventsArray;

@property (strong, nonatomic) NSMutableDictionary *friendSections;
@property (strong, nonatomic) NSArray *sortedFriends;
@property (strong, nonatomic) NSArray *sortedFriendsLetters;

@property (strong, nonatomic) NSMutableArray *sortedTimelineIds;
@property (strong, nonatomic) NSMutableDictionary *timelineDict;
@property (strong, nonatomic) NSMutableDictionary *friendEventDict;

@property (strong, nonatomic) NSMutableArray *pastEventsArray;

@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) FBSDKProfilePictureView *profPicView;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tabButtons;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *tabLabels;

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

@end

@implementation ProfileTVC {
    
    PFUser *currentUser;
    UIView *noEventsView;
    UIButton *createButton;
    UIButton *noFriendsButton;
    
    CAGradientLayer *maskLayer;
    
    BOOL showUpcomingEvents;
    BOOL pastEventsLoaded;
    FXBlurView *blurView;
    int tableVersion;
    BOOL showTimeline;
    BOOL isAnimatingScoreButton;
    
    BOOL clearTable;
    
    UILabel *scoreLabel;
    UILabel *navBarLabel;
    UILabel *hapsLabel;
    UIButton *leaderboardButton;
    
    UIButton *xButton;
    
    BOOL tableViewIsUp;
    
    NSString *selectedFriendId;
    
}

//@synthesize locManager, refreshControl;
@synthesize sections, sortedDays, locManager;
@synthesize nameLabel, detailLabel, profilePicImageView, settingsButton, containerView, profPicView, scoreButton, eventsArray, createdEventsArray, createdSections, createdSortedDays, pastEventsArray, timelineDict, friendEventDict, sortedTimelineIds;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentUser = [PFUser currentUser];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    [scoreButton setTitle:[NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]] forState:UIControlStateNormal];
    
    [settingsButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstName"], currentUser[@"lastName"]];
    
    if ((currentUser[@"userLocTitle"] != nil) && (! [currentUser[@"userLocTitle"] isEqualToString:@"Current Location"]) ) {
        
        if ( ! [currentUser[@"userLocTitle"] isEqualToString:@"Current Location"])
            detailLabel.text = [NSString stringWithFormat:@"%@", currentUser[@"userLocTitle"]];
    
    } else {
        if (currentUser[@"fbLocationName"] != nil)
            detailLabel.text = [NSString stringWithFormat:@"%@", currentUser[@"fbLocationName"]];
        else
            detailLabel.text = @"";
        
    }
    
    //self.tableView.delegate = self;
    //self.tableView.dataSource = self;
    
    profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, -32, 320, 320)];
    
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        profPicView.profileID = currentUser[@"FBObjectID"];
    } else {
        profPicView.profileID = nil;
        nameLabel.text = @"Anonymous User";
    }
    profPicView.pictureMode = FBSDKProfilePictureModeSquare;

    [containerView insertSubview:profPicView atIndex:0];

    

    maskLayer = [CAGradientLayer layer];

    // Hoizontal - commenting these two lines will make the gradient veritcal
    //maskLayer.startPoint = CGPointMake(0.0, 0.5);
    //maskLayer.endPoint = CGPointMake(1.0, 0.5);
    //maskLayer.startPoint = CGPointMake(0.0, 0.5);
    //maskLayer.endPoint = CGPointMake(1.0, 0.5);
    
    maskLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.1].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:0.3].CGColor, (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor, nil];
    
    maskLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:0.7].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.3].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.8].CGColor, nil];
    
    nameLabel.textColor = [UIColor whiteColor];
    detailLabel.textColor = [UIColor whiteColor];
    
    //l.startPoint = CGPointMake(0.0, 0.7f);
    //l.endPoint = CGPointMake(0.0f, 1.0f);
    maskLayer.locations = [NSArray arrayWithObjects:
                   [NSNumber numberWithFloat:0.0],
                   [NSNumber numberWithFloat:0.3],
                   [NSNumber numberWithFloat:0.7],
                   //[NSNumber numberWithFloat:0.9],
                   [NSNumber numberWithFloat:1.0], nil];
    
    maskLayer.bounds = profPicView.bounds;
    maskLayer.anchorPoint = CGPointZero;
    [profPicView.layer addSublayer:maskLayer];

    //[ bringSubviewToFront:nameLabel];
    //[self.view bringSubviewToFront:detailLabel];
    
    /*
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasCreatedEvent"] == NO) {
        
        UILabel *topTextLabel = [[UILabel alloc] init];
        topTextLabel.text = @"You haven't created";
        topTextLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
        topTextLabel.textColor = [UIColor colorWithRed:153.0/255 green:154.0/255 blue:155.0/255 alpha:1.0];
        [topTextLabel sizeToFit];
        topTextLabel.center = CGPointMake(self.view.center.x, 10);
        topTextLabel.tag = 9;
        [noEventsView addSubview:topTextLabel];
        
        
        UILabel *bottomTextLabel = [[UILabel alloc] init];
        bottomTextLabel.text = @"any events yet.";
        bottomTextLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
        bottomTextLabel.textColor = [UIColor colorWithRed:153.0/255 green:154.0/255 blue:155.0/255 alpha:1.0];
        [bottomTextLabel sizeToFit];
        bottomTextLabel.center = CGPointMake(self.view.center.x, 30);
        bottomTextLabel.tag = 9;
        [noEventsView addSubview:bottomTextLabel];
        
        
        UIButton *createEventButton = [[UIButton alloc] initWithFrame:CGRectMake(101.5, 55, 117, 40)];
        [createEventButton setImage:[UIImage imageNamed:@"createButton"] forState:UIControlStateNormal];
        [createEventButton setImage:[UIImage imageNamed:@"create pressed"] forState:UIControlStateHighlighted];
        [createEventButton addTarget:self action:@selector(createEventButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        createEventButton.tag = 9;
        [noEventsView addSubview:createEventButton];
        
    } */

    self.tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
    
    
    blurView = [[FXBlurView alloc] initWithFrame:profPicView.bounds];
    blurView.blurRadius = 15;
    blurView.alpha = 0;
    blurView.dynamic = YES;
    blurView.tintColor = [UIColor clearColor];
    [profPicView addSubview:blurView];
    
    scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 45, 150, 60)];
    scoreLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:50.0];
    scoreLabel.textAlignment = NSTextAlignmentLeft;
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.text = [currentUser[@"score"] stringValue];
    scoreLabel.alpha = 0;
    [scoreLabel sizeToFit];
    [containerView addSubview:scoreLabel];
    
    hapsLabel = [[UILabel alloc] initWithFrame:CGRectMake(scoreLabel.frame.size.width + 5, 30, 70, 60)];
    hapsLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:20.0];
    hapsLabel.textAlignment = NSTextAlignmentLeft;
    hapsLabel.textColor = [UIColor whiteColor];
    hapsLabel.text = @"haps";
    hapsLabel.alpha = 1;
    [scoreLabel addSubview:hapsLabel];
    [hapsLabel sizeToFit];
    hapsLabel.frame = CGRectMake(hapsLabel.frame.origin.x, scoreLabel.frame.size.height - hapsLabel.frame.size.height - 10, hapsLabel.frame.size.width, hapsLabel.frame.size.height);
    
    leaderboardButton = [[UIButton alloc] initWithFrame:CGRectMake(215, 10, 90, 30)];
    [leaderboardButton setTitle:@"Leaderboard" forState:UIControlStateNormal];
    [leaderboardButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leaderboardButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    leaderboardButton.layer.masksToBounds = YES;
    leaderboardButton.layer.cornerRadius = 4.0;
    leaderboardButton.layer.borderWidth = 1.0;
    leaderboardButton.layer.borderColor = [UIColor whiteColor].CGColor;
    //leaderboardButton.center = CGPointMake(260, scoreLabel.center.y);
    leaderboardButton.alpha = 0.0;
    [leaderboardButton addTarget:self action:@selector(showLeaderboard) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:leaderboardButton];
    
    
    timelineDict = [NSMutableDictionary dictionary];
    sortedTimelineIds = [NSMutableArray array];
    
    
    navBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 12, 200, 40)];
    navBarLabel.text = self.nameLabel.text;
    navBarLabel.textColor = [UIColor whiteColor];
    navBarLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:22.0];
    navBarLabel.textAlignment = NSTextAlignmentCenter;
    navBarLabel.alpha = 0;
    [navBarLabel sizeToFit];
    navBarLabel.center = CGPointMake(self.view.center.x, navBarLabel.center.y - 2);
    [self.view addSubview:navBarLabel];
    
    xButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    xButton.center = scoreButton.center;
    [xButton setImage:[UIImage imageNamed:@"x_white"] forState:UIControlStateNormal];
    xButton.alpha = 0;
    xButton.tag = 2;
    [xButton addTarget:self action:@selector(scoreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:xButton];
    
    tableViewIsUp = NO;
    
    showUpcomingEvents = YES;
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE, MMMM d"];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    pastEventsArray = [NSMutableArray new];
    pastEventsLoaded = NO;
    
    //self.scrollView.canCancelContentTouches = YES;
    //self.scrollView.delaysContentTouches = NO;
    
}

- (void)showLeaderboard {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coming soon!" message:@"For now, you can keep earning points by swiping, sharing, creating, and inviting your friends to events on Happening." delegate:nil cancelButtonTitle:@"Sounds awesome" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.mh hideCallout];
    
    currentUser = [PFUser currentUser];
    
    if (currentUser[@"score"] != nil) {
        [scoreButton setTitle:[NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]] forState:UIControlStateNormal];
        scoreLabel.text = [NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]];
    } else {
        [scoreButton setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
        scoreLabel.text = [NSString stringWithFormat:@"0"];
    }
    
    UIButton *createdButton = self.tabButtons[0];
    if (currentUser[@"createdCount"] != nil) {
        [createdButton setTitle:[NSString stringWithFormat:@"%@", [currentUser[@"createdCount"] stringValue]] forState:UIControlStateNormal];
    } else {
        currentUser[@"createdCount"] = @0;
        [createdButton setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
    }
    
    UIButton *eventsButton = self.tabButtons[1];
    if (currentUser[@"eventCount"] != nil) {
        [eventsButton setTitle:[NSString stringWithFormat:@"%@", [currentUser[@"eventCount"] stringValue]] forState:UIControlStateNormal];
    } else {
        currentUser[@"eventCount"] = @0;
        [eventsButton setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
    }
    
    UIButton *friendsButton = self.tabButtons[2];
    if (currentUser[@"friendCount"] != nil) {
        [friendsButton setTitle:[NSString stringWithFormat:@"%@", [currentUser[@"friendCount"] stringValue]] forState:UIControlStateNormal];
    } else {
        currentUser[@"friendCount"] = @0;
        [friendsButton setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
    }
    
    if (!showTimeline) {
        
        switch (tableVersion) {
            case 1: { // created by me
                
                [self loadCreatedEvents];
                break;
            }
            case 2: { // my events
                
                [self loadData];
                break;
            }
            case 3: { // friends
                
                [self loadFriends];
                break;
            }
                
            default: {
                
                [self loadData];
                break;
            }
        }
        
    } else {
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)loadData {
    
    NSLog(@"load...");
    
    tableVersion = 2;
    
    currentUser = [PFUser currentUser];
    
    PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    [swipesQuery whereKey:@"UserID" equalTo:currentUser.objectId];
    [swipesQuery whereKey:@"swipedRight" equalTo:@YES];
    [swipesQuery fromLocalDatastore];
    swipesQuery.limit = 1000;
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery fromLocalDatastore];
    [eventQuery whereKey:@"objectId" matchesKey:@"EventID" inQuery:swipesQuery];
    [eventQuery whereKey:@"Date" greaterThan:[[NSDate date]beginningOfDay]];
    [eventQuery orderByAscending:@"Date"];
    eventQuery.limit = 1000;
    
    BOOL firstTime = NO;
    
    if (!eventsArray)
        eventsArray = [NSArray new];
    
    if (!sections) {
        self.sections = [NSMutableDictionary dictionary];
        firstTime = YES;
    } else {
        [self.tableView reloadData];
        /*
        NSRange range = NSMakeRange(0, 0);
        NSIndexSet *section = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
         */
    }
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        
        if (!error) {
            
            eventsArray = events;
            
            BOOL didChange = NO;
        
            for (PFObject *event in events) {
                
                NSLog(@"%@", event.objectId);
                
                // Reduce event start date to date components (year, month, day)
                NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:event[@"Date"]];
                if ([dateRepresentingThisDay compare:[NSDate date]] == NSOrderedAscending) {
                    dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:[NSDate date]];
                }
                
                // If we don't yet have an array to hold the events for this day, create one
                NSMutableArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
                if (eventsOnThisDay == nil) {
                    eventsOnThisDay = [NSMutableArray array];
                    
                    // Use the reduced date as dictionary key to later retrieve the event list this day
                    [self.sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
                }
                
                // Add the event to the list for this day
                if (![eventsOnThisDay containsObject:event]) {
                    didChange = YES;
                    [eventsOnThisDay addObject:event];
                }
                
            }
            
            // Create a sorted list of days
            NSArray *unsortedDays = [self.sections allKeys];
            self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
            if (sortedDays == nil) sortedDays = [NSArray array];
            
            [noEventsView removeFromSuperview];
            
            
            if (events.count == 0) {
                [self loadPastEvents];
            } else if (didChange || firstTime) {
                [self.tableView reloadData];
                [self loadSwipes];
            }
            
            /*if (tableViewIsUp) {
                self.segContainerView.frame = CGRectMake(0, 212, 320, 55);
                self.tableView.frame = CGRectMake(0, 253, 320, 420);
                navBarLabel.alpha = 0;
                blurView.alpha = 0;
                nameLabel.alpha = 1;
                detailLabel.alpha = 1;
                tableViewIsUp = NO;
            }*/

            
        } else {
            
            NSLog(@"%@", error);
            [self loadPastEvents];
        }
    }];
    
}

- (void)loadSwipes {
    
    NSArray *friends = currentUser[@"friends"];
    NSMutableArray *friendIds = [NSMutableArray array];
    for (NSDictionary *dict in friends) {
        [friendIds addObject:[dict objectForKey:@"parseId"]];
    }
    [friendIds addObject:currentUser.objectId];
    
    NSMutableArray *eventIds = [NSMutableArray array];
    if (tableVersion == 1) {
        for (PFObject *event in createdEventsArray) {
            [eventIds addObject:event.objectId];
        }
    } else {
        for (PFObject *event in eventsArray) {
            [eventIds addObject:event.objectId];
        }
    }
    
    PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    [swipesQuery whereKey:@"UserID" containedIn:friendIds];
    [swipesQuery whereKey:@"swipedRight" equalTo:@YES];
    [swipesQuery whereKey:@"EventID" containedIn:eventIds];
    swipesQuery.limit = 1000;
    [swipesQuery findObjectsInBackgroundWithBlock:^(NSArray *swipes, NSError *error){
        
        if (!error) {
            
            //NSMutableArray *eventIds = [NSMutableArray array];
            //NSMutableDictionary *friendIdsForEventDict = [NSMutableDictionary dictionary];
            
            NSMutableArray *orderedObjects = [NSMutableArray arrayWithArray:swipes];
            
            if (!friendEventDict)
                friendEventDict = [NSMutableDictionary dictionary];
            
            for (int i = 0; i < orderedObjects.count; i++) {
                
                PFObject *object = orderedObjects[i];
                
                if ([object[@"FBObjectID"] isEqualToString:currentUser[@"FBObjectID"]]) {
                    
                    [orderedObjects removeObject:object];
                    [orderedObjects insertObject:object atIndex:0];
                    
                    NSMutableDictionary *dict = [friendEventDict objectForKey:object[@"EventID"]];
                    dict = [NSMutableDictionary dictionary];
                    [friendEventDict setObject:dict forKey:object[@"EventID"]];
                    [dict setObject:[NSMutableArray arrayWithObject:object[@"FBObjectID"]] forKey:@"fbids"];
                    
                    NSString *type;
                    if ([object[@"isGoing"] boolValue] == YES) {
                        type = @"going";
                    } else {
                        type = @"interested";
                    }
                    
                    ProfilePictureView *ppview = [[ProfilePictureView alloc] initWithFrame:CGRectMake(30 + 50 * 0, 93, 40, 40) type:type fbid:object[@"FBObjectID"]];
                    ppview.layer.borderColor = [UIColor whiteColor].CGColor;
                    ppview.tag = 9;
                    
                    [dict setObject:[NSMutableArray arrayWithObject:ppview] forKey:@"profilePictures"];
                    
                } else if ([object[@"isGoing"] boolValue] == YES) {
                    
                    [orderedObjects removeObject:object];
                    [orderedObjects insertObject:object atIndex:0];
                }
            }
            
            for (int i = 0; i < orderedObjects.count; i++) {
                
                PFObject *swipe = orderedObjects[i];
                
                NSMutableDictionary *dict = [friendEventDict objectForKey:swipe[@"EventID"]];
                
                if (![swipe[@"FBObjectID"] isEqualToString:currentUser[@"FBObjectID"]] && swipe[@"FBObjectID"] != nil) {
                    
                    NSString *type;
                    if ([swipe[@"isGoing"] boolValue] == YES) {
                        type = @"going";
                    } else {
                        type = @"interested";
                    }
                    
                    NSMutableArray *array = [dict objectForKey:@"fbids"];
                    [array addObject:swipe[@"FBObjectID"]];
                    
                    NSMutableArray *picArray = [dict objectForKey:@"profilePictures"];
                    if (picArray.count < 5) {
                        
                        ProfilePictureView *ppview = [[ProfilePictureView alloc] initWithFrame:CGRectMake(30 + 50 * picArray.count, 93, 40, 40) type:type fbid:swipe[@"FBObjectID"]];
                        ppview.layer.borderColor = [UIColor whiteColor].CGColor;
                        ppview.tag = 9;
                        [picArray addObject:ppview];
                    }
                    
                }
                
            }
            
            
            /* Order by popularity amongst friends
             
            NSCountedSet *countedSet = [NSCountedSet setWithArray:eventIds];
            
            NSArray *sortedValues = [countedSet.allObjects sortedArrayUsingComparator:^(id obj1, id obj2) {
                NSUInteger n = [countedSet countForObject:obj1];
                NSUInteger m = [countedSet countForObject:obj2];
                return (n <= m)? (n < m)? NSOrderedDescending : NSOrderedSame : NSOrderedAscending;
            }];
            
            sortedFriendsEvents = [NSMutableArray arrayWithArray:sortedValues];
            
            for (PFObject *event in events) {
                if ([sortedFriendsEvents containsObject:event.objectId]) {
                    NSMutableDictionary *dict = [friendEventDict objectForKey:event.objectId];
                    [dict setObject:event forKey:@"event"];
                }
            } */
            
            [self.tableView reloadData];
        
        }
    }];

    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    /*
    if (!showTimeline) {
        
        [self loadData];
        
        if (tableViewIsUp) {
            
            CGRect tableFrame = self.tableView.frame;
            tableFrame.origin.y = 41 + 44 + 10;
            self.tableView.frame = tableFrame;
            
            CGRect segContainerFrame = self.segContainerView.frame;
            segContainerFrame.origin.y = 44 + 10;
            self.segContainerView.frame = segContainerFrame;
            
        } else {
            
            self.segContainerView.frame = CGRectMake(0, 212, 320, 55);
            self.tableView.frame = CGRectMake(0, 253, 320, 420);
        }
        
    } else {
        
        self.tableView.frame = CGRectMake(0, 253-124-41+30, 320, self.tableView.frame.size.height - 22);
        self.segContainerView.frame = CGRectMake(0, 212, 320, 55);
        
    } */

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (clearTable) return 0;
    
    if (showTimeline) return 1;
    
    if (tableVersion == 1) return self.createdSections.count;
    
    if (tableVersion == 2) {
        
        if ((!pastEventsLoaded || pastEventsArray.count == 0) && self.sections.count != 0) {
            return self.sections.count;
        } else {
            NSLog(@"%lu", self.sections.count + 1);
            return self.sections.count + 1;
        }
        
    }
    
    if (tableVersion == 3) return self.friendSections.count;
    
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableVersion == 2 && pastEventsLoaded && (section > self.sections.count-1 || self.sections.count == 0)) {
        return @"Past Events";
    }
    
    if (tableVersion == 3) {
        NSString *letterRepresentingTheseFriends = [self.sortedFriendsLetters objectAtIndex:section];
        return [letterRepresentingTheseFriends capitalizedString];
    }
    
    NSDate *eventDate = [[NSDate alloc]init];
    if (sortedDays.count != 0) {
        eventDate = [self.sortedDays objectAtIndex:section];
    }
    
    if ((section == 0 || section == 1) && ([[eventDate beginningOfDay] isEqualToDate:[[NSDate date] beginningOfDay]])) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        
        return [NSString stringWithFormat:@"TODAY, %@", dateString];
    }
    
    if ((section == 0 || section == 1) && ([[eventDate beginningOfDay] isEqualToDate:[[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]])) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(86400)]];
        
        return [NSString stringWithFormat:@"TOMORROW, %@", dateString];
    }
    
    return [self.sectionDateFormatter stringFromDate:eventDate];

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (!showTimeline) {
    
        UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] init];
        return view;
        
    } else if (tableVersion == 3) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
        [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:12.0]];
        label.textColor = [UIColor colorWithRed:0.0/255 green:176.0/255 blue:242.0/255 alpha:1.0];
        [view addSubview:label];
        [view setBackgroundColor:[UIColor whiteColor]]; //your background color...
        NSString *string = [self.sortedFriendsLetters objectAtIndex:section];
        [label setText:string];
        
        return view;
    }

    return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableVersion != 1 || showTimeline) [createButton removeFromSuperview];
    if (tableVersion != 3 || showTimeline) [noFriendsButton removeFromSuperview];
    
    if (clearTable) return 0;
    
    if (showTimeline) {
        return sortedTimelineIds.count;
    }
    
    if (tableVersion == 3) {
        NSString *letterRepresentingTheseFriends = [self.sortedFriendsLetters objectAtIndex:section];
        NSDictionary *friendsForThisLetter = [self.friendSections objectForKey:letterRepresentingTheseFriends];
        NSArray *namesArray = [friendsForThisLetter objectForKey:@"Names"];
        return namesArray.count;
    }
    
    NSDate *dateRepresentingThisDay;
    NSArray *eventsOnThisDay;
    
    if (tableVersion == 1) {
        
        dateRepresentingThisDay = [self.createdSortedDays objectAtIndex:section];
        eventsOnThisDay = [self.createdSections objectForKey:dateRepresentingThisDay];
        
    } else if (tableVersion == 2) {
        
        if (eventsArray.count == 0) return 0;
        
        if (pastEventsLoaded && (section > self.sections.count - 1 || self.sections.count == 0)) {
            
            return pastEventsArray.count;
            
        }
        
        if (!pastEventsLoaded && sortedDays.count == 0) {
            
            return 1;
            
        } else {
            
            dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
            eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        }
        
        if (!pastEventsLoaded && section == self.sections.count - 1) {
            
            return eventsOnThisDay.count + 1;
            
        } else {
            
            return [eventsOnThisDay count];
        }
    
    }
    
    return [eventsOnThisDay count];
    
}

// %%%%%% Runs through this code every time I scroll in Table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [noEventsView removeFromSuperview];
    
    NSInteger sectionsAmount = [tableView numberOfSections];
    NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
    if (tableVersion == 2 && !pastEventsLoaded && !showTimeline && [indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
        // This is the last cell in the table
        NSLog(@"Last Cell");
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"loadPast" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadPast"];
        }
        
        cell.contentView.alpha = 1.0;
        if (eventsArray.count == 0)
            cell.alpha = 0;
        
        return cell;
        
    }
    
    if (showTimeline) {
        
        TimelineCell *cell = (TimelineCell *)[tableView dequeueReusableCellWithIdentifier:@"timeline" forIndexPath:indexPath];
        
        NSDictionary *objectDict = [timelineDict objectForKey:sortedTimelineIds[indexPath.row]];
        PFObject *object = [objectDict objectForKey:@"object"];
        
        [cell formatCellForObject:object];
        
        return cell;
        
    } else if (tableVersion != 3) {
    
        AttendTableCell *cell = (AttendTableCell *)[tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];
        
        NSDate *dateRepresentingThisDay;
        NSArray *eventsOnThisDay;
        
        PFObject *Event;
        id imageOnThisDay;
        BOOL isPastEvent = NO;
        
        if (tableVersion == 1) {
            
            dateRepresentingThisDay = [self.createdSortedDays objectAtIndex:indexPath.section];
            eventsOnThisDay = [self.createdSections objectForKey:dateRepresentingThisDay];
            Event = eventsOnThisDay[indexPath.row];
            
        } else if (tableVersion == 2) {
            
            if (!pastEventsLoaded || (pastEventsLoaded && (indexPath.section <= self.sections.count - 1 && self.sections.count != 0))) {
                
                NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
                NSMutableArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
                Event = eventsOnThisDay[indexPath.row];
                
            } else {
                
                if (pastEventsArray.count > 0) {
                    if (pastEventsArray[indexPath.row] != nil) {
                        Event = pastEventsArray[indexPath.row];
                        isPastEvent = YES;
                    } else {
                        return [[UITableViewCell alloc] init];
                    }
                } else {
                    return [[UITableViewCell alloc] init];
                }
            }
            
        }
        
        cell.eventObject = Event;
        cell.eventID = Event.objectId;
        
        cell.eventObject = Event;
        
        [cell.titleLabel setText:[NSString stringWithFormat:@"%@",Event[@"Title"]]];
        
        if (Event[@"Description"])
            [cell.subtitle setText:[NSString stringWithFormat:@"%@",Event[@"Description"]]];
        else
            [cell.subtitle setText:[NSString stringWithFormat:@""]];
        
        if (Event[@"Location"])
            [cell.locLabel setText:[NSString stringWithFormat:@"at %@",Event[@"Location"]]];
        else
            [cell.locLabel setText:[NSString stringWithFormat:@""]];
        
        
        // Time formatting
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mm a"];
        
        NSDate *startDate = Event[@"Date"];
        NSDate *endDate = Event[@"EndTime"];
        
        if (isPastEvent) {
            
            [formatter setDateFormat:@"EEE, MMM d"];
            NSString *dateString = [formatter stringFromDate:startDate];
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:startDate];
            cell.timeLabel.text = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
            
        } else if ([startDate timeIntervalSinceDate:endDate] > 60*60*4 || endDate == nil) {
            
            NSString *startTimeString = [formatter stringFromDate:startDate];
            NSString *eventTimeString = [[NSString alloc]init];
            eventTimeString = [NSString stringWithFormat:@"%@", startTimeString];
            //eventTimeString = [eventTimeString stringByReplacingOccurrencesOfString:@":00" withString:@""];
            
            [cell.timeLabel setText:[NSString stringWithFormat:@"%@",eventTimeString]];
            
        } else if ([startDate compare:[NSDate date]] == NSOrderedAscending && endDate != nil) {
            
            NSString *startTimeString = [formatter stringFromDate:startDate];
            startTimeString = [NSString stringWithFormat:@"%@", startTimeString];
            startTimeString = [startTimeString stringByReplacingOccurrencesOfString:@":00" withString:@""];
            
            if ([[NSDate date] compare:endDate] == NSOrderedAscending) {
                [cell.timeLabel setText: [NSString stringWithFormat:@"Happening NOW! Started at %@", startTimeString]];
            } else {
                [cell.timeLabel setText: [NSString stringWithFormat:@"Event has ended"]];
            }
            
        } else {
            
            NSString *startTimeString = [formatter stringFromDate:startDate];
            NSString *endTimeString = [formatter stringFromDate:endDate];
            NSString *eventTimeString = [[NSString alloc]init];
            eventTimeString = [NSString stringWithFormat:@"%@", startTimeString];
            if (endTimeString) {
                eventTimeString = [NSString stringWithFormat:@"%@ to %@", eventTimeString, endTimeString];
            }
            eventTimeString = [eventTimeString stringByReplacingOccurrencesOfString:@":00" withString:@""];
            
            [cell.timeLabel setText:[NSString stringWithFormat:@"%@",eventTimeString]];
        }

        
        cell.eventImageView.image = [UIImage imageNamed:Event[@"Hashtag"]];
        
        if (Event[@"Image"] != nil) {
            // Image formatting
            PFFile *imageFile = Event[@"Image"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                if (!error) {
                    
                    cell.blurView.tintColor = [UIColor blackColor];
                    cell.blurView.alpha = 0;
                    //cell.blurView.alpha = 0;
                    cell.eventImageView.image = [UIImage imageWithData:imageData];
                    
                    CAGradientLayer *l = [CAGradientLayer layer];
                    l.frame = cell.eventImageView.bounds;
                    l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
                    
                    l.startPoint = CGPointMake(0.0, 1.00f);
                    l.endPoint = CGPointMake(0.0f, 0.6f);
                    
                    
                    
                    //cell.eventImageView.image = [cell.eventImageView.image applyLightEffect];
                }
            }];
            
        } else {
            
            // default image
        }
        
        PFGeoPoint *loc = Event[@"GeoLoc"];
        
        if (loc.latitude == 0) {
            cell.distance.text = @"";
        } else {
            PFGeoPoint *userLoc = currentUser[@"userLoc"];
            NSNumber *meters = [NSNumber numberWithDouble:([loc distanceInMilesTo:userLoc])];
            
            if (meters.floatValue >= 100.0) {
                
                NSString *distance = [NSString stringWithFormat:(@"100+ mi")];
                cell.distance.text = distance;
                
            } else if (meters.floatValue >= 10.0) {
                
                NSString *distance = [NSString stringWithFormat:(@"%.f mi"), meters.floatValue];
                cell.distance.text = distance;
                
            } else {
                
                NSString *distance = [NSString stringWithFormat:(@"%.1f mi"), meters.floatValue];
                cell.distance.text = distance;
            }
            
        }
        
        [cell.distance sizeToFit];
        
        [[cell viewWithTag:77] removeFromSuperview];
        
        UIImageView *locIMV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locationPinThickOutline"]];
        locIMV.frame = CGRectMake(290 - cell.distance.frame.size.width - 11 - 5, 38, 10.4, 13);
        locIMV.tag = 77;
        [cell.contentView addSubview:locIMV];
        
        cell.interestedLabel.text = [NSString stringWithFormat:@"%@ interested", Event[@"swipesRight"]];
        
        
        for (UIView *view in cell.subviews) {
            if (view.tag == 9) [view removeFromSuperview];
        }
        
        cell.subtitle.alpha = 1;
        cell.interestedLabel.alpha = 1;
        [cell viewWithTag:11].alpha = 1;
        
        NSDictionary *dict = [friendEventDict objectForKey:Event.objectId];
        NSArray *picArray = [dict objectForKey:@"profilePictures"];
        if (picArray.count > 0) {
            
            cell.subtitle.alpha = 0;
            cell.interestedLabel.alpha = 0;
            [cell viewWithTag:11].alpha = 0;
            
            for (ProfilePictureView *ppView in picArray) {
                
                [ppView removeFromSuperview];
                [cell addSubview:ppView];
            }
        }
        
        return cell;
    
    } else if (tableVersion == 3) {
        
        inviteHomiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homies" forIndexPath:indexPath];
        cell.indexPath = indexPath;
        //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(friendProfileTap:)];
        
        //[cell addGestureRecognizer:tap];
        
        NSString *letterRepresentingTheseFriends = [self.sortedFriendsLetters objectAtIndex:indexPath.section];
        NSDictionary *friendsForThisLetter = [self.friendSections objectForKey:letterRepresentingTheseFriends];
        NSArray *namesArray = [friendsForThisLetter objectForKey:@"Names"];
        NSArray *parseIds = [friendsForThisLetter objectForKey:@"parseIds"];
        NSArray *imagesArray = [friendsForThisLetter objectForKey:@"Images"];
        
        cell.nameLabel.text = namesArray[indexPath.row];
        
        for (UIView *view in cell.subviews) {
            if (view.tag == 66) {
                [view removeFromSuperview];
            }
        }
        
        NSLog(@"%@", imagesArray[indexPath.row]);
        
        [cell addSubview:imagesArray[indexPath.row]];
        
        [[cell viewWithTag:234] removeFromSuperview];
        
        cell.parseId = parseIds[indexPath.row];
        
        /*
         if ([bestFriendsIds containsObject:idsArray[indexPath.row]]) {
         
         UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20 + 10, 0 + 5, 10, 10)];
         starImageView.image = [UIImage imageNamed:@"star-blue-bordered"];
         starImageView.tag = 234;
         [cell addSubview:starImageView];
         } */
        
        return cell;
        
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (showTimeline) return 46;
    if (tableVersion == 3) return 55;
    
    if (!pastEventsLoaded && tableVersion == 2 && sortedDays.count == 0) {
        return 70;
    }

    if (!pastEventsLoaded && tableVersion == 2) {
        NSInteger sectionsAmount = self.sections.count;
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
        NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        NSInteger rowsAmount = eventsOnThisDay.count;
        if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount) {
            
            return 70;
        }
    }

    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    if (showTimeline || eventsArray.count == 0) return 0;
    if (!pastEventsLoaded && tableVersion == 2 && sortedDays.count == 0) return 0;
    
    return 22;
}

- (IBAction)refreshTable:(id)sender {
    
    
    NSLog(@"Refreshing data...");
    [sender endRefreshing];
    [self.tableView reloadData];
    NSLog(@"Data refreshed!");
}


- (void)refreshMyEvents {
    
    NSLog(@"refreshing events....");
    
    self.segControl.selectedSegmentIndex = 0;
    [self loadData];
}

- (void)friendProfileTap:(inviteHomiesCell *)cell {
    
    NSLog(@"REMEMBER FSINVS:KJNV:SJN");
    [self performSegueWithIdentifier:@"toProf" sender:self];
    
}

- (void)noEvents {
    
    NSLog(@"No events");
    //[self.tableView reloadData];
    
    if (!noEventsView) {
    
        //noEventsView = [[UIView alloc] initWithFrame: CGRectMake(0, 430, self.view.frame.size.width, 200)];
        noEventsView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 519-66-202)];
        
        UILabel *bottomTextLabel = [[UILabel alloc] init];
        bottomTextLabel.text = @"You haven't saved any events.";
        bottomTextLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
        bottomTextLabel.textColor = [UIColor colorWithRed:153.0/255 green:154.0/255 blue:155.0/255 alpha:1.0];
        [bottomTextLabel sizeToFit];
        bottomTextLabel.center = CGPointMake(self.view.center.x, 30);
        [noEventsView addSubview:bottomTextLabel];
        
        
        UIButton *createEventButton = [[UIButton alloc] initWithFrame:CGRectMake(95.2, 130, 129.6, 40)];
        [createEventButton setImage:[UIImage imageNamed:@"discoverButton"] forState:UIControlStateNormal];
        [createEventButton setImage:[UIImage imageNamed:@"discover pressed"] forState:UIControlStateHighlighted];
        [createEventButton addTarget:self action:@selector(discoverButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        //[noEventsView addSubview:createEventButton];
        
        
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(135, 70, 150, 150)];
        imv.center = CGPointMake(self.view.center.x, noEventsView.frame.size.height / 2 + 8);
        imv.image = [UIImage imageNamed:@"right swipe"];
        [noEventsView addSubview:imv];
        
        UILabel *lastLabel = [[UILabel alloc] init];
        lastLabel.text = @"Swipe right to save an event";
        lastLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:14.0];
        lastLabel.textColor = [UIColor colorWithRed:153.0/255 green:154.0/255 blue:155.0/255 alpha:1.0];
        [lastLabel sizeToFit];
        lastLabel.center = CGPointMake(self.view.center.x, noEventsView.frame.size.height - 20);
        [noEventsView addSubview:lastLabel];
        
    }
    
    [self.tableView addSubview:noEventsView];
}

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    // Use the user's current calendar and time zone
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timeZone];
    
    // Selectively convert the date components (year, month, day) of the input date
    NSDateComponents *dateComps = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:inputDate];
    
    // Set the time components manually
    [dateComps setHour:0];
    [dateComps setMinute:0];
    [dateComps setSecond:0];
    
    // Convert back
    NSDate *beginningOfDay = [calendar dateFromComponents:dateComps];
    return beginningOfDay;
}

- (IBAction)plusButtonTapped:(id)sender {
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        NSLog(@" ====== iOS 7 ====== ");
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"You must have iOS 8 to create an event for now. Sorry!!" delegate:self cancelButtonTitle:@"Bummer" otherButtonTitles:nil, nil];
        [alert show];
        
    } else {
        
        [self performSegueWithIdentifier:@"createNewEvent" sender:self];
        
    }
    
}

- (void)createEventButtonTapped {
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        
        NSLog(@" ====== iOS 7 ====== ");
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops" message:@"You must have iOS 8 to create an event for now. Sorry!!" delegate:self cancelButtonTitle:@"Bummer" otherButtonTitles:nil, nil];
        [alert show];

    } else {
        
        [self performSegueWithIdentifier:@"createNewEvent" sender:self];
        
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger sectionsAmount = [tableView numberOfSections];
    NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
    if (tableVersion == 2 && !pastEventsLoaded && !showTimeline && [indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
        
        [self loadPastEvents];
        
    } else if (!showTimeline && tableVersion != 3) {
        
        [self performSegueWithIdentifier:@"toExpandedView" sender:self];
    }
    
}

- (void)loadTimeline {
    
    PFQuery *timelineQuery = [PFQuery queryWithClassName:@"Timeline"];
    [timelineQuery whereKey:@"userId" equalTo:currentUser.objectId];
    [timelineQuery addAscendingOrder:@"createdDate"];
    [timelineQuery fromLocalDatastore];
    timelineQuery.limit = 1000;
    [timelineQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            for (PFObject *object in objects) {
                
                if ([timelineDict objectForKey:object.objectId] == nil) { // object doesn't exist
                
                    if (object.objectId != nil) {
                        [object pinInBackground];
                        [sortedTimelineIds insertObject:object.objectId atIndex:0];
                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                        [timelineDict setObject:dict forKey:object.objectId];
                        [dict setObject:object forKey:@"object"];
                    } else {
                        [object unpinInBackground];
                    }
                    
                }
            }
            
            scoreLabel.text = [currentUser[@"score"] stringValue];
            [self.tableView reloadData];
            
        } else {
            
            NSLog(@"%@", error);
        }
        
        
    }];

    
}

- (IBAction)scoreButtonPressed:(UIButton *)sender {
    
    // if tag = 1, showing number. tag = 2, showing X
    
    if (sender.tag == 1) {
        
        sender.alpha = 0;
        settingsButton.alpha = 0;
        xButton.alpha = 1.0;
        [scoreButton setTitle:[NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]] forState:UIControlStateNormal];
        scoreLabel.text = [NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]];
        showTimeline = YES;
    
    } else {
        
        sender.alpha = 0;
        scoreButton.alpha = 1.0;
        settingsButton.alpha = 1.0;
        [scoreButton setTitle:[NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]] forState:UIControlStateNormal];
        scoreLabel.text = [NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]];
        showTimeline = NO;

    }
    
    [self switchTableViewToScore:showTimeline];
    
}

- (void)switchTableViewToScore:(BOOL)toScore {
    
    clearTable = YES;
    [self.tableView reloadData];
    clearTable = NO;
    
    isAnimatingScoreButton = YES;
    self.scoreButton.enabled = NO;
    xButton.enabled = NO;
    
    if (toScore) {
        
        nameLabel.alpha = 1.0;
        detailLabel.alpha = 1.0;
        blurView.alpha = 0;
        self.segContainerView.alpha = 0;
        
        [self loadTimeline];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
            //self.tableView.contentOffset = CGPointMake(0, -300);
            self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y + 300, 320, self.tableView.frame.size.height);
            
            // Set the scale to the imageView
            self.profPicView.frame = CGRectMake(-105, -64, 530, 530);
            blurView.frame = CGRectMake(-105, -64, 530, 530);
            maskLayer.frame = CGRectMake(0, 0, 530, 530);
            nameLabel.alpha = 0;
            detailLabel.alpha = 0;
            
            //float scale = 1.0f - 5.0f * (fabs(-scrollView.contentOffset.y)  / scrollView.frame.size.height);
            //Cap the scaling between zero and 1
            //scale = (1 - MAX(0.0f, scale));
            
        } completion:^(BOOL finished){
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
                
                self.profPicView.frame = CGRectMake(0, -64, 320, 320);
                scoreLabel.alpha = 1.0;
                leaderboardButton.alpha = 1.0;
                blurView.alpha = 1.0;
                self.tableView.contentOffset = CGPointMake(0, 0);
                self.tableView.frame = CGRectMake(0, 18+41, 320, self.tableView.frame.size.height - 18);
                navBarLabel.alpha = 1.0;
                //blurView.frame = CGRectMake(0, 0, 320, 320);
                //maskLayer.frame = CGRectMake(0, 0, 320, 320);
                self.segContainerView.frame = CGRectMake(0, 154, 320, self.segContainerView.frame.size.height);
                
            } completion:^(BOOL finished){
                
                blurView.dynamic = NO;
                isAnimatingScoreButton = NO;
                blurView.dynamic = YES;
                self.scoreButton.enabled = YES;
                xButton.enabled = YES;

            }];
            
        }];
        
    } else {
        
        switch (tableVersion) {
            case 1: { // created by me
                [self loadCreatedEvents];
                break;
            }
            case 2: { // my events
                [self loadData];
                break;
            }
            case 3: { // friends
                [self loadFriends];
                break;
            }
            default: {
                [self loadData];
                break;
            }
        }
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
            self.tableView.contentOffset = CGPointMake(0, -200);
            self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y + 300, 320, self.tableView.frame.size.height);
            scoreLabel.alpha = 0;
            leaderboardButton.alpha = 0.0;
            navBarLabel.alpha = 0;
            
        } completion:^(BOOL finished){
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
                
                self.segContainerView.alpha = 1.0;
                nameLabel.alpha = 1;
                detailLabel.alpha = 1;
                blurView.alpha = 0;
                self.tableView.contentOffset = CGPointMake(0, 0);
                self.tableView.frame = CGRectMake(0, 157+41, 320, self.tableView.frame.size.height + 18);
                
            } completion:^(BOOL finished){
                
                isAnimatingScoreButton = NO;
                blurView.dynamic = YES;
                self.scoreButton.enabled = YES;
                xButton.enabled = YES;
            }];
            
        }];
        
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat y = -scrollView.contentOffset.y;
    //NSLog(@"%f", y);
    
    if (tableVersion == 2 && ([scrollView contentOffset].y + scrollView.frame.size.height - 60) >= [scrollView contentSize].height){
        
        // Get new record from here
        if (!pastEventsLoaded) {
            NSLog(@"&& MADE IT");
            [self loadPastEvents];
            
        }
        
    }
    
    if (!isAnimatingScoreButton && !showTimeline) {
    
        if (y >= 0) { // $$$$$$$$$ Scrolling down $$$$$$$$$$
            
            /* self.tableView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y);
            self.segContainerView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y); */
            
            if (tableViewIsUp && y > 20) {
                
                tableViewIsUp = NO;
                
                [UIView animateWithDuration:0.4 animations:^{
                    
                    self.segContainerView.frame = CGRectMake(0, 154, 320, self.segContainerView.frame.size.height);
                    self.tableView.frame = CGRectMake(0, 157+41, 320, 420);
                    
                    blurView.alpha = 0.0;
                    nameLabel.alpha = 1.0;
                    detailLabel.alpha = 1.0;
                    navBarLabel.alpha = 0.0;

                } completion:^(BOOL finished) {
                    
                }];
                    
                
            } else if (!tableViewIsUp) {  // %%%%%%%%%%%%%%%%% AUTO SCROLL
                
                self.tableView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y);
                self.segContainerView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y);
            }
            
            float scale = 1.0f + fabs(scrollView.contentOffset.y)  / scrollView.frame.size.height;
            
            float alphaScale = 1.0f - 5.0f * (fabs(scrollView.contentOffset.y)  / scrollView.frame.size.height);
            
            self.nameLabel.alpha = alphaScale;
            self.detailLabel.alpha = alphaScale;
            //navBarLabel.alpha = 1 - alphaScale;
            //maskLayer.opacity = alphaScale * 2;

            //Cap the scaling between zero and 1
            scale = MAX(0.0f, scale);
            
            // Set the scale to the imageView
            self.profPicView.transform = CGAffineTransformMakeScale(scale, scale);
            
        } else if (y < 0) {  // $$$$$$$$$$$ Scrolling up $$$$$$$$$$$
            
            /*
            if (self.tableView.frame.origin.y >= 253) {
                self.tableView.transform = CGAffineTransformMakeTranslation(0, -y);
                self.segContainerView.transform = CGAffineTransformMakeTranslation(0, -y);
            }*/
            
            /*
            float scale = 1.0f - 5.0f * (fabs(-scrollView.contentOffset.y)  / scrollView.frame.size.height);
            scale = (1 - MAX(0.0f, scale));
            blurView.alpha = scale * 2;
            nameLabel.alpha = 1 - scale * 3;
            detailLabel.alpha = 1 - scale * 3;
            if (y < -50) {
                float scale2 = (fabs(y + 50) / scrollView.frame.size.height) * 14;
                navBarLabel.alpha = scale2;
            } else {
                navBarLabel.alpha = 0;
            } */
                
             /*
            if (y >= (-209 + 41 + 10) / 2 && 222 > 3) { // -79
                self.tableView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y * 2);
                self.segContainerView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y * 2);
            } else {
                [UIView animateWithDuration:0.1 animations:^{
                    CGRect tableFrame = self.tableView.frame;
                    tableFrame.origin.y = 0;
                    self.tableView.frame = tableFrame;
                    
                    CGRect segContainerFrame = self.segContainerView.frame;
                    segContainerFrame.origin.y = 0;
                    self.segContainerView.frame = segContainerFrame;
                }];
            }*/

            tableViewIsUp = YES;
            
            [UIView animateWithDuration:0.4 animations:^{ // %%%%%%%%%%% AUTO SCROLL %%%%%%%%%%%
                
                CGRect tableFrame = self.tableView.frame;
                tableFrame.origin.y = 0+41; //10;
                self.tableView.frame = tableFrame;
                
                CGRect segContainerFrame = self.segContainerView.frame;
                segContainerFrame.origin.y = 0; //10 + 44;
                self.segContainerView.frame = segContainerFrame;
                
                blurView.alpha = 1.0;
                nameLabel.alpha = 0.0;
                detailLabel.alpha = 0.0;
                navBarLabel.alpha = 1.0;

            } completion:^(BOOL finished) {
                
            }];
                
            
        }
        
        
        //score button
    } else if (isAnimatingScoreButton) {
        
        if (y > 0) {

        } else if (y < 0) {
            
            //profPicView.frame = CGRectMake(0, -64, 320, 320);
            nameLabel.alpha = 1.0;
            detailLabel.alpha = 1.0;
            
            float scale = 1.0f - 5.0f * (fabs(-scrollView.contentOffset.y)  / scrollView.frame.size.height);
            //Cap the scaling between zero and 1
            scale = (1 - MAX(0.0f, scale));
            //blurView.alpha = scale;

        } else {
            

        }
    
    }
}

- (void)loadPastEvents {
    
    pastEventsLoaded = YES;
    
    PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    [swipesQuery whereKey:@"UserID" equalTo:currentUser.objectId];
    [swipesQuery whereKey:@"swipedRight" equalTo:@YES];
    //[swipesQuery fromLocalDatastore];
    swipesQuery.limit = 1000;
    
    PFQuery *pastEventQuery = [PFQuery queryWithClassName:@"Event"];
    [pastEventQuery whereKey:@"objectId" matchesKey:@"EventID" inQuery:swipesQuery];
    [pastEventQuery whereKey:@"Date" lessThan:[[NSDate date] beginningOfDay]];
    [pastEventQuery addDescendingOrder:@"Date"];
    
    [pastEventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error){
        
        if (!error) {
            
            for (int i = 0; i < events.count; i++) {
                
                PFObject *event = events[i];
                eventsArray = [eventsArray arrayByAddingObjectsFromArray:events];
                
                /*
                NSMutableDictionary *dict = [self.sections objectForKey:event.objectId];
                if ([dict objectForKey:@"Image"] == nil) {
                    if (event[@"Image"] != nil) [dict setObject:event[@"Image"] forKey:@"Image"];
                    else [dict setObject:[UIImage imageNamed:event[@"Hashtag"]] forKey:@"Image"];
                } */
                
                if (![pastEventsArray containsObject:event]) {
                    [pastEventsArray addObject:event];
                }
                
            }
            
            pastEventsLoaded = YES;
            
            if (eventsArray.count == 0) {
                
                [self noEvents];
                
            } else {
                
                NSLog(@"reloading data...");
                [self.tableView reloadData];
                [self loadSwipes];
            }
            
            //[self.tableView beginUpdates];
            //[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithArray:indexPaths] withRowAnimation:UITableViewRowAnimationNone];
            //[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            
            //[self.tableView endUpdates];
        }
    }];
    
}

- (void)loadCreatedEvents {
    
    tableVersion = 1;
    
    currentUser = [PFUser currentUser];
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    //[eventQuery fromLocalDatastore];
    [eventQuery whereKey:@"CreatedBy" equalTo:currentUser.objectId];
    [eventQuery orderByDescending:@"Date"];
    eventQuery.limit = 1000;
    
    if (!createdEventsArray)
        createdEventsArray = [NSArray new];
    
    BOOL firstTime = NO;
    
    clearTable = YES;
    [self.tableView reloadData];
    clearTable = NO;
    
    if (!self.createdSections) {
        self.createdSections = [NSMutableDictionary dictionary];
        firstTime = YES;
    } else {
        [self.tableView reloadData];
    }
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        
        if (!error) {
            
            createdEventsArray = events;
            
            BOOL didChange = NO;
            
            for (PFObject *event in events) {
                
                // Reduce event start date to date components (year, month, day)
                NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:event[@"Date"]];
                if ([dateRepresentingThisDay compare:[NSDate date]] == NSOrderedAscending) {
                    dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:[NSDate date]];
                }
                
                // If we don't yet have an array to hold the events for this day, create one
                NSMutableArray *eventsOnThisDay = [self.createdSections objectForKey:dateRepresentingThisDay];
                if (eventsOnThisDay == nil) {
                    eventsOnThisDay = [NSMutableArray array];
                    
                    // Use the reduced date as dictionary key to later retrieve the event list this day
                    [self.createdSections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
                }
                
                // Add the event to the list for this day
                if (![eventsOnThisDay containsObject:event]) {
                    didChange = YES;
                    [eventsOnThisDay addObject:event];
                }
                
            }
            
            // Create a sorted list of days
            NSArray *unsortedDays = [self.createdSections allKeys];
            self.createdSortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
            
            
            [noEventsView removeFromSuperview];
            
            
            if (createdEventsArray.count == 0) {
                
                if (!createButton) {
                
                    createButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 100, 200, 50)];
                    [createButton setTitle:@"CREATE A HAPPENING" forState:UIControlStateNormal];
                    [createButton setTitleColor:[UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0] forState:UIControlStateNormal];
                    createButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
                    createButton.layer.cornerRadius = 5.0;
                    createButton.clipsToBounds = YES;
                    createButton.layer.borderColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
                    createButton.layer.borderWidth = 2.0;
                    [createButton addTarget:self action:@selector(toCreateHappening) forControlEvents:UIControlEventTouchUpInside];
                }
                [self.tableView addSubview:createButton];
                
            } else {
                
                [self.tableView reloadData];
                [self loadSwipes];
            }
            
            
            
        } else {
            
            NSLog(@"error: %@", error);
        }
    }];

    
}

- (void)toCreateHappening {
    
    AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [ad.mh createButtonPressed];
    
}


- (void)loadFriends {
    
    tableVersion = 3;
    
    self.friendSections = [[NSMutableDictionary alloc] init];
    self.sortedFriends = [NSArray array];
    self.sortedFriendsLetters = [NSArray array];

    //indexTitles = [[NSArray alloc] init];
    //indexTitles = @[@"\u263A", @"√", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];

    
    NSArray *friends = [PFUser currentUser][@"friends"];
    
    NSMutableArray *names = [[NSMutableArray alloc] init];
    NSMutableArray *friendObjectIDs = [[NSMutableArray alloc] init];
    NSMutableArray *parseIds = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in friends) {
        [friendObjectIDs addObject:[dict objectForKey:@"id"]];
        [names addObject:[dict objectForKey:@"name"]];
        [parseIds addObject:[dict objectForKey:@"parseId"]];
    }
    
    NSMutableArray *p = [NSMutableArray arrayWithCapacity:names.count];
    for (NSUInteger i = 0 ; i != names.count ; i++) {
        [p addObject:[NSNumber numberWithInteger:i]];
    }
    [p sortWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
        // Modify this to use [first objectAtIndex:[obj1 intValue]].name property
        NSString *lhs = [names objectAtIndex:[obj1 intValue]];
        // Same goes for the next line: use the name
        NSString *rhs = [names objectAtIndex:[obj2 intValue]];
        return [lhs compare:rhs];
    }];
    NSMutableArray *sortedFirst = [NSMutableArray arrayWithCapacity:names.count];
    NSMutableArray *sortedSecond = [NSMutableArray arrayWithCapacity:friendObjectIDs.count];
    NSMutableArray *sortedThird = [NSMutableArray arrayWithCapacity:parseIds.count];
    [p enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger pos = [obj intValue];
        [sortedFirst addObject:[names objectAtIndex:pos]];
        [sortedSecond addObject:[friendObjectIDs objectAtIndex:pos]];
        [sortedThird addObject:[parseIds objectAtIndex:pos]];
    }];
    
    names = sortedFirst;
    friendObjectIDs = sortedSecond;
    parseIds = sortedThird;
    
    NSLog(@"friend ids: %@", friendObjectIDs);
    
    self.sortedFriends = [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (int i = 0; i < names.count; i++) {
        
        NSString *letter = [[names objectAtIndex: i] substringToIndex:1];
        NSMutableDictionary *letterDict = [self.friendSections objectForKey:letter];
        if (letterDict == nil) {
            letterDict = [NSMutableDictionary dictionary];
        }
        
        [self.friendSections setObject:letterDict forKey:letter];
        
        
        NSMutableArray *namesArray = [letterDict objectForKey:@"Names"];
        if (namesArray == nil) {
            namesArray = [NSMutableArray array];
        }
        
        [letterDict setObject:namesArray forKey:@"Names"];
        [namesArray addObject:names[i]];
        
        
        NSMutableArray *idsArray = [letterDict objectForKey:@"IDs"];
        if (idsArray == nil) {
            idsArray = [NSMutableArray array];
        }
        [letterDict setObject:idsArray forKey:@"IDs"];
        [idsArray addObject:friendObjectIDs[i]];
        
        NSMutableArray *parseIdsArray = [letterDict objectForKey:@"parseIds"];
        if (parseIdsArray == nil) {
            parseIdsArray = [NSMutableArray array];
        }
        [letterDict setObject:parseIdsArray forKey:@"parseIds"];
        [parseIdsArray addObject:parseIds[i]];
        
        
        NSMutableArray *imagesArray = [letterDict objectForKey:@"Images"];
        if (imagesArray == nil) {
            imagesArray = [NSMutableArray array];
        }
        [letterDict setObject:imagesArray forKey:@"Images"];
        FBSDKProfilePictureView *pp = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10, 7.5, 40, 40)];
        pp.layer.cornerRadius = 20;
        pp.layer.masksToBounds = YES;
        pp.profileID = friendObjectIDs[i];
        pp.tag = 66;
        [imagesArray addObject:pp];
        
        
        NSMutableArray *tappedArray = [letterDict objectForKey:@"Tapped"];
        if (tappedArray == nil) {
            tappedArray = [NSMutableArray array];
        }
        
        [letterDict setObject:tappedArray forKey:@"Tapped"];
        NSNumber *no = [NSNumber numberWithInt:0];
        [tappedArray addObject:no];
        
    }
    
    NSArray *unsortedFriendsLetters = [self.friendSections allKeys];
    self.sortedFriendsLetters = [unsortedFriendsLetters sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [self.tableView reloadData];
    
    if (friends.count == 0) {
        
        if (!noFriendsButton) {
            
            noFriendsButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 100, 180, 50)];
            [noFriendsButton setTitle:@"INVITE FRIENDS" forState:UIControlStateNormal];
            [noFriendsButton setTitleColor:[UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0] forState:UIControlStateNormal];
            noFriendsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
            noFriendsButton.layer.cornerRadius = 5.0;
            noFriendsButton.clipsToBounds = YES;
            noFriendsButton.layer.borderColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
            noFriendsButton.layer.borderWidth = 2.0;
            [noFriendsButton addTarget:self action:@selector(inviteFriends) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.tableView addSubview:noFriendsButton];
    }
    
}

- (void)inviteFriends {
    
    UIActivityItemProvider *ActivityProvider = [[UIActivityItemProvider alloc] init];
    
    NSURL *myWebsite = [NSURL URLWithString:@"http://hap.ng/app"];
    NSString *shareText = [NSString stringWithFormat:@"Check out this new app called Happening. It's a really easy way to find cool events to go to with friends! "];
    
    NSArray *itemsToShare = @[shareText, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:itemsToShare applicationActivities:nil];
    
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

- (IBAction)tabButtonTapped:(UIButton *)sender {
    
    if (sender.tag != tableVersion) {
    
        [sender setTitleColor:[UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/2555 alpha:1.0] forState:UIControlStateNormal];
        UILabel *tappedLabel = self.tabLabels[sender.tag - 1];
        tappedLabel.textColor = [UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/2555 alpha:1.0];
        
        for (int i = 0; i < self.tabButtons.count; i++) {
            
            UIButton *button = self.tabButtons[i];
            if (button.tag != sender.tag) {
                
                [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                UILabel *label = self.tabLabels[button.tag - 1];
                label.textColor = [UIColor lightGrayColor];
            }

        }
        
        switch (sender.tag) {
            case 1: { // created by me
                
                NSLog(@"Load Created Events");
                [self loadCreatedEvents];
                
                break;
            }
            case 2: { // my events
                
                NSLog(@"Load Saved Events");
                [self loadData];
                
                break;
            }
            case 3: { // friends
                
                NSLog(@"Load Friends");
                [self loadFriends];
                
                break;
            }
                
            default:
                break;
        }
    
    }
    
}

- (void)didChangeRSVPforEvent:(PFObject *)object type:(NSString *)type {
    
    NSLog(@"rsvps changed");
    eventsArray = nil;
    self.sections = nil;
    self.sortedDays = nil;
    friendEventDict = nil;
    [self loadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showMyEvent"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        AttendTableCell *cell = (AttendTableCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath];
        
        UINavigationController *navController = [segue destinationViewController];
        showMyEventVC *vc = (showMyEventVC *)([navController topViewController]);
        vc.eventID = cell.eventID;
        
        vc.profileVC = self;
        
    } else if ([segue.identifier isEqualToString:@"createNewEvent"]) {
        
        UINavigationController *navController = [segue destinationViewController];
        EventTVC *vc = (EventTVC *)([navController topViewController]);
        vc.delegate = self;
        
        vc.profileVC = self;
        
    } else if ([segue.identifier isEqualToString:@"toProfileSettings"]) {
        
        UINavigationController *navController = [segue destinationViewController];
        ProfileSettingsTVC *vc = (ProfileSettingsTVC *)([navController topViewController]);
        
        vc.profileVC = self;
        
    } else if ([segue.identifier isEqualToString:@"toExpandedView"]) {
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        AttendTableCell *cell = (AttendTableCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath];
        
        ExpandedCardVC *vc = (ExpandedCardVC *)[segue destinationViewController];
        vc.delegate = self;
        vc.event = cell.eventObject;
        vc.image = cell.eventImageView.image;
        vc.eventID = cell.eventID;
        vc.distanceString = cell.distance.text;
        
        [vc.navigationController setNavigationBarHidden:NO animated:YES];
        
    } else if ([segue.identifier isEqualToString:@"toProf"]) {
        
        NSIndexPath *ip = [self.tableView indexPathForSelectedRow];
        inviteHomiesCell *cell = (inviteHomiesCell *)[self.tableView cellForRowAtIndexPath:ip];
        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.userID = cell.parseId;
        NSLog(@"++++ %@", cell.parseId);
    }
    
}

@end
