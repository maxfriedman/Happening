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
#import "TimelineCell.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface ProfileTVC () <EventTVCDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) FBSDKProfilePictureView *profPicView;

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

@end

@implementation ProfileTVC {
    
    PFUser *currentUser;
    UIView *noEventsView;
    NSArray *eventsArray;
    
    CAGradientLayer *maskLayer;
    
    BOOL showUpcomingEvents;
    FXBlurView *blurView;
    int tableVersion;
    BOOL showTimeline;
    BOOL isAnimatingScoreButton;
    
    UILabel *scoreLabel;
    
    NSMutableArray *sortedTimelineIds;
    NSMutableDictionary *timelineDict;
    NSMutableDictionary *friendEventDict;
    
    UILabel *navBarLabel;
    
    UIButton *xButton;
    
    int totalEventCount;
    
    BOOL tableViewIsUp;

}

//@synthesize locManager, refreshControl;
@synthesize sections, sortedDays, locManager;
@synthesize nameLabel, detailLabel, profilePicImageView, settingsButton, containerView, profPicView, scoreButton;

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
    
    self.tableView.delaysContentTouches = NO;
    self.tableView.canCancelContentTouches = YES;
    
    profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, -64, 320, 320)];
    
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

    
    noEventsView = [[UIView alloc] initWithFrame: CGRectMake(0, 430, self.view.frame.size.width, 200)];
    [self.view addSubview:noEventsView];
    
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
    
    scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 100)];
    scoreLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:50.0];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.text = [currentUser[@"score"] stringValue];
    scoreLabel.alpha = 0;
    [containerView addSubview:scoreLabel];
    
    tableVersion = 1;
    
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
    totalEventCount = 0;
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE, MMMM d"];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.sections = [NSMutableDictionary dictionary];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (!showTimeline) {
        
        [self loadData];
        /*
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
        }*/
        
    } else {
        /*
        self.tableView.frame = CGRectMake(0, 253-124-41+30, 320, self.tableView.frame.size.height - 22);
        self.segContainerView.frame = CGRectMake(0, 212, 320, 55);
        */
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    //[self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)loadData {
    
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
    
    eventsArray = [NSArray new];
    
    totalEventCount = 0;
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        
        if (!error) {
            
            eventsArray = events;
            totalEventCount ++;
            
            BOOL didChange = NO;
        
            for (PFObject *event in events) {
                
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
            
            
            [noEventsView removeFromSuperview];
            
            
            if (didChange) {
                [self loadSwipes];
            }
            
            [self.tableView reloadData];
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
            [self noEvents];
        }
    }];
    
}

- (void)loadSwipes {
    
    NSArray *friends = currentUser[@"friends"];
    NSMutableArray *friendIds = [NSMutableArray array];
    for (NSDictionary *dict in friends) {
        [friendIds addObject:[dict objectForKey:@"parseId"]];
    }
    
    NSMutableArray *eventIds = [NSMutableArray array];
    for (PFObject *event in eventsArray) {
        [eventIds addObject:event.objectId];
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
            
            friendEventDict = [NSMutableDictionary dictionary];
            
            for (PFObject *swipe in swipes) {
                
                NSLog(@"%@", swipe[@"username"]);
                NSLog(@"%@", swipe[@"EventID"]);
                
                NSMutableDictionary *dict = [friendEventDict objectForKey:swipe[@"EventID"]];
                if (dict == nil) {
                    dict = [NSMutableDictionary dictionary];
                    [friendEventDict setObject:dict forKey:swipe[@"EventID"]];
                    [dict setObject:[NSMutableArray arrayWithObject:swipe[@"FBObjectID"]] forKey:@"fbids"];
                    
                    FBSDKProfilePictureView *ppview = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(30 + 50 * 0, 93, 40, 40)];
                    ppview.profileID = swipe[@"FBObjectID"];
                    ppview.clipsToBounds = YES;
                    ppview.layer.cornerRadius = 40/2;
                    ppview.tag = 9;
                    
                    [dict setObject:[NSMutableArray arrayWithObject:ppview] forKey:@"profilePictures"];
                    
                } else {
                    
                    NSMutableArray *array = [dict objectForKey:@"fbids"];
                    [array addObject:swipe[@"FBObjectID"]];
                    
                    NSMutableArray *picArray = [dict objectForKey:@"profilePictures"];
                    if (picArray.count < 5) {
                        FBSDKProfilePictureView *ppview = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(30 + 50 * picArray.count, 93, 40, 40)];
                        ppview.profileID = swipe[@"FBObjectID"];
                        ppview.clipsToBounds = YES;
                        ppview.layer.cornerRadius = 40/2;
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
            
            NSLog(@"%@",friendEventDict);
            
            [self.tableView reloadData];
            /*if (tableViewIsUp) {
                self.segContainerView.frame = CGRectMake(0, 212, 320, 55);
                self.tableView.frame = CGRectMake(0, 253, 320, 420);
                navBarLabel.alpha = 0;
                blurView.alpha = 0;
                nameLabel.alpha = 1;
                detailLabel.alpha = 1;
                tableViewIsUp = NO;
            }*/

        
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
    
    if (showTimeline) return 1;
    
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDate *eventDate = [[NSDate alloc]init];
    eventDate = [self.sortedDays objectAtIndex:section];
    
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
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    //view.tintColor = [UIColor blackColor]
    if (!showTimeline) {
        
        // Text Color
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        [header.textLabel setTextColor:[UIColor darkTextColor]];
        [header.textLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:14]];
        
        // For some reason the the sub label was being added to every header---> this removes it.
        for (UIView *view in header.contentView.subviews) {
            
            if (view.tag == 99)
                [view removeFromSuperview];
        }
        
        if ([header.textLabel.text isEqualToString:@"TODAY"]) {
            
            UILabel *subDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 16, 100, 20)];
            subDateLabel.textColor = [UIColor darkTextColor];
            subDateLabel.font = [UIFont fontWithName:@"OpenSans" size:9];
            subDateLabel.tag = 99;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            subDateLabel.text = dateString;
            
            [header.contentView addSubview:subDateLabel];
        
        } else if ([header.textLabel.text isEqualToString:@"TOMORROW"] && section == 0) {
            
            UILabel *subDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(107, 16, 100, 20)];
            subDateLabel.textColor = [UIColor darkTextColor];
            subDateLabel.font = [UIFont fontWithName:@"OpenSans" size:9];
            subDateLabel.tag = 99;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(86400)]];
            subDateLabel.text = dateString;
            
            [header.contentView addSubview:subDateLabel];
            
        } else if ([header.textLabel.text isEqualToString:@"TOMORROW"] && section == 1) {
            
            UILabel *subDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(107, 0, 100, 17)];
            subDateLabel.textColor = [UIColor darkTextColor];
            subDateLabel.font = [UIFont fontWithName:@"OpenSans" size:9];
            subDateLabel.tag = 99;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(86400)]];
            subDateLabel.text = dateString;
            
            [header.contentView addSubview:subDateLabel];
        }
        
    }
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (showTimeline) {
        return sortedTimelineIds.count;
    }
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    
    /*
    if (totalEventCount < 4 && section + 1 == sections.count) {
        
        int extraFakeEvents = 4 - totalEventCount + (int)eventsOnThisDay.count;
        NSLog(@"Adding %d events, %d are real", extraFakeEvents, (int)eventsOnThisDay.count);
        return extraFakeEvents;
    } */
    
    return [eventsOnThisDay count];
    
}

// %%%%%% Runs through this code every time I scroll in Table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (showTimeline) {
        
        TimelineCell *cell = (TimelineCell *)[tableView dequeueReusableCellWithIdentifier:@"timeline" forIndexPath:indexPath];
        
        NSDictionary *objectDict = [timelineDict objectForKey:sortedTimelineIds[indexPath.row]];
        PFObject *object = [objectDict objectForKey:@"object"];
        
        [cell formatCellForObject:object];
        
        return cell;
        
    } else {
    
        AttendTableCell *cell = (AttendTableCell *)[tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];
        
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
        NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        
        if (indexPath.row < eventsOnThisDay.count) {
        
            cell.contentView.alpha = 1.0;
            
            PFObject *Event = eventsOnThisDay[indexPath.row];
            
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
            
            cell.eventID = Event.objectId;
            
            // Time formatting
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"h:mm a"];
            
            NSDate *startDate = Event[@"Date"];
            NSDate *endDate = Event[@"EndTime"];
            
            if ([startDate timeIntervalSinceDate:endDate] > 60*60*4 || endDate == nil) {
              
                NSString *startTimeString = [formatter stringFromDate:startDate];
                NSString *eventTimeString = [[NSString alloc]init];
                eventTimeString = [NSString stringWithFormat:@"%@", startTimeString];
                //eventTimeString = [eventTimeString stringByReplacingOccurrencesOfString:@":00" withString:@""];
                
                [cell.timeLabel setText:[NSString stringWithFormat:@"%@",eventTimeString]];
                
            } else if ([startDate compare:[NSDate date]] == NSOrderedAscending) {
                
                [cell.timeLabel setText: [NSString stringWithFormat:@"Happening NOW!"]];
                
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
                        
                        //cell.blurView.alpha = 0;
                        cell.eventImageView.image = [UIImage imageWithData:imageData];
                        
                        CAGradientLayer *l = [CAGradientLayer layer];
                        l.frame = cell.eventImageView.bounds;
                        l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
                        
                        l.startPoint = CGPointMake(0.0, 1.00f);
                        l.endPoint = CGPointMake(0.0f, 0.6f);

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
                
                for (FBSDKProfilePictureView *ppView in picArray) {
                    
                    [ppView removeFromSuperview];
                    [cell addSubview:ppView];
                }
            }
        
        } else {
            
            for (UIView *view in cell.subviews){
                if (view.tag == 9) [view removeFromSuperview];
            }
            
            NSLog(@"FAKE CELL");
            cell.contentView.alpha = 0;
        }
        
        return cell;
    
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (showTimeline) return 46;
    
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (showTimeline) return 0;
    
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

- (void)noEvents {
    
    noEventsView = [[UIView alloc] initWithFrame: CGRectMake(0, 300, self.view.frame.size.width, 519-66-202)];
    //noEventsView.backgroundColor = [UIColor redColor];

    [self.tableView addSubview:noEventsView];
    
    /*
    UILabel *topTextLabel = [[UILabel alloc] init];
    topTextLabel.text = @"Uh oh!";
    topTextLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
    topTextLabel.textColor = [UIColor colorWithRed:153.0/255 green:154.0/255 blue:155.0/255 alpha:1.0];
    [topTextLabel sizeToFit];
    topTextLabel.center = CGPointMake(self.view.center.x, 75);
    [noEventsView addSubview:topTextLabel];
    */
    
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

- (IBAction)segControl:(UISegmentedControl *)sender {
    
    if (sender.selectedSegmentIndex == 0) { // Upcoming events
        
        [self loadData];
        
    } else { // Past Events
        
        //[self loadPastEvents];
        
    }
    
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
    
    if (!showTimeline) {
        [self performSegueWithIdentifier:@"toExpandedView" sender:self];
    }
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
        vc.event = cell.eventObject;
        vc.image = cell.eventImageView.image;
        vc.eventID = cell.eventID;
        vc.distanceString = cell.distance.text;
        
        [vc.navigationController setNavigationBarHidden:NO animated:YES];
        
    }
    
}

- (void)loadTimeline {
    
    PFQuery *timelineQuery = [PFQuery queryWithClassName:@"Timeline"];
    [timelineQuery whereKey:@"userId" equalTo:currentUser.objectId];
    [timelineQuery addAscendingOrder:@"createdDate"];
    [timelineQuery fromLocalDatastore];
    [timelineQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            for (PFObject *object in objects) {
                
                if ([timelineDict objectForKey:object.objectId] == nil) { // object doesn't exist
                
                    [object pinInBackground];
                    [sortedTimelineIds insertObject:object.objectId atIndex:0];
                    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                    [timelineDict setObject:dict forKey:object.objectId];
                    [dict setObject:object forKey:@"object"];
                    
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
        xButton.alpha = 1.0;
        [scoreButton setTitle:[NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]] forState:UIControlStateNormal];
        scoreLabel.text = [NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]];
        showTimeline = YES;
    
    } else {
        
        sender.alpha = 0;
        scoreButton.alpha = 1.0;
        [scoreButton setTitle:[NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]] forState:UIControlStateNormal];
        scoreLabel.text = [NSString stringWithFormat:@"%@", [currentUser[@"score"] stringValue]];
        showTimeline = NO;

    }
    
    [self switchTableViewToScore:showTimeline];
    
}

- (void)switchTableViewToScore:(BOOL)toScore {
    
    //if (self.tableView.contentOffset.y == 0) {
    
    isAnimatingScoreButton = YES;
    
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
                blurView.alpha = 1.0;
                self.tableView.contentOffset = CGPointMake(0, 0);
                self.tableView.frame = CGRectMake(0, 18, 320, self.tableView.frame.size.height - 18);
                navBarLabel.alpha = 1.0;
                //blurView.frame = CGRectMake(0, 0, 320, 320);
                //maskLayer.frame = CGRectMake(0, 0, 320, 320);
                self.segContainerView.frame = CGRectMake(0, 212, 320, self.segContainerView.frame.size.height);
                
            } completion:^(BOOL finished){
                
                blurView.dynamic = NO;
                isAnimatingScoreButton = NO;
                blurView.dynamic = YES;

            }];
            
        }];
        
    } else {
        
        [self loadData];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
            
            self.tableView.contentOffset = CGPointMake(0, -200);
            self.tableView.frame = CGRectMake(0, self.tableView.frame.origin.y + 300, 320, self.tableView.frame.size.height);
            scoreLabel.alpha = 0;
            navBarLabel.alpha = 0;
            
        } completion:^(BOOL finished){
            
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
                
                self.segContainerView.alpha = 1.0;
                nameLabel.alpha = 1;
                detailLabel.alpha = 1;
                blurView.alpha = 0;
                self.tableView.contentOffset = CGPointMake(0, 0);
                self.tableView.frame = CGRectMake(0, 157, 320, self.tableView.frame.size.height + 18);
                
            } completion:^(BOOL finished){
                
                isAnimatingScoreButton = NO;
                blurView.dynamic = YES;
            }];
            
        }];
        
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat y = -scrollView.contentOffset.y;
    
    NSLog(@"%f", y);
    
    if (!isAnimatingScoreButton && !showTimeline) {
    
        if (y >= 0) { // $$$$$$$$$ Scrolling down $$$$$$$$$$
            
            if (totalEventCount > 333) {
                
                self.tableView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y);
                self.segContainerView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y);
            
            } else if (tableViewIsUp && y > 20) {
                
                
                [UIView animateWithDuration:0.4 animations:^{
                    
                    self.segContainerView.frame = CGRectMake(0, 212, 320, self.segContainerView.frame.size.height);
                    self.tableView.frame = CGRectMake(0, 157, 320, 420);
                    
                    blurView.alpha = 0.0;
                    nameLabel.alpha = 1.0;
                    detailLabel.alpha = 1.0;
                    navBarLabel.alpha = 0.0;

                } completion:^(BOOL finished) {

                    tableViewIsUp = NO;
                    
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
            
            
            if (y == 0 && totalEventCount > 333) { // %%%%% y = 0 %%%%%
                
                self.nameLabel.alpha = 1.0;
                self.detailLabel.alpha = 1.0;
                profPicView.alpha = 1.0;
                blurView.alpha = 0;
                for (UIView *view in scrollView.subviews) {
                    view.alpha = 1.0;
                }
                
                [UIView animateWithDuration:0.1 animations:^{
                    self.segContainerView.frame = CGRectMake(0, 212, 320, self.segContainerView.frame.size.height);
                    self.tableView.frame = CGRectMake(0, 157, 320, 420);
                }];
                
            }
            
            
        } else if (y < 0) {  // $$$$$$$$$$$ Scrolling up $$$$$$$$$$$
            
            if (self.tableView.frame.origin.y >= 253) {
                self.tableView.transform = CGAffineTransformMakeTranslation(0, -y);
                self.segContainerView.transform = CGAffineTransformMakeTranslation(0, -y);
            }
            
            if (totalEventCount > 333) {
                
                float scale = 1.0f - 5.0f * (fabs(-scrollView.contentOffset.y)  / scrollView.frame.size.height);
                
                //Cap the scaling between zero and 1
                scale = (1 - MAX(0.0f, scale));
                
                blurView.alpha = scale * 2;
                nameLabel.alpha = 1 - scale * 3;
                detailLabel.alpha = 1 - scale * 3;
                
                if (y < -50) {
                    
                    float scale2 = (fabs(y + 50) / scrollView.frame.size.height) * 14;
                    NSLog(@"== %f", scale2);
                    navBarLabel.alpha = scale2;
                    
                } else {
                    
                    navBarLabel.alpha = 0;
                }
                
                
                if (y >= (-209 + 41 + 10) / 2 && totalEventCount > 3) { // -79
                
                    self.tableView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y * 2);
                    self.segContainerView.transform = CGAffineTransformMakeTranslation(0, -scrollView.contentOffset.y * 2);
                
                } else {
                
                    [UIView animateWithDuration:0.1 animations:^{
                        CGRect tableFrame = self.tableView.frame;
                        tableFrame.origin.y = 41;
                        self.tableView.frame = tableFrame;
                        
                        CGRect segContainerFrame = self.segContainerView.frame;
                        segContainerFrame.origin.y = 10;
                        self.segContainerView.frame = segContainerFrame;
                    }];
                }

            
            } else {
            
                [UIView animateWithDuration:0.4 animations:^{ // %%%%%%%%%%% AUTO SCROLL %%%%%%%%%%%
                    
                    CGRect tableFrame = self.tableView.frame;
                    tableFrame.origin.y = 10;
                    self.tableView.frame = tableFrame;
                    
                    CGRect segContainerFrame = self.segContainerView.frame;
                    segContainerFrame.origin.y = 10 + 44;
                    self.segContainerView.frame = segContainerFrame;
                    
                    blurView.alpha = 1.0;
                    nameLabel.alpha = 0.0;
                    detailLabel.alpha = 0.0;
                    navBarLabel.alpha = 1.0;

                } completion:^(BOOL finished) {
                    
                    tableViewIsUp = YES;
                    
                }];
                
            }
            
        } else {
            
            CGRect tableFrame = self.tableView.frame;
            tableFrame.origin.y = 253;
            self.tableView.frame = tableFrame;
            
            CGRect segContainerFrame = self.segContainerView.frame;
            segContainerFrame.origin.y = 212;
            self.segContainerView.frame = segContainerFrame;
            
            CGRect ppFrame = self.profPicView.frame;
            ppFrame.origin.y = -64;
            self.profPicView.frame = ppFrame;
            
            self.nameLabel.alpha = 1.0;
            self.detailLabel.alpha = 1.0;
            profPicView.alpha = 1.0;
            for (UIView *view in scrollView.subviews) {
                view.alpha = 1.0;
            }
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

@end
