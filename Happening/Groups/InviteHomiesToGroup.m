//
//  InviteHomiesToGroup.m
//  Happening
//
//  Created by Max on 7/14/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "InviteHomiesToGroup.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import "inviteHomiesCell.h"
#import "NewGroupCreatorVC.h"
#import "GroupsCell.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "CustomConstants.h"
#import "UIButton+Extensions.h"
#import "AnonymousUserView.h"

#define MCANIMATE_SHORTHAND
#import <POP+MCAnimate.h>

@interface InviteHomiesToGroup () <UIScrollViewDelegate, UIAlertViewDelegate, AnonymousUserViewDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation InviteHomiesToGroup {

    NSMutableArray *friendsArray;
    NSArray *sortedFriends;
    NSMutableArray *uniqueFriendsByLetter;
    NSMutableDictionary *sections;
    NSArray *sortedFriendsLetters;
    NSMutableArray *selectedImagesArray;
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
}

@synthesize namesOnBottomView;

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
    //[selectedDict setObject:selectedIDs forKey:@"Users"];
    
    
    
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        AnonymousUserView *anonView = [[AnonymousUserView alloc] initWithFrame:CGRectMake(0, 64, 320, 568-64)];
        anonView.delegate = self;
        anonView.tag = 456;
        [anonView setImage:[UIImage imageNamed:@"Invite Screenshot"]];
        [anonView setMessage:@"Sign in to invite your friends!"];
        [self.navigationController.view addSubview:anonView];
    } else {
        [self loadFriends];
    }
}

- (void)scrollToTop {
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

- (void)facebookSuccessfulSignup {
    [[self.view viewWithTag:456] removeFromSuperview];
    [self loadFriends];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSArray *namesArray = [friendsForThisLetter objectForKey:@"Names"];
    
    return namesArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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


- (void) handleChecking:(UITapGestureRecognizer *)tapRecognizer {
    
    CGPoint tapLocation = [tapRecognizer locationInView:self.tableView];
    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    NSString *theID = @"";
        
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
                [newImv addSubview:maskView];
                
                UIImageView *checkIMV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
                checkIMV.image = [UIImage imageNamed:@"white_check"];
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
                [imv addSubview:maskView];
                
                UIImageView *checkIMV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
                checkIMV.image = [UIImage imageNamed:@"white_check"];
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
    
    /* Snapchat clone
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
     */
    
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    namesOnBottomView.transform = CGAffineTransformMakeTranslation(0, scrollView.contentOffset.y);
    
}

- (void)inviteButtonTapped {
    
    //[SVProgressHUD setViewForExtension:[UIApplication sharedApplication].keyWindow];
    //[SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [SVProgressHUD setViewForExtension:self.tableView.superview];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, 30)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show]; //WithMaskType:SVProgressHUDMaskTypeGradient];
            //[SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
            //[SVProgressHUD setStatus:@"Loading Happenings"];
        });
    });
    
    
    BOOL createGroupAlert = NO;
    
    if (selectedNamesArray.count > 1) {
        
        createGroupAlert = YES;
        
        NSString *nameString = [NSString stringWithFormat:@"%@", selectedNamesArray[0]];
        for (int i = 1; i < finalUserIDArray.count - 1; i++) {
            nameString = [nameString stringByAppendingString:[NSString stringWithFormat:@", %@", selectedNamesArray[i]]];
        }
        
        if (selectedNamesArray.count > 1)
            nameString = [nameString stringByAppendingString:[NSString stringWithFormat:@" and %@", selectedNamesArray[selectedNamesArray.count - 1]]];
        
        NSString *groupString = [NSString stringWithFormat:@"Would you like to create a group with %@?",  nameString];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Create a group?" message:groupString delegate:self cancelButtonTitle:@"Create New Group" otherButtonTitles:@"Invite Separately", nil];
        alert.delegate = self;
        alert.tag = 3;
        [alert show];
        
    }
    
    PFUser *currentUser = [PFUser currentUser];
    
    // %%%%%%%%%%%%%%%%%% USER PUSH %%%%%%%%%%%%%%%%%%%%%%
    
    if (!createGroupAlert) {
        
        [self sendIndividualInvites];
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 3) {
        
        [self interactionEnabled:NO];
        
        if (buttonIndex == 0) {
            
            NSLog(@"Group invites from button");
            
            [SVProgressHUD setViewForExtension:self.view];
            [SVProgressHUD show];
            
            PFUser *cu = [PFUser currentUser];
            NSMutableArray *tempIDArray = [NSMutableArray arrayWithArray:finalUserIDArray];
            [tempIDArray addObject:cu[@"FBObjectID"]];
            tempIDArray = (NSMutableArray *)[tempIDArray sortedArrayUsingSelector:@selector(compare:)];
            
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"FBObjectID" containedIn:tempIDArray];
            
            PFQuery *groupUserQuery = [PFQuery queryWithClassName:@"Group_User"];
            [groupUserQuery whereKey:@"user_id" matchesKey:@"objectId" inQuery:userQuery];
            
            PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
            [groupQuery whereKey:@"objectId" matchesKey:@"group_id" inQuery:groupUserQuery];
            [groupQuery whereKey:@"memberCount" equalTo:@(tempIDArray.count)];
            [groupQuery findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error){
                
                if (!error) {
                    
                    BOOL groupExists = NO;
                    
                    for (PFObject *group in groups) {
                        
                        NSArray *userObjects = group[@"user_dicts"];
                        NSMutableArray *tempArray = [NSMutableArray new];
                        for (NSDictionary *user in userObjects) {
                            [tempArray addObject:[user valueForKey:@"id"]];
                        }
                        
                        tempArray = (NSMutableArray *)[tempArray sortedArrayUsingSelector:@selector(compare:)];
                        
                        if ([tempArray isEqualToArray:tempIDArray]) {
                            groupExists = YES;
                            NSLog(@"Group exists!");
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hold your horses" message:[NSString stringWithFormat:@"This group already exists, it's called: \"%@\".", group[@"name"]] delegate:self cancelButtonTitle:@"Ohh yeah!" otherButtonTitles:nil, nil];
                            [alertView show];
                            break;
                        } else { //redundant
                            groupExists = NO;
                        }
                        
                    }
                    
                    if (!groupExists) {
                        
                        NSLog(@"Group doesn't exist...");
                        [SVProgressHUD dismiss];
                        [self interactionEnabled:YES];
                        [self performSegueWithIdentifier:@"toNewGroup" sender:self];
                    }
                    
                } else {
                    
                    NSLog(@"Group doesn't exist...");
                    [SVProgressHUD dismiss];
                    [self interactionEnabled:YES];
                    [self performSegueWithIdentifier:@"toNewGroup" sender:self];
                }
                
                [SVProgressHUD dismiss];
                
            }];
            
        } else {
            
            NSLog(@"Individual invites from button");
            [self sendIndividualInvites];
            
        }
    }
    
    
}

- (void)interactionEnabled:(BOOL)enabled {
    
    self.tableView.userInteractionEnabled = enabled;
    sendInvitesButton.enabled = enabled;
}

- (void)sendIndividualInvites {
    
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *userQuery = [PFUser query];
    __block int saveCount = 0;
    [userQuery whereKey:@"FBObjectID" containedIn:finalUserIDArray];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
        
        if (!error) {
            
            for (int i = 0; i < users.count; i++) {
                
                PFObject *user = (PFObject *)users[i];
                
                PFObject *cu = (PFObject *)currentUser;
                
                NSMutableArray *usersForGroup = [[NSMutableArray alloc] initWithObjects:user, cu, nil];
                NSMutableArray *userIds = [NSMutableArray array];
                for (PFUser *user in usersForGroup) {
                    [userIds addObject:user.objectId];
                }
                
                PFQuery *groupUserQuery1 = [PFQuery queryWithClassName:@"Group_User"];
                [groupUserQuery1 whereKey:@"user_id" equalTo:currentUser.objectId];
                
                PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
                [groupQuery fromLocalDatastore];
                [groupQuery whereKey:@"user_parse_ids" containsAllObjectsInArray:userIds];
                [groupQuery whereKey:@"memberCount" equalTo:@2];
                
                [groupQuery getFirstObjectInBackgroundWithBlock:^(PFObject *group, NSError *error){
                    
                    BOOL createNewGroup = YES;
                    
                    if (!error) {
                        
                        NSLog(@"1-1 group exists!");
                        createNewGroup = NO;
                            
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:[NSString stringWithFormat:@"You already have an individual group with %@ %@!", user[@"firstName"], user[@"lastName"]] delegate:self cancelButtonTitle:@"Oh yeah" otherButtonTitles:nil, nil];
                        [alertView show];
                    
                        saveCount++;
                        
                        if (saveCount == users.count) {
                            
                            [self dismissViewControllerAnimated:YES completion:^{
                                
                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }];
                        }
                        
                    }
                    
                    if (createNewGroup) {
                        
                        NSLog(@"users do not have a 1-1 group. Create new group!");
                        
                        PFObject *group = [PFObject objectWithClassName:@"Group"];
                        group[@"name"] =  [NSString stringWithFormat:@"%@ and %@", currentUser[@"firstName"], user[@"firstName"]];//[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
                        group[@"memberCount"] = @2;
                        group[@"avatar"] = [PFFile fileWithName:@"image.png" data:UIImagePNGRepresentation([UIImage imageNamed:@"userImage"])];
                        group[@"isDefaultImage"] = @YES;
                        group[@"isDefaultName"] = @YES;
                        
                        NSMutableArray *userDictsArray = [NSMutableArray array];
                        NSMutableArray *parseArray = [NSMutableArray array];
                        NSMutableArray *fbArray = [NSMutableArray array];
                        for (PFUser *user in usersForGroup) {
                            [parseArray addObject:user.objectId];
                            [fbArray addObject:user[@"FBObjectID"]];
                            
                            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                            
                            [dict setObject:user.objectId forKey:@"parseId"];
                            [dict setObject:[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]] forKey:@"name"];
                            [dict setObject:user[@"FBObjectID"] forKey:@"id"];
                            [userDictsArray addObject:dict];
                        }
                        
                        group[@"user_parse_ids"]= parseArray;
                        group[@"user_dicts"] = userDictsArray;
                        
                        [group saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                            
                            if (success) {
                                
                                [group pinInBackground];
                                
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
                                 } */ //gender string formatting
                                /*
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
                                 } */ //parse push notif
                                /*
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
                                 NSLog(@"successful push to %@ - %@", user[@"firstName"], user.objectId);
                                 } else {
                                 NSLog(@"failed push to %@ - %@ with error: %@", user[@"firstName"], user.objectId, error);
                                 
                                 //[notifyButton setTitle:@"Uh-oh." forState:UIControlStateNormal];
                                 //subLabel.text = [NSString stringWithFormat:@"We were unable to notify %@!", user[@"firstName"]];
                                 }
                                 
                                 }];
                                 
                                 NSLog(@"PUSH MESSAGE: %@", pushMessage);
                                 */ //more parse push
                                /*
                                 PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
                                 notification[@"Type"] = @"group";
                                 notification[@"Subtype"] = @"new_individual";
                                 notification[@"EventID"] = self.objectID;
                                 notification[@"UserID"] = user.objectId;
                                 notification[@"GroupID"] = group.objectId;
                                 notification[@"InviterID"] = currentUser.objectId;
                                 notification[@"Seen"] = @NO;
                                 notification[@"Message"] = pushMessage;
                                 [notification saveInBackground];
                                 */ //save push notif to parse
                                
                                PFObject *timelineObject = [PFObject objectWithClassName:@"Timeline"];
                                
                                timelineObject[@"type"] = @"groupCreate";
                                timelineObject[@"userId"] = user.objectId;
                                timelineObject[@"createdDate"] = [NSDate date];
                                [timelineObject pinInBackground];
                                [timelineObject saveEventually];
                                
                                [currentUser incrementKey:@"score" byAmount:@15];
                                [currentUser saveEventually];
                                
                                [self setupConversationWithMessage:[NSString stringWithFormat:@"%@ %@ created a personal group with %@ %@.", currentUser[@"firstName"], currentUser[@"lastName"], user[@"firstName"], user[@"lastName"]] forGroup:group];
                                
                                saveCount++;
                                
                                if (saveCount == users.count) {
                                    
                                    [self dismissViewControllerAnimated:YES completion:^{
                                        
                                        [self.delegate showBoom];
                                        [SVProgressHUD showSuccessWithStatus:@"Boom"];
                                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                    }];
                                }
                            }
                        }];
                    }
                }];
            }
            
        } else {
            
            [self interactionEnabled:YES];
            [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
        }
        
    }];
    
}

- (void)setupConversationWithMessage:(NSString *)messageText forGroup:(PFObject *)group {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    
    LYRConversation *conversation = nil;
    BOOL shouldCreateNewConvo = YES;
    
    NSError *error = nil;
    NSOrderedSet *conversations = [appDelegate.layerClient executeQuery:query error:&error];
    if (!error) {
        
        NSLog(@"%tu conversations", conversations.count);
        
        for (LYRConversation *convo in conversations) {
            
            if ([[convo.metadata valueForKey:@"groupId"] isEqualToString:group.objectId]) {
                
                NSLog(@"group convo exists");
                conversation = convo;
                shouldCreateNewConvo = NO;
                break;
            }
        }
    }
    
    if (shouldCreateNewConvo) {
        
        NSArray *userObjects = group[@"user_dicts"];
        NSMutableArray *idArray = [NSMutableArray new];
        for (NSDictionary *user in userObjects) {
            [idArray addObject:[user valueForKey:@"parseId"]];
        }
        
        conversation = [appDelegate.layerClient newConversationWithParticipants:[NSSet setWithArray:idArray] options:nil error:&error];
        [conversation setValue:group[@"name"] forMetadataAtKeyPath:@"title"];
        [conversation setValue:group.objectId forMetadataAtKeyPath:@"groupId"];
        
        group[@"chatId"] = conversation.identifier.absoluteString;
        [group saveEventually];
        
    }
    
    if (!conversation || conversation == nil) {
        NSLog(@"New Conversation creation failed: %@", error);
        [SVProgressHUD showErrorWithStatus:@"Failed to create conversation"];
        [self interactionEnabled:YES];
    }
    
    //Send messages w data
    
    /* %%%%%%%%%%%%%%% System notification message %%%%%%%%%%%%%%%%%% */
    NSDictionary *dataDictionary = @{@"message":messageText,
                                     @"type":@"invite",
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
    LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart,cellInfoMessagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:&error];
    // Sends the specified message
    
    BOOL success = [conversation sendMessage:message error:&error];
    if (success) {
        //NSLog(@"Message queued to be sent: %@", message);
    } else {
        NSLog(@"Message send failed: %@", error);
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate showError:@"Failed to send message"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    
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
    
    if ([segue.identifier isEqualToString:@"toNewGroup"]) {
        
        NewGroupCreatorVC *vc = (NewGroupCreatorVC *)[segue destinationViewController];
        vc.eventId = @"";
        PFUser *currentUser = [PFUser currentUser];
        vc.userIdArray = (NSMutableArray *)[finalUserIDArray arrayByAddingObject:currentUser[@"FBObjectID"]];
        vc.memCount = (int)vc.userIdArray.count;
        vc.event = nil;
        vc.fromGroupsTab = YES;
        vc.inviteHomiesToGroup = self;
        NSLog(@"%@", vc.userIdArray);
        
    }
    
}

@end

