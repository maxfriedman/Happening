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
#import "ConversationCell.h"
#import "AnonymousUserView.h"
#import "FXBlurView.h"
#import "InviteHomiesToGroup.h"
#import "GroupChatVC.h"

@interface GroupsTVC () <ATLConversationListViewControllerDelegate, ATLConversationListViewControllerDataSource, AnonymousUserViewDelegate, InviteHomiesToGroupDelegate>

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
    
    UIView *noConvosView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    self.delegate = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.title = @"Groups";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"white plus"] style:UIBarButtonItemStylePlain target:self action:@selector(createGroup:)];
    
    groupDict = [NSMutableDictionary new];
    
    [self setDisplaysAvatarItem:YES];
    [self setDeletionModes:@[@(LYRDeletionModeAllParticipants)]];
    
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    
    if ([PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        AnonymousUserView *anonView = [[AnonymousUserView alloc] initWithFrame:CGRectMake(0, 64, 320, 519-64)];
        anonView.delegate = self;
        anonView.tag = 456;
        [self.navigationController.view addSubview:anonView];
        [anonView setImage:[UIImage imageNamed:@"Group Screenshot"]];
        [anonView setMessage:@"Sign in to create a group and invite your friends to events!"];
    } else {
        //[self ];
    }
}

/*
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Made it");
    
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
} */

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
            [self showNoConvosView];
        }
        
    } else {
        NSLog(@"Query failed with error %@", error);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [SVProgressHUD dismiss];
    
    currentUser = [PFUser currentUser];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.mh.groupHub decrementBy:appDelegate.mh.groupHub.count];
    [appDelegate loadGroups];
    [appDelegate.mh hideTabBar:NO];
    
    [ATLConversationCollectionViewHeader appearance].participantLabelFont = [UIFont fontWithName:@"OpenSans" size:11.0];
    
    [ATLConversationTableViewCell appearance].conversationTitleLabelFont = [UIFont fontWithName:@"OpenSans-Semibold" size:17.0];
    [ATLConversationTableViewCell appearance].lastMessageLabelFont = [UIFont fontWithName:@"OpenSans" size:12.0];
    [ATLConversationTableViewCell appearance].dateLabelFont = [UIFont fontWithName:@"OpenSans" size:13.0];
    [ATLConversationTableViewCell appearance].unreadMessageIndicatorBackgroundColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0];

    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    // Fetches all LYRConversation objects
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    NSError *error;
    NSOrderedSet *conversations = [appDelegate.layerClient executeQuery:query error:&error];
    if (!error) {
        NSLog(@"%tu conversations", conversations.count);
        
        if (conversations.count == 0 && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
            [self showNoConvosView];
        } else {

        }
        
    } else {
        
        NSLog(@"Query failed with error %@", error);
    }

}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ConversationCell *cell = (ConversationCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsZero;
    
    return cell;
}*/


#pragma mark - ATLConversationListViewControllerDelegate Methods

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didSelectConversation:(LYRConversation *)conversation
{
    selectedConvo = conversation;
    //[self performSegueWithIdentifier:@"toGroupPage" sender:self];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    GroupChatVC *controller = [GroupChatVC conversationViewControllerWithLayerClient:appDelegate.layerClient];
    
    //controller.userDicts = userDicts;
    //controller.fbids = fbIds;
    //controller.groupObject = group;
    
    NSString *title = [[selectedConvo metadata] objectForKey:@"title"];
    if ([title isEqualToString:@"_indy_"]) {
        //vc.title = [NSString stringWithFormat:@"%@ and %@", [self.dataSource conversationListViewController:self titleForConversation:selectedConvo], currentUser[@"firstName"]];
        //vc.showDetails = NO;
    } else {
        //vc.title = title;
        //vc.showDetails = YES;
    }
    
    controller.groupObject = [groupDict valueForKey:[selectedConvo.metadata valueForKey:@"groupId"]];
    
    if (controller.groupObject.isDataAvailable) {
        
        controller.userDicts = controller.groupObject[@"user_dicts"];
        
        NSMutableArray *fbids =[NSMutableArray new];
        for (NSDictionary *dict in controller.userDicts) {
            [fbids addObject:[dict valueForKey:@"id"]];
        }
        
        controller.fbids = fbids;
        
    }
    
    //vc.loadTopView = YES;
    
    if (!controller.groupObject) {
        
        NSLog(@"Group hasn't loaded yet. Load in next VC");
    }
    
    controller.conversation = conversation;
    
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (void)conversationListViewController:(ATLConversationListViewController *)conversationListViewController didDeleteConversation:(LYRConversation *)conversation deletionMode:(LYRDeletionMode)deletionMode
{
    if (deletionMode == 0 /* LYRDeletionModeLocal */) {
    
        NSLog(@"Conversation deleted");
        NSString *messageText = [NSString stringWithFormat:@"%@ %@ has left the group.", currentUser[@"firstName"], currentUser[@"lastName"]];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        //Send message w data
        NSDictionary *dataDictionary = @{@"message":messageText,
                                         @"type":@"leave",
                                         @"groupId":[conversation.metadata objectForKey:@"groupId"]
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
        NSError *error = nil;
        LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart,cellInfoMessagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:&error];

        // Sends the specified message
        BOOL success = [conversation sendMessage:message error:&error];
        if (success) {
            NSLog(@"Message queued to be sent: %@", message);
        } else {
            NSLog(@"Message send failed: %@", error);
        }
        
        PFQuery *groupUserQuery = [PFQuery queryWithClassName:@"Group_User"];
        [groupUserQuery whereKey:@"user_id" equalTo:currentUser.objectId];
        [groupUserQuery whereKey:@"group_id" equalTo:[conversation.metadata objectForKey:@"groupId"]];
        [groupUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *groupUser, NSError *error){
            if (!error)
                [groupUser deleteEventually];
        }];
        
        PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
        [groupQuery includeKey:@"user_objects"];
        [groupQuery getObjectInBackgroundWithId:[conversation.metadata objectForKey:@"groupId"] block:^(PFObject *group, NSError *error) {
            if (!error) {
                [group incrementKey:@"memberCount" byAmount:@(-1)];
                NSMutableArray *users = group[@"user_objects"];
                for (int i = 0; i < users.count; i++) {
                    PFUser *user = users[i];
                    if ([user.objectId isEqualToString:currentUser.objectId]) {
                        [users removeObject:user];
                        break;
                    }
                }
                group[@"user_objects"] = users;
                [group saveEventually];
            }
        }];
        
        [conversation removeParticipants:[NSSet setWithArray:[NSArray arrayWithObject:currentUser[@"FBObjectID"]]] error:&error];
    
    } else if (deletionMode == 2 /* LYRDeletionModeAllParticipants*/) {

        PFObject *group = [PFObject objectWithoutDataWithClassName:@"Group" objectId:[conversation.metadata objectForKey:@"groupId"]];
        [group deleteEventually];
    }
    
    [self.tableView reloadData];

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

-(BOOL)doesString:(NSString *)first contain:(NSString*)other {
    NSRange range = [first rangeOfString:other];
    return range.length != 0;
}

#pragma mark - ATLConversationListViewControllerDataSource Methods

- (NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController titleForConversation:(LYRConversation *)conversation
{
    if (noConvosView) {
        [UIView animateWithDuration:0.3 animations:^{
            noConvosView.alpha = 0;
        } completion:^(BOOL finished) {
            [noConvosView removeFromSuperview];
        }];
    }
    
    NSString *title = [conversation.metadata valueForKey:@"title"];
    if ((title != nil) && ![title isEqualToString:@"_indy_"]){
        
        //if (title containsString:<#(NSString *)#>)
        PFObject *group = [groupDict objectForKey:[conversation.metadata valueForKey:@"groupId"]];
        if (group != nil && [group[@"memberCount"] intValue] == 2 && group[@"isDefaultName"]) {
            title = [title stringByReplacingOccurrencesOfString:[PFUser currentUser][@"firstName"] withString:@""];
            title = [title stringByReplacingOccurrencesOfString:@"and" withString:@""];
            title = [title stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        
        return title;
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    //[query includeKey:@"user_objects"];
    [query fromLocalDatastore];
    PFObject *ob = [query getObjectWithId:[conversation.metadata valueForKey:@"groupId"]];
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

    if (ob != nil) [groupDict setObject:ob forKey:[conversation.metadata valueForKey:@"groupId"]];
    else { ob = [PFObject objectWithoutDataWithClassName:@"Group" objectId:[conversation.metadata valueForKey:@"groupId"]];
        [ob fetchIfNeeded];
        [groupDict setObject:ob forKey:[conversation.metadata valueForKey:@"groupId"]];
        [ob pinInBackground];
    }
    //NSArray *array = ob[@"user_objects"];
    //NSLog(@"%lu", array.count);
    
    return ob;
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

-(void)showNoConvosView {
    
    if (!noConvosView) {
    
        noConvosView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 320, 519-64)];
        
        noConvosView.backgroundColor = [UIColor clearColor];
        
        UIImageView *imv = [[UIImageView alloc] initWithFrame:noConvosView.bounds];
        imv.image = [UIImage imageNamed:@"Group Screenshot"];
        [noConvosView addSubview:imv];
        
        FXBlurView *blurEffectView = [[FXBlurView alloc] initWithFrame:noConvosView.bounds];
        blurEffectView.tintColor = [UIColor blackColor];
        blurEffectView.tag = 77;
        blurEffectView.blurRadius = 13;
        blurEffectView.dynamic = NO;
        
        [noConvosView addSubview:blurEffectView];
        //self.tableView.scrollEnabled = NO;
        
        UILabel *messageLabel = [[UILabel alloc] init];
        [messageLabel setText:[NSString stringWithFormat:@"Events are better with friends. Create a group to make it happen!"]];
        [messageLabel setFont:[UIFont fontWithName:@"OpenSans" size:22.0]];
        messageLabel.textColor = [UIColor blackColor];
        
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        [messageLabel setFrame:CGRectMake(40, 120, 240, 150)];
        messageLabel.numberOfLines = 0;
        
        [blurEffectView addSubview:messageLabel];
        
        UIButton *createButton = [[UIButton alloc] initWithFrame:CGRectMake(56, 360, 208, 50)];
        createButton.tag = 3;
        UIColor *hapBlue = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0];
        [createButton setTitle:@"CREATE GROUP" forState:UIControlStateNormal];
        [createButton setTitleColor:hapBlue forState:UIControlStateNormal];
        [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [createButton setBackgroundColor:[UIColor whiteColor]];
        
        createButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
        
        createButton.layer.masksToBounds = YES;
        createButton.layer.borderColor = hapBlue.CGColor;
        createButton.layer.borderWidth = 1.5;
        createButton.layer.cornerRadius = 50/2;
        
        [createButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
        [createButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
        [createButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragExit];
        //[createButton setImage:[UIImage imageNamed:@"Facebook Login"] forState:UIControlStateNormal];
        [createButton addTarget:self action:@selector(createGroup:) forControlEvents:UIControlEventTouchUpInside];
        [noConvosView addSubview:createButton];
        
        noConvosView.tag = 765;
        
        [self.navigationController.view addSubview:noConvosView];
        
    }
}

-(void)buttonNormal:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setBackgroundColor:[UIColor whiteColor]];
}

-(void)buttonHighlight:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setBackgroundColor:[UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0]];
}

-(void)createGroup:(id)sender {
    
    NSLog(@"Create new group");
    [self performSegueWithIdentifier:@"createGroup" sender:self];
    
}

-(void)showBoom {
    
    NSLog(@"Boom");
    
    [noConvosView removeFromSuperview];
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -66)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
            [SVProgressHUD showSuccessWithStatus:@"Boom"];
            [SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
        });
    });
    
    [self.tableView reloadData];

    
}

-(void)showError:(NSString *)message {
    
}


-(NSString *)conversationListViewController:(ATLConversationListViewController *)conversationListViewController textForButtonWithDeletionMode:(LYRDeletionMode)deletionMode {
    
    return @"Delete Group";
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
        
        if (vc.group.isDataAvailable) {
            
            vc.userDicts = vc.group[@"user_dicts"];

        }
        
        vc.loadTopView = YES;

        if (!vc.group) {
            
            NSLog(@"Group hasn't loaded yet. Load in next VC");
        }
        
        //vc.groupName = @"Test";
    } else if ([segue.identifier isEqualToString:@"createGroup"]) {
        
        InviteHomiesToGroup *vc = (InviteHomiesToGroup *)[[segue destinationViewController] topViewController];

        vc.delegate = self;

    }
    
}


@end
