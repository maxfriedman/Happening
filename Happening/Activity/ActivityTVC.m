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
#import "ProfilePictureView.h"
#import "AppDelegate.h"
#import "AnonymousUserView.h"

@interface ActivityTVC () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, AnonymousUserViewDelegate>

@property NSMutableArray *MEactivityObjects;
@property NSMutableArray *FRIENDSactivityObjects;
@property (nonatomic, strong) UIButton *scrollToTopButton;
@property (nonatomic, assign) CGFloat lastContentOffset;

@end

@implementation ActivityTVC {
    
    BOOL meButtonPressed;
    NSString *selectedFriendId;
    NSArray *funnyEndings;
    NSMutableDictionary *activityObjectDict;
    NSMutableArray *friendIds;
    BOOL isRefreshing;
    
    
}

@synthesize meButton, sliderView, friendsButton, containerView, MEactivityObjects, FRIENDSactivityObjects, scrollToTopButton;

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
    
    funnyEndings = @[@" Hold the applause.", @" Hollah!", @" Now it's a party.", @" About time.", @" Heck yes.", @" Aw yeah.", @" *Air five*", @" Whoop whoop.", @" *fist pump*", @" *slow clap*", @" *fist bump*", @" Turn up?", @" Leggo.", @" Booyah.", @" Oh ya.", @" Awesome sauce.", @" &$*# @&#%!!!"];
    
    scrollToTopButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 110, 25)];
    scrollToTopButton.center = CGPointMake(self.view.center.x, self.containerView.frame.origin.y + self.containerView.frame.size.height - 100);
    scrollToTopButton.alpha = 1.00;
    scrollToTopButton.backgroundColor = [UIColor colorWithRed:0.0 green:185.0/255 blue:245.0/255 alpha:1.0];
    scrollToTopButton.layer.cornerRadius = 25/2;
    scrollToTopButton.clipsToBounds = YES;
    [scrollToTopButton setTitle:@"New stuff!" forState:UIControlStateNormal];
    [scrollToTopButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:12.0]];
    [scrollToTopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [scrollToTopButton addTarget:self action:@selector(toTop) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:scrollToTopButton aboveSubview:self.tableView];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self.tableView sendSubviewToBack:refreshControl];
    
    isRefreshing = NO;

}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    
    [self updateFriends];
    [self updateMe];
    [self.tableView reloadData];
    [self.tableView layoutIfNeeded];
    [refreshControl endRefreshing];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)toTop {
    scrollToTopButton.alpha = 0.9999;
    [UIView animateWithDuration:0.5 animations:^{
        [self.tableView setContentOffset:CGPointZero];
        scrollToTopButton.center = CGPointMake(self.view.center.x, -100);
    } completion:^(BOOL finished) {
        //scrollToTopButton.alpha = 0;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
    
        [[self.view viewWithTag:456] removeFromSuperview];
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        
        NSArray *friends = [[PFUser currentUser] objectForKey:@"friends"];
        friendIds = [NSMutableArray new];
        for (NSDictionary *dict in friends) {
            [friendIds addObject:[dict valueForKey:@"id"]];
        }
        
        if (!MEactivityObjects || !FRIENDSactivityObjects) {
            MEactivityObjects = [NSMutableArray array];
            FRIENDSactivityObjects = [NSMutableArray array];
            activityObjectDict = [NSMutableDictionary dictionary];
            [self loadObjectsFromCache];
        } else {
            [self updateFriends];
            [self updateMe];
        }
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate.mh.activityHub decrementBy:appDelegate.mh.activityHub.count];
        
    } else {
        
        AnonymousUserView *anonView = [[AnonymousUserView alloc] initWithFrame:CGRectMake(0, 64, 320, 519-64)];
        anonView.delegate = self;
        anonView.tag = 456;
        [self.navigationController.view addSubview:anonView];
        [anonView setImage:[UIImage imageNamed:@"activity feed"]];
        [anonView setMessage:@"Sign in to see what your friends are up to and to view your notifications!"];
        
    }
    
}

- (void)loadObjectsFromCache {
    

    PFQuery *finalQuery = [PFQuery queryWithClassName:@"Activity"];
    
    /*
    PFQuery *reminderQuery = [PFQuery queryWithClassName:@"Activity"];
    [reminderQuery fromLocalDatastore];
    [reminderQuery whereKey:@"type" equalTo:@"reminder"];
    [reminderQuery whereKey:@"userParseId" equalTo:[PFUser currentUser].objectId];
     
    PFQuery *friendJoinedQuery = [PFQuery queryWithClassName:@"Activity"];
    [friendJoinedQuery fromLocalDatastore];
    [friendJoinedQuery whereKey:@"type" equalTo:@"friendJoined"];
    [friendJoinedQuery whereKey:@"userParseId" containedIn:idsArray];
    
    PFQuery *meQuery = [PFQuery orQueryWithSubqueries:@[reminderQuery, friendJoinedQuery]];
    [meQuery fromLocalDatastore]; */
    
    __block BOOL shouldContinue = NO;
    
    PFQuery *meQuery = [PFQuery queryWithClassName:@"Activity"];
    [meQuery fromPinWithName:@"me"];
    [meQuery orderByDescending:@"createdDate"];
    [meQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            for (int i = 0; i < objects.count; i++) {
                
                PFObject *object = objects[i];
                
                if (i < 15) {
                    
                    NSMutableDictionary *activityDict = [NSMutableDictionary dictionary];
                    [activityObjectDict setObject:activityDict forKey:object.objectId];
                        
                    if (object[@"eventId"] != nil) {
                        [activityDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                    }
                    
                    [activityDict setObject:@NO forKey:@"isNew"];
                    [MEactivityObjects addObject:object];
                    
                } else {
                    
                    [object unpinInBackground];
                }
                
            }
            
        } else {
            
            NSLog(@"Error loading activity objects: %@", error);
        }
        
        [self.tableView reloadData];
        [self updateMe];
        
    }];
    
    
    PFQuery *friendsQuery = [PFQuery queryWithClassName:@"Activity"];
    [friendsQuery fromPinWithName:@"friends"];
    [friendsQuery orderByDescending:@"createdDate"];
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            for (int i = 0; i < objects.count; i++) {
                
                PFObject *object = objects[i];
                
                if (i < 15) {
                    
                    NSMutableDictionary *activityDict = [NSMutableDictionary dictionary];
                    [activityObjectDict setObject:activityDict forKey:object.objectId];
                        
                    if (object[@"eventId"] != nil) {
                        [activityDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                    }
                    [activityDict setObject:@NO forKey:@"isNew"];
                    [FRIENDSactivityObjects addObject:object];
                    
                } else {
                    
                    [object unpinInBackground];
                }
                
            }
            
        } else {
            
            NSLog(@"Error loading activity objects: %@", error);
        }
        
        [self.tableView reloadData];
        [self updateFriends];
        
    }];
    
    
                                                   /*
    PFQuery *interestedQuery = [PFQuery queryWithClassName:@"Activity"];
    [interestedQuery whereKey:@"type" equalTo:@"interested"];
    [interestedQuery whereKey:@"userParseId" containedIn:idsArray];
     
    finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:reminderQuery,friendJoinedQuery,interestedQuery, nil]];
    
    
    //[finalQuery includeKey:@"eventObject"];
    [finalQuery orderByDescending:@"createdDate"];
    [finalQuery fromLocalDatastore];
    //finalQuery.limit = 15;
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            for (int i = 0; i < objects.count; i++) {
                
                PFObject *object = objects[i];
                
                if (i < 15) {
                    
                    NSMutableDictionary *activityDict = [NSMutableDictionary dictionary];
                    [activityObjectDict setObject:activityDict forKey:object.objectId];
                    
                    NSString *type = object[@"type"];
                    
                    if ([type isEqualToString:@"interested"] || [type isEqualToString:@"match"] || [type isEqualToString:@"going"]) {
                        
                        if (object[@"eventId"] != nil) {
                            [activityDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                        }
                        [activityDict setObject:@NO forKey:@"isNew"];
                        [FRIENDSactivityObjects addObject:object];
                        
                    } else if ([type isEqualToString:@"reminder"] || [type isEqualToString:@"match"] || [type isEqualToString:@"friendJoined"]) {
                        
                        if (object[@"eventId"] != nil) {
                            [activityDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                        }
                        [activityDict setObject:@NO forKey:@"isNew"];
                        [MEactivityObjects addObject:object];
                        
                    }
                
                } else {
                    
                    [object unpinInBackground];
                }
                
            }
            
            [self.tableView reloadData];
            [self checkForUpdatedActivities];
            
        } else {
            
            NSLog(@"Error loading activity objects: %@", error);
        }
        
    }]; */

}

- (void)updateFriends {
    
    PFQuery *finalQuery = [PFQuery queryWithClassName:@"Activity"];
    
    PFQuery *interestedQuery = [PFQuery queryWithClassName:@"Activity"];
    [interestedQuery whereKey:@"type" containedIn:@[@"interested", @"going", @"create"]];
    [interestedQuery whereKey:@"userFBId" containedIn:friendIds];
    
    finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:interestedQuery, nil]];
    
    [finalQuery orderByDescending:@"createdDate"]; // required bc of limit, need most recent results. Enumerate array backwards.
    
    finalQuery.limit = 15;
    
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            BOOL shouldReload = NO;
            BOOL tableIsEmpty = NO;
            if (meButtonPressed && MEactivityObjects.count == 0) tableIsEmpty = YES;
            if (!meButtonPressed && FRIENDSactivityObjects.count == 0) tableIsEmpty = YES;
            
            for (int i = (int)objects.count - 1; i >= 0; i--) {
                
                PFObject *object = objects[i];
                
                if ([activityObjectDict objectForKey:object.objectId] == nil) { // activity object doesn't exist
                    
                    NSMutableDictionary *activityDict = [NSMutableDictionary dictionary];
                    [activityObjectDict setObject:activityDict forKey:object.objectId];
                    
                    if (![FRIENDSactivityObjects containsObject:object]) {
                        [object pinInBackgroundWithName:@"friends"];
                        if (object[@"eventId"] != nil) {
                            [activityDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                        }
                        [activityDict setObject:@YES forKey:@"isNew"];
                        shouldReload = YES;
                        [FRIENDSactivityObjects insertObject:object atIndex:0];
                    }
                }
            }
            
            if (shouldReload && !meButtonPressed) {
                NSLog(@"New activities! Updating...");
                
                if (!tableIsEmpty) {
                    CGSize beforeContentSize = self.tableView.contentSize;
                    [self.tableView reloadData];
                    CGSize afterContentSize = self.tableView.contentSize;
                    
                    CGPoint afterContentOffset = self.tableView.contentOffset;
                    CGPoint newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height  -  10  );
                    
                    self.tableView.contentOffset = newContentOffset;
                    
                    
                    scrollToTopButton.alpha = 1;
                    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        scrollToTopButton.center = CGPointMake(scrollToTopButton.center.x, containerView.frame.origin.y + containerView.frame.size.height + 20);
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                } else {
                    
                    [self.tableView reloadData];
                    
                }
                
            } else if (shouldReload) {
                
                [self friendsButtonPressed:self.friendsButton];
            }
            
        } else {
            
            NSLog(@"Error loading activity objects: %@", error);
        }
        
    }];

    
}

- (void)updateMe {
    
    PFQuery *finalQuery = [PFQuery queryWithClassName:@"Activity"];
    
    PFQuery *reminderQuery = [PFQuery queryWithClassName:@"Activity"];
    [reminderQuery whereKey:@"type" equalTo:@"reminder"];
    [reminderQuery whereKey:@"userParseId" equalTo:[PFUser currentUser].objectId];
    
    PFQuery *friendJoinedQuery = [PFQuery queryWithClassName:@"Activity"];
    [friendJoinedQuery whereKey:@"type" equalTo:@"friendJoined"];
    [friendJoinedQuery whereKey:@"userFBId" containedIn:friendIds];
    
    finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:reminderQuery,friendJoinedQuery, nil]];
    
    [finalQuery orderByDescending:@"createdDate"]; // required bc of limit, need most recent results. Enumerate array backwards.
    
    finalQuery.limit = 15;
    
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            NSLog(@"%@",objects);
            
            BOOL shouldReload = NO;
            BOOL tableIsEmpty = NO;
            if (meButtonPressed && MEactivityObjects.count == 0) tableIsEmpty = YES;
            if (!meButtonPressed && FRIENDSactivityObjects.count == 0) tableIsEmpty = YES;
            
            for (int i = (int)objects.count - 1; i >= 0; i--) {
                
                PFObject *object = objects[i];
                
                if ([activityObjectDict objectForKey:object.objectId] == nil) { // activity object doesn't exist
                    
                    NSMutableDictionary *activityDict = [NSMutableDictionary dictionary];
                    [activityObjectDict setObject:activityDict forKey:object.objectId];
                    
                    if (![MEactivityObjects containsObject:object]) {
                        [object pinInBackgroundWithName:@"me"];
                        if (object[@"eventId"] != nil) {
                            [activityDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                        }
                        [activityDict setObject:@YES forKey:@"isNew"];
                        shouldReload = YES;
                        [MEactivityObjects insertObject:object atIndex:0];
                    }
                }
            }
            
            if (shouldReload && meButtonPressed) {
                NSLog(@"New activities! Updating...");
                
                if (!tableIsEmpty) {
                    CGSize beforeContentSize = self.tableView.contentSize;
                    [self.tableView reloadData];
                    CGSize afterContentSize = self.tableView.contentSize;
                    
                    CGPoint afterContentOffset = self.tableView.contentOffset;
                    CGPoint newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height  -  10  );
                    
                    self.tableView.contentOffset = newContentOffset;
                    
                    
                    scrollToTopButton.alpha = 1;
                    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        scrollToTopButton.center = CGPointMake(scrollToTopButton.center.x, containerView.frame.origin.y + containerView.frame.size.height + 20);
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                } else {
                    
                    [self.tableView reloadData];
                    
                }
                
            } else if (shouldReload) {
                
                [self meButtonPressed:self.meButton];
                
            }
            
        } else {
            
            NSLog(@"Error loading activity objects: %@", error);
        }
        
    }];
    
}

- (void)loadPastActivities {
    
    if (meButtonPressed) {
        
        PFQuery *finalQuery = [PFQuery queryWithClassName:@"Activity"];
        
        PFQuery *reminderQuery = [PFQuery queryWithClassName:@"Activity"];
        [reminderQuery whereKey:@"type" equalTo:@"reminder"];
        [reminderQuery whereKey:@"userParseId" equalTo:[PFUser currentUser].objectId];
        
        PFQuery *friendJoinedQuery = [PFQuery queryWithClassName:@"Activity"];
        [friendJoinedQuery whereKey:@"type" equalTo:@"friendJoined"];
        [friendJoinedQuery whereKey:@"userFBId" containedIn:friendIds];
        
        finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:reminderQuery,friendJoinedQuery, nil]];
        
        PFObject *object = [MEactivityObjects lastObject];
        NSDate *lastObjectDate = object[@"createdDate"];
        [finalQuery whereKey:@"createdDate" lessThan:lastObjectDate];
        
        [finalQuery orderByDescending:@"createdDate"]; // required bc of limit, need most recent results. Enumerate array backwards.
        
        finalQuery.limit = 15;
        
        [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                
                BOOL shouldReload = NO;
                BOOL tableIsEmpty = NO;
                if (MEactivityObjects.count == 0) tableIsEmpty = YES;
                int indexOfInsertion = (int)MEactivityObjects.count;
                
                //for (int i = (int)objects.count - 1; i >= 0; i--) {
                
                for (int i = 0; i < objects.count; i++) {
                    
                    PFObject *object = objects[i];
                    
                    if ([activityObjectDict objectForKey:object.objectId] == nil) { // activity object doesn't exist
                        
                        NSMutableDictionary *activityDict = [NSMutableDictionary dictionary];
                        [activityObjectDict setObject:activityDict forKey:object.objectId];
                        
                        if (![MEactivityObjects containsObject:object]) {
                            if (object[@"eventId"] != nil) {
                                [activityDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                            }
                            [activityDict setObject:@NO forKey:@"isNew"];
                            shouldReload = YES;
                            [MEactivityObjects addObject:object];
                            //[MEactivityObjects insertObject:object atIndex:indexOfInsertion];
                        }
                    }
                }
                
                if (shouldReload && meButtonPressed) {
                    NSLog(@"Updating old activities...");
                
                    [self.tableView reloadData];
                    isRefreshing = NO;
                    
                } else if (shouldReload) {
                    
                    [self meButtonPressed:self.meButton];
                    
                }
                
            } else {
                
                NSLog(@"Error loading activity objects: %@", error);
            }
            
        }];

        
        
    } else {
        
        PFQuery *finalQuery = [PFQuery queryWithClassName:@"Activity"];
        
        PFQuery *interestedQuery = [PFQuery queryWithClassName:@"Activity"];
        [interestedQuery whereKey:@"type" containedIn:@[@"interested", @"going", @"create"]];
        [interestedQuery whereKey:@"userFBId" containedIn:friendIds];
        
        finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:interestedQuery, nil]];
        
        PFObject *object = [FRIENDSactivityObjects lastObject];
        NSDate *lastObjectDate = object[@"createdDate"];
        [finalQuery whereKey:@"createdDate" lessThan:lastObjectDate];
        
        [finalQuery orderByDescending:@"createdDate"]; // required bc of limit, need most recent results. Enumerate array backwards.
        
        finalQuery.limit = 15;
        
        [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                
                BOOL shouldReload = NO;
                BOOL tableIsEmpty = NO;
                if (FRIENDSactivityObjects.count == 0) tableIsEmpty = YES;
                
                for (int i = 0; i < objects.count; i++) {
                    
                    PFObject *object = objects[i];
                    
                    if ([activityObjectDict objectForKey:object.objectId] == nil) { // activity object doesn't exist
                        
                        NSMutableDictionary *activityDict = [NSMutableDictionary dictionary];
                        [activityObjectDict setObject:activityDict forKey:object.objectId];
                        
                        if (![FRIENDSactivityObjects containsObject:object]) {
                            [object pinInBackgroundWithName:@"friends"];
                            if (object[@"eventId"] != nil) {
                                [activityDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                            }
                            [activityDict setObject:@NO forKey:@"isNew"];
                            shouldReload = YES;
                            [FRIENDSactivityObjects addObject:object];
                        }
                    }
                }
                
                if (shouldReload) {
                    NSLog(@"Updating old activities...");
                    
                    [self.tableView reloadData];
                    isRefreshing = NO;
                    
                } else if (shouldReload) {
                    
                    [self friendsButtonPressed:self.friendsButton];
                }
                
            } else {
                
                NSLog(@"Error loading activity objects: %@", error);
            }
            
        }];
        
        
    }
    
    
    
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
    [interestedQuery whereKey:@"type" containedIn:@[@"interested", @"going", @"create"]];
    [interestedQuery whereKey:@"userParseId" containedIn:idsArray];
    
    finalQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:reminderQuery,friendJoinedQuery,interestedQuery, nil]];
    //}
    
    [finalQuery includeKey:@"eventObject"];
    [finalQuery orderByDescending:@"createdDate"]; // required bc of limit, need most recent results. Enumerate array backwards.
    
    finalQuery.limit = 15;
    
    [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            
            BOOL shouldReload = NO;
            BOOL tableIsEmpty = NO;
            if (meButtonPressed && MEactivityObjects.count == 0) tableIsEmpty = YES;
            if (!meButtonPressed && FRIENDSactivityObjects.count == 0) tableIsEmpty = YES;
            
            for (int i = (int)objects.count - 1; i >= 0; i--) {
                
                PFObject *object = objects[i];
               
                if ([activityObjectDict objectForKey:object.objectId] == nil) { // activity object doesn't exist
                    
                    [object pinInBackground];
                    
                    NSMutableDictionary *activityDict = [NSMutableDictionary dictionary];
                    [activityObjectDict setObject:activityDict forKey:object.objectId];
                
                    NSString *type = object[@"type"];
                    
                    if ([type isEqualToString:@"interested"] || [type isEqualToString:@"going"] || [type isEqualToString:@"create"]) {
                        
                            if (object[@"eventId"] != nil) {
                                [activityDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                            }
                            [activityDict setObject:@YES forKey:@"isNew"];
                            shouldReload = YES;
                            [FRIENDSactivityObjects insertObject:object atIndex:0];
                        
                    } else if ([type isEqualToString:@"reminder"] || [type isEqualToString:@"match"] || [type isEqualToString:@"friendJoined"]) {
                        
                        if (![MEactivityObjects containsObject:object]) {
                            [object pinInBackground];
                            if (object[@"eventId"] != nil) {
                                [activityDict setObject:[NSMutableDictionary dictionary] forKey:object[@"eventId"]];
                            }
                            [activityDict setObject:@YES forKey:@"isNew"];
                            shouldReload = YES;
                            [MEactivityObjects insertObject:object atIndex:0];
                        }
                    }
                }
            }
            
            if (shouldReload) {
                NSLog(@"New activities! Updating...");
                
                if (!tableIsEmpty) {
                    CGSize beforeContentSize = self.tableView.contentSize;
                    [self.tableView reloadData];
                    CGSize afterContentSize = self.tableView.contentSize;
                    
                    CGPoint afterContentOffset = self.tableView.contentOffset;
                    CGPoint newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height  -  10  );
                    
                    self.tableView.contentOffset = newContentOffset;
                    
                    
                    scrollToTopButton.alpha = 1;
                    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        scrollToTopButton.center = CGPointMake(scrollToTopButton.center.x, containerView.frame.origin.y + containerView.frame.size.height + 20);
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                } else {
                    
                    [self.tableView reloadData];

                }
                
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (meButtonPressed)
        return MEactivityObjects.count;
    
    return FRIENDSactivityObjects.count;
}


// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PFObject *object = [self objectAtIndex:indexPath.row];
    NSString *type = object[@"type"];
    
    NSString *timestampString = @"";
    NSDate *timestampDate = object[@"createdDate"];
    NSUInteger intervalInSeconds = [[NSDate date] timeIntervalSinceDate:timestampDate];
    NSUInteger intervalInMinutes = intervalInSeconds / 60;
    NSUInteger intervalInHours = intervalInMinutes / 60;
    NSUInteger intervalInDays = intervalInHours / 24;
    NSUInteger intervalInWeeks = intervalInDays / 7;
    
    if (intervalInMinutes < 60) {
        timestampString = [NSString stringWithFormat:@"%dm", (int)intervalInMinutes];
    } else if (intervalInHours < 24) {
        timestampString = [NSString stringWithFormat:@"%dh", (int)intervalInHours];
    } else if (intervalInDays < 7) {
        timestampString = [NSString stringWithFormat:@"%dd", (int)intervalInDays];
    } else {
        timestampString = [NSString stringWithFormat:@"%dw", (int)intervalInWeeks];
    }
    
    NSMutableDictionary *activityDict = [activityObjectDict objectForKey:object.objectId];
    
    if ([type isEqualToString:@"interested"] || [type isEqualToString:@"going"] || [type isEqualToString:@"create"]) {
        
        NSString *CellIdentifier = @"interested";
        interestedCell *cell = (interestedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[interestedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.timestampLabel.text = timestampString;
        cell.eventDateLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:12.0];
        
        if ([[activityDict objectForKey:@"isNew"] boolValue] == NO) {
            cell.backgroundColor = [UIColor whiteColor];
        } else {
            cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [activityDict setObject:@NO forKey:@"isNew"];
        }
        
        if ([activityDict objectForKey:@"profPicView"] == nil) {
            
            for (UIView *view in cell.subviews) {
                if (view.tag == 99) [view removeFromSuperview];
            }
            
            ProfilePictureView *ppview = [[ProfilePictureView alloc] initWithFrame:CGRectMake(7, 7, 36, 36) type:type fbid:object[@"userFBId"]];
            ppview.parseId = object[@"userParseId"];
            
            UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapped:)];
            [ppview addGestureRecognizer:gr];
            ppview.tag = 99;
            [cell addSubview:ppview];
            [activityDict setObject:ppview forKey:@"profPicView"];
            
        } else {
            
            for (UIView *view in cell.subviews) {
                if (view.tag == 99) [view removeFromSuperview];
            }

            [cell addSubview:[activityDict objectForKey:@"profPicView"]];
        }
        
        UIFont *font = [UIFont fontWithName:@"OpenSans-Bold" size:12.0];
        NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithObject:font
                                                                                  forKey:NSFontAttributeName];
        //[attrsDictionary setObject:[UIColor colorWithRed:0.0/255 green:176.0/255 blue:242.0/255 alpha:1.0] forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:object[@"userFullName"] attributes:attrsDictionary];
        NSMutableAttributedString *aAttrString2;
        if ([type isEqualToString:@"going"])
            aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@" is going to:"];
        else if ([type isEqualToString:@"interested"])
            aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@" is interested in:"];
        else
            aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@" created a Happening:"];

        [aAttrString1 appendAttributedString:aAttrString2];
        
        cell.messageLabel.attributedText = aAttrString1;
        
        cell.eventTitleLabel.text = object[@"eventName"];
        cell.eventLocLabel.text = object[@"eventLoc"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE, MMM d"];
        NSDate *eventDate = object[@"eventDate"];
        cell.eventDateLabel.text = [formatter stringFromDate:eventDate];
        
        cell.eventImageView.image = nil;
        
        if ([activityDict objectForKey:@"event"] == nil) {
            PFObject *event = object[@"eventObject"];
            [event fetchInBackgroundWithBlock:^(PFObject *event, NSError *error) {
                [activityDict setObject:event forKey:@"event"];
                cell.eventObject = event;
                PFFile *file = event[@"Image"];
                cell.eventImageView.alpha = 0;
                if (file) {
                    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        cell.eventImageView.image = [UIImage imageWithData:data];
                        [activityDict setObject:cell.eventImageView.image forKey:@"image"];
                        [UIView animateWithDuration:0.4 animations:^{
                            cell.eventImageView.alpha = 1.0;
                        }];
                    }];
                } else {
                    cell.eventImageView.image = [UIImage imageNamed:event[@"Hashtag"]];
                    [activityDict setObject:cell.eventImageView.image forKey:@"image"];
                    [UIView animateWithDuration:0.4 animations:^{
                        cell.eventImageView.alpha = 1.0;
                    }];
                }
            }];
            
        } else if ([activityDict objectForKey:@"image"] == nil) {
            
            PFObject *event = [activityDict objectForKey:@"event"];
            PFFile *file = event[@"Image"];
            cell.eventImageView.alpha = 0;
            if (file) {
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    cell.eventImageView.image = [UIImage imageWithData:data];
                    [activityDict setObject:cell.eventImageView.image forKey:@"image"];
                    [UIView animateWithDuration:0.4 animations:^{
                        cell.eventImageView.alpha = 1.0;
                    }];
                }];
            } else {
                cell.eventImageView.image = [UIImage imageNamed:event[@"Hashtag"]];
                [activityDict setObject:cell.eventImageView.image forKey:@"image"];
                [UIView animateWithDuration:0.4 animations:^{
                    cell.eventImageView.alpha = 1.0;
                }];
            }
            
        } else {
        
            cell.eventObject = [activityDict objectForKey:@"event"];
            cell.eventImageView.image = [activityDict objectForKey:@"image"];
        }
        
        if ([[eventDate beginningOfDay] compare:[[NSDate date] beginningOfDay]] == NSOrderedAscending) {
            cell.eventDateLabel.font = [UIFont fontWithName:@"OpenSansLight-Italic" size:12.0];
        }
        
        return cell;
        
    } else if ([type isEqualToString:@"reminder"]) {
        
        NSString *CellIdentifier = type;
        reminderCell *cell = (reminderCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[reminderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.timestampLabel.text = timestampString;
        cell.eventDateLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:12.0];
        
        if ([[activityDict objectForKey:@"isNew"] boolValue] == NO) {
            cell.backgroundColor = [UIColor whiteColor];
        } else {
            cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [activityDict setObject:@NO forKey:@"isNew"];
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
        
        cell.eventImageView.image = nil;
        
        if ([activityDict objectForKey:@"event"] == nil) {
            PFObject *event = object[@"eventObject"];
            [event fetchInBackgroundWithBlock:^(PFObject *event, NSError *error) {
                [activityDict setObject:event forKey:@"event"];
                cell.eventObject = event;
                PFFile *file = event[@"Image"];
                cell.eventImageView.alpha = 0;
                if (file) {
                    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        cell.eventImageView.image = [UIImage imageWithData:data];
                        [activityDict setObject:cell.eventImageView.image forKey:@"image"];
                        [UIView animateWithDuration:0.4 animations:^{
                            cell.eventImageView.alpha = 1.0;
                        }];
                    }];
                } else {
                    cell.eventImageView.image = [UIImage imageNamed:event[@"Hashtag"]];
                    [activityDict setObject:cell.eventImageView.image forKey:@"image"];
                    [UIView animateWithDuration:0.4 animations:^{
                        cell.eventImageView.alpha = 1.0;
                    }];
                }

            }];
            
        } else if ([activityDict objectForKey:@"image"] == nil) {
            
            PFObject *event = [activityDict objectForKey:@"event"];
            PFFile *file = event[@"Image"];
            cell.eventImageView.alpha = 0;
            if (file) {
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    cell.eventImageView.image = [UIImage imageWithData:data];
                    [activityDict setObject:cell.eventImageView.image forKey:@"image"];
                    [UIView animateWithDuration:0.4 animations:^{
                        cell.eventImageView.alpha = 1.0;
                    }];
                }];
            } else {
                cell.eventImageView.image = [UIImage imageNamed:event[@"Hashtag"]];
                [activityDict setObject:cell.eventImageView.image forKey:@"image"];
                [UIView animateWithDuration:0.4 animations:^{
                    cell.eventImageView.alpha = 1.0;
                }];
            }
            
        } else {
            
            cell.eventObject = [activityDict objectForKey:@"event"];
            cell.eventImageView.image = [activityDict objectForKey:@"image"];
        }
        
        if ([[eventDate beginningOfDay] compare:[[NSDate date] beginningOfDay]] == NSOrderedAscending) {
            cell.eventDateLabel.font = [UIFont fontWithName:@"OpenSansLight-Italic" size:12.0];
        }
        
        return cell;
        
    } else if ([type isEqualToString:@"match"]) {
        
        NSString *CellIdentifier = type;
        matchesCell *cell = (matchesCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[matchesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        //cell.timestampLabel.text = timestampString;
        
        return cell;

    } else if ([type isEqualToString:@"friendJoined"]) {
        
        NSString *CellIdentifier = type;
        friendJoinedCell *cell = (friendJoinedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[friendJoinedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.timestampLabel.text = timestampString;
        
        cell.activityObject = object;
        
        if ([[activityDict objectForKey:@"isNew"] boolValue] == NO) {
            cell.backgroundColor = [UIColor whiteColor];
        } else {
            cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [activityDict setObject:@NO forKey:@"isNew"];
        }
        
        if ([activityDict objectForKey:@"profPicView"] == nil) {

            ProfilePictureView *ppview = [[ProfilePictureView alloc] initWithFrame:CGRectMake(7, 7, 36, 36) type:@"none" fbid:object[@"userFBId"]];
            ppview.parseId = object[@"userParseId"];
            UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapped:)];
            [ppview addGestureRecognizer:gr];
            ppview.tag = 99;
            [cell addSubview:ppview];
            [activityDict setObject:ppview forKey:@"profPicView"];
            
        } else {
            
            for (UIView *view in cell.subviews) {
                if (view.tag == 99) [view removeFromSuperview];
            }

            [cell addSubview:[activityDict objectForKey:@"profPicView"]];
        }

        
        UIFont *font = [UIFont fontWithName:@"OpenSans-Light" size:10.0];
        NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithObject:font
                                                                                  forKey:NSFontAttributeName];
        NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"Your Facebook friend "];
        NSString *name = object[@"userFullName"];
        NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:name attributes:attrsDictionary];
        NSMutableAttributedString *aAttrString3 = [[NSMutableAttributedString alloc] initWithString:@" just joined Happening."];
        [aAttrString1 appendAttributedString:aAttrString2];
        [aAttrString1 appendAttributedString:aAttrString3];
        
        cell.messageLabel.attributedText = aAttrString1;

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

        if ([type isEqualToString:@"interested"] || [type isEqualToString:@"going"] || [type isEqualToString:@"create"]) {
            
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    if (scrollToTopButton.alpha == 1.0 && self.lastContentOffset < scrollView.contentOffset.y) {
        
        scrollToTopButton.alpha = 0.9999;
        [UIView animateWithDuration:0.5 animations:^{
            scrollToTopButton.center = CGPointMake(self.view.center.x, -100);
        } completion:^(BOOL finished) {
            //scrollToTopButton.alpha = 0;
        }];
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
    
    if (([scrollView contentOffset].y + scrollView.frame.size.height - 20) >= [scrollView contentSize].height){ // scrolled to bottom
        
        if (!isRefreshing) {
            NSLog(@"&& MADE IT");
            [self loadPastActivities];
            isRefreshing = YES;
        }
        
    }
    
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.tableView.contentOffset.y > 0) {
    
        CGRect newFrame = containerView.frame;
        newFrame.origin.x = 0;
        newFrame.origin.y = self.tableView.contentOffset.y;
        containerView.frame = newFrame;
        
    } else {
        
        containerView.frame = CGRectMake(0, 0, 320, 40);
        
    }
 
}*/

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

- (void)profileTapped:(UIGestureRecognizer *)gr {
    
    ProfilePictureView *ppview = (ProfilePictureView *)gr.view;
    selectedFriendId = ppview.parseId;
        
    [self performSegueWithIdentifier:@"toProf" sender:self];
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *c = [self.tableView cellForRowAtIndexPath:indexPath];
    c.backgroundColor = [UIColor whiteColor];
    
    PFObject *object = [self objectAtIndex:indexPath.row];
    
    if (object) {
        
        NSString *type = [object objectForKey:@"type"];
        
        if ([type isEqualToString:@"interested"] || [type isEqualToString:@"going"] || [type isEqualToString:@"create"]) {
            
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

- (void)facebookSuccessfulSignup {
    [[self.view viewWithTag:456] removeFromSuperview];
    //[self loadFriends];
    // Fetches all LYRConversation objects
    
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    NSError *error;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSOrderedSet *conversations = [appDelegate.layerClient executeQuery:query error:&error];
    if (!error) {
        NSLog(@"%tu conversations", conversations.count);
        
        if (conversations.count == 0 && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        }
        
    } else {
        NSLog(@"Query failed with error %@", error);
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
            
            if ([type isEqualToString:@"interested"] || [type isEqualToString:@"going"] || [type isEqualToString:@"create"]) {
                
                interestedCell *cell = (interestedCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                ExpandedCardVC *vc = (ExpandedCardVC *)[[segue destinationViewController] topViewController];
                
                PFObject *activityObject = [self objectAtIndex:indexPath.row];
                
                NSDictionary *dict = [activityObjectDict objectForKey:activityObject.objectId];
                
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
                
                NSDictionary *dict = [activityObjectDict objectForKey:activityObject.objectId];
                
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
