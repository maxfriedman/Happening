//
//  inviteHomies.m
//  Happening
//
//  Created by Max on 5/26/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "inviteHomies.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import "inviteHomiesCell.h"
#import "NewGroupCreatorVC.h"
#import "GroupsCell.h"

@interface inviteHomies () <UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation inviteHomies {
    NSMutableArray *headerList;
    NSMutableArray *friendsArray;
    NSArray *sortedFriends;
    NSMutableArray *uniqueFriendsByLetter;
    NSMutableDictionary *sections;
    NSArray *sortedFriendsLetters;
    NSMutableArray *selectedRowsArray;
    NSMutableArray *selectedIDs;

    UILabel *friendsLabel;
    UIScrollView *friendScrollView;
    UIButton *sendInvitesButton;
    
    NSArray *indexTitles;

    NSMutableArray *finalUserIDArray;
}

@synthesize namesOnBottomView, eventTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    headerList = [[NSMutableArray alloc] initWithObjects:@"GROUPS", @"INTERESTED", @"", /*@"NOT INTERESTED",*/ nil];
    friendsArray = [[NSMutableArray alloc] init];
    selectedRowsArray = [[NSMutableArray alloc] init];
    selectedIDs = [[NSMutableArray alloc] init];

    
    namesOnBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 568 - 64, 320, 50)];
    namesOnBottomView.backgroundColor = [UIColor colorWithRed:0.0/255 green:176.0/255 blue:242.0/255 alpha:1.0];
    [self.view addSubview:namesOnBottomView];
    
    friendScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 260, 50)];
    friendScrollView.scrollEnabled = YES;
    friendScrollView.showsHorizontalScrollIndicator = NO;
    [namesOnBottomView addSubview:friendScrollView];
    
    friendsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 14, 260, 22)];
    friendsLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:16.0];
    friendsLabel.textColor = [UIColor whiteColor];
    [friendScrollView addSubview:friendsLabel];
    
    sendInvitesButton = [[UIButton alloc] initWithFrame:CGRectMake(275, 9, 32, 32)];
    [sendInvitesButton setImage:[UIImage imageNamed:@"arrowRightThick"] forState:UIControlStateNormal];
    [sendInvitesButton addTarget:self action:@selector(inviteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [namesOnBottomView addSubview:sendInvitesButton];
    
    [self loadFriends];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFriends {
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends?limit=1000" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            //code
            
            NSArray* friends = [result objectForKey:@"data"];
            NSLog(@"Found: %lu friends", (unsigned long)friends.count);
        
            __block int friendCount = 1;
            
            NSMutableArray *names = [[NSMutableArray alloc] init];
            
            NSMutableArray *friendObjectIDs = [[NSMutableArray alloc] init];
            for (int i = 0; i < friends.count; i ++) {
                NSDictionary *friend = friends[i];
                [friendObjectIDs addObject:[friend objectForKey:@"id"]];
                [names addObject:[friend objectForKey:@"name"]];
            }
            
            NSMutableArray *p = [NSMutableArray arrayWithCapacity:names.count];
            for (NSUInteger i = 0 ; i != names.count ; i++) {
                [p addObject:[NSNumber numberWithInteger:i]];
            }
            [p sortWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
                // Modify this to use [first objectAtIndex:[obj1 intValue]].name property
                NSString *lhs = [names objectAtIndex:[obj1 intValue]];
                // Same goes for the next line: use the name
                NSString *rhs = [names objectAtIndex:[obj2 intValue]];
                return [lhs compare:rhs];
            }];
            NSMutableArray *sortedFirst = [NSMutableArray arrayWithCapacity:names.count];
            NSMutableArray *sortedSecond = [NSMutableArray arrayWithCapacity:friendObjectIDs.count];
            [p enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSUInteger pos = [obj intValue];
                [sortedFirst addObject:[names objectAtIndex:pos]];
                [sortedSecond addObject:[friendObjectIDs objectAtIndex:pos]];
            }];
            
            names = sortedFirst;
            friendObjectIDs = sortedSecond;
            
            sortedFriends = [names sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

            sections = [[NSMutableDictionary alloc] init];
            
            for (int i = 0; i < names.count; i++) {
                
                NSString *letter = [[names objectAtIndex: i] substringToIndex:1];
                NSMutableDictionary *letterDict = [sections objectForKey:letter];
                if (letterDict == nil) {
                    letterDict = [NSMutableDictionary dictionary];
                }
                
                [sections setObject:letterDict forKey:letter];

                
                NSMutableArray *namesArray = [letterDict objectForKey:@"Names"];
                if (namesArray == nil) {
                    namesArray = [NSMutableArray array];
                }
                
                [letterDict setObject:namesArray forKey:@"Names"];
                [namesArray addObject:names[i]];
                
                
                NSMutableArray *idsArray = [letterDict objectForKey:@"IDs"];
                if (idsArray == nil) {
                    idsArray = [NSMutableArray array];
                }
                
                [letterDict setObject:idsArray forKey:@"IDs"];
                
                FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
                profPicView.layer.cornerRadius = 15;
                profPicView.layer.masksToBounds = YES;
                profPicView.profileID = friendObjectIDs[i];
                profPicView.tag = 9;
                
                [idsArray addObject:profPicView];
                
                NSMutableArray *tappedArray = [letterDict objectForKey:@"Tapped"];
                if (tappedArray == nil) {
                    tappedArray = [NSMutableArray array];
                }
                
                [letterDict setObject:tappedArray forKey:@"Tapped"];
                NSNumber *no = [NSNumber numberWithInt:0];
                [tappedArray addObject:no];
                
            }
            
            NSArray *unsortedFriendsLetters = [sections allKeys];
            sortedFriendsLetters = [unsortedFriendsLetters sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            NSArray *addArray = [NSArray arrayWithObjects:@"GROUPS", @"INTERESTED", nil];

            
            sortedFriendsLetters = [addArray arrayByAddingObjectsFromArray:sortedFriendsLetters];

            NSMutableArray *blankGroupNamesArray1 = [NSMutableArray array];
            NSMutableArray *blankMemberNamesArray1 = [NSMutableArray array];
            NSMutableArray *blankIDsArray1 = [NSMutableArray array];
            NSMutableArray *blankTappedArray1 = [NSMutableArray array];
            NSMutableArray *blankNamesArray2 = [NSMutableArray array];
            NSMutableArray *blankIDsArray2 = [NSMutableArray array];
            NSMutableArray *blankTappedArray2 = [NSMutableArray array];
            
            NSMutableDictionary *blankDict1 = [NSMutableDictionary dictionary];
            NSMutableDictionary *blankDict2 = [NSMutableDictionary dictionary];
            
            [sections setObject:blankDict1 forKey:@"GROUPS"];
            [sections setObject:blankDict2 forKey:@"INTERESTED"];
            
            [blankDict1 setObject:blankGroupNamesArray1 forKey:@"GroupNames"];
            [blankDict1 setObject:blankMemberNamesArray1 forKey:@"MemberNames"];
            [blankDict1 setObject:blankIDsArray1 forKey:@"IDs"];
            [blankDict1 setObject:blankTappedArray1 forKey:@"Tapped"];
            [blankDict2 setObject:blankNamesArray2 forKey:@"Names"];
            [blankDict2 setObject:blankIDsArray2 forKey:@"IDs"];
            [blankDict2 setObject:blankTappedArray2 forKey:@"Tapped"];
            
            
            PFUser *currentUser = [PFUser currentUser];
            
            PFQuery *groupsUserQuery = [PFQuery queryWithClassName:@"Group_User"];
            [groupsUserQuery whereKey:@"user_id" equalTo:currentUser.objectId];
            
            PFQuery *groupsQuery = [PFQuery queryWithClassName:@"Group"];
            [groupsQuery whereKey:@"objectId" matchesKey:@"group_id" inQuery:groupsUserQuery];
            [groupsQuery includeKey:@"user_objects"];
            
            __block BOOL reload = NO;
            
            [groupsQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                
                if (!error) {
                    
                    NSMutableDictionary *groupsDict = [sections objectForKey:@"GROUPS"];
                    NSMutableArray *groupNamesArray = [groupsDict objectForKey:@"GroupNames"];
                    NSMutableArray *memberNamesArray = [groupsDict objectForKey:@"MemberNames"];
                    NSMutableArray *idsArray = [groupsDict objectForKey:@"IDs"];
                    NSMutableArray *tappeddArray = [groupsDict objectForKey:@"Tapped"];
                    
                    for (PFObject *group in array) {
                        
                        [groupNamesArray addObject: group[@"name"]];
                        NSArray *users = group[@"user_objects"];
                        
                        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                        
                        for (PFUser *user in users) {
                            if (![user.objectId isEqualToString: currentUser.objectId]) {
                                [tempArray addObject:[NSString stringWithFormat:@"%@", user[@"firstName"]]];
                            }
                        }
                        
                        NSString *memberString = [NSString stringWithFormat:@"With %@", tempArray[0]];
                        
                        for (int i = 1; i < tempArray.count - 1; i++) {
                            memberString = [memberString stringByAppendingString:[NSString stringWithFormat:@", %@", tempArray[i]]];
                        }
                        
                        PFUser *user = users[users.count-1];
                        if (tempArray.count > 1)
                            memberString = [memberString stringByAppendingString:[NSString stringWithFormat:@" and %@", user[@"firstName"]]];
                        
                        [memberNamesArray addObject:memberString];
                        
                        NSNumber *no = [NSNumber numberWithInt:0];
                        [tappeddArray addObject:no];
                        
                        [idsArray addObject:group.objectId];
                    
                    }
                    NSLog(@"reload groups");
                    NSLog(@"sections: %@", sections);
                    
                    if (reload) {
                        [self.tableView reloadData];
                    } else {
                        reload = YES;
                    }
                }
                
            }];
            
            
             PFQuery *friendQuery = [PFQuery queryWithClassName:@"Swipes"];
             [friendQuery whereKey:@"FBObjectID" containedIn:friendObjectIDs];
             [friendQuery whereKey:@"EventID" equalTo:self.objectID];
             [friendQuery whereKey:@"swipedRight" equalTo:@YES];
             
             PFQuery *userQuery = [PFUser query];
             [userQuery whereKey:@"objectId" matchesKey:@"UserID" inQuery:friendQuery];
             
             [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                NSLog(@"%lu friends interested", (unsigned long)objects.count);
                
                if (!error) {
                    
                    NSMutableDictionary *interestedDict = [sections objectForKey:@"INTERESTED"];
                    NSMutableArray *namesArray = [interestedDict objectForKey:@"Names"];
                    NSMutableArray *idsArray = [interestedDict objectForKey:@"IDs"];
                    NSMutableArray *tappeddArray = [interestedDict objectForKey:@"Tapped"];
                    
                    for (PFObject *object in objects) {
    
                        [namesArray addObject:[NSString stringWithFormat:@"%@ %@", object[@"firstName"], object[@"lastName"]]];

                        NSString *fbObjID = object[@"FBObjectID"];
                        
                        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
                        profPicView.layer.cornerRadius = 15;
                        profPicView.layer.masksToBounds = YES;
                        profPicView.profileID = fbObjID;
                        profPicView.tag = 9;
                        
                        [idsArray addObject:profPicView];
                        
                        NSNumber *no = [NSNumber numberWithInt:0];
                        [tappeddArray addObject:no];
                        
                        friendCount++;
                        
                        if (friendCount == 1) {
                            //card.friendsInterested.text = [NSString stringWithFormat:@"%d friend interested", friendCount];
                        } else {
                            //card.friendsInterested.text = [NSString stringWithFormat:@"%d friends interested", friendCount];
                        }
                        
                    }
                    
                    if (objects.count == 0) {
                        NSLog(@"No new friends");
                        
                        //[self noFriendsAddButton:friendScrollView];
                        
                    }
                    NSLog(@"reload interested");
                    if (reload) {
                        [self.tableView reloadData];
                    } else {
                        reload = YES;
                    }
                }
                
            }];
            
        }];
        
    } else {
        
        NSLog(@"no token......");
    }

    
    indexTitles = [[NSArray alloc] init];
    indexTitles = @[@"\u263A", @"√", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    NSLog(@"%@", indexTitles);
    NSLog(@"%lu", (unsigned long)indexTitles.count);
    
}

- (IBAction)xButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        //<#code#>
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        
    NSString *letterRepresentingTheseFriends = [sortedFriendsLetters objectAtIndex:section];
    NSDictionary *friendsForThisLetter = [sections objectForKey:letterRepresentingTheseFriends];
    NSArray *namesArray = [NSArray array];
    if (section == 0) {
        namesArray = [friendsForThisLetter objectForKey:@"GroupNames"];
        return namesArray.count + 1;
    } else
        namesArray = [friendsForThisLetter objectForKey:@"Names"];
        
    return namesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NSDictionary *friendsForThisLetter = [sections objectForKey:@"GROUPS"];
        NSArray *namesArray = [friendsForThisLetter objectForKey:@"GroupNames"];
        if (indexPath.row == (namesArray.count)) {
            return 44;
        } else {
            return 70;
        }
    }
    
    
    return 44;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:12.0]];
    label.textColor = [UIColor colorWithRed:0.0/255 green:176.0/255 blue:242.0/255 alpha:1.0];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor whiteColor]]; //your background color...
    NSString *string = [sortedFriendsLetters objectAtIndex:section];
    [label setText:string];
    
    return view;
}


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
     [self.tableView bringSubviewToFront:namesOnBottomView];
     
     if (indexPath.section == 0) {
         
         NSString *letterRepresentingTheseFriends = [sortedFriendsLetters objectAtIndex:indexPath.section];
         NSDictionary *friendsForThisLetter = [sections objectForKey:letterRepresentingTheseFriends];
         NSArray *groupNamesArray = [friendsForThisLetter objectForKey:@"GroupNames"];
         NSArray *memberNamesArray = [friendsForThisLetter objectForKey:@"MemberNames"];
         NSArray *idsArray = [friendsForThisLetter objectForKey:@"IDs"];
         NSMutableArray *tappedArray = [friendsForThisLetter objectForKey:@"Tapped"];
             
         if (indexPath.row < (groupNamesArray.count)) {
             
                 GroupsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groups" forIndexPath:indexPath];
                 UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
                 [cell addGestureRecognizer:tap];
             
             if ([tappedArray[indexPath.row] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                 
                 //cell.checkButton.image = [UIImage imageNamed:@"check"];
                 //cell.nameLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17];
                 
             } else {
                 
                 //cell.checkButton.image = [UIImage imageNamed:@"check-empty"];
                 //cell.nameLabel.font = [UIFont fontWithName:@"OpenSans" size:17];

             }
             
             cell.nameLabel.text = groupNamesArray[indexPath.row];
             cell.membersLabel.text = memberNamesArray[indexPath.row];
             
             return cell;
             
         } else {
             
             UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"create" forIndexPath:indexPath];
             UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
             [cell addGestureRecognizer:tap];
             return cell;
             
             
         }

         
     } else {
         
         inviteHomiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homies" forIndexPath:indexPath];
     
         UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
         
         [cell addGestureRecognizer:tap];
         
         NSString *letterRepresentingTheseFriends = [sortedFriendsLetters objectAtIndex:indexPath.section];
         NSDictionary *friendsForThisLetter = [sections objectForKey:letterRepresentingTheseFriends];
         NSArray *namesArray = [friendsForThisLetter objectForKey:@"Names"];
         NSArray *idsArray = [friendsForThisLetter objectForKey:@"IDs"];
         NSMutableArray *tappedArray = [friendsForThisLetter objectForKey:@"Tapped"];
         
         
         if ([tappedArray[indexPath.row] isEqualToNumber:[NSNumber numberWithInt:1]]) {
             
             cell.checkButton.image = [UIImage imageNamed:@"check"];
             cell.nameLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17];
             
         } else {
             
             cell.checkButton.image = [UIImage imageNamed:@"check-empty"];
             cell.nameLabel.font = [UIFont fontWithName:@"OpenSans" size:17];
             
         }
         
         cell.nameLabel.text = namesArray[indexPath.row];
         
         for (UIView *view in cell.subviews) {
             if (view.tag == 9) {
                 [view removeFromSuperview];
             }
         }
         
         [cell addSubview:idsArray[indexPath.row]];
         
         return cell;
     }
     
     return nil;

 }


- (void) handleChecking:(UITapGestureRecognizer *)tapRecognizer {
    
    CGPoint tapLocation = [tapRecognizer locationInView:self.tableView];
    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    NSLog(@"Tap");
    if (tappedIndexPath.section == 0) {
    
        NSString *letterRepresentingTheseFriends = [sortedFriendsLetters objectAtIndex:tappedIndexPath.section];
        NSDictionary *friendsForThisLetter = [sections objectForKey:letterRepresentingTheseFriends];
        NSMutableArray *tappedArray = [friendsForThisLetter objectForKey:@"Tapped"];
        NSMutableArray *groupNamesArray = [friendsForThisLetter objectForKey:@"GroupNames"];
        NSMutableArray *memberNamesArray = [friendsForThisLetter objectForKey:@"MemberNames"];
        NSArray *idsArray = [friendsForThisLetter objectForKey:@"IDs"];
        
        if (tappedIndexPath.row == groupNamesArray.count) { // Create Group
            
            NSLog(@"Create Group");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"To create a new group..." message:@"Select the friends you want to invite and hit \"send.\" You will be asked if you would like to create a new group with those people- hit \"Yes!\"" delegate:self cancelButtonTitle:@"Boom" otherButtonTitles:nil, nil];
            [alert show];
            
        } else {
            
            NSString *theName = groupNamesArray[tappedIndexPath.row];
        
            if ([selectedRowsArray containsObject:theName]) {
                    
                [selectedRowsArray removeObject:theName];
                [selectedIDs removeObject:idsArray[tappedIndexPath.row]];
            
            } else {
                    
                [selectedRowsArray addObject:theName];
                [selectedIDs addObject:idsArray[tappedIndexPath.row]];
            }
                
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:40];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:40];
            NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:0 inSection:40];
                
            if ([tappedArray[tappedIndexPath.row] isEqualToNumber:[NSNumber numberWithInt:1]]) {
            
                
                for (int i = 0; i < groupNamesArray.count; i++) {
                    if ([groupNamesArray[i] isEqualToString:theName]) {
                        tappedArray[i] = [NSNumber numberWithInt:0];
                        indexPath1 = [NSIndexPath indexPathForRow:i inSection:0];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath1] withRowAnimation: UITableViewRowAnimationLeft];
                        break;
                    }
                }

                
            } else {
                
                for (int i = 0; i < groupNamesArray.count; i++) {
                    if ([groupNamesArray[i] isEqualToString:theName]) {
                        tappedArray[i] = [NSNumber numberWithInt:1];
                        indexPath1 = [NSIndexPath indexPathForRow:i inSection:0];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath1] withRowAnimation: UITableViewRowAnimationLeft];
                        break;
                    }
                }
            }
        }
        
    } else {
        
            NSString *letterRepresentingTheseFriends = [sortedFriendsLetters objectAtIndex:tappedIndexPath.section];
            NSDictionary *friendsForThisLetter = [sections objectForKey:letterRepresentingTheseFriends];
            NSMutableArray *tappedArray = [friendsForThisLetter objectForKey:@"Tapped"];
            NSMutableArray *namesArray = [friendsForThisLetter objectForKey:@"Names"];
            NSArray *idsArray = [friendsForThisLetter objectForKey:@"IDs"];
            
            NSString *theName = namesArray[tappedIndexPath.row];
            
            if ([selectedRowsArray containsObject:theName]) {
                
                [selectedRowsArray removeObject:theName];
                [selectedIDs removeObject:idsArray[tappedIndexPath.row]];
                
            } else {
                
                [selectedRowsArray addObject:theName];
                [selectedIDs addObject:idsArray[tappedIndexPath.row]];
            }
            
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:40];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:40];
            NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:0 inSection:40];
            
            
            if ([tappedArray[tappedIndexPath.row] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                
                NSDictionary *friendsForThisLetter2 = [sections objectForKey:@"INTERESTED"];
                NSArray *namesArray2 = [friendsForThisLetter2 objectForKey:@"Names"];
                NSMutableArray *tappedArray2 = [friendsForThisLetter2 objectForKey:@"Tapped"];
                
                for (int i = 0; i < namesArray2.count; i++) {
                    if ([namesArray2[i] isEqualToString:theName]) {
                        tappedArray2[i] = [NSNumber numberWithInt:0];
                        indexPath2 = [NSIndexPath indexPathForRow:i inSection:1];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath2] withRowAnimation: UITableViewRowAnimationLeft];
                        break;
                    }
                }
                
                NSDictionary *friendsForThisLetter3 = [sections objectForKey:[theName substringToIndex:1]];
                NSArray *namesArray3 = [friendsForThisLetter3 objectForKey:@"Names"];
                NSMutableArray *tappedArray3 = [friendsForThisLetter3 objectForKey:@"Tapped"];
                
                for (int i = 0; i < namesArray3.count; i++) {
                    if ([namesArray3[i] isEqualToString:theName]) {
                        tappedArray3[i] = [NSNumber numberWithInt:0];
                        NSUInteger letterIndex = [sortedFriendsLetters indexOfObject:[theName substringToIndex:1]];
                        indexPath3 = [NSIndexPath indexPathForRow:i inSection:letterIndex];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath3] withRowAnimation: UITableViewRowAnimationLeft];
                        break;
                    }
                }
                
            } else {

                NSDictionary *friendsForThisLetter2 = [sections objectForKey:@"INTERESTED"];
                NSArray *namesArray2 = [friendsForThisLetter2 objectForKey:@"Names"];
                NSMutableArray *tappedArray2 = [friendsForThisLetter2 objectForKey:@"Tapped"];
                
                for (int i = 0; i < namesArray2.count; i++) {
                    if ([namesArray2[i] isEqualToString:theName]) {
                        tappedArray2[i] = [NSNumber numberWithInt:1];
                        indexPath2 = [NSIndexPath indexPathForRow:i inSection:1];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath2] withRowAnimation: UITableViewRowAnimationLeft];
                        break;
                    }
                }
                
                NSDictionary *friendsForThisLetter3 = [sections objectForKey:[theName substringToIndex:1]];
                NSArray *namesArray3 = [friendsForThisLetter3 objectForKey:@"Names"];
                NSMutableArray *tappedArray3 = [friendsForThisLetter3 objectForKey:@"Tapped"];
                
                for (int i = 0; i < namesArray3.count; i++) {
                    if ([namesArray3[i] isEqualToString:theName]) {
                        tappedArray3[i] = [NSNumber numberWithInt:1];
                        NSUInteger letterIndex = [sortedFriendsLetters indexOfObject:[theName substringToIndex:1]];
                        indexPath3 = [NSIndexPath indexPathForRow:i inSection:letterIndex];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath3] withRowAnimation: UITableViewRowAnimationLeft];
                        break;
                    }
                }
            }
        }
        
    
    
    [self updateNamesOnBottom];
    
}

-(void)updateNamesOnBottom {
    
    
    if (selectedRowsArray.count == 1) {
        
        friendsLabel.text = [NSString stringWithFormat:@"%@", selectedRowsArray[0]];
        [friendsLabel sizeToFit];
        
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            float newPos = friendsLabel.frame.size.width - friendScrollView.frame.size.width + 15;
            if (newPos > 0) {
                friendScrollView.contentOffset = CGPointMake(newPos, 0);
            } else {
                friendScrollView.contentOffset = CGPointMake(0, 0);
                
            }
            
        } completion:nil];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            if (namesOnBottomView.frame.origin.y != 568-64-50 + self.tableView.contentOffset.y) {
                if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height)) {
                    //user has scrolled to the bottom
                    [self.tableView setContentOffset:CGPointMake(0, 99999)];
                }
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
                namesOnBottomView.frame = CGRectMake(0, 568-64-50 + self.tableView.contentOffset.y, 320, namesOnBottomView.frame.size.height);
            }
            
            friendScrollView.contentSize = CGSizeMake(friendsLabel.frame.size.width + 15, friendsLabel.frame.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
        
    } else if (selectedRowsArray.count == 0) {
        
        friendsLabel.text = @"";
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            namesOnBottomView.frame = CGRectMake(0, namesOnBottomView.frame.origin.y + namesOnBottomView.frame.size.height, 320, namesOnBottomView.frame.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
    
    } else {
        
        friendsLabel.text = [NSString stringWithFormat:@"%@", selectedRowsArray[0]];
        
        for (int i = 1; i < selectedRowsArray.count; i++) {
        
            friendsLabel.text = [NSString stringWithFormat:@"%@, %@", friendsLabel.text, selectedRowsArray[i]];
        }
        
        [friendsLabel sizeToFit];
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            float newPos = friendsLabel.frame.size.width - friendScrollView.frame.size.width + 15;
            if (newPos > 0) {
                friendScrollView.contentOffset = CGPointMake(newPos, 0);
            } else {
                friendScrollView.contentOffset = CGPointMake(0, 0);
            }
            
            friendScrollView.contentSize = CGSizeMake(friendsLabel.frame.size.width + 15, friendsLabel.frame.size.height);

            
        } completion:nil];
        
        
        
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
     namesOnBottomView.transform = CGAffineTransformMakeTranslation(0, scrollView.contentOffset.y);
    
}

- (void)inviteButtonTapped {
    
    BOOL createGroupAlert = NO;
    
    finalUserIDArray = [[NSMutableArray alloc] init];
    NSMutableArray *finalNamesArray = [[NSMutableArray alloc] init];
    NSMutableArray *finalGroupIDArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < selectedRowsArray.count; i++) {
        
        if ([[selectedIDs[i] class] isSubclassOfClass:[FBSDKProfilePictureView class]]) {
            FBSDKProfilePictureView *profPicView = selectedIDs[i];
            NSLog(@"Invite: %@, %@  ---- ", selectedRowsArray[i], profPicView.profileID);
            [finalUserIDArray addObject:profPicView.profileID];
            [finalNamesArray addObject:selectedRowsArray[i]];
        } else {
            [finalGroupIDArray addObject:selectedIDs[i]];
        }
    }

    if (finalNamesArray.count > 1) {
        
        createGroupAlert = YES;
        
        NSString *nameString = [NSString stringWithFormat:@"%@", finalNamesArray[0]];
        for (int i = 1; i < finalNamesArray.count - 1; i++) {
            nameString = [nameString stringByAppendingString:[NSString stringWithFormat:@", %@", finalNamesArray[i]]];
        }
        
        if (finalNamesArray.count > 1)
            nameString = [nameString stringByAppendingString:[NSString stringWithFormat:@" and %@", finalNamesArray[finalNamesArray.count - 1]]];
        
        NSString *groupString = [NSString stringWithFormat:@"Would you like to create a group with %@?",  nameString];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create a group?" message:groupString delegate:self cancelButtonTitle:@"Create new group" otherButtonTitles:@"Send individual invites", nil];
        alert.delegate = self;
        alert.tag = 3;
        [alert show];
    }
    
    PFUser *currentUser = [PFUser currentUser];

    // %%%%%%%%%%%%%%%%%% USER PUSH %%%%%%%%%%%%%%%%%%%%%%
    
    if (!createGroupAlert) {
    
        [self sendIndividualInvites];
    }
    
    
    // %%%%%%%%%%%%%%%%%% GROUP PUSH %%%%%%%%%%%%%%%%%%%%%%
    
    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
    [groupQuery whereKey:@"objectId" containedIn:finalGroupIDArray];
    [groupQuery includeKey:@"user_objects"];
    [groupQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for (PFObject *group in objects) {
           
            NSArray *users = group[@"user_objects"];
            
            int count = (int)(users.count - 1.0);
            NSString *pushMessage = @"";
            pushMessage = [NSString stringWithFormat:@"%@ %@ wants to go to %@ with you!", currentUser[@"firstName"], currentUser[@"lastName"], eventTitle];
            
            PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
            notification[@"Type"] = @"group";
            notification[@"Subtype"] = @"new_group";
            notification[@"EventID"] = self.objectID;
            notification[@"UserID"] = currentUser.objectId;  // THIS IS THE DIFFERENCE
            notification[@"GroupID"] = group.objectId;
            notification[@"InviterID"] = currentUser.objectId;
            notification[@"Seen"] = @NO;
            notification[@"Message"] = pushMessage;
            //notification[@"AllUserObjects"] = users;
            [notification saveInBackground];
            
            for (PFUser *user in users) {
                if (![user.objectId isEqualToString:currentUser.objectId]) {
            
                    /*
                     NSString *gender = user[@"gender"];
                     NSString *genderString = @"";
                     
                     if ([gender isEqualToString:@"male"]) {
                     genderString = @"with him";
                     } else if ([gender isEqualToString:@"female"]) {
                     genderString = @"with her";
                     } else {
                     genderString = @"together";
                     } */
                    
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"userID" equalTo:user.objectId];
                    
                    // Send push notification to query
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    
                    NSDictionary *data = @{
                                           @"alert" : pushMessage,
                                           @"badge" : @"Increment",
                                           @"eventID" : self.objectID,
                                           @"senderID" : currentUser.objectId,
                                           @"type" : @"Invite"
                                           };
                    
                    [push setData:data];
                    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * __nullable error) {
                        
                        if (succeeded) {
                            //[notifyButton setTitle:@"Boom." forState:UIControlStateNormal];
                            //subLabel.text = [NSString stringWithFormat:@"We just notified %@!", user[@"firstName"]];
                        } else {
                            //[notifyButton setTitle:@"Uh-oh." forState:UIControlStateNormal];
                            //subLabel.text = [NSString stringWithFormat:@"We were unable to notify %@!", user[@"firstName"]];
                        }
                        
                    }];
                    
                    NSLog(@"SENT PUSH: %@", pushMessage);
                    
                    
                    ///////////////////// SAVE NOTIFICATIONS DATA /////////////////////////
                    
                    PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
                    notification[@"Type"] = @"group";
                    notification[@"Subtype"] = @"invite_group";
                    notification[@"EventID"] = self.objectID;
                    notification[@"UserID"] = user.objectId;
                    notification[@"GroupID"] = group.objectId;
                    notification[@"InviterID"] = currentUser.objectId;
                    notification[@"Seen"] = @NO;
                    notification[@"Message"] = pushMessage;
                    notification[@"AllUserObjects"] = users;
                    
                    [notification saveInBackground];
                    
                }
                
                if (!createGroupAlert) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        //
                    }];
                }
            }
        }
     
    }];
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 3) {
        
        if (buttonIndex == 0) {
        
            NSLog(@"Group invites from button");
            [self performSegueWithIdentifier:@"toNewGroup" sender:self];
            
        } else {
            
            NSLog(@"Individual invites from button");
            [self sendIndividualInvites];
        
        }
    }


}

- (void)sendIndividualInvites {
    
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"FBObjectID" containedIn:finalUserIDArray];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
        
        if (!error) {
            
            for (PFObject *user in users) {
                
                PFObject *group = [PFObject objectWithClassName:@"Group"];
                PFObject *cu = (PFObject *)currentUser;
                NSMutableArray *usersForGroup = [[NSMutableArray alloc] initWithObjects:user, cu, nil];
                group[@"user_objects"] = usersForGroup;
                group[@"name"] = @"_indy_"; //[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
                group[@"memberCount"] = @2;
                
                [group saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                
                    PFObject *groupUser1 = [PFObject objectWithClassName:@"Group_User"];
                    groupUser1[@"user_id"] = currentUser.objectId;
                    groupUser1[@"group_id"] = group.objectId;
                    [groupUser1 saveInBackground];
                    
                    PFObject *groupUser2 = [PFObject objectWithClassName:@"Group_User"];
                    groupUser2[@"user_id"] = user.objectId;
                    groupUser2[@"group_id"] = group.objectId;
                    [groupUser2 saveInBackground];
                    
                    /*
                     NSString *gender = user[@"gender"];
                     NSString *genderString = @"";
                     
                     if ([gender isEqualToString:@"male"]) {
                     genderString = @"with him";
                     } else if ([gender isEqualToString:@"female"]) {
                     genderString = @"with her";
                     } else {
                     genderString = @"together";
                     } */
                    
                    
                    PFQuery *pushQuery = [PFInstallation query];
                    [pushQuery whereKey:@"userID" equalTo:user.objectId];
                    
                    // Send push notification to query
                    PFPush *push = [[PFPush alloc] init];
                    [push setQuery:pushQuery]; // Set our Installation query
                    
                    int count = (int)(users.count - 1.0);
                    NSString *pushMessage = @"";
                    //if (count == 0) {
                    pushMessage = [NSString stringWithFormat:@"%@ %@ wants to go to %@ with you!", currentUser[@"firstName"], currentUser[@"lastName"], eventTitle];
                    /* } else if (count == 1) {
                     pushMessage = [NSString stringWithFormat:@"%@ %@ wants to go to %@ with you and one other person!", currentUser[@"firstName"], currentUser[@"lastName"], eventTitle];
                     } else {
                     pushMessage = [NSString stringWithFormat:@"%@ %@ wants to go to %@ with you and %d others!", currentUser[@"firstName"], currentUser[@"lastName"], eventTitle, count];
                     } */
                    
                    NSDictionary *data = @{
                                           @"alert" : pushMessage,
                                           @"badge" : @"Increment",
                                           @"eventID" : self.objectID,
                                           @"senderID" : currentUser.objectId,
                                           @"type" : @"Invite"
                                           };
                    
                    [push setData:data];
                    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * __nullable error) {
                        
                        if (succeeded) {
                            //[notifyButton setTitle:@"Boom." forState:UIControlStateNormal];
                            //subLabel.text = [NSString stringWithFormat:@"We just notified %@!", user[@"firstName"]];
                            NSLog(@"x");
                        } else {
                            //[notifyButton setTitle:@"Uh-oh." forState:UIControlStateNormal];
                            //subLabel.text = [NSString stringWithFormat:@"We were unable to notify %@!", user[@"firstName"]];
                        }
                        
                    }];
                    
                    NSLog(@"SENT PUSH: %@", pushMessage);
                    
                    
                    // %%%%%%%%%%%%%%%%%% SAVE NOTIFICATIONS DATA %%%%%%%%%%%%%%%%%%
                    
                    PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
                    notification[@"Type"] = @"group";
                    notification[@"Subtype"] = @"new_individual";
                    notification[@"EventID"] = self.objectID;
                    notification[@"UserID"] = user.objectId;
                    notification[@"GroupID"] = group.objectId;
                    notification[@"InviterID"] = currentUser.objectId;
                    notification[@"Seen"] = @NO;
                    notification[@"Message"] = pushMessage;
                    //notification[@"AllUserObjects"] = users;
                    
                    [notification saveInBackground];
                
                }];
            }
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            //
        }];
        
    }];
    

}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return indexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //NSLog(@"title: %@", title);
    
    if (index == 0)
        return 0;
    else if (index == 1 || index == 2)
        return index-1;
        
    return [sortedFriendsLetters indexOfObject:title] - 1;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toNewGroup"]) {
        
        NewGroupCreatorVC *vc = (NewGroupCreatorVC *)[segue destinationViewController];
        vc.eventId = self.objectID;
        if (finalUserIDArray.count > 3) {
            vc.userIdArray = finalUserIDArray;
            vc.memCount = (int)finalUserIDArray.count + 1;
        } else {
            PFUser *currentUser = [PFUser currentUser];
            vc.userIdArray = [finalUserIDArray arrayByAddingObject:currentUser[@"FBObjectID"]];
            vc.memCount = (int)vc.userIdArray.count;
        }
    }
    
}

@end

