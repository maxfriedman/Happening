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

@interface AttendEvent ()

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

@end

@implementation AttendEvent

@synthesize locManager, refreshControl;
@synthesize sections;
@synthesize sortedDays;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"Back";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    
    // Instantiate event dictionary--- this is where all event info is stored
    self.sections = [NSMutableDictionary dictionary];
    
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

}

// %%%%%% Runs through this code every time I scroll in "Attend" Table for some reason %%%%%%%%%%%
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];

    [cell setupCell];
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    
    PFObject *Event = eventsOnThisDay[indexPath.row];
    
    [cell.titleLabel setText:[NSString stringWithFormat:@"%@",Event[@"Title"]]];
    
    [cell.subtitle setText:[NSString stringWithFormat:@"%@",Event[@"Subtitle"]]];
    
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
    [cell.timeLabel setText:[NSString stringWithFormat:@"%@",eventTimeString]];
    
    // Image formatting
    PFFile *imageFile = Event[@"Image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            cell.image.image = [UIImage imageWithData:imageData];
            cell.image.alpha = 0.9;
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
        NSString *distance = [NSString stringWithFormat:(@"%.2f mi"), meters.floatValue];
        cell.distance.text = distance;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"toMoreDetail"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        AttendTableCell *cell = [self.tableView cellForRowAtIndexPath:selectedIndexPath];
        moreDetailFromTable *vc = (moreDetailFromTable *)segue.destinationViewController;
        vc.eventID = cell.eventID;
        vc.eventIDLabel.text = cell.eventID;
        vc.hidesBottomBarWhenPushed = YES;
        
        // pass the element to this detail view controller
        //viewController.element = element;
    }

}

@end
