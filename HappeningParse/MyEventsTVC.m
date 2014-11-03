//
//  MyEventsTVC.m
//  HappeningParse
//
//  Created by Max on 10/27/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "MyEventsTVC.h"

@interface MyEventsTVC ()

@end

@implementation MyEventsTVC {

NSUInteger count;
NSMutableArray *sectionDates;
NSMutableArray *rowDates;
NSArray *eventsArray;
NSInteger index;
NSInteger sectionIndex;

NSMutableArray *rowCountArray;
NSMutableArray *cells;
NSMutableArray *indexpaths;

}

@synthesize locManager, refreshControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.tabBarController.selectedIndex = 1;
    });
    
    refreshControl = [[UIRefreshControl alloc]init];
    [self setRefreshControl:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {

    [self.tableView reloadData];

    PFUser *user = [PFUser currentUser];
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"CreatedBy" equalTo:user.username];
    
    // Works for now, but doesn't allow for events to be shown from the past
    [eventQuery whereKey:@"Date" greaterThan:[NSDate date]];
    [eventQuery orderByAscending:@"Date"];
    
    eventsArray = [[NSArray alloc]init];
    eventsArray = [eventQuery findObjects];
    
    count = eventsArray.count;
    
   // NSLog(@"%lu", (unsigned long)count);
    
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
                
                //NSLog(@"%@", eventObject[@"Title"]);
                rowCount++;
                
                [rowDates addObject:someDate];
                
            }
            
        }
        
    }
    
    //NSLog(@"%lu",(unsigned long)[rowDates count]);
    
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

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [sectionDates count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM d"];
    NSDate *eventDate = [[NSDate alloc]init];
    eventDate = sectionDates[section];
    NSString *dateString = [formatter stringFromDate:eventDate];
    
    return dateString;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[rowCountArray objectAtIndex:section]intValue];
    
    
}

// %%%%%% Runs through this code every time I scroll in "Attend" Table for some reason %%%%%%%%%%%
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"event" forIndexPath:indexPath];
    
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
                if(self.locManager==nil){
                    locManager = [[CLLocationManager alloc] init];
                    locManager.delegate=self;
                    [locManager requestAlwaysAuthorization];
                    locManager.desiredAccuracy=kCLLocationAccuracyBest;
                    locManager.distanceFilter=50;
                    
                }
                
                // Might want to delete this-- If I do, if someone decides to turn location services off, they will continue to get a message every time they launch the app...
                if([CLLocationManager locationServicesEnabled]){
                    [self.locManager startUpdatingLocation];
                    CLLocation *currentLocation = locManager.location;
                    //NSLog(@"Current Location is: %@", currentLocation);
                }
                
                PFGeoPoint *loc = Event[@"GeoLoc"];
                
                if (loc.latitude == 0) {
                    cell.distance.text = @"";
                } else {
                    PFGeoPoint *userLoc = [PFGeoPoint geoPointWithLocation:(locManager.location)];
                    NSNumber *meters = [NSNumber numberWithDouble:([loc distanceInMilesTo:userLoc])];
                    NSString *distance = [NSString stringWithFormat:(@"%.2f mi"), meters.floatValue];
                    cell.distance.text = distance;
                }
                
                index++;
                
                if (index > eventsArray.count - 1) {
                    index = 0;
                    
                }
                break;
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

@end
