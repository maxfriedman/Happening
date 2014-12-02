//
//  AttendEvent.m
//  HappeningParse
//
//  Created by Max on 10/5/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "AttendEvent.h"
#import "AttendTableCell.h"
#import "AppDelegate.h"
#import "moreDetailFromTable.h"

@interface AttendEvent ()

@end

@implementation AttendEvent {

    NSUInteger count;
    NSMutableArray *sectionDates;
    NSMutableArray *rowDates;
    NSInteger index;
    NSInteger sectionIndex;
    
    NSMutableArray *rowCountArray;
    NSMutableArray *cells;
    NSMutableArray *indexpaths;
    NSMutableArray *eventIds;
    
    NSMutableDictionary *eventDict;
    
}
@synthesize locManager;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"Back";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    //[self.tableView reloadData];
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
    
    //eventsArray = [[NSArray alloc]init];
    //eventsArray = [eventQuery findObjects];
    
    eventDict = [[NSMutableDictionary alloc]init];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *eventsArray, NSError *error) {
    
        count = eventsArray.count;
        int sectionCount = 0;
        sectionDates = [[NSMutableArray alloc]init];
    
    
        for (int j=0; j<80; j++) {
        
            //Account for today's date %%%%%
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(86400 * j)];
            
            for (int i=0; i<count; i++) {
                PFObject *eventObject = eventsArray[i];
                NSDate *someDate = eventObject[@"Date"];
                
                if ([date beginningOfDay] == [someDate beginningOfDay]) {
                
                    sectionCount++;
                    [sectionDates addObject:someDate];
                    /*
                    if ([eventDict objectForKeyedSubscript:date] != nil) {
                        NSMutableArray *array = [eventDict objectForKey:date];
                        [array addObject:someDate];
                        [eventDict setObject:array forKey:date];
                    } else {
                        NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:someDate, nil];
                        [eventDict setObject:array forKey:date];
                    } */
                    break;
                }
            }
        }
    
        int rowCount = 0;
        rowDates = [[NSMutableArray alloc]init];
        
        for (int j=0; j<80; j++) {
        
            //Account for today's date %%%%%
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:(86400 * j)];
            
            for (int i=0; i<count; i++) {
                PFObject *eventObject = eventsArray[i];
                NSDate *someDate = eventObject[@"Date"];
                if ([date beginningOfDay] == [someDate beginningOfDay]) {
                
                    rowCount++;
                    [rowDates addObject:someDate];
                    [eventIds addObject:eventObject[@"eventID"]];
                    
                }
            }
        }
    
        rowCountArray = [[NSMutableArray alloc]init];
        int rowForSectionCount = 0;
    
        for (int i = 0; i < sectionCount; i++) {

            for (int j = 0; j < rowCount; j++) {
            
                NSDate *rowDate = rowDates[j];
                NSDate *sectionDate = sectionDates[i];
            
                if ([rowDate beginningOfDay] == [sectionDate beginningOfDay]) {
                
                    rowForSectionCount++;
                }
            }
            [rowCountArray addObject:[NSNumber numberWithInt:rowForSectionCount]];
            rowForSectionCount = 0;
        }

        // delete this????
        [self.tableView reloadData];
    }];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //[eventDict count];
    return [sectionDates count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDate *eventDate = [[NSDate alloc]init];
    eventDate = sectionDates[section];
    
    if (section == 0 && ([eventDate beginningOfDay] == [[NSDate date] beginningOfDay])) {
        return @"Today";
    }
    
    if (section == 1 && ([eventDate beginningOfDay] == [[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay])) {
        return @"Tomorrow";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM d"];
    NSString *dateString = [formatter stringFromDate:eventDate];
    
    return dateString;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[rowCountArray objectAtIndex:section]intValue];
    

}

// %%%%%% Runs through this code every time I scroll in "Attend" Table for some reason %%%%%%%%%%%
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];

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
    
    //eventsArray = [[NSArray alloc]init];
    //eventsArray = [eventQuery findObjects];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *eventsArray, NSError *error) {
    
    for (int i = 0; i < eventsArray.count; i++) {
        
        PFObject *Event = eventsArray[i];
        NSDate *eventDate = Event[@"Date"];
        NSDate *someDate = sectionDates[indexPath.section];
        
        if ([eventDate beginningOfDay] == [someDate beginningOfDay]) {
        
            
            PFObject *Event = eventsArray[i];
            NSDate *eventDate = Event[@"Date"];
            NSDate *rowDate = rowDates[i + indexPath.row];
            
            if ([eventDate beginningOfDay] == [rowDate beginningOfDay]) {
            
                PFObject *Event = eventsArray[i + indexPath.row];
            
                [cell.titleLabel setText:[NSString stringWithFormat:@"%@",Event[@"Title"]]];
                
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
        
                break;
            }
        }
    }
    }];
     
    return cell;
}

/*
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Row selected -- %@", cell.eventID);
    //self.hidesBottomBarWhenPushed = YES;
    //[self performSegueWithIdentifier:@"toMoreDetail" sender:self];
                                            
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row/section from the data source
        int newCount = [rowCountArray[indexPath.section]intValue] - 1;
        
        //if (newCount == 0) {
          //  [rowCountArray removeObjectAtIndex:indexPath.section];
          //  [sectionDates removeObjectAtIndex:indexPath.section];
        //} else
        rowCountArray[indexPath.section] = [NSNumber numberWithInt:newCount];
        
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
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
