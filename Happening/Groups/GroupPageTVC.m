//
//  GroupPageTVCTableViewController.m
//  Happening
//
//  Created by Max on 6/4/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupPageTVC.h"
#import "GroupsEventCell.h"
#import "GroupChatVC.h"
#import "CupertinoYankee.h"
#import "AppDelegate.h"
#import "GroupRSVP.h"
#import "ExternalProfileTVC.h"
#import "GroupDetailsTVC.h"
#import "SVProgressHUD.h"
#import "CustomConstants.h"

@interface GroupPageTVC ()

@property (strong, nonatomic) IBOutlet UIButton *topButtonView;
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
    
    NSMutableArray *rsvpYesArray;
    NSMutableArray *rsvpNoArray;
    NSMutableArray *rsvpMaybeArray;

    NSMutableArray *allUsers;
    
    NSMutableDictionary *sections;
    NSMutableDictionary *extraSections;

    PFObject *groupEvent;
    
    NSString *friendObjectID;
    
    RKNotificationHub *chatHub;
}

@synthesize groupId, locManager, groupName, chatBubble, conversation, group;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.translucent = NO;
    // self.navigationItem.title = groupName;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.mh hideTabBar:NO];
    
    if(locManager && [CLLocationManager locationServicesEnabled]){
        [self.locManager startUpdatingLocation];
        CLLocation *currentLocation = locManager.location;
        currentUser[@"userLoc"] = [PFGeoPoint geoPointWithLocation:currentLocation];
        NSLog(@"Current Location is: %@", currentLocation);
        [currentUser saveEventually];
    }
    
    currentUser = [PFUser currentUser];
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE, MMMM d"];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.sections = [NSMutableDictionary dictionary];
    
    //if (self.segControl.selectedSegmentIndex == 0)
    [chatBubble addTarget:self action:@selector(chatTapped:) forControlEvents:UIControlEventTouchUpInside];
    allUsers = [NSMutableArray array];
    allUsers = group[@"user_objects"];
    NSLog(@"%lu", allUsers.count);

    
    [self.topButtonView addTarget:self action:@selector(toGroupDetails:) forControlEvents:UIControlEventTouchUpInside];
    
    [self loadChat];
    
    if (self.group) {
        [self loadEventData];
        if (self.loadTopView) {
            /*
            NSArray *usersCopy = [NSArray arrayWithArray:allUsers];
            
            for (int i = 0; i < allUsers.count; i++) {
                
                PFUser *user = allUsers[i];
                if (user.isDataAvailable)
                    [allUsers removeObjectAtIndex:i];
            }*/
            
            [PFObject fetchAllInBackground:allUsers block:^(NSArray *array, NSError *error) {
                if (!error) {

                    //[allUsers addObjectsFromArray:array];
                    allUsers = [NSMutableArray arrayWithArray: array];
                    NSLog(@"%lu", allUsers.count);

                    if (![allUsers containsObject:currentUser]) {
                        NSLog(@"ADDING CURRENT USER");
                        [allUsers addObject:currentUser];
                        group[@"user_objects"] = allUsers;
                        [group saveEventually];
                        
                    }
                    [self loadTopButtonView];
                }
            }];
        }
    } else {
        [SVProgressHUD show];
        [self loadGroup];
    }
    
}

- (void)loadEventData {
    
    rsvpMaybeArray = [NSMutableArray array];
    rsvpNoArray = [NSMutableArray array];
    rsvpYesArray = [NSMutableArray array];
    extraSections = [NSMutableDictionary dictionary];
    
    [SVProgressHUD show];
    
    PFQuery *groupEventQuery = [PFQuery queryWithClassName:@"Group_Event"];
    //[groupEventQuery fromLocalDatastore];
    [groupEventQuery whereKey:@"GroupID" equalTo:group.objectId];
    [groupEventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error){
        
        NSMutableArray *idArray = [NSMutableArray new];
        
        for (PFObject *object in events) {
            
            //[object pinInBackground];
            
            NSMutableDictionary *extras = [NSMutableDictionary dictionary];
            [extraSections setObject:extras forKey:object[@"EventID"]];
            [extras setObject:object.objectId forKey:@"ID"];
            [extras setObject:object forKey:@"eventObject"];
        
            [idArray addObject:object[@"EventID"]];
            
            [extras setObject:allUsers forKey:@"maybe"];
            [extras setObject:[NSMutableArray array] forKey:@"no"];
            [extras setObject:[NSMutableArray array] forKey:@"yes"];
        
        }
        
        PFQuery *groupRSVPQuery = [PFQuery queryWithClassName:@"Group_RSVP"];
        [groupRSVPQuery whereKey:@"EventID" containedIn:idArray];
        [groupRSVPQuery whereKey:@"GroupID" equalTo:group.objectId];
        [groupRSVPQuery includeKey:@"User_Object"];
        [groupRSVPQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            
            for (PFObject *rsvpObject in objects) {
                
                PFUser *user = rsvpObject[@"User_Object"];

                NSMutableDictionary *extras = [extraSections objectForKey:rsvpObject[@"EventID"]];
                NSMutableArray *yesUsers = [extras objectForKey:@"yes"];
                NSMutableArray *noUsers = [extras objectForKey:@"no"];
                NSMutableArray *maybeUsers = [extras objectForKey:@"maybe"];
                
                if ([rsvpObject[@"GoingType"] isEqualToString:@"yes"]) {
                    [yesUsers addObject:user];
                    [maybeUsers removeObject:user];
                    [extras setObject:yesUsers forKey:@"yes"];
                    [extras setObject:maybeUsers forKey:@"maybe"];
                } else if ([rsvpObject[@"GoingType"] isEqualToString:@"no"]) {
                    [noUsers addObject:user];
                    [maybeUsers removeObject:user];
                    [extras setObject:noUsers forKey:@"no"];
                    [extras setObject:maybeUsers forKey:@"maybe"];
                } else if ([rsvpObject[@"GoingType"] isEqualToString:@"maybe"]) {
                    //[maybeUsers addObject:rsvpObject[@"User_Object"]];
                }
             
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
            }
            
        }];
        
        
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
        //[eventQuery fromLocalDatastore];
        [eventQuery whereKey:@"objectId" containedIn:idArray];
        [eventQuery whereKey:@"EndTime" greaterThan:[NSDate date]];
        [eventQuery orderByAscending:@"Date"];
        
        count = 0;
        eventsArray = [[NSArray alloc]init];
        
        [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error){
            
            eventsArray = events;
            //NSLog(@"Events Array: %@", events);
            
            for (PFObject *event in eventsArray)
            {
                //[event pinInBackground];
                
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
         
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
            
          }];
        
    }];
    
}

- (void)loadGroup {
    
    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
    [groupQuery includeKey:@"user_objects"];
    [groupQuery getObjectInBackgroundWithId:[conversation.metadata valueForKey:@"groupId"] block:^(PFObject *ob, NSError *error){
        
        if (!error) {
        
            NSLog(@"Loading group...");
            group = ob;
            [group pinInBackground];
            allUsers = [NSMutableArray array];
            allUsers = group[@"user_objects"];

            [self loadEventData];
            [self loadTopButtonView];
        
        } else {
            [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
        }
        
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
    
    
    GroupsEventCell *cell = (GroupsEventCell *)[tableView dequeueReusableCellWithIdentifier:@"groupEvent" forIndexPath:indexPath];
    
    [noEventsView removeFromSuperview];
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    
    PFObject *Event = eventsOnThisDay[indexPath.row];
    cell.eventId = Event.objectId;
    
    [cell.titleLabel setText:[NSString stringWithFormat:@"%@",Event[@"Title"]]];
    
    [cell.locationLabel setText:[NSString stringWithFormat:@"at %@",Event[@"Location"]]];
    
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
        
        if (meters.floatValue >= 100.0) {
            
            NSString *distance = [NSString stringWithFormat:(@"100+ mi")];
            cell.distanceLabel.text = distance;
            
        } else if (meters.floatValue >= 10.0) {
            
            NSString *distance = [NSString stringWithFormat:(@"%.f mi"), meters.floatValue];
            cell.distanceLabel.text = distance;
            
        } else {
            
            NSString *distance = [NSString stringWithFormat:(@"%.1f mi"), meters.floatValue];
            cell.distanceLabel.text = distance;
        }
        
    }
    
    [cell.distanceLabel sizeToFit];
    
    [[cell viewWithTag:77] removeFromSuperview];
    UIImageView *locIMV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locationPinThickOutline"]];
    locIMV.frame = CGRectMake(290 - cell.distanceLabel.frame.size.width - 11 - 4, 38, 11, 13);
    [cell.contentView addSubview:locIMV];
    locIMV.tag = 77;
    
    //cell.interestedLabel.text = [NSString stringWithFormat:@"%@ interested", Event[@"swipesRight"]];
    
    NSMutableDictionary *dict = [extraSections objectForKey:Event.objectId];
    NSArray *maybe = [dict objectForKey:@"maybe"];
    NSArray *no = [dict objectForKey:@"no"];
    NSArray *yes = [dict objectForKey:@"yes"];
    
    NSUInteger totalCount = allUsers.count;
    NSString *rsvpCount = [NSString stringWithFormat:@"%lu of %lu", (unsigned long)yes.count, (unsigned long)totalCount];
    
    [cell.rsvpButton setTitle:rsvpCount forState:UIControlStateNormal];
    
    cell.groupEventId = [dict objectForKey:@"ID"];
    
    [cell.chatButton addTarget:self action:@selector(chatTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.groupEventObject = [dict objectForKey:@"eventObject"];
    
    NSString *invitedByName = cell.groupEventObject[@"invitedByName"];
    
    if ([cell.groupEventObject[@"invitedByID"] isEqualToString:currentUser.objectId]) {
        cell.invitedByLabel.text = @"Invited by you";
    } else {
        NSString *firstWord = [[invitedByName componentsSeparatedByString:@" "] objectAtIndex:0];
        NSString *secondWord = [[invitedByName componentsSeparatedByString:@" "] objectAtIndex:1];
        cell.invitedByLabel.text = [NSString stringWithFormat:@"Invited by %@ %@.", firstWord, [secondWord substringToIndex:1]];
    }
    
    int userCount = 0;
    
    //NSLog(@"YES: %@", yes);
    //NSLog(@"NO: %@", no);
    //NSLog(@"MAYBE: %@", maybe);

    
    for (int i = 0; i < cell.subviews.count; i++) {
        UIView *view = cell.subviews[i];
        if (view.tag == 9)
            [view removeFromSuperview];
    }
    
    
    for (int i = 0; i < yes.count; i++) {
        
        PFUser *user = yes[i];
        
        if ([user.objectId isEqualToString:currentUser.objectId]) {
            cell.cornerImageView.image = [UIImage imageNamed:@"check75"];
            [cell.checkButton setImage:[UIImage imageNamed:@"checked6green"] forState:UIControlStateNormal];
            [cell.xButton setImage:[UIImage imageNamed:@"close7"] forState:UIControlStateNormal];
            cell.checkButton.tag = 1;
            cell.xButton.tag = 0;
            
        } else if (userCount < 2) {
            
            UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(164 + 50*userCount, 92, 40, 40)];
            FBSDKProfilePictureView *profPic = [[FBSDKProfilePictureView alloc] initWithFrame:picViewContainer.bounds];
            profPic.profileID = user[@"FBObjectID"];
            [picViewContainer addSubview:profPic];
            picViewContainer.tag = 9;
            
            profPic.layer.cornerRadius = 20.0;
            profPic.layer.masksToBounds = YES;
            
            UIImageView *cornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
            cornerImageView.image = [UIImage imageNamed:@"check75"];
            cornerImageView.layer.cornerRadius = 7.5;
            cornerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            cornerImageView.layer.borderWidth = 1.0;
            [picViewContainer addSubview:cornerImageView];
            
            [cell addSubview:picViewContainer];
            
            userCount++;
        }
        
    }
    
    for (int i = 0; i < maybe.count; i++) {
        
        PFUser *user = maybe[i];
        
        if ([user.objectId isEqualToString:currentUser.objectId]) {
            cell.cornerImageView.image = [UIImage imageNamed:@"question"];
            [cell.checkButton setImage:[UIImage imageNamed:@"checked6"] forState:UIControlStateNormal];
            [cell.xButton setImage:[UIImage imageNamed:@"close7"] forState:UIControlStateNormal];
            cell.checkButton.tag = 0;
            cell.xButton.tag = 0;
            
        } else if (userCount < 2) {
            
            UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(164 + 50*userCount, 92, 40, 40)];
            FBSDKProfilePictureView *profPic = [[FBSDKProfilePictureView alloc] initWithFrame:picViewContainer.bounds];
            profPic.profileID = user[@"FBObjectID"];
            [picViewContainer addSubview:profPic];
            
            profPic.layer.cornerRadius = 20.0;
            profPic.layer.masksToBounds = YES;
            
            UIImageView *cornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
            cornerImageView.image = [UIImage imageNamed:@"question"];
            cornerImageView.layer.cornerRadius = 7.5;
            cornerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            cornerImageView.layer.borderWidth = 1.0;
            [picViewContainer addSubview:cornerImageView];
            picViewContainer.tag = 9;
            
            [cell addSubview:picViewContainer];
            
            userCount++;
        }
    }
    
    for (int i = 0; i < no.count; i++) {
        
        PFUser *user = no[i];
        
        if ([user.objectId isEqualToString:currentUser.objectId]) {
            cell.cornerImageView.image = [UIImage imageNamed:@"X"];
            [cell.checkButton setImage:[UIImage imageNamed:@"checked6"] forState:UIControlStateNormal];
            [cell.xButton setImage:[UIImage imageNamed:@"close7red"] forState:UIControlStateNormal];
            cell.xButton.tag = 1;
            cell.checkButton.tag = 0;
            
        } else if (userCount < 2) {
            
            UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(164 + 50*userCount, 92, 40, 40)];
            FBSDKProfilePictureView *profPic = [[FBSDKProfilePictureView alloc] initWithFrame:picViewContainer.bounds];
            profPic.profileID = user[@"FBObjectID"];
            [picViewContainer addSubview:profPic];
            
            profPic.layer.cornerRadius = 20.0;
            profPic.layer.masksToBounds = YES;
            
            UIImageView *cornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
            cornerImageView.image = [UIImage imageNamed:@"X"];
            cornerImageView.layer.cornerRadius = 7.5;
            cornerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            cornerImageView.layer.borderWidth = 1.0;
            [picViewContainer addSubview:cornerImageView];
            picViewContainer.tag = 9;
            
            [cell addSubview:picViewContainer];
            
            userCount++;
        }
    }
    
    
    

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section != 0) {
        return 22;
    }
    return 33;
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
    [self loadEventData];
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
        UILabel *subDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(67, 16 - 7, 100, 20)];
        subDateLabel.textColor = [UIColor darkTextColor];
        subDateLabel.font = [UIFont fontWithName:@"OpenSans" size:9];
        subDateLabel.tag = 99;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        subDateLabel.text = dateString;
        
        [header.contentView addSubview:subDateLabel];
        
    }  else if ([header.textLabel.text isEqualToString:@"TOMORROW"] && section == 0) {
        
        UILabel *subDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(107, 16 - 7, 100, 20)];
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

- (void)loadChat {
    
    if (conversation.hasUnreadMessages) {
        chatHub = [[RKNotificationHub alloc]initWithView:(UIView *)chatBubble]; // sets the count to 0
        
        //%%% CIRCLE FRAME
        //[hub setCircleAtFrame:CGRectMake(-10, -10, 30, 30)]; //frame relative to the view you set it to
        
        //%%% MOVE FRAME
        [chatHub moveCircleByX:-6 Y:6]; // moves the circle 5 pixels left and down from its current position
        
        //%%% CIRCLE SIZE
        [chatHub scaleCircleSizeBy:0.2]; // doubles the size of the circle, keeps the same center
        
        [chatHub setCircleColor: [UIColor colorWithRed:0 green:176.0/255 blue:255.0/255 alpha:1.0] labelColor:[UIColor whiteColor]];
        [chatHub increment];
        [chatHub hideCount];
        [chatHub pop];
    }
    
}

- (void)chatTapped:(id)sender {
    
    [chatBubble setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
    [chatHub decrementBy:chatHub.count];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    GroupChatVC *controller = [GroupChatVC conversationViewControllerWithLayerClient:appDelegate.layerClient];

    controller.usersArray = allUsers;
    controller.groupObject = group;
    controller.conversation = conversation;
     
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)loadTopButtonView {
    
    float width = (allUsers.count * 50 + 5);
    if (width > 280) width = 280;
    UIView *picView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    picView.center = CGPointMake(self.topButtonView.center.x - 15, self.topButtonView.center.y);
    picView.userInteractionEnabled = YES;
    [picView addGestureRecognizer:[[UIGestureRecognizer alloc] initWithTarget:self action:@selector(toGroupDetails:)]];
    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(picView.frame.size.width + 5, 17.5, 15, 15)];
    [moreButton setImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
    [picView addSubview:moreButton];
    
    [self.topButtonView addSubview:picView];
    
    NSInteger userCount = allUsers.count;
    if (userCount > 5) userCount = 5;
    
    for (int i = 0; i < userCount; i++) {
                
        PFUser *user = allUsers[i];
        
        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(5 + 50 * i, 5, 40, 40)]; // initWithProfileID:user[@"FBObjectID"] pictureCropping:FBSDKProfilePictureModeSquare];
        if (user.isDataAvailable || [user.objectId isEqualToString:currentUser.objectId]) {
            profPicView.profileID = user[@"FBObjectID"];
            UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFriendProfile:)];
            [profPicView addGestureRecognizer:gr];
        }
        profPicView.pictureMode = FBSDKProfilePictureModeSquare;
        
        profPicView.layer.cornerRadius = 20;
        profPicView.layer.masksToBounds = YES;
        profPicView.accessibilityIdentifier = user.objectId;
        profPicView.userInteractionEnabled = YES;
        
        [picView addSubview:profPicView];
        
        /*
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont fontWithName:@"OpenSans" size:7];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.text = object[@"firstName"];
        nameLabel.frame = CGRectMake(5 + (50 * friendCount), 42, 30, 8);
        [friendScrollView addSubview:nameLabel];
        
        friendScrollView.contentSize = CGSizeMake((50 * friendCount) + 40, 50);
         
         */
        
    }
    
    self.loadTopView = NO;
    
}

- (void)toGroupDetails:(UIGestureRecognizer *)gr {
    
    //GroupPageTVC *vc = [[GroupPageTVC alloc] init];
    //[self.navigationController pushViewController:vc animated:YES];

    [self performSegueWithIdentifier:@"toDetails" sender:self];
}

- (IBAction)saveWhosGoing:(id)sender {
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    GroupsEventCell *cell = (GroupsEventCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSMutableDictionary *dict = [extraSections objectForKey:cell.eventId];
    rsvpMaybeArray = [[NSMutableArray alloc] initWithArray: [dict objectForKey:@"maybe"]];
    rsvpNoArray = [[NSMutableArray alloc] initWithArray: [dict objectForKey:@"no"]];
    rsvpYesArray = [[NSMutableArray alloc] initWithArray: [dict objectForKey:@"yes"]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group_RSVP"];
    [query whereKey:@"Group_Event_ID" equalTo:cell.groupEventId];
    [query fromLocalDatastore];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        PFObject *rsvpObject = [PFObject objectWithClassName:@"Group_RSVP"];
    
        if (!error) {
            
            rsvpObject = object;
            if (cell.checkButton.tag == 1) {
               object[@"GoingType"] = @"yes";
            } else if (cell.xButton.tag == 1) {
                object[@"GoingType"] = @"no";
            } else {
                object[@"GoingType"] = @"maybe";
            }
            
        } else {
            
            rsvpObject[@"EventID"] = cell.eventId;
            rsvpObject[@"GroupID"] = group.objectId;
            rsvpObject[@"Group_Event_ID"] = groupEvent.objectId;
            rsvpObject[@"UserID"] = currentUser.objectId;
            rsvpObject[@"User_Object"] = currentUser;
            rsvpObject[@"GoingType"] = @"yes";
            [rsvpObject pinInBackground];
            [rsvpObject saveEventually];
        }
        
        
        [rsvpObject saveEventually:^(BOOL success, NSError *error){
            
            if (!error && (cell.xButton.tag == 1 || cell.checkButton.tag == 1)) {
                
                NSString *messageText = @"";
                if (cell.checkButton.tag == 1) {
                    messageText = [NSString stringWithFormat:@"%@ %@ is going to '%@'", currentUser[@"firstName"], currentUser[@"lastName"], cell.titleLabel.text];
                } else if (cell.xButton.tag == 1) {
                    messageText = [NSString stringWithFormat:@"%@ %@ is not going to '%@'", currentUser[@"firstName"], currentUser[@"lastName"], cell.titleLabel.text];
                }
                
                NSDictionary *dataDictionary = @{@"message":messageText,
                                                 @"type":@"RSVP",
                                                 @"groupId":group.objectId,
                                                 };
                NSError *JSONSerializerError;
                NSData *dataDictionaryJSON = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
                LYRMessagePart *dataMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemObject data:dataDictionaryJSON];
                // Create messagepart with info about cell
                float actualLineSize = [messageText boundingRectWithSize:CGSizeMake(270, CGFLOAT_MAX)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:10.0]}
                                                                 context:nil].size.height;
                NSDictionary *cellInfoDictionary = @{@"height": [NSString stringWithFormat:@"%f", actualLineSize]};
                NSData *cellInfoDictionaryJSON = [NSJSONSerialization dataWithJSONObject:cellInfoDictionary options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
                LYRMessagePart *cellInfoMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemCellInfo data:cellInfoDictionaryJSON];
                // Add message to ordered set.  This ordered set messages will get sent to the participants
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart,cellInfoMessagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:&error];
                
                // Sends the specified message
                BOOL success = [conversation sendMessage:message error:&error];
                if (success) {
                    //NSLog(@"Message queued to be sent: %@", message);
                } else {
                    NSLog(@"Message send failed: %@", error);
                }
            }
            
        }];
    
    }];
}

- (void)showFriendProfile:(UIGestureRecognizer *)gr {
    
    UIView *view = gr.view;
    friendObjectID = view.accessibilityIdentifier;
    [self performSegueWithIdentifier:@"toProf" sender:self];

}

- (IBAction)xButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        //<#code#>
    }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"toRSVP"]) {
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        GroupsEventCell *cell = (GroupsEventCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        NSMutableDictionary *dict = [extraSections objectForKey:cell.eventId];
        rsvpMaybeArray = [dict objectForKey:@"maybe"];
        rsvpNoArray = [dict objectForKey:@"no"];
        rsvpYesArray = [dict objectForKey:@"yes"];
        
        GroupRSVP *vc = (GroupRSVP *)[[segue destinationViewController] topViewController];
        vc.yesUsers = [NSMutableArray arrayWithArray:rsvpYesArray];
        vc.noUsers = [NSMutableArray arrayWithArray:rsvpNoArray];
        vc.maybeUsers = [NSMutableArray arrayWithArray:rsvpMaybeArray];
        vc.groupEventId = [dict objectForKey:@"ID"];
        
        vc.group = group;
        vc.titleString = cell.titleLabel.text;
        vc.convo = conversation;

    } else if ([segue.identifier isEqualToString:@"toChat"]) {
        
        GroupChatVC *vc = (GroupChatVC *)[segue destinationViewController];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        vc = [GroupChatVC conversationViewControllerWithLayerClient:appDelegate.layerClient];
        
    } else if ([segue.identifier isEqualToString:@"toProf"]) {
        
        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.userID = friendObjectID;
        
    } else if ([segue.identifier isEqualToString:@"toDetails"]) {
        
        GroupDetailsTVC *vc = (GroupDetailsTVC *)[segue destinationViewController];
        vc.groupNameString = self.title;
        vc.group = group;
        vc.users = allUsers;
        vc.convo = conversation;
    
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

@end
