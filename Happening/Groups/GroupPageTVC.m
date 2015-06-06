//
//  GroupPageTVCTableViewController.m
//  Happening
//
//  Created by Max on 6/4/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupPageTVC.h"
#import "GroupsEventCell.h"
#import <Parse/Parse.h>
#import "CupertinoYankee.h"

@interface GroupPageTVC ()

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;
//@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;

@end

@implementation GroupPageTVC {
    
    PFUser *currentUser;
    NSArray *eventsArray;
    UIView *noEventsView;
    NSUInteger count;
}

@synthesize groupId, locManager, groupName;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if(locManager && [CLLocationManager locationServicesEnabled]){
        [self.locManager startUpdatingLocation];
        CLLocation *currentLocation = locManager.location;
        currentUser[@"userLoc"] = [PFGeoPoint geoPointWithLocation:currentLocation];
        NSLog(@"Current Location is: %@", currentLocation);
        [currentUser saveInBackground];
    }
    
    currentUser = [PFUser currentUser];

    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = groupName;
    
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE, MMMM d"];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.sections = [NSMutableDictionary dictionary];
    
    //if (self.segControl.selectedSegmentIndex == 0)
    [self loadData];

}

- (void)loadData {
    
    PFQuery *notificationQuery = [PFQuery queryWithClassName:@"Notifications"];
    [notificationQuery whereKey:@"UserID" equalTo:currentUser.objectId];
    [notificationQuery whereKey:@"Type" equalTo:@"group"];
    [notificationQuery whereKey:@"GroupID" equalTo:groupId];
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"objectId" matchesKey:@"EventID" inQuery:notificationQuery];
    [eventQuery whereKey:@"EndTime" greaterThan:[NSDate date]];
    [eventQuery orderByAscending:@"Date"];
    
    count = 0;
    eventsArray = [[NSArray alloc]init];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error){
        
       eventsArray = events;
        NSLog(@"Events Array: %@", events);
        
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
    
    NSLog(@"indexp: %ld", (long)indexPath.row);
    
    GroupsEventCell *cell = (GroupsEventCell *)[tableView dequeueReusableCellWithIdentifier:@"groupEvent" forIndexPath:indexPath];
    
    [noEventsView removeFromSuperview];
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    
    PFObject *Event = eventsOnThisDay[indexPath.row];
    
    [cell.titleLabel setText:[NSString stringWithFormat:@"%@",Event[@"Title"]]];
    
    [cell.locationLabel setText:[NSString stringWithFormat:@"%@",Event[@"Location"]]];
    
    //cell.eventID = Event.objectId;
    
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
        cell.distanceLabel.text = @"";
    } else {
        PFGeoPoint *userLoc = currentUser[@"userLoc"];
        NSNumber *meters = [NSNumber numberWithDouble:([loc distanceInMilesTo:userLoc])];
        NSString *distance = [NSString stringWithFormat:(@"%.1f mi"), meters.floatValue];
        cell.distanceLabel.text = distance;
    }
    
    //cell.interestedLabel.text = [NSString stringWithFormat:@"%@ interested", Event[@"swipesRight"]];
    
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
    
    //self.segControl.selectedSegmentIndex = 0;
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

- (IBAction)xButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        //<#code#>
    }];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

@end
