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
//#import "FXBlurView.h"

@interface AttendEvent ()

- (NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;

@end

@implementation AttendEvent {
    NSInteger count;
    NSArray *eventsArray;
    NSMutableArray *sectionHeaders1;
    UIView *noEventsView;
}

@synthesize locManager, refreshControl;


- (void)viewDidLoad {
    
    [super viewDidLoad];
        
}

-(void)viewWillAppear:(BOOL)animated {
    
    [self setEnabledSidewaysScrolling:YES];
    
    [self loadData];
}

- (void)loadData {
    
    sectionHeaders1 = [[NSMutableArray alloc] init];
    
    PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    // Query only for current user's events
    PFUser *user = [PFUser currentUser];
    [swipesQuery whereKey:@"UserID" equalTo:user.objectId];
    [swipesQuery whereKey:@"swipedRight" equalTo:@YES];
    //NSArray *swipesArray = [swipesQuery findObjects];
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"objectId" matchesKey:@"EventID" inQuery:swipesQuery];
    [eventQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]]; // show today's events, must be at least 30 minutes left in the event (END)
    [eventQuery orderByAscending:@"swipesRight"];
    
    count = 0;
    
    eventsArray = [[NSArray alloc]init];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        
        eventsArray = events;
        
        if (eventsArray.count == 0) {
            
            [noEventsView removeFromSuperview];
            //[self noEvents];
            
        } else {
            
            [noEventsView removeFromSuperview];
        }
        
        for (int i = 0; i < eventsArray.count; i++) {
            
            if (i == 0) {
                [sectionHeaders1 addObject:[NSString stringWithFormat:@"The must-do:"]];
            } else if (i == 1) {
                [sectionHeaders1 addObject:[NSString stringWithFormat:@"Runner-up:"]];
            } else {
                [sectionHeaders1 addObject:[NSString stringWithFormat:@"#%d", i+1]];
            }
        }
        
        [self.tableView reloadData];
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [sectionHeaders1 count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [sectionHeaders1 objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendTableCell *cell = (AttendTableCell *)[tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];

    [noEventsView removeFromSuperview];
    
    [cell setupCell];
    
    PFObject *Event = eventsArray[indexPath.section];
    
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

    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor darkGrayColor]];
    [header.textLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:14]];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section != 0) {
        return 22;
    }
    return 33;
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

- (void)setEnabledSidewaysScrolling:(BOOL)enabled {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    [rk scrolling:enabled];
    
}

- (void)showNavTitle {
    
    NSLog(@"show title");
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    rk.rightLabel.alpha = 1.0;
    rk.middleButton2.alpha = 1.0;
    rk.middleButton.alpha = 0.0;
}

- (void)noEvents {
    
    
    noEventsView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //noEventsView.backgroundColor = [UIColor redColor];
        
    [self.view addSubview:noEventsView];
    
    UILabel *topTextLabel = [[UILabel alloc] init];
    topTextLabel.text = @"Uh oh!";
    topTextLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
    topTextLabel.textColor = [UIColor colorWithRed:153.0/255 green:154.0/255 blue:155.0/255 alpha:1.0];
    [topTextLabel sizeToFit];
    topTextLabel.center = CGPointMake(self.view.center.x, 75);
    [noEventsView addSubview:topTextLabel];
    
    
    UILabel *bottomTextLabel = [[UILabel alloc] init];
    bottomTextLabel.text = @"You haven't saved any events.";
    bottomTextLabel.font = [UIFont fontWithName:@"OpenSans" size:18.0];
    bottomTextLabel.textColor = [UIColor colorWithRed:153.0/255 green:154.0/255 blue:155.0/255 alpha:1.0];
    [bottomTextLabel sizeToFit];
    bottomTextLabel.center = CGPointMake(self.view.center.x, 100);
    [noEventsView addSubview:bottomTextLabel];
    
    
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
    
}

- (void)discoverButtonTapped {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    [rk tapSegmentButtonAction:rk.middleButton];
    [rk middleButtonTapped];
    
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
        
        vc.attendEventVC = self;
        
        vc.hidesBottomBarWhenPushed = YES;
        
        // pass the element to this detail view controller
        //viewController.element = element;
    }

}

@end
