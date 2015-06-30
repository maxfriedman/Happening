//
//  GroupsTVC.m
//  Happening
//
//  Created by Max on 6/1/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupsTVC.h"
#import "GroupsCell.h"
#import "GroupPageTVC.h"
#import <Parse/Parse.h>
#import "UserManager.h"
#import <ATLConstants.h>
#import "AppDelegate.h"
#import "groupManager.h"
#import "PFObject+ATLAvatarItem.h"
#import "SVProgressHUD.h"
#import "CustomConstants.h"

@interface GroupsTVC () <ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource>

@end

@implementation GroupsTVC {
    
    NSMutableArray *groupNamesArray;
    NSMutableArray *groupMembersArray;
    NSMutableArray *groupMemCountArray;
    NSMutableArray *groupIDsArray;
    NSMutableArray *groupImagesArray;
    NSArray *groupsArray;
    PFUser *currentUser;
    
    NSString *selectedGroupId;
    NSString *selectedName;
    
    LYRConversation *selectedConvo;

    NSMutableDictionary *groupDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;

    currentUser = [PFUser currentUser];
    
    groupDict = [[NSMutableDictionary alloc] init];
    
    [self refreshData];
    
    //[self setDisplaysAvatarItem:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [SVProgressHUD dismiss];
    
    currentUser = [PFUser currentUser];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"refreshGroups"] == YES) {
        [self refreshData];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"refreshGroups"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.mh.groupHub decrementBy:appDelegate.mh.groupHub.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ATLConversationListViewControllerDelegate Methods

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    selectedConvo = conversation;
    [self performSegueWithIdentifier:@"toGroupPage" sender:self];
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    NSLog(@"Conversation deleted");
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didFailDeletingConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode error:(NSError *)error
{
    NSLog(@"Failed to delete conversation with error: %@", error);
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSearchForText:(NSString *)searchText completion:(void (^)(NSSet *filteredParticipants))completion
{
    
    [[groupManager sharedManager] queryForGroupWithName:searchText completion:^(NSArray *groups, NSError *error) {
        if (!error) {
            if (completion) completion([NSSet setWithArray:groups]);
        } else {
            if (completion) completion(nil);
            NSLog(@"Error searching for Users by name: %@", error);
        }
    }];
    
    /*
    
    [[UserManager sharedManager] queryForUserWithName:searchText completion:^(NSArray *participants, NSError *error) {
        if (!error) {
            if (completion) completion([NSSet setWithArray:participants]);
        } else {
            if (completion) completion(nil);
            NSLog(@"Error searching for Users by name: %@", error);
        }
    }]; */
}

#pragma mark - ATLConversationListViewControllerDataSource Methods

- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation
{
    NSString *title = [conversation.metadata valueForKey:@"title"];
    if ((title != nil) && ![title isEqualToString:@"_indy_"]){
        return [conversation.metadata valueForKey:@"title"];
    } else {
        NSArray *unresolvedParticipants = [[UserManager sharedManager] unCachedUserIDsFromParticipants:[conversation.participants allObjects]];
        NSArray *resolvedNames = [[UserManager sharedManager] resolvedNamesFromParticipants:[conversation.participants allObjects]];
        
        if ([unresolvedParticipants count]) {
            [[UserManager sharedManager] queryAndCacheUsersWithIDs:unresolvedParticipants completion:^(NSArray *participants, NSError *error) {
                if (!error) {
                    if (participants.count) {
                        [self reloadCellForConversation:conversation];
                    }
                } else {
                    NSLog(@"Error querying for Users: %@", error);
                }
            }];
        }
        
        if ([resolvedNames count] && [unresolvedParticipants count]) {
            return [NSString stringWithFormat:@"%@ and %lu others", [resolvedNames componentsJoinedByString:@", "], (unsigned long)[unresolvedParticipants count]];
        } else if ([resolvedNames count] && [unresolvedParticipants count] == 0) {
            return [NSString stringWithFormat:@"%@", [resolvedNames componentsJoinedByString:@", "]];
        } else {
            return @""; //[NSString stringWithFormat:@"Conversation with %lu users...", (unsigned long)conversation.participants.count];
        }
    }
}


- (id<ATLAvatarItem>)conversationListViewController:(ATLConversationListViewController *)conversationListViewController avatarItemForConversation:(LYRConversation *)conversation {
    
    //ATLAvatarImageView *imv = [[ATLAvatarImageView alloc] initWithImage:[UIImage imageNamed:@"checked6green"]];
    //id<ATLAvatarItem> item = nil;
    
    PFObject *ob = [groupDict objectForKey:[conversation.metadata valueForKey:@"groupId"]];
    
    return ob;
}



- (void)refreshData {
    
    NSLog(@"refreshing data...");
    
    groupNamesArray = [NSMutableArray array];
    groupMembersArray = [NSMutableArray array];
    groupMemCountArray = [NSMutableArray array];
    groupImagesArray = [NSMutableArray array];
    groupIDsArray = [NSMutableArray array];
    groupsArray = [NSArray array];
    
    PFQuery *groupsUserQuery = [PFQuery queryWithClassName:@"Group_User"];
    [groupsUserQuery whereKey:@"user_id" equalTo:currentUser.objectId];
    
    PFQuery *groupsQuery = [PFQuery queryWithClassName:@"Group"];
    [groupsQuery whereKey:@"objectId" matchesKey:@"group_id" inQuery:groupsUserQuery];
    [groupsQuery includeKey:@"user_objects"];
    
    [groupsQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        
        if (!error) {
            
            groupsArray = array;
            
            for (PFObject *group in array) {
                
                [groupDict setObject:group forKey:group.objectId];
                
                PFFile *file = group[@"avatar"];
                [groupImagesArray addObject:file];
                
                NSNumber *memCount = group[@"memberCount"];
                [groupMemCountArray addObject:memCount];
                [groupIDsArray addObject:group.objectId];
                
                NSArray *users = group[@"user_objects"];
                NSString *groupName = group[@"name"];
                
                if ([groupName isEqualToString:@"_indy_"]) {
                    for (PFUser *user in users) {
                        if (![user.objectId isEqualToString: currentUser.objectId]) {
                            [groupNamesArray addObject:[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]]];
                        }
                    }
                    
                    [groupMembersArray addObject: @"No new notifications."];
                    
                } else {
                    
                    [groupNamesArray addObject:groupName];
                    
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
                    
                    [groupMembersArray addObject:memberString];
                    
                }
                
                [self.tableView reloadData];
                [self setDisplaysAvatarItem:YES];
            }
            
        }
        
    }];
    
}

- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController lastMessageTextForConversation:(LYRConversation *)conversation {
    
    LYRMessagePart *part = conversation.lastMessage.parts[0];
    
    if([part.MIMEType  isEqual: ATLMimeTypeCustomObject] || [part.MIMEType  isEqual: ATLMimeTypeSystemObject])
    {
        
        NSData *data = part.data;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        return [json objectForKey:@"message"];
    }
    return nil;
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [groupsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GroupsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"group" forIndexPath:indexPath];
    
    PFFile *file = groupImagesArray[indexPath.row];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if (!error) {
            UIImage *image = [UIImage imageWithData:data];
            cell.avatarImageView.image = image;
        }
    }];
    
    cell.nameLabel.text = groupNamesArray[indexPath.row];
    cell.membersLabel.text = groupMembersArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    selectedGroupId = groupIDsArray[indexPath.row];
    selectedName = groupNamesArray[indexPath.row];
    [self performSegueWithIdentifier:@"toGroupPage" sender:self];
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"toGroupPage"]) {
        
        GroupPageTVC *vc = (GroupPageTVC *)[segue destinationViewController];
        //vc.groupId = selectedGroupId;
        //vc.groupName = selectedName;
        
        vc.conversation = selectedConvo;
        NSString *title = [[selectedConvo metadata] objectForKey:@"title"];
        if ([title isEqualToString:@"_indy_"]) {
            vc.title = [NSString stringWithFormat:@"%@ and %@", [self.dataSource conversationListViewController:self titleForConversation:selectedConvo], currentUser[@"firstName"]];
            vc.showDetails = NO;
        } else {
            vc.title = title;
            vc.showDetails = YES;
        }
        
        vc.group = [groupDict valueForKey:[selectedConvo.metadata valueForKey:@"groupId"]];
        vc.loadTopView = YES;
        
        if (!vc.group) {
            
            NSLog(@"Group hasn't loaded yet. Load in next VC");
        }
        
        
        
        
        
        //vc.groupName = @"Test";
    }
    
}


@end
