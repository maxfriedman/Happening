//
//  AttendEvent.m
//  Happening
//
//  Created by Max on 10/5/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "AttendEvent.h"
#import "AttendTableCell.h"
#import "AppDelegate.h"
#import "moreDetailFromTable.h"
#import "UIImage+ImageEffects.h"
#import "FXBlurView.h"

@interface AttendEvent ()

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

@end

@implementation AttendEvent {
    NSInteger count;
    NSArray *eventsArray;
}

@synthesize locManager, refreshControl;
@synthesize sections;
@synthesize sortedDays;


- (void)viewDidLoad {
    
    [super viewDidLoad];
        
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self setEnabledSidewaysScrolling:YES];
    
    // Instantiate event dictionary--- this is where all event info is stored
    self.sections = [NSMutableDictionary dictionary];
    
    PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    // Query only for current user's events
    PFUser *user = [PFUser currentUser];
    [swipesQuery whereKey:@"UserID" equalTo:user.objectId];
    [swipesQuery whereKey:@"swipedRight" equalTo:@YES];
    //NSArray *swipesArray = [swipesQuery findObjects];
    
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
        
        [self.tableView reloadData];
    }];
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE, MMMM d"];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [self.sections count];
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
    
    return [self.sectionDateFormatter stringFromDate:eventDate];}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    return [eventsOnThisDay count];
    //return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];

    [cell setupCell];
    
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
    NSString *startTimeString = [formatter stringFromDate:Event[@"Date"]];
    NSString *endTimeString = [formatter stringFromDate:Event[@"EndTime"]];
    NSString *eventTimeString = [[NSString alloc]init];
    eventTimeString = [NSString stringWithFormat:@"%@", startTimeString];
    if (endTimeString) {
        eventTimeString = [NSString stringWithFormat:@"%@ to %@", eventTimeString, endTimeString];
    }
    eventTimeString = [eventTimeString stringByReplacingOccurrencesOfString:@":00" withString:@""];
    
    [cell.timeLabel setText:[NSString stringWithFormat:@"%@",eventTimeString]];

    // Image formatting
    PFFile *imageFile = Event[@"Image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            
            
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
            
            cell.eventImageView.layer.mask = l;
            //cell.blurView.dynamic = NO;
            
            //blurView.layer.mask = l;
            
            //[cell addSubview:blurView];
            

        }
    }];
    
    // Location formatting
    if(locManager && [CLLocationManager locationServicesEnabled]){
        [self.locManager startUpdatingLocation];
        CLLocation *currentLocation = locManager.location;
        PFUser *user = [PFUser currentUser];
        user[@"userLoc"] = [PFGeoPoint geoPointWithLocation:currentLocation];
        NSLog(@"Current Location is: %@", currentLocation);
        [user saveInBackground];
    }
    
    PFGeoPoint *loc = Event[@"GeoLoc"];
    
    if (loc.latitude == 0) {
        cell.distance.text = @"";
    } else {
        PFUser *user = [PFUser currentUser];
        PFGeoPoint *userLoc = user[@"userLoc"];
        NSNumber *meters = [NSNumber numberWithDouble:([loc distanceInMilesTo:userLoc])];
        NSString *distance = [NSString stringWithFormat:(@"%.1f mi"), meters.floatValue];
        cell.distance.text = distance;
    }
    
    cell.interestedLabel.text = [NSString stringWithFormat:@"%@ interested", Event[@"swipesRight"]];
    
    //cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
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
        UILabel *subDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 16, 100, 20)];
        subDateLabel.textColor = [UIColor darkTextColor];
        subDateLabel.font = [UIFont fontWithName:@"OpenSans" size:9];
        subDateLabel.tag = 99;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        subDateLabel.text = dateString;
        
        [header.contentView addSubview:subDateLabel];
        
    }  else if ([header.textLabel.text isEqualToString:@"TOMORROW"] && section == 0) {

        UILabel *subDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 16, 100, 20)];
        subDateLabel.textColor = [UIColor darkTextColor];
        subDateLabel.font = [UIFont fontWithName:@"OpenSans" size:9];
        subDateLabel.tag = 99;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:(86400)]];
        subDateLabel.text = dateString;
        
        [header.contentView addSubview:subDateLabel];
        
    } else if ([header.textLabel.text isEqualToString:@"TOMORROW"] && section == 1) {
        
        UILabel *subDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(105, 0, 100, 17)];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section != 0) {
        return 22;
    }
    return 40;
}

// Method for deleting table cells, only works if there are multiple events/cells in a section

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row/section from the data source
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
        NSMutableArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        
        if (eventsOnThisDay.count <= 1) {
            
            PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
            // Query only for current user's events
            PFUser *user = [PFUser currentUser];
            [swipesQuery whereKey:@"UserID" equalTo:user.username];
            [swipesQuery whereKey:@"swipedRight" equalTo:@YES];
            //NSArray *swipesArray = [swipesQuery findObjects];
            
            PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
            [eventQuery whereKey:@"objectId" matchesKey:@"EventID" inQuery:swipesQuery];
            [eventQuery whereKey:@"Date" greaterThan:[NSDate date]];
            [eventQuery orderByAscending:@"Date"];
            
            [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *eventsArray, NSError *error) {
            
            for (PFObject *event in eventsArray)
            {
                // Reduce event start date to date components (year, month, day)
                NSDate *dateRepresentingThisDay = [self dateAtBeginningOfDayForDate:event[@"Date"]];
                
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
        
        PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
        [swipesQuery whereKey:@"EventID" equalTo:cell.eventID];
        PFUser *user = [PFUser currentUser];
        [swipesQuery whereKey:@"UserID" equalTo:user.username];
        PFObject *swipesObject = [swipesQuery getFirstObject];
        [swipesObject setValue:@NO forKey:@"swipedRight"];
        [swipesObject setValue:@YES forKey:@"swipedLeft"];
        [swipesObject saveInBackground];
        
        // Make a dictionary with with the eventID (objectID), row number, section number, and total number in the order
        // Use this to find the correct event, use the eventID to query swipes, and switch swiped right and swiped left
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
            } else {
            
            [eventsOnThisDay removeObjectAtIndex:indexPath.row];
            [self.sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        
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

- (void)setEnabledSidewaysScrolling:(BOOL)enabled {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    [rk scrolling:enabled];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toMoreDetail"]) {
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
        
        // pass the element to this detail view controller
        //viewController.element = element;
    }

}

@end
