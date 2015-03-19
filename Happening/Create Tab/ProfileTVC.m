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
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

@interface ProfileTVC () <EventTVCDelegate>

@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

@end

@implementation ProfileTVC {
    
    PFUser *user;
    NSArray *eventsArray;
}

//@synthesize locManager, refreshControl;
@synthesize sections, sortedDays, locManager;
@synthesize nameLabel, detailLabel, profilePicImageView, myEventsTableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    user = [PFUser currentUser];
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
    detailLabel.text = [NSString stringWithFormat:@"%@", user[@"city"]];
    
    FBProfilePictureView *profPicView = [[FBProfilePictureView alloc] initWithProfileID:user[@"FBObjectID"] pictureCropping:FBProfilePictureCroppingSquare];
    profPicView.layer.cornerRadius = 10;
    profPicView.layer.masksToBounds = YES;
    profPicView.layer.borderColor = [UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0].CGColor;
    profPicView.layer.borderWidth = 3.0;
    profPicView.frame = CGRectMake(120, 24, 80, 80);
    [self.view addSubview:profPicView];
    
    profilePicImageView.layer.cornerRadius = 10;
    profilePicImageView.layer.masksToBounds = YES;
    profilePicImageView.layer.borderColor =  [UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0].CGColor;
    profilePicImageView.layer.borderWidth = 3.0;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    
    //[self.tableView reloadData];
    
    [self setEnabledSidewaysScrolling:YES];
    
    // Instantiate event dictionary--- this is where all event info is stored
    self.sections = [NSMutableDictionary dictionary];
    
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"CreatedBy" equalTo:user.objectId];
    
    // Works for now, but doesn't allow for events to be shown from the past
    [eventQuery whereKey:@"Date" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-2592000]]; //30 days
    [eventQuery orderByAscending:@"Date"];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        eventsArray = array;
        
        [self.tableView reloadData];
    }];
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE, MMMM d"];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [eventsArray count];
    
}

// %%%%%% Runs through this code every time I scroll in Table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttendTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];
    
    [cell setupCell];
    
    PFObject *Event = eventsArray[indexPath.row];
    
    [cell.titleLabel setText:[NSString stringWithFormat:@"%@",Event[@"Title"]]];
    
    if (Event[@"Description"])
        [cell.subtitle setText:[NSString stringWithFormat:@"%@",Event[@"Description"]]];
    else
        [cell.subtitle setText:[NSString stringWithFormat:@""]];
    
    [cell.locLabel setText:[NSString stringWithFormat:@"%@",Event[@"Location"]]];
    
    cell.eventID = Event.objectId;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, MMM d"];
    NSDate *eventDate = [[NSDate alloc]init];
    eventDate = Event[@"Date"];
    
    NSString *finalString;
    
    // FORMAT FOR MULTI-DAY EVENT
    NSDate *endDate = Event[@"EndTime"];
    
    
    if ([eventDate beginningOfDay] == [[NSDate date]beginningOfDay]) {  // TODAY
        
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"Today at %@", timeString];
        
    } else if ([eventDate beginningOfDay] == [[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]) { // TOMORROW
        
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"Tomorrow at %@", timeString];
        
    } else if ([eventDate endOfWeek] == [[NSDate date]endOfWeek]) { // SAME WEEK
        
        /*
        [formatter setDateFormat:@"EEEE"];
        NSString *dayOfWeekString = [formatter stringFromDate:eventDate];
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"%@ at %@", dayOfWeekString, timeString];
         */
        NSString *dateString = [formatter stringFromDate:eventDate];
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
        
    } else if ([eventDate beginningOfDay] != [endDate beginningOfDay]) { //MULTI-DAY EVENT
        
        [formatter setDateFormat:@"MMM d"];
        NSString *dateString = [formatter stringFromDate:eventDate];
        NSString *endDateString = [formatter stringFromDate:endDate];
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        NSString *endTimeString = [formatter stringFromDate:endDate];
        
        finalString = [NSString stringWithFormat:@"%@ at %@ to %@ at %@", dateString, timeString, endDateString, endTimeString];
        
    } else { // Past this week- uses abbreviated date format
        
        NSString *dateString = [formatter stringFromDate:eventDate];
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
        
    }
    
    [cell.timeLabel setText:[NSString stringWithFormat:@"%@",finalString]];
    
    cell.eventImageView.image = [UIImage imageNamed:Event[@"Hashtag"]];
    
    if (Event[@"Image"] != nil) {
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
    
    //cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section != 0) {
        return 22;
    }
    return 10;
}

- (IBAction)refreshTable:(id)sender {
    
    
    NSLog(@"Refreshing data...");
    [sender endRefreshing];
    [self.tableView reloadData];
    NSLog(@"Data refreshed!");
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"showMyEvent"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        AttendTableCell *cell = (AttendTableCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath];
        
        UINavigationController *navController = [segue destinationViewController];
        showMyEventVC *vc = (showMyEventVC *)([navController topViewController]);
        vc.eventID = cell.eventID;
        
    } else if ([segue.identifier isEqualToString:@"createNewEvent"]) {
        
        UINavigationController *navController = [segue destinationViewController];
        EventTVC *vc = (EventTVC *)([navController topViewController]);
        vc.delegate = self;
        
    }
}

- (void)setEnabledSidewaysScrolling:(BOOL)enabled {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    [rk scrolling:enabled];
    
}

@end
