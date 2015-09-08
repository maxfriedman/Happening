//
//  InviteFromCreateView.m
//  Happening
//
//  Created by Max on 8/25/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "InviteFromCreateView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "inviteHomiesCell.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "CustomConstants.h"
#import "UIButton+Extensions.h"
#import "GroupsCell.h"

#define MCANIMATE_SHORTHAND
#import <POP+MCAnimate.h>

@interface InviteFromCreateView () <UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation InviteFromCreateView {
    
    NSMutableArray *friendsArray;
    NSArray *sortedFriends;
    NSMutableArray *uniqueFriendsByLetter;
    NSMutableDictionary *sections;
    NSArray *sortedFriendsLetters;

    NSMutableArray *selectedNamesArray;
    
    NSMutableArray *selectedIDs;
    
    UILabel *friendsLabel;
    UIScrollView *friendScrollView;
    UIButton *sendInvitesButton;
    
    NSArray *indexTitles;
    
    NSMutableArray *finalUserIDArray;
    NSMutableArray *finalGroupIDArray;
    
    NSMutableDictionary *selectedDict;
    NSArray *bestFriendsIds;
    
    NSMutableArray *fbIds;
    
    BOOL wasDefaultName;
    
}

@synthesize namesOnBottomView, convo, selectedImagesArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToTop)]];
    
    friendsArray = [[NSMutableArray alloc] init];
    selectedNamesArray = [[NSMutableArray alloc] init];
    selectedImagesArray = [[NSMutableArray alloc] init];
    selectedIDs = [[NSMutableArray alloc] init];
    finalUserIDArray = [[NSMutableArray alloc] init];
    finalGroupIDArray = [[NSMutableArray alloc] init];
    
    namesOnBottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 568 - 64, 320, 50)];
    //namesOnBottomView.backgroundColor = [UIColor colorWithRed:0.0/255 green:176.0/255 blue:242.0/255 alpha:1.0];
    namesOnBottomView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [namesOnBottomView addSubview:lineView];
    
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
    [sendInvitesButton setImage:[UIImage imageNamed:@"Right_arrow"] forState:UIControlStateNormal];
    [sendInvitesButton addTarget:self action:@selector(inviteButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [sendInvitesButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    [namesOnBottomView addSubview:sendInvitesButton];
    
    selectedDict = [[NSMutableDictionary alloc] init];
    
    [self loadFriends];
}

- (void)scrollToTop {
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

- (void)loadFriends {
    
    sections = [[NSMutableDictionary alloc] init];
    
    indexTitles = [[NSArray alloc] init];
    indexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    if ([[PFUser currentUser] objectForKey:@"BestFriends"] != nil)
        bestFriendsIds = [[PFUser currentUser] objectForKey:@"BestFriends"];
    else
        bestFriendsIds = [NSArray new];
    
    NSArray *friends = [PFUser currentUser][@"friends"];
    
    NSMutableArray *names = [[NSMutableArray alloc] init];
    NSMutableArray *friendObjectIDs = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in friends) {
        [friendObjectIDs addObject:[dict objectForKey:@"id"]];
        [names addObject:[dict objectForKey:@"name"]];
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
        [idsArray addObject:friendObjectIDs[i]];
        
        
        NSMutableArray *imagesArray = [letterDict objectForKey:@"Images"];
        if (imagesArray == nil) {
            imagesArray = [NSMutableArray array];
        }
        [letterDict setObject:imagesArray forKey:@"Images"];
        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10, 7.5, 40, 40)];
        profPicView.layer.cornerRadius = 20;
        profPicView.layer.masksToBounds = YES;
        profPicView.profileID = friendObjectIDs[i];
        profPicView.tag = 9;
        [imagesArray addObject:profPicView];
        
        
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
    
    NSArray *addArray = [NSArray arrayWithObjects:@"GROUPS", nil];
    sortedFriendsLetters = [addArray arrayByAddingObjectsFromArray:sortedFriendsLetters];
    
    /*
    fbIds = [NSMutableArray array];
    for (NSDictionary *dict in group[@"user_dicts"]) {
        [fbIds addObject:[dict valueForKey:@"id"]];
    }*/
    
    NSMutableArray *blankGroupNamesArray1 = [NSMutableArray array];
    NSMutableArray *blankMemberNamesArray1 = [NSMutableArray array];
    NSMutableArray *blankGroupImagesArray1 = [NSMutableArray array];
    NSMutableArray *blankIDsArray1 = [NSMutableArray array];
    NSMutableArray *blankTappedArray1 = [NSMutableArray array];
    
    NSMutableDictionary *blankDict1 = [NSMutableDictionary dictionary];
    
    [sections setObject:blankDict1 forKey:@"GROUPS"];
    
    [blankDict1 setObject:blankGroupNamesArray1 forKey:@"GroupNames"];
    [blankDict1 setObject:blankMemberNamesArray1 forKey:@"MemberNames"];
    [blankDict1 setObject:blankGroupImagesArray1 forKey:@"GroupImages"];
    [blankDict1 setObject:blankIDsArray1 forKey:@"IDs"];
    [blankDict1 setObject:blankTappedArray1 forKey:@"Tapped"];
    
    [self.tableView reloadData];
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *groupsUserQuery = [PFQuery queryWithClassName:@"Group_User"];
    [groupsUserQuery whereKey:@"user_id" equalTo:currentUser.objectId];
    
    PFQuery *groupsQuery = [PFQuery queryWithClassName:@"Group"];
    [groupsQuery fromLocalDatastore];
    //[groupsQuery whereKey:@"objectId" matchesKey:@"group_id" inQuery:groupsUserQuery];
    [groupsQuery whereKey:@"memberCount" greaterThan:@2];
    
    [groupsQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error) {
            
            NSMutableDictionary *groupsDict = [sections objectForKey:@"GROUPS"];
            NSMutableArray *groupNamesArray = [groupsDict objectForKey:@"GroupNames"];
            NSMutableArray *groupImagesArray = [groupsDict objectForKey:@"GroupImages"];
            NSMutableArray *memberNamesArray = [groupsDict objectForKey:@"MemberNames"];
            NSMutableArray *idsArray = [groupsDict objectForKey:@"IDs"];
            NSMutableArray *tappedArray = [groupsDict objectForKey:@"Tapped"];
            
            for (PFObject *group in array) {
                
                NSArray *users = group[@"user_dicts"];
                
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                for (NSDictionary *dict in users) {
                    if (![[dict objectForKey:@"parseId"] isEqualToString:currentUser.objectId]) {
                        NSString *name = [dict valueForKey:@"name"];
                        [tempArray addObject:[NSString stringWithFormat:@"%@", [[name componentsSeparatedByString:@" "] objectAtIndex:0]]];
                    }
                }
                
                [groupNamesArray addObject: group[@"name"]];
                
                NSString *memberString = [NSString stringWithFormat:@"With %@", tempArray[0]];
                
                for (int i = 1; i < tempArray.count - 1; i++) {
                    memberString = [memberString stringByAppendingString:[NSString stringWithFormat:@", %@", tempArray[i]]];
                }
                
                if (tempArray.count > 1) {
                    NSString *name = [tempArray lastObject];
                    memberString = [memberString stringByAppendingString:[NSString stringWithFormat:@" and %@", name]];
                }
                
                [memberNamesArray addObject:memberString];
                
                NSNumber *no = [NSNumber numberWithInt:0];
                [tappedArray addObject:no];
                
                [idsArray addObject:group.objectId];
                
                if (group[@"avatar"] != nil) {
                    [groupImagesArray addObject:group[@"avatar"]];
                }
                
            }
            
            NSLog(@"reload data");
            [SVProgressHUD dismiss];
            //NSLog(@"%@", sections);
            
            [self.tableView reloadData];
            
        } else {
            NSLog(@"error: %@", error);
        }
    }];

    
    [self.tableView reloadData];
    
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
    } else
        namesArray = [friendsForThisLetter objectForKey:@"Names"];
    
    return namesArray.count;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 70;
    }
    
    return 55;
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
        NSMutableArray *groupImagesArray = [friendsForThisLetter objectForKey:@"GroupImages"];
        NSArray *idsArray = [friendsForThisLetter objectForKey:@"IDs"];
        NSMutableArray *tappedArray = [friendsForThisLetter objectForKey:@"Tapped"];
        
        GroupsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groups" forIndexPath:indexPath];
        cell.indexPath = indexPath;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
        [cell addGestureRecognizer:tap];
        
        if ([tappedArray[indexPath.row] isEqualToNumber:[NSNumber numberWithInt:1]]) {
            
            //cell.checkButton.image = [UIImage imageNamed:@"check"];
            cell.nameLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17];
            //[cell.checkImageView.stop frame];
            cell.checkImageView.springBounciness = 20;
            cell.checkImageView.springSpeed = 20;
            //cell.checkImageView.spring.center = cell.checkView.center;
            
            cell.checkImageView.spring.frame = CGRectMake(cell.checkView.frame.origin.x + 4, cell.checkView.frame.origin.y + 4, 22, 22);
            
        } else {
            
            [cell.checkImageView.stop frame];
            //cell.checkButton.image = [UIImage imageNamed:@"check-empty"];
            cell.nameLabel.font = [UIFont fontWithName:@"OpenSans" size:17];
            cell.checkImageView.frame = CGRectMake(cell.checkView.frame.origin.x + 15, cell.checkView.frame.origin.y + 15, 0, 0);
        }
        
        id file = groupImagesArray[indexPath.row];
        if ([file isKindOfClass:[PFFile class]]) {
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    cell.avatarImageView.image = image;
                    groupImagesArray[indexPath.row] = image;
                }
            }];
        } else {
            cell.avatarImageView.image = groupImagesArray[indexPath.row];
        }
        
        cell.nameLabel.text = groupNamesArray[indexPath.row];
        cell.membersLabel.text = memberNamesArray[indexPath.row];
        
        return cell;
        
    } else {
        
        inviteHomiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"homies" forIndexPath:indexPath];
        cell.indexPath = indexPath;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
        
        [cell addGestureRecognizer:tap];
        
        NSString *letterRepresentingTheseFriends = [sortedFriendsLetters objectAtIndex:indexPath.section];
        NSDictionary *friendsForThisLetter = [sections objectForKey:letterRepresentingTheseFriends];
        NSArray *namesArray = [friendsForThisLetter objectForKey:@"Names"];
        NSArray *idsArray = [friendsForThisLetter objectForKey:@"IDs"];
        NSArray *imagesArray = [friendsForThisLetter objectForKey:@"Images"];
        NSMutableArray *tappedArray = [friendsForThisLetter objectForKey:@"Tapped"];
        
        
        BOOL isGroupMember = [fbIds containsObject:idsArray[indexPath.row]];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = YES;
        cell.checkView.alpha = 1.0;
        
        if (isGroupMember) {
            
            cell.checkView.alpha = 0;
            cell.userInteractionEnabled = NO;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
        } else if ([tappedArray[indexPath.row] isEqualToNumber:[NSNumber numberWithInt:1]]) {
            
            //cell.checkButton.image = [UIImage imageNamed:@"check"];
            cell.nameLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17];
            //[cell.checkImageView.stop frame];
            cell.checkImageView.springBounciness = 20;
            cell.checkImageView.springSpeed = 20;
            //cell.checkImageView.spring.center = cell.checkView.center;
            
            cell.checkImageView.spring.frame = CGRectMake(cell.checkView.frame.origin.x + 4, cell.checkView.frame.origin.y + 4, 22, 22);
            
        } else {
            
            [cell.checkImageView.stop frame];
            //cell.checkButton.image = [UIImage imageNamed:@"check-empty"];
            cell.nameLabel.font = [UIFont fontWithName:@"OpenSans" size:17];
            cell.checkImageView.frame = CGRectMake(cell.checkView.frame.origin.x + 15, cell.checkView.frame.origin.y + 15, 0, 0);
        }
        
        cell.nameLabel.text = namesArray[indexPath.row];
        
        for (UIView *view in cell.subviews) {
            if (view.tag == 9) {
                [view removeFromSuperview];
            }
        }
        
        [cell addSubview:imagesArray[indexPath.row]];
        
        [[cell viewWithTag:234] removeFromSuperview];
        
        if ([bestFriendsIds containsObject:idsArray[indexPath.row]]) {
            
            UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20 + 10, 0 + 5, 10, 10)];
            starImageView.image = [UIImage imageNamed:@"star-blue-bordered"];
            starImageView.tag = 234;
            //[cell addSubview:starImageView];
        }
    
        return cell;
        
    }
    
    return nil;
}


- (void) handleChecking:(UITapGestureRecognizer *)tapRecognizer {
    
    CGPoint tapLocation = [tapRecognizer locationInView:self.tableView];
    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    NSString *theID = @"";
    
    NSLog(@"Tap");
    if (tappedIndexPath.section == 0) {
        
        NSString *letterRepresentingTheseFriends = [sortedFriendsLetters objectAtIndex:tappedIndexPath.section];
        NSDictionary *friendsForThisLetter = [sections objectForKey:letterRepresentingTheseFriends];
        NSMutableArray *tappedArray = [friendsForThisLetter objectForKey:@"Tapped"];
        NSMutableArray *groupNamesArray = [friendsForThisLetter objectForKey:@"GroupNames"];
        NSMutableArray *memberNamesArray = [friendsForThisLetter objectForKey:@"MemberNames"];
        NSArray *groupImagesArray = [friendsForThisLetter objectForKey:@"GroupImages"];
        NSArray *idsArray = [friendsForThisLetter objectForKey:@"IDs"];
        
        if (tappedIndexPath.row == groupNamesArray.count) { // Create Group
            
            NSLog(@"Create Group");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"To create a new group..." message:@"Tap your friends below and hit the arrow when you're done!" delegate:self cancelButtonTitle:@"Boom" otherButtonTitles:nil, nil];
            [alert show];
            
            return;
            
        } else {
            
            NSString *theName = groupNamesArray[tappedIndexPath.row];
            theID = idsArray[tappedIndexPath.row];
            
            if ([selectedIDs containsObject:theID]) {
                
                [selectedIDs removeObject:theID];
                [finalGroupIDArray removeObject:theID];
                NSMutableDictionary *dict = [selectedDict objectForKey:theID];
                [dict setObject:@(NO) forKey:@"Selected"];
                
            } else {
                
                [selectedIDs addObject:theID];
                [finalGroupIDArray addObject:theID];
                NSMutableDictionary *dict = [selectedDict objectForKey:theID];
                if (!dict) {
                    dict = [NSMutableDictionary dictionary];
                    
                    [dict setObject:groupImagesArray[tappedIndexPath.row] forKey:@"Image"];
                    [dict setObject:theName forKey:@"Name"];
                    [selectedDict setObject:dict forKey:theID];
                    [dict setObject:@(NO) forKey:@"Loaded"];
                    [dict setObject:tappedIndexPath forKey:@"IndexPath"];
                }
                [dict setObject:@(YES) forKey:@"Selected"];
            }
            
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:40];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:40];
            NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:0 inSection:40];
            
            if ([tappedArray[tappedIndexPath.row] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                
                
                for (int i = 0; i < groupNamesArray.count; i++) {
                    if ([groupNamesArray[i] isEqualToString:theName]) {
                        tappedArray[i] = [NSNumber numberWithInt:0];
                        indexPath1 = [NSIndexPath indexPathForRow:i inSection:0];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath1] withRowAnimation: UITableViewRowAnimationNone];
                        break;
                    }
                }
                
                
            } else {
                
                for (int i = 0; i < groupNamesArray.count; i++) {
                    if ([groupNamesArray[i] isEqualToString:theName]) {
                        tappedArray[i] = [NSNumber numberWithInt:1];
                        indexPath1 = [NSIndexPath indexPathForRow:i inSection:0];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath1] withRowAnimation: UITableViewRowAnimationNone];
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
        NSArray *imagesArray = [friendsForThisLetter objectForKey:@"Images"];
        
        NSString *theName = namesArray[tappedIndexPath.row];
        theID = idsArray[tappedIndexPath.row];
        
        if ([selectedIDs containsObject:theID]) {
            
            [selectedIDs removeObject:theID];
            [finalUserIDArray removeObject:theID];
            [selectedNamesArray removeObject:theName];
            NSMutableDictionary *dict = [selectedDict objectForKey:theID];
            [dict setObject:@(NO) forKey:@"Selected"];
            
        } else {
            
            [selectedIDs addObject:theID];
            [finalUserIDArray addObject:theID];
            [selectedNamesArray addObject:theName];
            NSMutableDictionary *dict = [selectedDict objectForKey:theID];
            if (!dict) {
                dict = [NSMutableDictionary dictionary];
                
                [dict setObject:imagesArray[tappedIndexPath.row] forKey:@"Image"];
                [dict setObject:theName forKey:@"Name"];
                [selectedDict setObject:dict forKey:theID];
                [dict setObject:@(NO) forKey:@"Loaded"];
                [dict setObject:tappedIndexPath forKey:@"IndexPath"];
            }
            [dict setObject:@(YES) forKey:@"Selected"];
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
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath2] withRowAnimation: UITableViewRowAnimationNone];
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
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath3] withRowAnimation: UITableViewRowAnimationNone];
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
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath2] withRowAnimation: UITableViewRowAnimationNone];
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
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath3] withRowAnimation: UITableViewRowAnimationNone];
                    break;
                }
            }
        }
    }
    
    [self updateNamesOnBottomForID:theID];

    
}

-(void)updateNamesOnBottomForID:(NSString *)fbID {
    
    NSMutableDictionary *dict = [selectedDict objectForKey:fbID];
    NSNumber *shouldAdd = [dict objectForKey:@"Selected"];
    id imageData = [dict objectForKey:@"Image"];
    NSNumber *didLoad = [dict objectForKey:@"Loaded"];
    
    
    int indexOfDeletedImage = 0;
    
    if ([shouldAdd boolValue] == NO) {
        for (int i = 0; i < selectedImagesArray.count; i++) {
            UIView *imv = selectedImagesArray[i];
            if ([imageData isEqual:imv]) {
                [selectedImagesArray removeObject:imv];
                
                [UIView animateWithDuration:0.3 animations:^{
                    imv.alpha = 0;
                } completion:^(BOOL finished) {
                    //x[imv removeFromSuperview];
                }];
                
                for (int i = 0; i < selectedImagesArray.count; i++) {
                    UIView *imageView = selectedImagesArray[i];
                    
                    if (i >= indexOfDeletedImage) {
                        
                        [UIView animateWithDuration:0.3 animations:^{
                            imageView.frame = CGRectMake(10 + (45 * i), 5, 40, 40);
                        }];
                    }
                    
                }
                
                break;
            }
        }
    }
    
    if (selectedImagesArray.count == 0 && [shouldAdd boolValue] == YES) { // animate bottom bar up
        
        [UIView animateWithDuration:0.3 animations:^{
            
            if (namesOnBottomView.frame.origin.y != 568-64-50 + self.tableView.contentOffset.y) {
                if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height)) {
                    //user has scrolled to the bottom
                    [self.tableView setContentOffset:CGPointMake(0, 99999)];
                }
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
                namesOnBottomView.frame = CGRectMake(0, 568-64-50 + self.tableView.contentOffset.y, 320, namesOnBottomView.frame.size.height);
            }
            
            friendScrollView.contentSize = CGSizeMake(5 + 40, 40);
            
        } completion:^(BOOL finished) {
            
        }];
        
    } else if (selectedImagesArray.count == 0 && [shouldAdd boolValue] == NO) { // animate bottom bar down
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            namesOnBottomView.frame = CGRectMake(0, namesOnBottomView.frame.origin.y + namesOnBottomView.frame.size.height, 320, namesOnBottomView.frame.size.height);
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
    if ([shouldAdd boolValue] == YES) {
        
        if ([didLoad boolValue] == YES) { // use cached image
            
            
            if ([imageData isKindOfClass:[FBSDKProfilePictureView class]]) {
                
                FBSDKProfilePictureView *imv = imageData;
                imv.alpha = 1.0;
                imv.frame = CGRectMake(10 + (45 * selectedImagesArray.count), 5, 40, 40);
                [friendScrollView addSubview:imv];
                [selectedImagesArray addObject:imv];
                /*
                 if ([bestFriendsIds containsObject:imv.profileID]) {
                 UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10 + 25 + (45 * selectedImagesArray.count), 0, 15, 15)];
                 starImageView.image = [UIImage imageNamed:@"star-blue-bordered"];
                 [friendScrollView addSubview:starImageView];
                 } */
                
            } else {
                
                UIImageView *imv = imageData;
                imv.alpha = 1.0;
                imv.frame = CGRectMake(10 + (45 * selectedImagesArray.count), 5, 40, 40);
                [friendScrollView addSubview:imv];
                [selectedImagesArray addObject:imv];
            }
            
        } else { // create and cache image
            
            if ([imageData isKindOfClass:[FBSDKProfilePictureView class]]) {
                
                FBSDKProfilePictureView *imv = imageData;
                FBSDKProfilePictureView *newImv = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10 + (45 * selectedImagesArray.count), 5, 40, 40)];
                newImv.profileID = imv.profileID;
                newImv.layer.cornerRadius = 20;
                newImv.layer.masksToBounds = YES;
                
                newImv.userInteractionEnabled = YES;
                [newImv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomPicTapped:)]];
                newImv.accessibilityIdentifier = fbID;
                
                //newImv.alpha = 0;
                [dict setObject:newImv forKey:@"Image"];
                [dict setObject:@(YES) forKey:@"Loaded"];
                
                UIView *maskView = [[UIView alloc] initWithFrame:newImv.bounds];
                maskView.backgroundColor = [UIColor blackColor];
                maskView.alpha = 0.3;
                maskView.tag = 123;
                [newImv addSubview:maskView];
                
                UIImageView *checkIMV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
                checkIMV.image = [UIImage imageNamed:@"white_check"];
                checkIMV.tag = 123;
                [newImv addSubview:checkIMV];
                
                [friendScrollView addSubview:newImv];
                [selectedImagesArray addObject:newImv];
                
            } else {
                
                __block UIImageView *tempImageView = [[UIImageView alloc]  initWithFrame:CGRectMake(10 + (45 * (selectedImagesArray.count)), 5, 40, 40)];
                tempImageView.image = [UIImage imageNamed:@"userImage"];
                [friendScrollView addSubview:tempImageView];
                [selectedImagesArray addObject:tempImageView];
                [dict setObject:tempImageView forKey:@"Image"];
                
                //PFFile *file = imageData;
                //[file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                //if (!error) {
                [tempImageView removeFromSuperview];
                [selectedImagesArray removeObject:tempImageView];
                
                // UIImage *image = [UIImage imageWithData:data];
                
                UIImage *test = (UIImage *)imageData;
                
                UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(10 + (45 * selectedImagesArray.count), 5, 40, 40)];
                
                imv.image = [test copy];
                imv.layer.cornerRadius = 20;
                imv.layer.masksToBounds = YES;
                imv.tag = 3;
                //imv.alpha = 0;
                [dict setObject:imv forKey:@"Image"];
                [dict setObject:@(YES) forKey:@"Loaded"];
                [friendScrollView addSubview:imv];
                [selectedImagesArray addObject:imv];
                
                UIView *maskView = [[UIView alloc] initWithFrame:imv.bounds];
                maskView.backgroundColor = [UIColor blackColor];
                maskView.alpha = 0.3;
                maskView.tag = 123;
                [imv addSubview:maskView];
                
                UIImageView *checkIMV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
                checkIMV.image = [UIImage imageNamed:@"white_check"];
                checkIMV.tag = 123;
                [imv addSubview:checkIMV];
                
                imv.userInteractionEnabled = YES;
                [imv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomPicTapped:)]];
                imv.accessibilityIdentifier = fbID;
                //}
                //}];
                
            }
        }
        
    } else { // remove
        
        NSLog(@"remove");
        
        
    }
    
    
    /*
     UIImageView *imv = selectedImagesArray[0];
     imv.frame = CGRectMake(10, 5, 40, 40);
     [friendScrollView addSubview:imv];
     
     for (int i = 1; i < selectedNamesArray.count; i++) {
     
     UIImageView *imv = selectedImagesArray[i];
     imv.frame = CGRectMake(10 + 5 + 40*i, 5, 40, 40);
     [friendScrollView addSubview:imv];
     } */
    
    float newPos = 10 + selectedImagesArray.count * 45;
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        if (newPos > 0) {
            friendScrollView.contentOffset = CGPointMake(newPos, 0);
        } else {
            friendScrollView.contentOffset = CGPointMake(0, 0);
        }
        
        friendScrollView.contentSize = CGSizeMake(newPos, 40);
        
    } completion:nil];
    
}

- (void)bottomPicTapped:(UIGestureRecognizer *)gr {
    
    UIImageView *imv = (UIImageView *)gr.view;
    NSString *theID = imv.accessibilityIdentifier;
    
    NSMutableDictionary *dict = [selectedDict objectForKey:theID];
    NSIndexPath *tappedIndexPath = [dict objectForKey:@"IndexPath"];
    
    if (tappedIndexPath.section == 0) {
        
        NSString *letterRepresentingTheseFriends = [sortedFriendsLetters objectAtIndex:tappedIndexPath.section];
        NSDictionary *friendsForThisLetter = [sections objectForKey:letterRepresentingTheseFriends];
        NSMutableArray *tappedArray = [friendsForThisLetter objectForKey:@"Tapped"];
        NSMutableArray *groupNamesArray = [friendsForThisLetter objectForKey:@"GroupNames"];
        NSMutableArray *memberNamesArray = [friendsForThisLetter objectForKey:@"MemberNames"];
        NSMutableArray *groupImagesArray = [friendsForThisLetter objectForKey:@"GroupImages"];
        NSArray *idsArray = [friendsForThisLetter objectForKey:@"IDs"];
            
            NSString *theName = groupNamesArray[tappedIndexPath.row];
            theID = idsArray[tappedIndexPath.row];
            
            if ([selectedIDs containsObject:theID]) {
                
                [selectedIDs removeObject:theID];
                [finalGroupIDArray removeObject:theID];
                NSMutableDictionary *dict = [selectedDict objectForKey:theID];
                [dict setObject:@(NO) forKey:@"Selected"];
                
            } else {
                
                [selectedIDs addObject:theID];
                [finalGroupIDArray addObject:theID];
                NSMutableDictionary *dict = [selectedDict objectForKey:theID];
                if (!dict) {
                    dict = [NSMutableDictionary dictionary];
                    
                    [dict setObject:groupImagesArray[tappedIndexPath.row] forKey:@"Image"];
                    [dict setObject:theName forKey:@"Name"];
                    [selectedDict setObject:dict forKey:theID];
                    [dict setObject:@(NO) forKey:@"Loaded"];
                    [dict setObject:tappedIndexPath forKey:@"IndexPath"];
                }
                [dict setObject:@(YES) forKey:@"Selected"];
            }
            
            NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:0 inSection:40];
            NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:40];
            NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:0 inSection:40];
            
            if ([tappedArray[tappedIndexPath.row] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                
                
                for (int i = 0; i < groupNamesArray.count; i++) {
                    if ([groupNamesArray[i] isEqualToString:theName]) {
                        tappedArray[i] = [NSNumber numberWithInt:0];
                        indexPath1 = [NSIndexPath indexPathForRow:i inSection:0];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath1] withRowAnimation: UITableViewRowAnimationNone];
                        break;
                    }
                }
                
                
            } else {
                
                for (int i = 0; i < groupNamesArray.count; i++) {
                    if ([groupNamesArray[i] isEqualToString:theName]) {
                        tappedArray[i] = [NSNumber numberWithInt:1];
                        indexPath1 = [NSIndexPath indexPathForRow:i inSection:0];
                        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath1] withRowAnimation: UITableViewRowAnimationNone];
                        break;
                    }
                }
            }
        
    } else {
        
        NSString *letterRepresentingTheseFriends = [sortedFriendsLetters objectAtIndex:tappedIndexPath.section];
        NSDictionary *friendsForThisLetter = [sections objectForKey:letterRepresentingTheseFriends];
        NSMutableArray *tappedArray = [friendsForThisLetter objectForKey:@"Tapped"];
        NSMutableArray *namesArray = [friendsForThisLetter objectForKey:@"Names"];
        NSArray *idsArray = [friendsForThisLetter objectForKey:@"IDs"];
        NSArray *imagesArray = [friendsForThisLetter objectForKey:@"Images"];
        
        NSString *theName = namesArray[tappedIndexPath.row];
        theID = idsArray[tappedIndexPath.row];
        
        if ([selectedIDs containsObject:theID]) {
            
            [selectedIDs removeObject:theID];
            [finalUserIDArray removeObject:theID];
            [selectedNamesArray removeObject:theName];
            NSMutableDictionary *dict = [selectedDict objectForKey:theID];
            [dict setObject:@(NO) forKey:@"Selected"];
            
        } else {
            
            [selectedIDs addObject:theID];
            [finalUserIDArray addObject:theID];
            [selectedNamesArray addObject:theName];
            NSMutableDictionary *dict = [selectedDict objectForKey:theID];
            if (!dict) {
                dict = [NSMutableDictionary dictionary];
                
                [dict setObject:imagesArray[tappedIndexPath.row] forKey:@"Image"];
                [dict setObject:theName forKey:@"Name"];
                [selectedDict setObject:dict forKey:theID];
                [dict setObject:@(NO) forKey:@"Loaded"];
                [dict setObject:tappedIndexPath forKey:@"IndexPath"];
            }
            [dict setObject:@(YES) forKey:@"Selected"];
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
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath2] withRowAnimation: UITableViewRowAnimationNone];
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
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath3] withRowAnimation: UITableViewRowAnimationNone];
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
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath2] withRowAnimation: UITableViewRowAnimationNone];
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
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath3] withRowAnimation: UITableViewRowAnimationNone];
                    break;
                }
            }
        }
    }
    
    [self updateNamesOnBottomForID:theID];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    namesOnBottomView.transform = CGAffineTransformMakeTranslation(0, scrollView.contentOffset.y);
    
}


- (void)inviteButtonTapped {
    
    [SVProgressHUD setViewForExtension:self.view];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            //[SVProgressHUD show];
        });
    });
    
    [self.delegate didInviteHomiesWithPics:selectedImagesArray ids:selectedIDs];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return indexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [sortedFriendsLetters indexOfObject:title];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}

@end
