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
#import "ExpandedCardVC.h"

@interface GroupPageTVC () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, GroupDetailsTVCDelegate>

@property (strong, nonatomic) IBOutlet UIButton *topButtonView;
@property (strong, nonatomic) NSMutableDictionary *sections;
@property (strong, nonatomic) NSArray *sortedDays;
@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *cellDateFormatter;
//@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GroupPageTVC {
    
    PFUser *currentUser;
    NSUInteger count;
    
    NSMutableArray *rsvpYesArray;
    NSMutableArray *rsvpNoArray;
    NSMutableArray *rsvpMaybeArray;
    
    NSMutableDictionary *sections;
    NSMutableDictionary *extraSections;
    
    NSString *friendObjectID;
    
    RKNotificationHub *chatHub;
    
    NSMutableArray *fbIds;
    NSMutableArray *parseIds;
    NSMutableArray *names;
    NSMutableArray *eventIdsArray;
    
    NSMutableArray *pastEventsArray;
    BOOL pastEventsLoaded;
    
    NSMutableDictionary *imagesDict;
    
    BOOL groupChanged;
}

@synthesize groupId, locManager, groupName, chatBubble, conversation, group, containerView, userDicts, noEventsView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    //[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    //self.navigationController.navigationBar.translucent = NO;
    // self.navigationItem.title = groupName;
    
    currentUser = [PFUser currentUser];
    
    self.sectionDateFormatter = [[NSDateFormatter alloc] init];
    [self.sectionDateFormatter setDateFormat:@"EEEE, MMMM d"];
    
    self.cellDateFormatter = [[NSDateFormatter alloc] init];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.sections = [NSMutableDictionary dictionary];
    
    //if (self.segControl.selectedSegmentIndex == 0)
    [chatBubble addTarget:self action:@selector(chatTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.viewPastEventsButton addTarget:self action:@selector(loadPastEvents) forControlEvents:UIControlEventTouchUpInside];
    
    //[SVProgressHUD setViewForExtension:self.view];
    //[SVProgressHUD showWithStatus:@"Loading group..."];
    
    [self.topButtonView addTarget:self action:@selector(toGroupDetails:) forControlEvents:UIControlEventTouchUpInside];
    
    names = [NSMutableArray new];
    fbIds = [NSMutableArray new];
    parseIds = [NSMutableArray new];
    
    pastEventsArray = [NSMutableArray new];
    pastEventsLoaded = NO;
    
    for (NSDictionary *dict in userDicts) {
        
        [names addObject:[dict valueForKey:@"name"]];
        [fbIds addObject:[dict valueForKey:@"id"]];
        [parseIds addObject:[dict valueForKey:@"parseId"]];
        
    }
    
    if (self.isModal)
        [noEventsView viewWithTag:33].alpha = 0;
    
    //[self loadChat];
    
    if (self.group.isDataAvailable) {
        [self loadEventData];
        if (self.loadTopView) {
            /*
             NSArray *usersCopy = [NSArray arrayWithArray:allUsers];
             
             for (int i = 0; i < allUsers.count; i++) {
             
             PFUser *user = allUsers[i];
             if (user.isDataAvailable)
             [allUsers removeObjectAtIndex:i];
             }*/
            
            self.topButtonView.enabled = NO;
            [self loadTopButtonView];
            
            /*
             [PFObject fetchAllInBackground:allUsers block:^(NSArray *array, NSError *error) {
             if (!error) {
             
             //[allUsers addObjectsFromArray:array];
             allUsers = [NSMutableArray arrayWithArray: array];
             NSLog(@"%lu", allUsers.count);
             
             for (PFUser *user in allUsers) {
             NSLog(@"%@", user[@"firstName"]);
             }
             
             
             [self loadTopButtonView];
             }
             }];*/
        }
    } else {
        [self loadGroup];
    }
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self.tableView sendSubviewToBack:refreshControl];
    
    //isRefreshing = NO;
    
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    
    [self updateEvents];
    //[self updateMe];
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    [refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.title = group[@"name"];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.mh hideTabBar:NO];
    
    if(locManager && [CLLocationManager locationServicesEnabled]){
        [self.locManager startUpdatingLocation];
        CLLocation *currentLocation = locManager.location;
        currentUser[@"userLoc"] = [PFGeoPoint geoPointWithLocation:currentLocation];
        NSLog(@"Current Location is: %@", currentLocation);
        [currentUser saveEventually];
    }

    if (eventIdsArray == nil) eventIdsArray = [NSMutableArray array];
    else [self didRsvpsChange];
    
}

- (void)loadEventData {
    
    rsvpMaybeArray = [NSMutableArray array];
    rsvpNoArray = [NSMutableArray array];
    rsvpYesArray = [NSMutableArray array];
    extraSections = [NSMutableDictionary dictionary];
    
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD showWithStatus:@"Loading Events..."];
    
    
    PFQuery *groupEventQuery = [PFQuery queryWithClassName:@"Group_Event"];
    [groupEventQuery fromLocalDatastore];
    [groupEventQuery whereKey:@"GroupID" equalTo:group.objectId];
    [groupEventQuery findObjectsInBackgroundWithBlock:^(NSArray *groupEvents, NSError *error){
        
        NSMutableArray *idsArray = [NSMutableArray array];
        
        for (PFObject *object in groupEvents) {
            
            //[object pinInBackground];
            
            if (object.objectId != nil) {
            
                NSMutableDictionary *extras = [NSMutableDictionary dictionary];
                [extraSections setObject:extras forKey:object[@"EventID"]];
                [extras setObject:object.objectId forKey:@"ID"];
                [extras setObject:object forKey:@"groupEventObject"];
                [extras setObject:@NO forKey:@"hasLoaded"];
            
                [idsArray addObject:object[@"EventID"]];
                
                [extras setObject:[NSMutableArray arrayWithArray:fbIds] forKey:@"maybe"];
                [extras setObject:[NSMutableArray array] forKey:@"no"];
                [extras setObject:[NSMutableArray array] forKey:@"yes"];
                
                NSMutableArray *picsArray = [NSMutableArray array];
                for (NSString *fbid in fbIds) {
                    [picsArray addObject:[self ppViewForId:fbid]];
                }
                [extras setObject:picsArray forKey:@"maybePics"];
                [extras setObject:[NSMutableArray array] forKey:@"yesPics"];
                [extras setObject:[NSMutableArray array] forKey:@"noPics"];
            
            }
        
        }
        
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
        [eventQuery fromLocalDatastore];
        [eventQuery whereKey:@"objectId" containedIn:idsArray];
        [eventQuery whereKey:@"Date" greaterThan:[[NSDate date] beginningOfDay]];
        [eventQuery orderByAscending:@"Date"];
        
        count = 0;
        
        [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error){
            
            if (!error && events.count > 0) {
                
                for (PFObject *event in events) {
                    
                    [eventIdsArray addObject:event.objectId];
                    
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
                    
                    NSMutableDictionary *dict = [extraSections objectForKey:event.objectId];
                    if ([dict objectForKey:@"Image"] == nil) {
                        if (event[@"Image"] != nil) [dict setObject:event[@"Image"] forKey:@"Image"];
                        else [dict setObject:[UIImage imageNamed:event[@"Hashtag"]] forKey:@"Image"];
                    }

                    
                    count++;
                }
                
                // Create a sorted list of days
                NSArray *unsortedDays = [self.sections allKeys];
                self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
                
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
                
                
            } else {
                
                PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
                [eventQuery whereKey:@"objectId" containedIn:idsArray];
                [eventQuery whereKey:@"Date" greaterThan:[[NSDate date] beginningOfDay]];
                [eventQuery orderByAscending:@"Date"];
                
                count = 0;
                
                [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error){
                    
                    if (!error) {
                        
                        for (PFObject *event in events) {
                            
                            [eventIdsArray addObject:event.objectId];
                            
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
                            
                            NSMutableDictionary *dict = [extraSections objectForKey:event.objectId];
                            if ([dict objectForKey:@"Image"] == nil) {
                                if (event[@"Image"] != nil) [dict setObject:event[@"Image"] forKey:@"Image"];
                                else [dict setObject:[UIImage imageNamed:event[@"Hashtag"]] forKey:@"Image"];
                            }
                            
                            
                            count++;
                        }
                        
                        // Create a sorted list of days
                        NSArray *unsortedDays = [self.sections allKeys];
                        self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
                        
                        if (events.count == 0) {
                            
                            [self.view addSubview:noEventsView];
                            
                        } else {
                            
                            [noEventsView removeFromSuperview];
                        }
                        
                        [SVProgressHUD dismiss];
                        [self.tableView reloadData];
                        
                    }
                }];
                
            }
            
        }];
        
        //[self loadRsvpsWithEventIds:idArray];
        
    }];
    
}


- (void)updateEvents {
    
    PFQuery *groupEventQuery = [PFQuery queryWithClassName:@"Group_Event"];
    [groupEventQuery whereKey:@"GroupID" equalTo:self.group.objectId];
    [groupEventQuery findObjectsInBackgroundWithBlock:^(NSArray *groupEvents, NSError *error){
        
        if (!error) {
            
            [PFObject pinAllInBackground:groupEvents block:^(BOOL success, NSError *error){
                
                if (success) {
                    NSLog(@"successfully updated and pinned %lu group events", groupEvents.count);
                } else {
                    NSLog(@"failed to update and pin group events with error: %@", error);
                    
                }
                
            }];
            
            NSMutableArray *eventIds = [NSMutableArray array];
            for (PFObject *groupEvent in groupEvents) {
                [eventIds addObject:groupEvent[@"EventID"]];
            }
            
            PFQuery *localEventQuery = [PFQuery queryWithClassName:@"Event"];
            [localEventQuery fromLocalDatastore];
            localEventQuery.limit = 1000;
            [localEventQuery whereKey:@"objectId" containedIn:eventIds];
            [localEventQuery selectKeys:@[@"objectId"]];
            [localEventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
                
                if (!error) {
                    
                    for (PFObject *event in events) {
                        
                        [eventIds removeObject:event.objectId];
                    }
                    
                    if (eventIds.count > 0) {
                        
                        PFQuery *eventQuery = [[PFQuery alloc] initWithClassName:@"Event"];
                        [eventQuery whereKey:@"objectId" containedIn:eventIds];
                        eventQuery.limit = 1000;
                        [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
                            
                            if (!error) {
                                [PFObject pinAllInBackground:events block:^(BOOL success, NSError *error){
                                    if (success) {
                                        NSLog(@"successfully updated and pinned %lu events", events.count);
                                        
                                        //add new events and reload??
                                        
                                    } else {
                                        NSLog(@"failed to update and pin group events with error: %@", error);
                                    }
                                }];
                            }
                        }];
                    }
                }
            }];
            
        } else {
            
            NSLog(@"failed to update and pin group events with error: %@", error);
        }
        
    }];
    
    
    
    /*
    PFQuery *groupEventQuery = [PFQuery queryWithClassName:@"Group_Event"];
    [groupEventQuery fromLocalDatastore];
    [groupEventQuery whereKey:@"GroupID" equalTo:group.objectId];
    [groupEventQuery findObjectsInBackgroundWithBlock:^(NSArray *groupEvents, NSError *error){
        
        NSMutableArray *idsArray = [NSMutableArray array];
        
        for (PFObject *object in groupEvents) {
            
            //[object pinInBackground];
            
            NSMutableDictionary *extras = [NSMutableDictionary dictionary];
            [extraSections setObject:extras forKey:object[@"EventID"]];
            [extras setObject:object.objectId forKey:@"ID"];
            [extras setObject:object forKey:@"groupEventObject"];
            
            [idsArray addObject:object[@"EventID"]];
            
            [extras setObject:[NSMutableArray arrayWithArray:fbIds] forKey:@"maybe"];
            [extras setObject:[NSMutableArray array] forKey:@"no"];
            [extras setObject:[NSMutableArray array] forKey:@"yes"];
            
        }
        
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
        [eventQuery fromLocalDatastore];
        [eventQuery whereKey:@"objectId" containedIn:idsArray];
        [eventQuery whereKey:@"EndTime" greaterThan:[NSDate date]];
        [eventQuery orderByAscending:@"Date"];
        
        count = 0;
        
        [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error){
            
            for (PFObject *event in events) {
                
                [eventIdsArray addObject:event.objectId];
                
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
                
                NSMutableDictionary *dict = [extraSections objectForKey:event.objectId];
                if ([dict objectForKey:@"Image"] == nil) {
                    if (event[@"Image"] != nil) [dict setObject:event[@"Image"] forKey:@"Image"];
                    else [dict setObject:[UIImage imageNamed:event[@"Hashtag"]] forKey:@"Image"];
                }
                
                
                count++;
            }
            
            // Create a sorted list of days
            NSArray *unsortedDays = [self.sections allKeys];
            self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
            
            if (events.count == 0) {
                
                [self.view addSubview:noEventsView];
                
            } else {
                
                [noEventsView removeFromSuperview];
            }
            
            //[self updateEvents];
            
            //[SVProgressHUD dismiss];
            [self loadPastEvents];
            [self.tableView reloadData];
            
        }];
        
        //[self loadRsvpsWithEventIds:idArray];
        
    }]; */
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
        
    if (scrollView.contentOffset.y > 0.0 && (([scrollView contentOffset].y + scrollView.frame.size.height - 60) >= [scrollView contentSize].height)){
        
        // Get new record from here
        if (!pastEventsLoaded) {
            NSLog(@"&& MADE IT");
            [self loadPastEvents];
        }
        
    }
}



- (void)loadPastEvents {
    
    pastEventsLoaded = YES;
    
    UIActivityIndicatorView *indicatorView = nil;
    
    if (![noEventsView isDescendantOfView:self.view]) {
    
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:self.sections.count - 1];
        NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        NSInteger rowsAmount = eventsOnThisDay.count;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowsAmount inSection:self.sections.count-1];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        for (UIView *view in cell.contentView.subviews) {
            if (view.tag == 2) [view removeFromSuperview];
        }
    
        indicatorView = (UIActivityIndicatorView *)[cell.contentView viewWithTag:3];
        [indicatorView startAnimating];
        
    } else {
        
        [noEventsView removeFromSuperview];
    }
    
    PFQuery *groupEventQuery = [PFQuery queryWithClassName:@"Group_Event"];
    [groupEventQuery whereKey:@"GroupID" equalTo:self.group.objectId];
    [groupEventQuery findObjectsInBackgroundWithBlock:^(NSArray *groupEvents, NSError *error){
        
        NSMutableArray *idsArray = [NSMutableArray array];
        
        for (PFObject *object in groupEvents) {
            
            //[object pinInBackground];
            
            NSMutableDictionary *extras = [NSMutableDictionary dictionary];
            [extraSections setObject:extras forKey:object[@"EventID"]];
            [extras setObject:object.objectId forKey:@"ID"];
            [extras setObject:object forKey:@"groupEventObject"];
            [extras setObject:@NO forKey:@"hasLoaded"];
            
            [idsArray addObject:object[@"EventID"]];
            
            [extras setObject:[NSMutableArray arrayWithArray:fbIds] forKey:@"maybe"];
            [extras setObject:[NSMutableArray array] forKey:@"no"];
            [extras setObject:[NSMutableArray array] forKey:@"yes"];
            
            NSMutableArray *picsArray = [NSMutableArray array];
            for (NSString *fbid in fbIds) {
                [picsArray addObject:[self ppViewForId:fbid]];
            }
            [extras setObject:picsArray forKey:@"maybePics"];
            [extras setObject:[NSMutableArray array] forKey:@"yesPics"];
            [extras setObject:[NSMutableArray array] forKey:@"noPics"];
            
        }
    
    
        PFQuery *pastEventQuery = [PFQuery queryWithClassName:@"Event"];
        [pastEventQuery whereKey:@"objectId" matchesKey:@"EventID" inQuery:groupEventQuery];
        [pastEventQuery whereKey:@"Date" lessThan:[[NSDate date] beginningOfDay]];
        [pastEventQuery addDescendingOrder:@"Date"];
        
        [pastEventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error){
            
            if (!error) {
                
                NSMutableArray *indexPaths = [NSMutableArray array];
                
                for (int i = 0; i < events.count; i++) {
                    
                    PFObject *event = events[i];
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:self.sections.count];
                    [indexPaths addObject:ip];
                    
                    NSMutableDictionary *dict = [extraSections objectForKey:event.objectId];
                    if ([dict objectForKey:@"Image"] == nil) {
                        if (event[@"Image"] != nil) [dict setObject:event[@"Image"] forKey:@"Image"];
                        else [dict setObject:[UIImage imageNamed:event[@"Hashtag"]] forKey:@"Image"];
                    }
                    
                    [pastEventsArray addObject:event];
                    
                }
                
                NSLog(@"%@", pastEventsArray);
                
                pastEventsLoaded = YES;
                if (indicatorView != nil)
                    [indicatorView stopAnimating];
                [self.tableView reloadData];
                
                //[self.tableView beginUpdates];
                //[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithArray:indexPaths] withRowAnimation:UITableViewRowAnimationNone];
                //[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];

                //[self.tableView endUpdates];
            }
        }];
    }];
    
}

/*
- (void)loadRsvpsWithEventIds:(NSArray *)idArray {
    
    PFQuery *groupRSVPQuery = [PFQuery queryWithClassName:@"Group_RSVP"];
    [groupRSVPQuery whereKey:@"EventID" containedIn:idArray];
    [groupRSVPQuery whereKey:@"GroupID" equalTo:group.objectId];
    [groupRSVPQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        for (PFObject *rsvpObject in objects) {
            
            //PFUser *user = rsvpObject[@"User_Object"];
            NSString *userFBID = rsvpObject[@"UserFBID"];
            
            NSMutableDictionary *extras = [extraSections objectForKey:rsvpObject[@"EventID"]];
            NSMutableArray *yesUsers = [extras objectForKey:@"yes"];
            NSMutableArray *noUsers = [extras objectForKey:@"no"];
            NSMutableArray *maybeUsers = [extras objectForKey:@"maybe"];
            
            if ([rsvpObject[@"GoingType"] isEqualToString:@"yes"]) {
                [yesUsers addObject:userFBID];
                [maybeUsers removeObject:userFBID];
                [extras setObject:yesUsers forKey:@"yes"];
                [extras setObject:maybeUsers forKey:@"maybe"];
            } else if ([rsvpObject[@"GoingType"] isEqualToString:@"no"]) {
                [noUsers addObject:userFBID];
                [maybeUsers removeObject:userFBID];
                [extras setObject:noUsers forKey:@"no"];
                [extras setObject:maybeUsers forKey:@"maybe"];
            } else if ([rsvpObject[@"GoingType"] isEqualToString:@"maybe"]) {
                //[maybeUsers addObject:rsvpObject[@"User_Object"]];
            }
            
            //[SVProgressHUD dismiss];
            [self.tableView reloadData];
        }
        
    }];
    
} */

- (void)loadGroup {
    
    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
    [groupQuery includeKey:@"user_objects"];
    //[groupQuery getObjectInBackgroundWithId:[conversation.metadata valueForKey:@"groupId"] block:^(PFObject *ob, NSError *error){
    
    [group fetchInBackgroundWithBlock:^(PFObject *ob, NSError *error){
        
        if (!error) {
            
            NSLog(@"Loading group...");
            group = ob;
            [group pinInBackground];
            //allUsers = [NSArray array];
            //allUsers = group[@"user_objects"];
            
            userDicts = group[@"user_dicts"];
            
            /*
            [PFObject fetchAllIfNeededInBackground:allUsers block:^(NSArray *users, NSError *error) {
               
                for (PFUser *user in users) {
                    NSLog(@"%@", user[@"firstName"]);
                    [user pinInBackground];
                }
                
                allUsers = users;
                
                [self loadEventData];
                [self loadTopButtonView];
            }]; */

            [self loadEventData];
            [self loadTopButtonView];
            
            /*
            if (![allUsers containsObject:currentUser]) {
                NSLog(@"ADDING CURRENT USER");
                [allUsers addObject:currentUser];
                group[@"user_objects"] = allUsers;
                [group saveEventually];
                
            }*/
            
        
        } else {
            [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
        }
        
    }];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!pastEventsLoaded) {
        NSInteger sectionsAmount = self.sections.count;
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
        NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        NSInteger rowsAmount = eventsOnThisDay.count;
        if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount) {
            
            return 70;
        }
    }
    
    return 150;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (!pastEventsLoaded || pastEventsArray.count == 0) {
        return self.sections.count;
    } else {
        return self.sections.count + 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (pastEventsLoaded && (section > self.sections.count-1 || self.sections.count == 0)) {
        
        return @"Past Events";
        
    }
    
    
    NSDate *eventDate = [[NSDate alloc]init];
    eventDate = [self.sortedDays objectAtIndex:section];
    
    if ((section == 0 || section == 1) && ([[eventDate beginningOfDay] isEqualToDate:[[NSDate date] beginningOfDay]])) {
        return @"Today";
    }
    
    if ((section == 0 || section == 1) && ([[eventDate beginningOfDay] isEqualToDate:[[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]])) {
        return @"Tomorrow";
    }
    
    return [self.sectionDateFormatter stringFromDate:eventDate];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (pastEventsLoaded && (section > self.sections.count - 1 || self.sections.count == 0)) {
        
        return pastEventsArray.count;
        
    }

    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    
    if (!pastEventsLoaded && section == self.sections.count - 1)
        return [eventsOnThisDay count] + 1;
    else
        return [eventsOnThisDay count];
    
}

// %%%%%% Runs through this code every time I scroll in Table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [noEventsView removeFromSuperview];
    
    NSInteger sectionsAmount = [tableView numberOfSections];
    NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
    if (!pastEventsLoaded && [indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
        // This is the last cell in the table
        NSLog(@"Last Cell");
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"loadPast" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"loadPast"];
        }
        
        return cell;
        
    }
    
    GroupsEventCell *cell = (GroupsEventCell *)[tableView dequeueReusableCellWithIdentifier:@"groupEvent" forIndexPath:indexPath];
    
    PFObject *Event;
    id imageOnThisDay;
    BOOL isPastEvent = NO;
    
    if (!pastEventsLoaded || (pastEventsLoaded && (indexPath.section <= self.sections.count - 1 && self.sections.count != 0))) {
        
        NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
        NSMutableArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        
        Event = eventsOnThisDay[indexPath.row];
        cell.eventObject = Event;
        cell.eventId = Event.objectId;
        
    } else {
        
        Event = pastEventsArray[indexPath.row];
        cell.eventObject = Event;
        cell.eventId = Event.objectId;
        isPastEvent = YES;
    }
    
    NSMutableDictionary *extrasDict = [extraSections objectForKey:Event.objectId];
    imageOnThisDay = [extrasDict objectForKey:@"Image"];
    
    [cell.titleLabel setText:[NSString stringWithFormat:@"%@",Event[@"Title"]]];
    
    [cell.locationLabel setText:[NSString stringWithFormat:@"at %@",Event[@"Location"]]];
    
    //cell.eventID = Event.objectId;
    
    // Time formatting
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    
    NSDate *startDate = Event[@"Date"];
    NSDate *endDate = Event[@"EndTime"];
    
    if (isPastEvent) {
        
        [formatter setDateFormat:@"EEE, MMM d"];
        NSString *dateString = [formatter stringFromDate:startDate];
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:startDate];
        cell.timeLabel.text = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
        
    } else if ([startDate timeIntervalSinceDate:endDate] > 60*60*4 || endDate == nil) {
        
        NSString *startTimeString = [formatter stringFromDate:startDate];
        NSString *eventTimeString = [[NSString alloc]init];
        eventTimeString = [NSString stringWithFormat:@"%@", startTimeString];
        //eventTimeString = [eventTimeString stringByReplacingOccurrencesOfString:@":00" withString:@""];
        
        [cell.timeLabel setText:[NSString stringWithFormat:@"%@",eventTimeString]];
        
    } else if ([startDate compare:[NSDate date]] == NSOrderedAscending) {
        
        NSString *startTimeString = [formatter stringFromDate:startDate];
        startTimeString = [NSString stringWithFormat:@"%@", startTimeString];
        startTimeString = [startTimeString stringByReplacingOccurrencesOfString:@":00" withString:@""];
        
        if ([[NSDate date] compare:endDate] == NSOrderedAscending) {
            [cell.timeLabel setText: [NSString stringWithFormat:@"Happening NOW! Started at %@", startTimeString]];
        } else {
            [cell.timeLabel setText: [NSString stringWithFormat:@"Event has ended"]];
        }
    
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

    
    if ([imageOnThisDay isKindOfClass:[PFFile class]]) {
        // Image formatting
        cell.eventImageView.image = [UIImage imageNamed:Event[@"Hashtag"]];
        PFFile *imageFile = imageOnThisDay;
        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                
                cell.blurView.tintColor = [UIColor blackColor];
                
                //cell.blurView.alpha = 0;
                cell.eventImageView.image = [UIImage imageWithData:imageData];
                //cell.blurView.alpha = 0;
                [extrasDict setObject:cell.eventImageView.image forKey:@"Image"];
                
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
        
    } else if (imageOnThisDay != nil) {
        
        // default image
        cell.eventImageView.image = (UIImage *)imageOnThisDay;

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
    
    //NSLog(@"YES: %@", yes);
    //NSLog(@"NO: %@", no);
    //NSLog(@"MAYBE: %@", maybe);

    
    for (int i = 0; i < cell.contentView.subviews.count; i++) {
        UIView *view = cell.contentView.subviews[i];
        if (view.tag == 9)
            [view removeFromSuperview];
    }
    
    cell.groupEventId = [extrasDict objectForKey:@"ID"];
    
    [cell.chatButton addTarget:self action:@selector(chatTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.groupEventObject = [extrasDict objectForKey:@"groupEventObject"];
    
    /*
    NSString *invitedByName = cell.groupEventObject[@"invitedByName"];
    
    if ([cell.groupEventObject[@"invitedByID"] isEqualToString:currentUser.objectId]) {
        cell.invitedByLabel.text = @"Invited by you";
    } else {
        NSString *firstWord = [[invitedByName componentsSeparatedByString:@" "] objectAtIndex:0];
        NSString *secondWord = [[invitedByName componentsSeparatedByString:@" "] objectAtIndex:1];
        cell.invitedByLabel.text = [NSString stringWithFormat:@"Invited by %@ %@.", firstWord, [secondWord substringToIndex:1]];
    } */
    
    PFQuery *groupRSVPQuery = [PFQuery queryWithClassName:@"Group_RSVP"];
    [groupRSVPQuery whereKey:@"EventID" equalTo:Event.objectId];
    [groupRSVPQuery whereKey:@"GroupID" equalTo:group.objectId];
    [groupRSVPQuery fromLocalDatastore];
    [groupRSVPQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
     
        if (!error) {
            
            cell.rsvpObject = object;
            NSString *goingType = object[@"GoingType"];
            
            if ([goingType isEqualToString:@"yes"]) {
                cell.cornerImageView.image = [UIImage imageNamed:@"check75"];
                [cell.checkButton setImage:[UIImage imageNamed:@"checked6green"] forState:UIControlStateNormal];
                [cell.xButton setImage:[UIImage imageNamed:@"close7"] forState:UIControlStateNormal];
                cell.checkButton.tag = 1;
                cell.xButton.tag = 0;
                
            } else if ([goingType isEqualToString:@"no"]) {
                cell.cornerImageView.image = [UIImage imageNamed:@"X"];
                [cell.checkButton setImage:[UIImage imageNamed:@"checked6"] forState:UIControlStateNormal];
                [cell.xButton setImage:[UIImage imageNamed:@"close7red"] forState:UIControlStateNormal];
                cell.xButton.tag = 1;
                cell.checkButton.tag = 0;
                
            } else if ([goingType isEqualToString:@"maybe"]) {
                cell.cornerImageView.image = [UIImage imageNamed:@"question"];
                [cell.checkButton setImage:[UIImage imageNamed:@"checked6"] forState:UIControlStateNormal];
                [cell.xButton setImage:[UIImage imageNamed:@"close7"] forState:UIControlStateNormal];
                cell.checkButton.tag = 0;
                cell.xButton.tag = 0;
                
            }
        }
        
    }];
    
    if ([[extrasDict objectForKey:@"hasLoaded"] boolValue] == YES) {
        
        NSLog(@"REFRESHING RSVPs");
        [self loadRsvpsForCell:cell];
        [extrasDict setObject:@YES forKey:@"hasLoaded"];
            
    } else {
    
        NSLog(@"LOADING RSVPs");
        PFQuery *groupRSVPQuery = [PFQuery queryWithClassName:@"Group_RSVP"];
        [groupRSVPQuery whereKey:@"EventID" equalTo:Event.objectId];
        [groupRSVPQuery whereKey:@"GroupID" equalTo:group.objectId];
        [groupRSVPQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            
            NSMutableArray *yesUsers = [extrasDict objectForKey:@"yes"];
            NSMutableArray *noUsers = [extrasDict objectForKey:@"no"];
            yesUsers = [NSMutableArray array];
            noUsers = [NSMutableArray array];
            NSMutableArray *maybeUsers = [extrasDict objectForKey:@"maybe"];
            maybeUsers = [NSMutableArray arrayWithArray:fbIds];
            NSMutableArray *maybePics = [extrasDict objectForKey:@"maybePics"];
            NSMutableArray *yesPics = [extrasDict objectForKey:@"yesPics"];
            NSMutableArray *noPics = [extrasDict objectForKey:@"noPics"];
            yesPics = [NSMutableArray array];
            noPics = [NSMutableArray array];

            
            for (PFObject *rsvpObject in objects) {
                
                NSString *userFBID = rsvpObject[@"UserFBID"];
                
                if ([rsvpObject[@"GoingType"] isEqualToString:@"yes"]) {
                    [yesUsers addObject:userFBID];
                    [maybeUsers removeObject:userFBID];
                    [extrasDict setObject:yesUsers forKey:@"yes"];
                    [extrasDict setObject:maybeUsers forKey:@"maybe"];
                    
                    for (int i = 0; i < maybePics.count; i++) {
                        FBSDKProfilePictureView *ppview = maybePics[i];
                        if ([ppview.profileID isEqualToString:userFBID]) {
                            [yesPics addObject:ppview];
                            [maybePics removeObject:ppview];
                            [extrasDict setObject:yesPics forKey:@"yesPics"];
                            [extrasDict setObject:maybePics forKey:@"maybePics"];
                        }
                    }
                    
                } else if ([rsvpObject[@"GoingType"] isEqualToString:@"no"]) {
                    [noUsers addObject:userFBID];
                    [maybeUsers removeObject:userFBID];
                    [extrasDict setObject:noUsers forKey:@"no"];
                    [extrasDict setObject:maybeUsers forKey:@"maybe"];
                    
                    for (int i = 0; i < maybePics.count; i++) {
                        FBSDKProfilePictureView *ppview = maybePics[i];
                        if ([ppview.profileID isEqualToString:userFBID]) {
                            [noPics addObject:ppview];
                            [maybePics removeObject:ppview];
                            [extrasDict setObject:noPics forKey:@"noPics"];
                            [extrasDict setObject:maybePics forKey:@"maybePics"];
                        }
                    }
                    
                } else if ([rsvpObject[@"GoingType"] isEqualToString:@"maybe"]) {
                    //[maybeUsers addObject:rsvpObject[@"User_Object"]];
                }
            }
                
            [self loadRsvpsForCell:cell];
            
        }];
    
    }

    return cell;
}

- (void)loadRsvpsForCell:(GroupsEventCell *)cell {
    
    NSMutableDictionary *extrasDict = [extraSections objectForKey:cell.eventId];
    
    NSMutableArray *yesUsers = [extrasDict objectForKey:@"yes"];
    NSMutableArray *noUsers = [extrasDict objectForKey:@"no"];
    NSMutableArray *maybeUsers = [extrasDict objectForKey:@"maybe"];
    
    NSMutableArray *yesPics = [extrasDict objectForKey:@"yesPics"];
    NSMutableArray *noPics = [extrasDict objectForKey:@"noPics"];
    NSMutableArray *maybePics = [extrasDict objectForKey:@"maybePics"];
    
    
    NSUInteger totalCount = fbIds.count;
    NSString *rsvpCount = [NSString stringWithFormat:@"%lu of %lu", (unsigned long)yesUsers.count, (unsigned long)totalCount];
    
    [cell.rsvpButton setTitle:rsvpCount forState:UIControlStateNormal];
    
    int userCount = 0;
    
    for (int i = 0; i < yesUsers.count; i++) {
        
        //PFUser *user = yes[i];
        NSString *fbId = yesUsers[i];
        
        if (userCount < 4 && ![fbId isEqualToString:currentUser[@"FBObjectID"]]) {

            for (FBSDKProfilePictureView *ppview in yesPics) {
                if ([ppview.profileID isEqualToString:fbId]) {
                    
                    UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(80 + 50*userCount, 92, 40, 40)];
                    ppview.frame = picViewContainer.bounds;
                    
                    [picViewContainer addSubview:ppview];
                    picViewContainer.tag = 9;
                    
                    UIImageView *cornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
                    cornerImageView.image = [UIImage imageNamed:@"check75"];
                    cornerImageView.layer.cornerRadius = 7.5;
                    cornerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
                    cornerImageView.layer.borderWidth = 1.0;
                    [picViewContainer addSubview:cornerImageView];
                    
                    [cell.contentView addSubview:picViewContainer];
                    
                    userCount++;
                }
            }

        }
        
    }
    
    for (int i = 0; i < maybeUsers.count; i++) {
        
        NSString *fbId = maybeUsers[i];
        
        if (userCount < 4 && ![fbId isEqualToString:currentUser[@"FBObjectID"]]) {
            
            for (FBSDKProfilePictureView *ppview in maybePics) {
                if ([ppview.profileID isEqualToString:fbId]) {
                    
                    UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(80 + 50*userCount, 92, 40, 40)];
                    ppview.frame = picViewContainer.bounds;
                    
                    [picViewContainer addSubview:ppview];
                    picViewContainer.tag = 9;
                    
                    UIImageView *cornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
                    cornerImageView.image = [UIImage imageNamed:@"question"];
                    cornerImageView.layer.cornerRadius = 7.5;
                    cornerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
                    cornerImageView.layer.borderWidth = 1.0;
                    [picViewContainer addSubview:cornerImageView];
                    
                    [cell.contentView addSubview:picViewContainer];
                    
                    userCount++;
                }
            }
        }
    }
    
    for (int i = 0; i < noUsers.count; i++) {
        
        NSString *fbId = noUsers[i];
        
        if (userCount < 4 && ![fbId isEqualToString:currentUser[@"FBObjectID"]]) {
            
            for (FBSDKProfilePictureView *ppview in noPics) {
                if ([ppview.profileID isEqualToString:fbId]) {
                    
                    UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(80 + 50*userCount, 92, 40, 40)];
                    ppview.frame = picViewContainer.bounds;
                    
                    [picViewContainer addSubview:ppview];
                    picViewContainer.tag = 9;
                    
                    UIImageView *cornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
                    cornerImageView.image = [UIImage imageNamed:@"X"];
                    cornerImageView.layer.cornerRadius = 7.5;
                    cornerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
                    cornerImageView.layer.borderWidth = 1.0;
                    [picViewContainer addSubview:cornerImageView];
                    
                    [cell.contentView addSubview:picViewContainer];
                    
                    userCount++;
                }
            }
        }
    }
    
    [extrasDict setObject:@YES forKey:@"hasLoaded"];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section != 0) {
        return 22;
    }
    return 33;
}

- (void)didRsvpsChange {
    
    NSMutableDictionary *extraSectionsCopy = [NSMutableDictionary dictionary];
    
    for (NSString *theId in eventIdsArray) {
        
        NSMutableDictionary *extras = [NSMutableDictionary dictionary];
        [extraSectionsCopy setObject:extras forKey:theId];
        [extras setObject:[NSMutableArray arrayWithArray:fbIds] forKey:@"maybe"];
        [extras setObject:[NSMutableArray array] forKey:@"yes"];
        [extras setObject:[NSMutableArray array] forKey:@"no"];
        
        NSMutableArray *picsArray = [NSMutableArray array];
        for (NSString *fbid in fbIds) {
            [picsArray addObject:[self ppViewForId:fbid]];
        }
        [extras setObject:picsArray forKey:@"maybePics"];
        [extras setObject:[NSMutableArray array] forKey:@"yesPics"];
        [extras setObject:[NSMutableArray array] forKey:@"noPics"];

        
    }
    
    PFQuery *groupRSVPQuery = [PFQuery queryWithClassName:@"Group_RSVP"];
    [groupRSVPQuery whereKey:@"EventID" containedIn:eventIdsArray];
    [groupRSVPQuery whereKey:@"GroupID" equalTo:group.objectId];
    [groupRSVPQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        if (!error) {
        
            //NSMutableDictionary *extraSectionsCopy = [NSMutableDictionary dictionary]; //WithDictionary:extraSections];
            
            for (PFObject *rsvpObject in objects) {
            
                NSMutableDictionary *dict = [extraSectionsCopy objectForKey:rsvpObject[@"EventID"]];
                NSMutableArray *maybe = [dict objectForKey:@"maybe"];
                NSMutableArray *maybePics = [dict objectForKey:@"maybePics"];
                
                NSString *userFBID = rsvpObject[@"UserFBID"];
                
                if ([rsvpObject[@"GoingType"] isEqualToString:@"yes"]) {
                    NSMutableArray *yes = [dict objectForKey:@"yes"];
                    [yes addObject:userFBID];
                    [maybe removeObject:userFBID];
                    [dict setObject:yes forKey:@"yes"];
                    [dict setObject:maybe forKey:@"maybe"];
                    
                    for (int i = 0; i < maybePics.count; i++) {
                        FBSDKProfilePictureView *ppview = maybePics[i];
                        if ([ppview.profileID isEqualToString:userFBID]) {
                            NSMutableArray *yesPics = [dict objectForKey:@"yesPics"];
                            [yesPics addObject:ppview];
                            [maybePics removeObject:ppview];
                            [dict setObject:yesPics forKey:@"yesPics"];
                            [dict setObject:maybePics forKey:@"maybePics"];
                        }
                    }

                } else if ([rsvpObject[@"GoingType"] isEqualToString:@"no"]) {
                    NSMutableArray *no = [dict objectForKey:@"no"];
                    [no addObject:userFBID];
                    [maybe removeObject:userFBID];
                    [dict setObject:no forKey:@"no"];
                    [dict setObject:maybe forKey:@"maybe"];
                    
                    for (int i = 0; i < maybePics.count; i++) {
                        FBSDKProfilePictureView *ppview = maybePics[i];
                        if ([ppview.profileID isEqualToString:userFBID]) {
                            NSMutableArray *noPics = [dict objectForKey:@"noPics"];
                            [noPics addObject:ppview];
                            [maybePics removeObject:ppview];
                            [dict setObject:noPics forKey:@"noPics"];
                            [dict setObject:maybePics forKey:@"maybePics"];
                        }
                    }

                } else if ([rsvpObject[@"GoingType"] isEqualToString:@"maybe"]) {
                    //[maybeUsers addObject:rsvpObject[@"User_Object"]];
                }
            
            }
    
            BOOL shouldReload = NO;
            
            for (NSString *eventId in eventIdsArray) {
                
                NSDictionary *originalDict = [extraSections objectForKey:eventId];
                NSDictionary *copiedDict = [extraSectionsCopy objectForKey:eventId];
                
                NSArray *yes1 = [originalDict objectForKey:@"yes"];
                yes1 = [yes1 sortedArrayUsingSelector:@selector(compare:)];
                NSArray *no1 = [originalDict objectForKey:@"no"];
                no1 = [no1 sortedArrayUsingSelector:@selector(compare:)];
                NSArray *maybe1 = [originalDict objectForKey:@"maybe"];
                maybe1 = [maybe1 sortedArrayUsingSelector:@selector(compare:)];

                
                NSArray *yes2 = [copiedDict objectForKey:@"yes"];
                yes2 = [yes2 sortedArrayUsingSelector:@selector(compare:)];
                NSArray *no2 = [copiedDict objectForKey:@"no"];
                no2 = [no2 sortedArrayUsingSelector:@selector(compare:)];
                NSArray *maybe2 = [copiedDict objectForKey:@"maybe"];
                maybe2 = [maybe2 sortedArrayUsingSelector:@selector(compare:)];
                
                BOOL arraysContainTheSameObjects = YES;
                
                if (![yes1 isEqual:yes2] || ![no1 isEqual:no2] || ![maybe1 isEqual:maybe2]) {
                    
                    NSLog(@"o: %@", originalDict);
                    NSLog(@"c: %@", copiedDict);
                    
                    arraysContainTheSameObjects = NO;
        
                    NSMutableDictionary *dict = [extraSections objectForKey:eventId];
                    
                    [dict setObject:yes2 forKey:@"yes"];
                    [dict setObject:no2 forKey:@"no"];
                    [dict setObject:maybe2 forKey:@"maybe"];
                    //[dict setObject:@YES forKey:@"didChange"];
                    
                    [dict setObject:[copiedDict objectForKey:@"maybePics"] forKey:@"maybePics"];
                    [dict setObject:[copiedDict objectForKey:@"yesPics"] forKey:@"yesPics"];
                    [dict setObject:[copiedDict objectForKey:@"noPics"] forKey:@"noPics"];

                    NSLog(@"RSVPS CHANGED ~~ %@ - %@ - %@", [copiedDict objectForKey:@"yesPics"], [copiedDict objectForKey:@"noPics"], [copiedDict objectForKey:@"maybePics"]);
                    
                    shouldReload = YES;
                    
                    [extraSections setObject:dict forKey:eventId];
                }
                
            }
            
            if (shouldReload) [self.tableView reloadData];
            
        }
        
    }];

    
}

- (FBSDKProfilePictureView *)ppViewForId:(NSString *)fbid {
    
    //UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 92, 40, 40)];
    FBSDKProfilePictureView *profPic = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    profPic.profileID = fbid;
    //[picViewContainer addSubview:profPic];
    //picViewContainer.tag = 9;
    
    profPic.layer.cornerRadius = 20.0;
    profPic.layer.masksToBounds = YES;
    
    /*
    UIImageView *cornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
    cornerImageView.image = [UIImage imageNamed:@"check75"];
    cornerImageView.layer.cornerRadius = 7.5;
    cornerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    cornerImageView.layer.borderWidth = 1.0;
    cornerImageView.tag = 123;
    [picViewContainer addSubview:cornerImageView];
    */
    return profPic;
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
    
    if (!chatHub) {
        
        chatHub = [[RKNotificationHub alloc]initWithView:(UIView *)chatBubble]; // sets the count to 0
        //%%% CIRCLE FRAME
        //[hub setCircleAtFrame:CGRectMake(-10, -10, 30, 30)]; //frame relative to the view you set it to
        
        //%%% MOVE FRAME
        [chatHub moveCircleByX:-6 Y:6]; // moves the circle 5 pixels left and down from its current position
        
        //%%% CIRCLE SIZE
        [chatHub scaleCircleSizeBy:0.2]; // doubles the size of the circle, keeps the same center
        
        [chatHub setCircleColor: [UIColor colorWithRed:0 green:176.0/255 blue:255.0/255 alpha:1.0] labelColor:[UIColor whiteColor]];
        
        [chatHub hideCount];

    }
    
    if (conversation.hasUnreadMessages) {
        
        [chatHub increment];
        [chatHub pop];
    
    } else {
        
        if (!groupChanged)
            [chatHub decrementBy:chatHub.count];
        else
            groupChanged = NO;
    }
    
}

- (void)chatTapped:(id)sender {
    
    [chatBubble setImage:[UIImage imageNamed:@"chat"] forState:UIControlStateNormal];
    [chatHub decrementBy:chatHub.count];

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    GroupChatVC *controller = [GroupChatVC conversationViewControllerWithLayerClient:appDelegate.layerClient];

    controller.userDicts = userDicts;
    controller.fbids = fbIds;
    controller.groupObject = group;
    controller.conversation = conversation;
     
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)loadTopButtonView {
    
    for (UIView *view in self.topButtonView.subviews) {
        if (view.tag == 21) [view removeFromSuperview];
    }
    
    float width = (fbIds.count * 50 + 5);
    if (width > 280) width = 280;
    UIView *picView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    picView.center = CGPointMake(self.topButtonView.center.x - 15, self.topButtonView.center.y);
    picView.userInteractionEnabled = YES;
    [picView addGestureRecognizer:[[UIGestureRecognizer alloc] initWithTarget:self action:@selector(toGroupDetails:)]];
    picView.tag = 21;
    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(picView.frame.size.width + 5, 17.5, 15, 15)];
    [moreButton setImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
    moreButton.tag = 21;
    [picView addSubview:moreButton];
    
    [self.topButtonView addSubview:picView];
    
    NSInteger userCount = fbIds.count;
    if (userCount > 5) userCount = 5;
    
    //userCount = fbIds.count;
    
    for (int i = 0; i < userCount; i++) {
                
        //PFUser *user = allUsers[i];
        NSString *fbId = fbIds[i];
        
        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(5 + 50 * i, 5, 40, 40)]; // initWithProfileID:user[@"FBObjectID"] pictureCropping:FBSDKProfilePictureModeSquare];
        //if (user.isDataAvailable || [user.objectId isEqualToString:currentUser.objectId]) {
            profPicView.profileID = fbId;
            UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toGroupDetails:)];
            [profPicView addGestureRecognizer:gr];
        //}
        //profPicView.pictureMode = FBSDKProfilePictureModeSquare;
        
        profPicView.layer.cornerRadius = 20;
        profPicView.layer.masksToBounds = YES;
        profPicView.accessibilityIdentifier = parseIds[i];
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
    self.topButtonView.enabled = YES;
    
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
    //[query whereKey:@"Group_Event_ID" equalTo:cell.groupEventId];
    [query whereKey:@"EventID" equalTo:cell.eventId];
    [query whereKey:@"GroupID" equalTo:group.objectId];
    [query fromLocalDatastore];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        PFObject *rsvpObject = [PFObject objectWithClassName:@"Group_RSVP"];
        
        if (!error) {
            
            NSLog(@"RSVP exists");
            rsvpObject = object;
            
        } else {
            
            NSLog(@"Create new RSVP object");
            
            rsvpObject[@"EventID"] = cell.eventId;
            rsvpObject[@"GroupID"] = group.objectId;
            rsvpObject[@"Group_Event_ID"] = cell.groupEventId;
            rsvpObject[@"UserID"] = currentUser.objectId;
            rsvpObject[@"User_Object"] = currentUser;
            rsvpObject[@"UserFBID"] = currentUser[@"FBObjectID"];
            //rsvpObject[@"GoingType"] = @"yes"; SET BELOW
            [rsvpObject pinInBackground];
            
        }
        
        if (cell.checkButton.tag == 1) {
            rsvpObject[@"GoingType"] = @"yes";
        } else if (cell.xButton.tag == 1) {
            rsvpObject[@"GoingType"] = @"no";
        } else {
            rsvpObject[@"GoingType"] = @"maybe";
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
                    [chatHub increment];
                    [chatHub pop];
                    
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
    
    NSInteger sectionsAmount = [tableView numberOfSections];
    NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
    if (!pastEventsLoaded && [indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
        
        [self loadPastEvents];
        
    } else
        [self performSegueWithIdentifier:@"toEvent" sender:self];
}

-(void)groupChanged {
    
    groupChanged = YES;
    
    self.title = group[@"name"];
    
    userDicts = group[@"user_dicts"];
    names = [NSMutableArray new];
    fbIds = [NSMutableArray new];
    parseIds = [NSMutableArray new];
    
    for (NSDictionary *dict in userDicts) {
        
        [names addObject:[dict valueForKey:@"name"]];
        [fbIds addObject:[dict valueForKey:@"id"]];
        [parseIds addObject:[dict valueForKey:@"parseId"]];
        
    }
    
    [self loadTopButtonView];
    [chatHub increment];
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
        vc.userDicts = userDicts;
        
        vc.groupEventObject = cell.groupEventObject;
        vc.eventObject = cell.eventObject;
        
        vc.group = group;
        vc.titleString = cell.titleLabel.text;
        vc.convo = conversation;

    } else if ([segue.identifier isEqualToString:@"toProf"]) {
        
        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.userID = friendObjectID;
        
    } else if ([segue.identifier isEqualToString:@"toDetails"]) {
        
        /*
        for (PFUser *user in allUsers) {
            NSLog(@"%@", user[@"firstName"]);
        }*/
        
        /*
        if (![allUsers containsObject:currentUser]) {
            NSLog(@"ADDING CURRENT USER");
            [allUsers addObject:currentUser];
            group[@"user_objects"] = allUsers;
            [group saveEventually];
            
        } */
        
        GroupDetailsTVC *vc = (GroupDetailsTVC *)[segue destinationViewController];
        vc.groupNameString = self.title;
        vc.group = group;
        //vc.users = [NSArray arrayWithArray:allUsers];
        vc.fbIds = fbIds;
        vc.names = names;
        vc.parseIds = parseIds;
        vc.convo = conversation;
        vc.delegate = self;
    
    } else if ([segue.identifier isEqualToString:@"toEvent"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GroupsEventCell *cell = (GroupsEventCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        ExpandedCardVC *vc = (ExpandedCardVC *)[segue destinationViewController];
        vc.distanceString = cell.distanceLabel.text;
        vc.event = cell.eventObject;
        vc.eventID = cell.eventObject.objectId;
        vc.image = cell.eventImageView.image;
        vc.isFromGroup = YES;
        vc.rsvpObject = cell.rsvpObject;
        vc.groupObject = self.group;
        vc.convo = self.conversation;
        vc.fbids = fbIds;
        vc.groupEventObject = cell.groupEventObject;
        
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
