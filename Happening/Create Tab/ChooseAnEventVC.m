//
//  ChooseAnEventVC.m
//  Happening
//
//  Created by Max on 7/30/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ChooseAnEventVC.h"
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
#import "LocationConstants.h"
#import "SVProgressHUD.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface ChooseAnEventVC () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

@end

@implementation ChooseAnEventVC {
    
    PFUser *user;
    NSArray *eventsArray;
    UIView *noEventsView;
    NSUInteger count;
    
    PFQuery *dateQuery;
    PFQuery *popularQuery;
    PFQuery *friendsQuery;
    PFQuery *friendSwipesQuery;
    
    NSArray *popularEvents;
    NSArray *sortedFriendsEvents;
    NSMutableDictionary *friendEventDict;
    
    BOOL showUpcomingEvents;
    
    BOOL clearTable;
    
    int tabNumberPressed;
}

@synthesize popularButton, friendsButton, dateButton;

-(void)viewWillAppear:(BOOL)animated {
    
    showUpcomingEvents = YES;
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE, MMMM d"];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.sections = [NSMutableDictionary dictionary];
    
    popularEvents = [NSArray new];
    sortedFriendsEvents = [NSArray new];
    friendEventDict = [NSMutableDictionary dictionary];
    
    //if (self.segControl.selectedSegmentIndex == 0)
    clearTable = NO;
    [self loadData];
    // else
    //   [self loadPastEvents];
    
}

- (void)loadData {
    
    user = [PFUser currentUser];
    
    LocationConstants *locConstants = [[LocationConstants alloc] init];
    PFGeoPoint *userLoc = user[@"GeoLoc"];
    NSString *selectedCity = user[@"userLocTitle"];
    CLLocation *theCityLoc = [locConstants getLocForCity:selectedCity];
    CLLocation *theUserLoc = [[CLLocation alloc] initWithLatitude:userLoc.latitude longitude:userLoc.longitude];
    CLLocationDistance distance = [theUserLoc distanceFromLocation:theCityLoc];
    CLLocationCoordinate2D finalLoc;
    if (distance > 20 * 1609.344 || distance == 0) { // User's current location is > 20 miles outside of the city, use default
        NSLog(@"User's current location is > 20 miles outside of the city, use default");
        finalLoc = theCityLoc.coordinate;
    } else {
        NSLog(@"Use the user's current location!");
        finalLoc = theUserLoc.coordinate;
    }
    float earthRadius = 6378137.0;
    float dn = 50 * 1609.344;
    float de = 50 * 1609.344;
    float dLat = dn/earthRadius;
    float dLon = de/(earthRadius*cosf(M_PI*finalLoc.latitude/180));
    float lat1 = finalLoc.latitude - dLat * 180/M_PI;
    float lon1 = finalLoc.longitude - dLon * 180/M_PI;
    float lat2 = finalLoc.latitude + dLat * 180/M_PI;
    float lon2 = finalLoc.longitude + dLon * 180/M_PI;
    
    PFGeoPoint *swc = [PFGeoPoint geoPointWithLatitude:lat1 longitude:lon1];
    PFGeoPoint *nwc = [PFGeoPoint geoPointWithLatitude:lat2 longitude:lon2];
    
    dateQuery = [PFQuery queryWithClassName:@"Event"];
    [dateQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]];
    [dateQuery whereKey:@"GeoLoc" withinGeoBoxFromSouthwest:swc toNortheast:nwc];
    
    popularQuery = [PFQuery queryWithClassName:@"Event"];
    [popularQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]];
    [popularQuery whereKey:@"GeoLoc" withinGeoBoxFromSouthwest:swc toNortheast:nwc];
    [popularQuery addDescendingOrder:@"weight"];
    [popularQuery addDescendingOrder:@"swipesRight"];
    
    
    NSArray *friends = user[@"friends"];
    NSMutableArray *friendIds = [NSMutableArray array];
    for (NSDictionary *dict in friends) {
        [friendIds addObject:[dict objectForKey:@"parseId"]];
    }
    
    friendSwipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    [friendSwipesQuery whereKey:@"UserID" containedIn:friendIds];
    [friendSwipesQuery whereKey:@"swipedRight" equalTo:@YES];
    [friendSwipesQuery whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-1814400]]; //3 weeks
    
    friendsQuery = [PFQuery queryWithClassName:@"Event"];
    [friendsQuery whereKey:@"objectId" matchesKey:@"EventID" inQuery:friendSwipesQuery];
    [friendsQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]];
    [friendsQuery whereKey:@"GeoLoc" withinGeoBoxFromSouthwest:swc toNortheast:nwc];
    
    [friendSwipesQuery whereKey:@"EventID" matchesKey:@"objectId" inQuery:friendsQuery];
    
    friendSwipesQuery.limit = 1000;
    [friendSwipesQuery addAscendingOrder:@"EventID"]; // groups events together
    
    
    [self loadPopularQuery];
    
}

- (void)loadPopularQuery {

    [self clearTable];
    
    tabNumberPressed = 1;
    
    popularQuery.limit = 10;
    [popularQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error){
       
        popularEvents = events;
        [self.tableView reloadData];
        
    }];
    
}

- (void)loadFriendsQuery {
    
    [self clearTable];
    
    tabNumberPressed = 2;

    popularQuery.limit = 100;
    [popularQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        
        if (!error) {
            
            NSArray *friends = user[@"friends"];
            NSMutableArray *friendIds = [NSMutableArray array];
            for (NSDictionary *dict in friends) {
                [friendIds addObject:[dict objectForKey:@"parseId"]];
            }
            
            PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
            [swipesQuery whereKey:@"UserID" containedIn:friendIds];
            [swipesQuery whereKey:@"swipedRight" equalTo:@YES];
            [swipesQuery whereKey:@"EventID" matchesKey:@"objectId" inQuery:popularQuery];
            swipesQuery.limit = 1000;
            [swipesQuery findObjectsInBackgroundWithBlock:^(NSArray *swipes, NSError *error){
               
                if (!error) {
                
                    NSMutableArray *eventIds = [NSMutableArray array];
                    //NSMutableDictionary *friendIdsForEventDict = [NSMutableDictionary dictionary];
                    
                    friendEventDict = [NSMutableDictionary dictionary];
                    
                    for (PFObject *swipe in swipes) {
                        [eventIds addObject:swipe[@"EventID"]];
                        
                        NSMutableDictionary *dict = [friendEventDict objectForKey:swipe[@"EventID"]];
                        if (dict == nil) {
                            dict = [NSMutableDictionary dictionary];
                            [friendEventDict setObject:dict forKey:swipe[@"EventID"]];
                            [dict setObject:[NSMutableArray arrayWithObject:swipe[@"FBObjectID"]] forKey:@"fbids"];
                        
                        } else {
                            
                            NSMutableArray *array = [dict objectForKey:@"fbids"];
                            [array addObject:swipe[@"FBObjectID"]];
                        }
                        
                    }
                    
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
                    }
                    
                    
                    [self.tableView reloadData];
                    
                }
            }];
        }
    }];
    
    
    /*
    [friendSwipesQuery findObjectsInBackgroundWithBlock:^(NSArray *swipes, NSError *error) {
       
        NSLog(@"swipes: %@", swipes);

        NSMutableArray *eventIds = [NSMutableArray array];
        
        for (PFObject *swipe in swipes) {

            [eventIds addObject:swipe[@"EventID"]];
        
        }
        
        
        
    }]; */
    
    
    
}

- (void)loadDateQuery {
    
    [self clearTable];
    
    tabNumberPressed = 3;

    dateQuery.limit = 10;
    
    [dateQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        
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
        
        }
        
        // Create a sorted list of days
        NSArray *unsortedDays = [self.sections allKeys];
        self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
        
        if (eventsArray.count > 0) {
            [self.tableView reloadData];
        }
        
    }];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tabNumberPressed == 1 || tabNumberPressed == 2)
        return 1;
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tabNumberPressed == 3) {
    
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
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tabNumberPressed == 1 || tabNumberPressed == 2) {
        return 0;
    } else {
        // whatever height you'd want for a real section header
        return 40;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (clearTable) return 0;
    
    if (tabNumberPressed == 1) {
        
        return popularEvents.count;
        
    } else if (tabNumberPressed == 2) {
        
        return sortedFriendsEvents.count;
        
    } else if (tabNumberPressed == 3) {
        
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
        NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        return eventsOnThisDay.count;
    }
    
    return 0;
    
}

// %%%%%% Runs through this code every time I scroll in Table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [SVProgressHUD dismiss];
    
    AttendTableCell *cell = (AttendTableCell *)[tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];
    
    PFObject *Event;
    
    if (tabNumberPressed == 1) {
    
        Event = popularEvents[indexPath.row];
    
    } else if (tabNumberPressed == 2) {
        
        NSString *eventId = sortedFriendsEvents[indexPath.row];
        NSDictionary *eventDict = [friendEventDict objectForKey:eventId];
        Event = [eventDict objectForKey:@"event"];

    } else if (tabNumberPressed == 3) {
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
        NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        Event = eventsOnThisDay[indexPath.row];
    }
    
    cell.eventObject = Event;
    
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
    locIMV.frame = CGRectMake(290 - cell.distance.frame.size.width - 11 - 5, 38, 10.4, 13);
    locIMV.tag = 77;
    [cell.contentView addSubview:locIMV];
    
    cell.interestedLabel.text = [NSString stringWithFormat:@"%@ interested", Event[@"swipesRight"]];
    
    cell.interestedLabel.alpha = 1;
    cell.subtitle.alpha = 1;
    [cell viewWithTag:4].alpha = 1; //interested fac
    
    for (UIView *view in cell.subviews) {
        if (view.tag == 9) [view removeFromSuperview];
    }
    
    if (tabNumberPressed == 2) {
        
        cell.interestedLabel.alpha = 0;
        cell.subtitle.alpha = 0;
        [cell viewWithTag:4].alpha = 0; //interested face
        
        NSString *eventId = sortedFriendsEvents[indexPath.row];
        NSDictionary *eventDict = [friendEventDict objectForKey:eventId];
        NSArray *fbids = [eventDict objectForKey:@"fbids"];
        
        for (int i = 0; i < fbids.count; i++) {
            
            if (i < 5) {
            
                NSString *fbid = fbids[i];
                FBSDKProfilePictureView *ppview = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(30 + (50 * i), 93, 40, 40)];
                ppview.profileID = fbid;
                ppview.clipsToBounds = YES;
                ppview.layer.cornerRadius = 40/2;
                [cell addSubview:ppview];
                ppview.tag = 9;
                
            }
            
        }
        
    }
    
    
    return cell;
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
        /*
        UILabel *subDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 16, 100, 20)];
        subDateLabel.textColor = [UIColor darkTextColor];
        subDateLabel.font = [UIFont fontWithName:@"OpenSans" size:9];
        subDateLabel.tag = 99;
        */
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        header.textLabel.text = [header.textLabel.text stringByAppendingString: dateString];
        
        //[header addSubview:subDateLabel];
        
    }  else if ([header.textLabel.text isEqualToString:@"TOMORROW"]) {
        
        /*
        UILabel *subDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(107, 16, 100, 20)];
        subDateLabel.textColor = [UIColor darkTextColor];
        subDateLabel.font = [UIFont fontWithName:@"OpenSans" size:9];
        subDateLabel.tag = 99; */
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(86400)]];
        header.textLabel.text = [header.textLabel.text stringByAppendingString: dateString];
        
        //[header addSubview:subDateLabel];
        
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


- (IBAction)popularButtonPressed:(id)sender {
    
    UIColor *hapBlue = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0];
    
    popularButton.backgroundColor = hapBlue;
    [popularButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    friendsButton.backgroundColor = [UIColor whiteColor];
    [friendsButton setTitleColor:hapBlue forState:UIControlStateNormal];
    dateButton.backgroundColor = [UIColor whiteColor];
    [dateButton setTitleColor:hapBlue forState:UIControlStateNormal];
    
    [self loadPopularQuery];
}

- (IBAction)friendsButtonPressed:(id)sender {
    
    UIColor *hapBlue = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0];
    
    popularButton.backgroundColor = [UIColor whiteColor];
    [popularButton setTitleColor:hapBlue forState:UIControlStateNormal];
    friendsButton.backgroundColor = hapBlue;
    [friendsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    dateButton.backgroundColor = [UIColor whiteColor];
    [dateButton setTitleColor:hapBlue forState:UIControlStateNormal];
    
    [self loadFriendsQuery];
}

- (IBAction)dateButtonPressed:(id)sender {
    
    UIColor *hapBlue = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0];
    
    popularButton.backgroundColor = [UIColor whiteColor];
    [popularButton setTitleColor:hapBlue forState:UIControlStateNormal];
    friendsButton.backgroundColor = [UIColor whiteColor];
    [friendsButton setTitleColor:hapBlue forState:UIControlStateNormal];
    dateButton.backgroundColor = hapBlue;
    [dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     
    [self loadDateQuery];
}

- (void)clearTable {
    [SVProgressHUD setViewForExtension:self.view.superview];
    [SVProgressHUD show];
    clearTable = YES;
    [self.tableView reloadData];
    clearTable = NO;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
