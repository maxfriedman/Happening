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

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface ProfileTVC () <EventTVCDelegate>

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

@end

@implementation ProfileTVC {
    
    PFUser *user;
    NSArray *eventsArray;
    UIView *noEventsView;
    NSUInteger count;
    
    BOOL showUpcomingEvents;
}

//@synthesize locManager, refreshControl;
@synthesize sections, sortedDays, locManager;
@synthesize nameLabel, detailLabel, profilePicImageView, myEventsTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"OpenSans-Semibold" size:18],
      NSFontAttributeName, nil]];
    
    user = [PFUser currentUser];
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
    
    if ((user[@"userLocTitle"] != nil) && (! [user[@"userLocTitle"] isEqualToString:@"Current Location"]) ) {
        
        if ( ! [user[@"userLocTitle"] isEqualToString:@"Current Location"])
            detailLabel.text = [NSString stringWithFormat:@"%@", user[@"userLocTitle"]];
    
    } else {
        if (user[@"fbLocationName"] != nil)
            detailLabel.text = [NSString stringWithFormat:@"%@", user[@"fbLocationName"]];
        else
            detailLabel.text = @"";
        
    }
    
    FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(120, 24, 80, 80)]; // initWithProfileID:user[@"FBObjectID"] pictureCropping:FBSDKProfilePictureModeSquare];
    profPicView.profileID = user[@"FBObjectID"];
    profPicView.pictureMode = FBSDKProfilePictureModeSquare;
    profPicView.layer.cornerRadius = 10;
    profPicView.layer.masksToBounds = YES;
    profPicView.layer.borderColor = [UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0].CGColor;
    profPicView.layer.borderWidth = 3.0;
    //profPicView.frame = CGRectMake(120, 24, 80, 80);
    [self.view addSubview:profPicView];
    
    profilePicImageView.layer.cornerRadius = 10;
    profilePicImageView.layer.masksToBounds = YES;
    profilePicImageView.layer.borderColor =  [UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0].CGColor;
    profilePicImageView.layer.borderWidth = 3.0;

    
    noEventsView = [[UIView alloc] initWithFrame: CGRectMake(0, 350, self.view.frame.size.width, 200)];
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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self setEnabledSidewaysScrolling:YES];
    showUpcomingEvents = YES;
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE, MMMM d"];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.sections = [NSMutableDictionary dictionary];
    
    //if (self.segControl.selectedSegmentIndex == 0)
        [self loadData];
   // else
     //   [self loadPastEvents];
    
}

- (void)loadData {
    
    user = [PFUser currentUser];
    
    PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    [swipesQuery whereKey:@"UserID" equalTo:user.objectId];
    [swipesQuery whereKey:@"swipedRight" equalTo:@YES];
    swipesQuery.limit = 1000;
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"objectId" matchesKey:@"EventID" inQuery:swipesQuery];
    [eventQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]]; // show today's events, must be at least 30 minutes left in the event (END)
    [eventQuery orderByAscending:@"Date"];
    eventQuery.limit = 1000;
    
    count = 0;
    
    eventsArray = [[NSArray alloc]init];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        
        eventsArray = events;
        
        for (PFObject *event in eventsArray)
        {
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
            [eventsOnThisDay addObject:event];
            
            count++;
        }
        
        // Create a sorted list of days
        NSArray *unsortedDays = [self.sections allKeys];
        self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
        
        if (eventsArray.count == 0) {
            
            //[noEventsView removeFromSuperview];
            //[self noEvents];
            
        } else {
            
            //[noEventsView removeFromSuperview];
        }
        
        [self.tableView reloadData];
        
    }];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDate *eventDate = [[NSDate alloc]init];
    eventDate = [self.sortedDays objectAtIndex:section];
    
    if ((section == 0 || section == 1) && ([eventDate beginningOfDay] == [[NSDate date] beginningOfDay])) {
        return @"Today";
    }
    
    if ((section == 0 || section == 1) && ([eventDate beginningOfDay] == [[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay])) {
        return @"Tomorrow";
    }
    
    return [self.sectionDateFormatter stringFromDate:eventDate];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    return [eventsOnThisDay count];
    
}

// %%%%%% Runs through this code every time I scroll in Table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttendTableCell *cell = (AttendTableCell *)[tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];
    
    [noEventsView removeFromSuperview];
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    
    PFObject *Event = eventsOnThisDay[indexPath.row];
    
    [cell.titleLabel setText:[NSString stringWithFormat:@"%@",Event[@"Title"]]];
    
    if (Event[@"Description"])
        [cell.subtitle setText:[NSString stringWithFormat:@"%@",Event[@"Description"]]];
    else
        [cell.subtitle setText:[NSString stringWithFormat:@""]];
    
    [cell.locLabel setText:[NSString stringWithFormat:@"at %@",Event[@"Location"]]];
    
    cell.eventID = Event.objectId;
    
    // Time formatting
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    
    NSDate *startDate = Event[@"Date"];
    NSDate *endDate = Event[@"EndTime"];
    
    if ([startDate compare:[NSDate date]] == NSOrderedAscending) {
        
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
                //l.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                //[NSNumber numberWithFloat:0.2],
                //[NSNumber numberWithFloat:0.3],
                //[NSNumber numberWithFloat:0.4], nil];
                
                //cell.eventImageView.layer.mask = l;
                //cell.blurView.dynamic = NO;
                
                //blurView.layer.mask = l;
                
                //[cell addSubview:blurView];
            }
        }];
        
    } else {
        
        // default image
    }
    
    // Location formatting
    if(locManager && [CLLocationManager locationServicesEnabled]){
        [self.locManager startUpdatingLocation];
        CLLocation *currentLocation = locManager.location;
        user[@"userLoc"] = [PFGeoPoint geoPointWithLocation:currentLocation];
        NSLog(@"Current Location is: %@", currentLocation);
        [user saveInBackground];
    }
    
    PFGeoPoint *loc = Event[@"GeoLoc"];
    
    if (loc.latitude == 0) {
        cell.distance.text = @"";
    } else {
        PFGeoPoint *userLoc = user[@"userLoc"];
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
    locIMV.frame = CGRectMake(290 - cell.distance.frame.size.width - 11 - 5, 38, 11, 13);
    locIMV.tag = 77;
    [cell.contentView addSubview:locIMV];

    
    cell.interestedLabel.text = [NSString stringWithFormat:@"%@ interested", Event[@"swipesRight"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section != 0) {
        return 22;
    }
    return 40;
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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    //view.tintColor = [UIColor blackColor]
    
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
        
    }  else if ([header.textLabel.text isEqualToString:@"TOMORROW"] && section == 0) {
        
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
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
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
    }
    
}

- (void)setEnabledSidewaysScrolling:(BOOL)enabled {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    [rk scrolling:enabled];
    
}

- (void)showNavTitle {
    
    NSLog(@"show title");
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    rk.rightButton.alpha = 1.0;
    
    rk.middleButton2.alpha = 1.0;
    rk.middleButton.alpha = 0.0;
}

@end
