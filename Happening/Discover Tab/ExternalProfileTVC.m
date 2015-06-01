//
//  ExternalProfileTVC.m
//  Happening
//
//  Created by Max on 2/14/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ExternalProfileTVC.h"
#import "AttendTableCell.h"
#import "CupertinoYankee.h"
#import "showMyEventVC.h"
#import "EventTVC.h"
#import "moreDetailFromTable.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ExternalProfileTVC ()

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

@end

@implementation ExternalProfileTVC {
    
    NSArray *eventsArray;
    NSInteger count;
    UIView *noEventsView;
    PFObject *user;
    UIVisualEffectView *blurEffectView;
}

//@synthesize locManager, refreshControl;
@synthesize sections, sortedDays, locManager, eventID, userID;
@synthesize nameLabel, detailLabel, profilePicImageView, myEventsTableView, nameEventsLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    nameLabel.text = @"";
    detailLabel.text = @"";
    nameEventsLabel.text = @"";

    profilePicImageView.layer.cornerRadius = 10;
    profilePicImageView.layer.masksToBounds = YES;
    profilePicImageView.layer.borderColor =  [UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0].CGColor;
    profilePicImageView.layer.borderWidth = 3.0;
    
    PFQuery *userQuery = [PFUser query];
    [userQuery getObjectInBackgroundWithId:userID block:^(PFObject *userObject, NSError *error){

        if (!error) {
        
            user = userObject;
        
            nameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
            detailLabel.text = [NSString stringWithFormat:@"%@", user[@"city"]];
            nameEventsLabel.text = [NSString stringWithFormat:@"%@'s events", user[@"firstName"]];
        
            FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(120, 24, 80, 80)];
            profPicView.profileID = user[@"FBObjectID"];
            profPicView.pictureMode = FBSDKProfilePictureModeSquare;
            profPicView.layer.cornerRadius = 10;
            profPicView.layer.masksToBounds = YES;
            profPicView.layer.borderColor = [UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0].CGColor;
            profPicView.layer.borderWidth = 3.0;
            [self.view addSubview:profPicView];
            
            [self loadData];
            [self bestFriendsCheck];
            
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE, MMMM d"];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.sections = [NSMutableDictionary dictionary];
    
}

- (void)loadData {
    
    PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    [swipesQuery whereKey:@"UserID" equalTo:user.objectId];
    [swipesQuery whereKey:@"swipedRight" equalTo:@YES];
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"objectId" matchesKey:@"EventID" inQuery:swipesQuery];
    [eventQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]]; // show today's events, must be at least 30 minutes left in the event (END)
    [eventQuery orderByAscending:@"Date"];
    
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
    
    [cell.locLabel setText:[NSString stringWithFormat:@"%@",Event[@"Location"]]];
    
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
        NSString *distance = [NSString stringWithFormat:(@"%.1f mi"), meters.floatValue];
        cell.distance.text = distance;
    }
    
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


- (void)noEvents {
    
    noEventsView = [[UIView alloc] initWithFrame: CGRectMake(0, 300, self.view.frame.size.width, self.view.frame.size.height)];
    //noEventsView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:noEventsView];
    
    /*
    UILabel *topTextLabel = [[UILabel alloc] init];
    topTextLabel.text = @"Uh oh!";
    topTextLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
    topTextLabel.textColor = [UIColor colorWithRed:153.0/255 green:154.0/255 blue:155.0/255 alpha:1.0];
    [topTextLabel sizeToFit];
    topTextLabel.center = CGPointMake(self.view.center.x, 75);
    [noEventsView addSubview:topTextLabel];
    */
    
#warning incomplete and untested
    
    UILabel *bottomTextLabel = [[UILabel alloc] init];
    bottomTextLabel.text = [NSString stringWithFormat:@"%@ hasn't saved any events.", user[@"firstName"] ];;
    bottomTextLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
    bottomTextLabel.textColor = [UIColor colorWithRed:153.0/255 green:154.0/255 blue:155.0/255 alpha:1.0];
    [bottomTextLabel sizeToFit];
    bottomTextLabel.center = CGPointMake(self.view.center.x, 100);
    [noEventsView addSubview:bottomTextLabel];
    
    /*
    UIButton *createEventButton = [[UIButton alloc] initWithFrame:CGRectMake(95.2, 130, 129.6, 40)];
    [createEventButton setImage:[UIImage imageNamed:@"discoverButton"] forState:UIControlStateNormal];
    [createEventButton setImage:[UIImage imageNamed:@"discover pressed"] forState:UIControlStateHighlighted];
    [createEventButton addTarget:self action:@selector(discoverButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [noEventsView addSubview:createEventButton];
    
    UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(135, 200, 200, 200)];
    imv.center = CGPointMake(self.view.center.x, 310);
    imv.image = [UIImage imageNamed:@"right swipe"];
    [noEventsView addSubview:imv];
    
    UILabel *lastLabel = [[UILabel alloc] init];
    lastLabel.text = @"Swipe right to save an event";
    lastLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:14.0];
    lastLabel.textColor = [UIColor colorWithRed:153.0/255 green:154.0/255 blue:155.0/255 alpha:1.0];
    [lastLabel sizeToFit];
    lastLabel.center = CGPointMake(self.view.center.x, 455);
    [noEventsView addSubview:lastLabel];
     */
    
}

- (void)bestFriendsCheck {
    
    PFUser *currentUser = [PFUser currentUser];
    NSArray *bestFriends = currentUser[@"BestFriends"];
    
    if ([bestFriends containsObject:user[@"FBObjectID"]]) { //BFFs
        
        
        
    } else { //Not BFFs
    
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        /*
        CGFloat height = 0;
        for (int i = 0; i < self.sections.count; i++) {
            NSLog(@"2324234");
            CGRect rect = [self.tableView rectForSection:(i)];
            
            height += CGRectGetHeight(rect);
            
        }
        
        NSLog(@"HEIGHT: %f", height);
        
        if (height <= 305)
            blurEffectView.frame = CGRectMake(0, 263, 320, 305);
        else */
            blurEffectView.frame = CGRectMake(0, 264, 320, 500);
/*
        UIView *colorView = [[UIView alloc] initWithFrame:blurEffectView.frame];
        colorView.backgroundColor = [UIColor cyanColor];
        colorView.alpha = 0.1;
        [self.view addSubview:colorView];
        */
        
        //self.tableView.backgroundColor = [UIColor cyanColor];
        
        [self.view addSubview:blurEffectView];
        
        self.tableView.scrollEnabled = NO;
        
        /*
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        vibrancyEffectView.frame = blurEffectView.bounds;
         */
        
        // Label for vibrant text
         NSString *gender = user[@"gender"];
         NSString *genderString = @"";
         
         if ([gender isEqualToString:@"male"]) {
         genderString = @"with him";
         } else if ([gender isEqualToString:@"female"]) {
         genderString = @"with her";
         }
        
         
        UILabel *vibrantLabel = [[UILabel alloc] init];
        [vibrantLabel setText:[NSString stringWithFormat:@"To view %@'s events you must be best friends %@", user[@"firstName"], genderString]];
        [vibrantLabel setFont:[UIFont fontWithName:@"OpenSans-Bold" size:22.0]];
        vibrantLabel.textColor = [UIColor blackColor];
        
        [vibrantLabel setTextAlignment:NSTextAlignmentCenter];
        [vibrantLabel setFrame:CGRectMake(40, 40, 240, 150)];
        vibrantLabel.numberOfLines = 0;

        
        // Add label to the vibrancy view
        //[[vibrancyEffectView contentView] addSubview:vibrantLabel];
        
        // Add the vibrancy view to the blur view
        //[[blurEffectView contentView] addSubview:vibrancyEffectView];
        
        [blurEffectView addSubview:vibrantLabel];
        
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

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //code
    }];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showUserEvent"]) {
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        AttendTableCell *cell = (AttendTableCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath];
            
        UINavigationController *navController = [segue destinationViewController];
        moreDetailFromTable *vc = (moreDetailFromTable *)([navController topViewController]);
        
        // Pass data
        vc.eventID = cell.eventID;
        vc.titleText = cell.titleLabel.text;
        vc.image = cell.eventImageView.image;
        //vc.timeLabel.text
        vc.distanceText = cell.distance.text;
        vc.subtitleText = cell.subtitle.text;
        vc.locationText = cell.locLabel.text;
    
        vc.hidesBottomBarWhenPushed = YES;
        
    }
}

@end
