//
//  ActivityVC.m
//  Happening
//
//  Created by Max on 7/19/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ActivityTVC.h"
#import "interestedCell.h"
#import "friendJoinedCell.h"
#import "reminderCell.h"
#import "matchesCell.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ExpandedCardVC.h"
#import "ExternalProfileTVC.h"

@interface ActivityTVC () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *MEactivityObjects;
@property NSMutableArray *FRIENDSactivityObjects;

@end

@implementation ActivityTVC {
    
    BOOL meButtonPressed;
    NSString *selectedFriendId;
    NSArray *funnyEndings;
    NSMutableDictionary *eventObjectDict;
    
}

@synthesize meButton, sliderView, friendsButton, containerView, MEactivityObjects, FRIENDSactivityObjects;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    meButtonPressed = NO;
    
    selectedFriendId = @"";
    
    // The className to query on
    //self.parseClassName = @"Activity";
    
    // The key of the PFObject to display in the label of the default cell style
    //self.textKey = @"Title";
    
    // The title for this table in the Navigation Controller.
    //self.title = @"Activity";
    
    // Whether the built-in pull-to-refresh is enabled
    //self.pullToRefreshEnabled = YES;
    
    // Whether the built-in pagination is enabled
    //self.paginationEnabled = YES;
    
    // The number of objects to show per page
    //self.objectsPerPage = 15;
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setSeparatorColor:[UIColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    funnyEndings = @[@" Hold the applause.", @" Hollah!", @" Now it's a party.", @" About time.", @" Heck yes.", @" Aw yeah.", @" *Air five*", @" Whoop whoop.", @" *fist pump*", @" *slow clap*", @" *fist bump*", @" Turn up?", @" Leggo.", @" Booyah.", @" Oh ya.", @" Awesome sauce.", @" &$^* #@*&%!!!"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!MEactivityObjects || !FRIENDSactivityObjects) {
        MEactivityObjects = [NSMutableArray array];
        FRIENDSactivityObjects = [NSMutableArray array];
        eventObjectDict = [NSMutableDictionary dictionary];
        [self loadObjectsFromCache];
    } else {
        [self checkForUpdatedActivities];
    }
    
    
}

- (void)loadObjectsFromCache {
    
    
    NSArray *friends = [[PFUser currentUser] objectForKey:@"friends"];
    NSMutableArray *idsArray = [NSMutableArray new];
    for (NSDictionary *dict in friends) {
        [idsArray addObject:[dict valueForKey:@"parseId"]];
    }
    
    PFQuery *finalQuery = [PFQuery queryWithClassName:@"Activity"];
    
    /*
     PFQuery *reminderQuery = [PFQuery queryWithClassName:@"Activity"];
     [reminderQuery whereKey:@"type" equalTo:@"reminder"];
     [reminderQuery whereKey:@"userParseId" equalTo:[PFUser currentUser].objectId];
     
     PFQuery *friendJoinedQuery = [PFQuery queryWithClassName:@"Activity"];
     [friendJoinedQuery whereKey:@"type" equalTo:@"friendJoined"];
     [friendJoinedQuery whereKey:@"userParseId" containedIn:idsArray];
     
     
     PFQuery *interestedQuery = [PFQuery queryWithClassName:@"Activity"];
     [interestedQuery whereKey:@"type" equalTo:@"interested"];
     [interestedQuery whereKey:@"userParseId" containedIn:idsArray];
     
     finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:reminderQuery,friendJoinedQuery,interestedQuery, nil]];
     */
    
    //[finalQuery includeKey:@"eventObject"];
    [finalQuery orderByAscending:@"createdAt"];
    [finalQuery fromLocalDatastore];
    
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            for (PFObject *object in objects) {
                
                [object pinInBackground];
                
                NSString *type = object[@"type"];
                
                if ([type isEqualToString:@"interested"] || [type isEqualToString:@"match"] || [type isEqualToString:@"going"]) {
                    
                    if (object[@"eventId"] != nil)
                        [eventObjectDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                    [FRIENDSactivityObjects addObject:object];
                    
                } else if ([type isEqualToString:@"reminder"] || [type isEqualToString:@"match"] || [type isEqualToString:@"friendJoined"]) {
                    
                    if (object[@"eventId"] != nil)
                        [eventObjectDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                    [MEactivityObjects addObject:object];
                    
                }
                
            }
            
            [self.tableView reloadData];
            [self checkForUpdatedActivities];
            
        } else {
            
            NSLog(@"Error loading activity objects: %@", error);
        }
        
    }];

}

- (void)checkForUpdatedActivities {
    
    
    NSArray *friends = [[PFUser currentUser] objectForKey:@"friends"];
    NSMutableArray *idsArray = [NSMutableArray new];
    for (NSDictionary *dict in friends) {
        [idsArray addObject:[dict valueForKey:@"parseId"]];
    }
    
    PFQuery *finalQuery = [PFQuery queryWithClassName:@"Activity"];
    
    //if (meButtonPressed) {
    
    PFQuery *reminderQuery = [PFQuery queryWithClassName:@"Activity"];
    [reminderQuery whereKey:@"type" equalTo:@"reminder"];
    [reminderQuery whereKey:@"userParseId" equalTo:[PFUser currentUser].objectId];
    
    PFQuery *friendJoinedQuery = [PFQuery queryWithClassName:@"Activity"];
    [friendJoinedQuery whereKey:@"type" equalTo:@"friendJoined"];
    [friendJoinedQuery whereKey:@"userParseId" containedIn:idsArray];
    
    //finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:reminderQuery, friendJoinedQuery, nil]];
    
    //} else {
    
    PFQuery *interestedQuery = [PFQuery queryWithClassName:@"Activity"];
    [interestedQuery whereKey:@"type" equalTo:@"interested"];
    [interestedQuery whereKey:@"userParseId" containedIn:idsArray];
    
    finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:reminderQuery,friendJoinedQuery,interestedQuery, nil]];
    //}
    
    [finalQuery includeKey:@"eventObject"];
    [finalQuery orderByDescending:@"createdAt"];
    
    NSArray *friendsArrayCopy = [NSArray arrayWithArray:FRIENDSactivityObjects];
    NSArray *meArrayCopy = [NSArray arrayWithArray:MEactivityObjects];
    
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            BOOL shouldReload = NO;
            
            for (PFObject *object in objects) {
                
                [object pinInBackground];
                
                NSString *type = object[@"type"];
                
                if ([type isEqualToString:@"interested"] || [type isEqualToString:@"match"] || [type isEqualToString:@"going"]) {
                    
                    if (![FRIENDSactivityObjects containsObject:object]) {
                        [object pinInBackground];
                        if (object[@"eventId"] != nil)
                            [eventObjectDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                        shouldReload = YES;
                        [FRIENDSactivityObjects insertObject:object atIndex:0];
                    }
                    
                } else if ([type isEqualToString:@"reminder"] || [type isEqualToString:@"match"] || [type isEqualToString:@"friendJoined"]) {
                    
                    if (![MEactivityObjects containsObject:object]) {
                        [object pinInBackground];
                        if (object[@"eventId"] != nil)
                            [eventObjectDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                        shouldReload = YES;
                        [MEactivityObjects insertObject:object atIndex:0];
                    }
                }
                
            }
            
            if (shouldReload) {
                NSLog(@"New activities! Updating...");
                [self.tableView reloadData];
            }
            
        } else {
            
            NSLog(@"Error loading activity objects: %@", error);
        }
        
    }];
    
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (meButtonPressed)
        return MEactivityObjects.count;
    
    return FRIENDSactivityObjects.count;
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    
    NSArray *friends = [[PFUser currentUser] objectForKey:@"friends"];
    NSMutableArray *idsArray = [NSMutableArray new];
    for (NSDictionary *dict in friends) {
        [idsArray addObject:[dict valueForKey:@"parseId"]];
    }
    
    PFQuery *finalQuery = [PFQuery queryWithClassName:@"Activity"];
    
    if (meButtonPressed) {
        
        PFQuery *reminderQuery = [PFQuery queryWithClassName:@"Activity"];
        [reminderQuery whereKey:@"type" equalTo:@"reminder"];
        [reminderQuery whereKey:@"userParseId" equalTo:[PFUser currentUser].objectId];
        
        PFQuery *friendJoinedQuery = [PFQuery queryWithClassName:@"Activity"];
        [friendJoinedQuery whereKey:@"type" equalTo:@"friendJoined"];
        [friendJoinedQuery whereKey:@"userParseId" containedIn:idsArray];
        
        finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:reminderQuery, friendJoinedQuery, nil]];
        
    } else {
     
        PFQuery *interestedQuery = [PFQuery queryWithClassName:@"Activity"];
        [interestedQuery whereKey:@"type" equalTo:@"interested"];
        [interestedQuery whereKey:@"userParseId" containedIn:idsArray];
        
        finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:interestedQuery, nil]];
    }

    [finalQuery includeKey:@"eventObject"];
    [finalQuery orderByAscending:@"createdAt"];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.

    
    //[query orderByAscending:@"priority"];
    
    return finalQuery;
}



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PFObject *object = [self objectAtIndex:indexPath.row];
    NSString *type = object[@"type"];
    
    if ([type isEqualToString:@"interested"]) {
        
        NSString *CellIdentifier = type;
        interestedCell *cell = (interestedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[interestedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        if (![cell viewWithTag:99]) {
            FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, 3, 25, 25)];
            profPicView.profileID = object[@"userFBId"];
            profPicView.pictureMode = FBSDKProfilePictureModeSquare;
            
            profPicView.layer.cornerRadius = 25/2;
            profPicView.layer.masksToBounds = YES;
            profPicView.accessibilityIdentifier = object[@"userParseId"];
            profPicView.userInteractionEnabled = YES;
            
            profPicView.tag = 99;
            [cell addSubview:profPicView];
            
            [profPicView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapped:)]];
        }
        
        UIFont *font = [UIFont fontWithName:@"OpenSans-Semibold" size:10.0];
        NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithObject:font
                                                                                  forKey:NSFontAttributeName];
        //[attrsDictionary setObject:[UIColor colorWithRed:0.0/255 green:176.0/255 blue:242.0/255 alpha:1.0] forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:object[@"userFullName"] attributes:attrsDictionary];
        NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@" is interested in an event."];
        [aAttrString1 appendAttributedString:aAttrString2];
        
        cell.messageLabel.attributedText = aAttrString1;
        
        cell.eventTitleLabel.text = object[@"eventName"];
        cell.eventLocLabel.text = object[@"eventLoc"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE, MMM d"];
        NSDate *eventDate = object[@"eventDate"];
        cell.eventDateLabel.text = [formatter stringFromDate:eventDate];
        
        NSMutableDictionary *eventDict = [eventObjectDict objectForKey:object[@"eventId"]];
        
        if ([eventDict objectForKey:@"event"] == nil) {
            PFObject *event = object[@"eventObject"];
            [event fetchInBackgroundWithBlock:^(PFObject *event, NSError *error) {
                [eventDict setObject:event forKey:@"event"];
                cell.eventObject = event;
                PFFile *file = event[@"Image"];
                cell.eventImageView.alpha = 0;
                if (file) {
                    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        cell.eventImageView.image = [UIImage imageWithData:data];
                        [eventDict setObject:cell.eventImageView.image forKey:@"image"];
                        [UIView animateWithDuration:0.2 animations:^{
                            cell.eventImageView.alpha = 1.0;
                        }];
                    }];
                } else {
                    cell.eventImageView.image = [UIImage imageNamed:event[@"Hashtag"]];
                    [eventDict setObject:cell.eventImageView.image forKey:@"image"];
                    [UIView animateWithDuration:0.2 animations:^{
                        cell.eventImageView.alpha = 1.0;
                    }];
                }
            }];
            
        } else if ([eventDict objectForKey:@"image"] == nil) {
            
            PFObject *event = [eventDict objectForKey:@"event"];
            PFFile *file = event[@"Image"];
            cell.eventImageView.alpha = 0;
            if (file) {
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    cell.eventImageView.image = [UIImage imageWithData:data];
                    [eventDict setObject:cell.eventImageView.image forKey:@"image"];
                    [UIView animateWithDuration:0.2 animations:^{
                        cell.eventImageView.alpha = 1.0;
                    }];
                }];
            } else {
                cell.eventImageView.image = [UIImage imageNamed:event[@"Hashtag"]];
                [eventDict setObject:cell.eventImageView.image forKey:@"image"];
                [UIView animateWithDuration:0.2 animations:^{
                    cell.eventImageView.alpha = 1.0;
                }];
            }
            
        } else {
        
            cell.eventObject = [eventDict objectForKey:@"event"];
            cell.eventImageView.image = [eventDict objectForKey:@"image"];
        }
        
        return cell;
        
    } else if ([type isEqualToString:@"reminder"]) {
        
        NSString *CellIdentifier = type;
        reminderCell *cell = (reminderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[reminderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        /*
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFriendProfile:)];
        [profPicView addGestureRecognizer:gr]; */
        
        UIFont *font = [UIFont fontWithName:@"OpenSans-Semibold" size:10.0];
        NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithObject:font
                                                                                  forKey:NSFontAttributeName];
        //[attrsDictionary setObject:[UIColor colorWithRed:0.0/255 green:176.0/255 blue:242.0/255 alpha:1.0] forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"Reminder: " attributes:attrsDictionary];
        NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@"event starts in "];
        NSString *timeFromNow = [NSString stringWithFormat:@"%.f minutes.", [object[@"eventDate"] timeIntervalSinceNow] / 60];
        NSMutableAttributedString *aAttrString3 = [[NSMutableAttributedString alloc] initWithString:timeFromNow attributes:attrsDictionary];
        [aAttrString1 appendAttributedString:aAttrString2];
        [aAttrString1 appendAttributedString:aAttrString3];
        
        cell.messageLabel.attributedText = aAttrString1;
        
        cell.eventTitleLabel.text = object[@"eventName"];
        cell.eventLocationLabel.text = object[@"eventLoc"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE, MMM d"];
        NSDate *eventDate = object[@"eventDate"];
        cell.eventDateLabel.text = [formatter stringFromDate:eventDate];
        
        NSMutableDictionary *eventDict = [eventObjectDict objectForKey:object[@"eventId"]];
        
        if ([eventDict objectForKey:@"event"] == nil) {
            PFObject *event = object[@"eventObject"];
            [event fetchInBackgroundWithBlock:^(PFObject *event, NSError *error) {
                [eventDict setObject:event forKey:@"event"];
                cell.eventObject = event;
                PFFile *file = event[@"Image"];
                cell.eventImageView.alpha = 0;
                if (file) {
                    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        cell.eventImageView.image = [UIImage imageWithData:data];
                        [eventDict setObject:cell.eventImageView.image forKey:@"image"];
                        [UIView animateWithDuration:0.2 animations:^{
                            cell.eventImageView.alpha = 1.0;
                        }];
                    }];
                } else {
                    cell.eventImageView.image = [UIImage imageNamed:event[@"Hashtag"]];
                    [eventDict setObject:cell.eventImageView.image forKey:@"image"];
                    [UIView animateWithDuration:0.2 animations:^{
                        cell.eventImageView.alpha = 1.0;
                    }];
                }
            }];
            
        } else if ([eventDict objectForKey:@"image"] == nil) {
            
            PFObject *event = [eventDict objectForKey:@"event"];
            PFFile *file = event[@"Image"];
            cell.eventImageView.alpha = 0;
            if (file) {
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    cell.eventImageView.image = [UIImage imageWithData:data];
                    [eventDict setObject:cell.eventImageView.image forKey:@"image"];
                    [UIView animateWithDuration:0.2 animations:^{
                        cell.eventImageView.alpha = 1.0;
                    }];
                }];
            } else {
                cell.eventImageView.image = [UIImage imageNamed:event[@"Hashtag"]];
                [eventDict setObject:cell.eventImageView.image forKey:@"image"];
                [UIView animateWithDuration:0.2 animations:^{
                    cell.eventImageView.alpha = 1.0;
                }];
            }
            
        } else {
            
            cell.eventObject = [eventDict objectForKey:@"event"];
            cell.eventImageView.image = [eventDict objectForKey:@"image"];
        }
        
        return cell;
        
    } else if ([type isEqualToString:@"match"]) {
        
        NSString *CellIdentifier = type;
        matchesCell *cell = (matchesCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[matchesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        return cell;

    } else if ([type isEqualToString:@"friendJoined"]) {
        
        NSString *CellIdentifier = type;
        friendJoinedCell *cell = (friendJoinedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[friendJoinedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.activityObject = object;
        
        if (![cell viewWithTag:99]) {
            FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(5, 5, 34, 34)];
            profPicView.profileID = object[@"userFBId"];
            profPicView.pictureMode = FBSDKProfilePictureModeSquare;
            
            profPicView.layer.cornerRadius = 34/2;
            profPicView.layer.masksToBounds = YES;
            profPicView.accessibilityIdentifier = object.objectId;
            profPicView.userInteractionEnabled = YES;
            
            profPicView.tag = 99;
            [cell addSubview:profPicView];
        }
        
        cell.messageLabel.text = [NSString stringWithFormat:@"Your Facebook friend %@ just joined Happening.", object[@"userFullName"]];
        NSUInteger randomIndex = arc4random() % [funnyEndings count];
        
        cell.messageLabel.text = [cell.messageLabel.text stringByAppendingString:funnyEndings[randomIndex]];
        
        return cell;
        
    }
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

- (PFObject *)objectAtIndex:(NSInteger)index {
    
    if (meButtonPressed)
        return MEactivityObjects[index];
    
    return FRIENDSactivityObjects[index];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    PFObject *object = [self objectAtIndex:indexPath.row];
    
    if (object) {
        
        NSString *type = [object objectForKey:@"type"];

        if ([type isEqualToString:@"interested"]) {
            
            return 70;
            
        } else if ([type isEqualToString:@"reminder"]) {
            
            return 70;
            
        } else if ([type isEqualToString:@"match"]) {
            
            return 44;
            
        } else if ([type isEqualToString:@"friendJoined"]) {
            
            return 44;
            
        }
    }
    
    return 44;
}

- (IBAction)meButtonPressed:(id)sender {
    
    NSLog(@"Made it");
    
    [meButton setTitleColor:[UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0] forState:UIControlStateNormal];
    [friendsButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        sliderView.frame = CGRectMake(0, 38, 160, 2);
        
    } completion:^(BOOL finished) {
        
    }];

    meButtonPressed = YES;
    [self.tableView reloadData];
    //[self clear];
    //[self loadObjects];
}

- (IBAction)friendsButtonPressed:(id)sender {
    
    [friendsButton setTitleColor:[UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0] forState:UIControlStateNormal];
    [meButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:0.3 animations:^{
        sliderView.frame = CGRectMake(160, 38, 160, 2);
    } completion:^(BOOL finished) {
        
    }];
    
    meButtonPressed = NO;
    [self.tableView reloadData];
    //[self clear];
    //[self loadObjects];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.tableView.contentOffset.y > 0) {
    
        CGRect newFrame = containerView.frame;
        newFrame.origin.x = 0;
        newFrame.origin.y = self.tableView.contentOffset.y;
        containerView.frame = newFrame;
        
    } else {
        
        containerView.frame = CGRectMake(0, 0, 320, 40);
        
    }
    
    
}

/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
 return [objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - Table view data source

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void)profileTapped:(UIGestureRecognizer *)gr {
    
    FBSDKProfilePictureView *ppView = (FBSDKProfilePictureView *)gr.view;
    selectedFriendId = ppView.accessibilityIdentifier;
    [self performSegueWithIdentifier:@"toProf" sender:self];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    PFObject *object = [self objectAtIndex:indexPath.row];
    
    if (object) {
        
        NSString *type = [object objectForKey:@"type"];
        
        if ([type isEqualToString:@"interested"]) {
            
            [self performSegueWithIdentifier:@"toEvent" sender:self];
            
        } else if ([type isEqualToString:@"reminder"]) {
            
            [self performSegueWithIdentifier:@"toEvent" sender:self];
            
        } else if ([type isEqualToString:@"match"]) {
            
            
        } else if ([type isEqualToString:@"friendJoined"]) {
            
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            friendJoinedCell *cell = (friendJoinedCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            selectedFriendId = cell.activityObject[@"userParseId"];
            
            [self performSegueWithIdentifier:@"toProf" sender:self];
        }
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toEvent"]) {
        /*
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        AttendTableCell *cell = (AttendTableCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath];
        
        ExpandedCardVC *vc = (ExpandedCardVC *)[segue destinationViewController];
        vc.event = cell.eventObject;
        vc.image = cell.eventImageView.image;
        vc.eventID = cell.eventID;
        vc.distanceString = cell.distance.text;
        */
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        PFObject *object = [self objectAtIndex:indexPath.row];
        
        if (object) {
            
            NSString *type = [object objectForKey:@"type"];
            
            if ([type isEqualToString:@"interested"]) {
                
                interestedCell *cell = (interestedCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                ExpandedCardVC *vc = (ExpandedCardVC *)[[segue destinationViewController] topViewController];
                
                PFObject *activityObject = [self objectAtIndex:indexPath.row];
                
                NSDictionary *dict = [eventObjectDict objectForKey:activityObject[@"eventId"]];
                
                if (cell.eventObject != nil) {
                    vc.event = cell.eventObject;
                    if (cell.eventImageView.image)
                        vc.image = [dict objectForKey:@"image"];
                }
                
                vc.eventID = activityObject.objectId;
                
            } else if ([type isEqualToString:@"reminder"]) {
                
                reminderCell *cell = (reminderCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                ExpandedCardVC *vc = (ExpandedCardVC *) [[segue destinationViewController] topViewController];
                
                PFObject *activityObject = [self objectAtIndex:indexPath.row];
                
                NSDictionary *dict = [eventObjectDict objectForKey:activityObject[@"eventId"]];
                
                if (cell.eventObject != nil) {
                    vc.event = cell.eventObject;
                    if (cell.eventImageView.image)
                        vc.image = [dict objectForKey:@"image"];
                }
                
                vc.eventID = activityObject.objectId;
                
            } else if ([type isEqualToString:@"match"]) {
                
                matchesCell *cell = (matchesCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                
            } else if ([type isEqualToString:@"friendJoined"]) {
                
                friendJoinedCell *cell = (friendJoinedCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                
            }
        }
    
    }  else if ([segue.identifier isEqualToString:@"toProf"]) {

        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.userID = selectedFriendId;
        
    }
    
}


@end
