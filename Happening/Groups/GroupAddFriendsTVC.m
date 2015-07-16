//
//  GroupAddFriendsTVC.m
//  Happening
//
//  Created by Max on 6/24/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupAddFriendsTVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import "inviteHomiesCell.h"
#import "NewGroupCreatorVC.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "CustomConstants.h"

@interface GroupAddFriendsTVC () <UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation GroupAddFriendsTVC {
    
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

@synthesize namesOnBottomView, convo, group;

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
           
            
            [self.tableView reloadData];
        }];
         
    } else {
        
        NSLog(@"no token......");
    }
    
    indexTitles = [[NSArray alloc] init];
    indexTitles = @[ /*@"\u263A",*/ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
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
    
    return 40;
    
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


- (void) handleChecking:(UITapGestureRecognizer *)tapRecognizer {
    
    CGPoint tapLocation = [tapRecognizer locationInView:self.tableView];
    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
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
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    NSDictionary *friendsForThisLetter3 = [sections objectForKey:[theName substringToIndex:1]];
    NSArray *namesArray3 = [friendsForThisLetter3 objectForKey:@"Names"];
    NSMutableArray *tappedArray3 = [friendsForThisLetter3 objectForKey:@"Tapped"];
        
    for (int i = 0; i < namesArray3.count; i++) {
        if ([namesArray3[i] isEqualToString:theName]) {
            tappedArray3[i] = [NSNumber numberWithInt:0];
            NSUInteger letterIndex = [sortedFriendsLetters indexOfObject:[theName substringToIndex:1]];
            indexPath = [NSIndexPath indexPathForRow:i inSection:letterIndex];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationNone];
            break;
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
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD show];
    
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
    
    
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"FBObjectID" containedIn:finalUserIDArray];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error){
       
        if (!error) {
            NSMutableArray *idArray = [[NSMutableArray alloc] init];
            for (PFUser *user in array) {
                [idArray addObject:user.objectId];
                
                PFObject *groupUser = [PFObject objectWithClassName:@"Group_User"];
                groupUser[@"user_id"] = user.objectId;
                groupUser[@"group_id"] = group.objectId;
                [groupUser saveInBackground];
            }
            
            [group incrementKey:@"memberCount" byAmount:@(finalUserIDArray.count)];
            
            NSArray *users = group[@"user_objects"];
            users = [users arrayByAddingObjectsFromArray:array];
            group[@"user_objects"] = users;
            
            [group saveEventually];
            
            NSError *convoError = nil;
            [convo addParticipants:[NSSet setWithArray:[NSArray arrayWithArray:idArray]] error:&convoError];
            if (!convoError) {
                
                //Send message w data
                PFUser *currentUser = [PFUser currentUser];
                NSString *messageText = [NSString stringWithFormat:@"%@ %@ added %@", currentUser[@"firstName"], currentUser[@"lastName"], finalNamesArray[0]];
                for (int i = 1; i < finalNamesArray.count - 1; i++) {
                    messageText = [messageText stringByAppendingString:[NSString stringWithFormat:@", %@", finalNamesArray[i]]];
                }
                
                if (finalNamesArray.count > 1) {
                    messageText = [messageText stringByAppendingString:[NSString stringWithFormat:@" and %@", [finalNamesArray lastObject]]];
                }
                
                messageText = [messageText stringByAppendingString:@" to the group."];
                
                NSDictionary *dataDictionary = @{@"message":messageText,
                                                 @"type":@"add",
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
                
                // Creates and returns a new message object with the given conversation and array of message parts
                //LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[messagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:nil];
                
                // Sends the specified message
                BOOL success = [convo sendMessage:message error:&error];
                if (success) {
                    NSLog(@"Message queued to be sent: %@", message);
                    [SVProgressHUD showSuccessWithStatus:@"Friends added!"];
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }];

                } else {
                    NSLog(@"Message send failed: %@", error);
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }];
                }

                
                
            } else {
                [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
            }
        } else {
            [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
        }
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
    
    
}
@end
