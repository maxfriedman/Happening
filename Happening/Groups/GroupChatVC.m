//
//  GroupChatVC.m
//  Happening
//
//  Created by Max on 6/9/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupChatVC.h"
#import "AppDelegate.h"
#import "UserManager.h"
#import "InviteCollectionViewCell.h"
#import "SystemCollectionViewCell.h"
#import "ExpandedCardVC.h"
#import <CoreText/CoreText.h>
#import "GroupPageTVC.h"
#import "GroupDetailsTVC.h"

@interface GroupChatVC () <ATLConversationViewControllerDataSource, ATLConversationViewControllerDelegate, LYRQueryControllerDelegate, GroupDetailsTVCDelegate>

@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation GroupChatVC {
    AppDelegate *appDelegate;
    UIButton *middleButton;
}

@synthesize userDicts;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    //self.addressBarController.delegate = self;
    
    self.layerClient.autodownloadMIMETypes = nil;
    
    // Setup the dateformatter used by the dataSource.
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    self.dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.layerClient = appDelegate.layerClient;
    appDelegate.conversationOpen = YES;

    /*
    if (userDicts.count == 2 && [self.groupObject[@"isDefaultImage"] boolValue] == YES) {
        
        //self.title = self.groupObject[@"name"];
        
        UIView *navigationView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.navigationController.navigationBar.frame.size.height)];
        UIButton *middleButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        middleButton.center = navigationView.center;
        middleButton.layer.cornerRadius = 17.5;
        middleButton.layer.masksToBounds = YES;
        
        for (NSDictionary *dict in userDicts) {
            if (![[dict valueForKey:@"parseId"] isEqualToString:[PFUser currentUser].objectId]) {
                
                FBSDKProfilePictureView *ppView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
                ppView.profileID = [dict valueForKey:@"id"];
                [middleButton addSubview:ppView];
            }
            
        }
        
        middleButton.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0];;
        //[middleButton addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
        [navigationView addSubview:middleButton];
        self.navigationItem.titleView = navigationView;
        
    } else {
    
        UIView *navigationView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.navigationController.navigationBar.frame.size.height)];
        //UIButton *middleButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
        UIButton *middleButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 0, 220, 35)];
        middleButton.center = navigationView.center;
        middleButton.layer.cornerRadius = 17.5;
        middleButton.layer.masksToBounds = YES;
     
        PFFile *file = self.groupObject[@"avatar"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [middleButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        }];
        
        [middleButton setTitle:self.groupObject[@"name"] forState:UIControlStateNormal];
        [middleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        middleButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
        
        middleButton.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0];;
        //[middleButton addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
        [navigationView addSubview:middleButton];
        self.navigationItem.titleView = navigationView;
    }*/
    
    UIView *navigationView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.navigationController.navigationBar.frame.size.height)];
    //UIButton *middleButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    
    middleButton = [[UIButton alloc]initWithFrame:CGRectMake(50, 0, 220, 35)];
    middleButton.center = navigationView.center;
    //middleButton.layer.cornerRadius = 17.5;
    //middleButton.layer.masksToBounds = YES;
    /*
     PFFile *file = self.groupObject[@"avatar"];
     [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
     [middleButton setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
     }];*/
    
    [middleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [middleButton setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateHighlighted];
    middleButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17.0];
    
    middleButton.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0];;
    //[middleButton addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
    [navigationView addSubview:middleButton];
    self.navigationItem.titleView = navigationView;
    
    NSString *name = self.groupObject[@"name"];
    
    if (userDicts.count == 2 && [self.groupObject[@"isDefaultName"] boolValue] == YES) {
        
        name = [name stringByReplacingOccurrencesOfString:[PFUser currentUser][@"firstName"] withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@"and" withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
        [middleButton setTitle:name forState:UIControlStateNormal];
    
    } else {
        
        [middleButton setTitle:name forState:UIControlStateNormal];
        //[middleButton setTitle:self.groupObject[@"name"] forState:UIControlStateNormal];

    }
    
    NSDictionary* attributes = @{
                                 NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle],
                                 NSForegroundColorAttributeName: [UIColor whiteColor]
                                 };
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:name attributes:attributes];
    //[middleButton setAttributedTitle:attString forState:UIControlStateNormal];
    
    
    UIBarButtonItem *bb = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"hamburger"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonPressed)];
    self.navigationItem.rightBarButtonItem = bb;
    
    navigationView.userInteractionEnabled = YES;
    
    [middleButton addTarget:self action:@selector(toGroupDetails) forControlEvents:UIControlEventTouchUpInside];
    
    // Register custom cell class for star cell
    [self registerClass:[InviteCollectionViewCell class] forMessageCellWithReuseIdentifier:ATLMIMETypeCustomObjectReuseIdentifier];
    [self registerClass:[SystemCollectionViewCell class] forMessageCellWithReuseIdentifier:ATLMIMETypeSystemObjectReuseIdentifier];
    
    if (self.isModal) {
        
        UIBarButtonItem *x = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"letter x"] style:UIBarButtonItemStylePlain target:self action:@selector(leftButtonPressed)];
        self.navigationItem.leftBarButtonItem = x;
        
    }
    
    /*
    PFQuery *noti = [PFQuery queryWithClassName:@"Notifications"];
    [noti whereKey:@"GroupID" equalTo:@"
    noti[@"UserID"] = userId;
    noti[@"GroupID"] = self.groupObject.objectId;
    noti[@"Type"] = @"group";
    noti[@"Subtype"] = @"chat";
    noti[@"Seen"] = [message.recipientStatusByUserID valueForKey:userId];
    [noti saveInBackground];
    */
    /*
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    //query.predicate = [LYRPredicate predicateWithProperty:@"id" predicateOperator:LYRPredicateOperatorIsEqualTo value:self.groupEventId];
    LYRQueryController *queryController = [appDelegate.layerClient queryControllerWithQuery:query];
    queryController.delegate = self;
    NSError *error;
    BOOL success = [queryController execute:&error];
    if (success) {
        self.conversation = [queryController objectAtIndexPath:0];
        NSLog(@"Query fetched %tu conversation objects", [queryController numberOfObjectsInSection:0]);
        NSLog(@"Query fetched %@ conversation objects", queryController );

    } else {
        NSLog(@"Query failed with error %@", error);
    }  */
    
    
    // Fetches conversation with a specific identifier
    
    
        
    [self configureUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    appDelegate.conversationOpen = NO;
}

- (void)leftButtonPressed {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [appDelegate.mh hideTabBar:NO];
        appDelegate.conversationOpen = NO;
    }];
}

- (void) toGroupDetails {
    
    NSLog(@"Middle button tapped!");
    
    UIStoryboard *storyboard =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GroupDetailsTVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"groupDetails"];
    vc.groupNameString = self.groupObject[@"name"];
    vc.group = self.groupObject;

    NSMutableArray *names = [NSMutableArray new];
    NSMutableArray *ids = [NSMutableArray new];
    NSMutableArray *parseIds = [NSMutableArray new];
    
    for (NSDictionary *dict in userDicts) {
        
        [names addObject:[dict valueForKey:@"name"]];
        [ids addObject:[dict valueForKey:@"id"]];
        [parseIds addObject:[dict valueForKey:@"parseId"]];
        
    }
    vc.fbIds = ids;
    vc.names = names;
    vc.parseIds = parseIds;
    vc.convo = self.conversation;
    vc.delegate = self;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void) groupChanged {
    
    NSString *name = self.groupObject[@"name"];
    [middleButton setTitle:name forState:UIControlStateNormal];

    
}

- (void)rightButtonPressed {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GroupPageTVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupPage"];
    
    vc.conversation = self.conversation;
    NSString *title = [[self.conversation metadata] objectForKey:@"title"];
    if ([title isEqualToString:@"_indy_"]) {
        vc.title = self.groupObject[@"name"];
        vc.showDetails = NO;
    } else {
        vc.title = title;
        vc.showDetails = YES;
    }
    
    vc.group = self.groupObject;
    
    if (vc.group.isDataAvailable) {
        
        vc.userDicts = vc.group[@"user_dicts"];
        
    }
    
    vc.loadTopView = YES;
    
    if (!vc.group) {
        
        NSLog(@"Group hasn't loaded yet. Load in next VC");
    }
    
    if (self.isModal) vc.isModal = YES;
    
    [self.navigationController pushViewController:vc animated:YES];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [appDelegate.mh hideTabBar:YES];
    
}

#pragma mark - UI Configuration methods

- (void)configureUI
{
    [[ATLOutgoingMessageCollectionViewCell appearance] setMessageTextColor:[UIColor whiteColor]];
}

#pragma mark - ATLConversationViewControllerDelegate methods

- (void)conversationViewController:(ATLConversationViewController *)viewController didSendMessage:(LYRMessage *)message
{
    NSLog(@"Message sent!");
    NSLog(@"%@", message);
    NSLog(@"%@", message.recipientStatusByUserID);
    
    PFUser *currentUser = [PFUser currentUser];
    for (NSString *userId in message.recipientStatusByUserID.allKeys) {
        if (![userId isEqualToString:currentUser.objectId]) {
            PFObject *noti = [PFObject objectWithClassName:@"Notifications"];
            noti[@"UserID"] = userId;
            noti[@"GroupID"] = self.groupObject.objectId;
            noti[@"Type"] = @"group";
            noti[@"Subtype"] = @"chat";
            //noti[@"Seen"] =
            //[noti saveInBackground];
        }
    }

}

- (void)conversationViewController:(ATLConversationViewController *)viewController didFailSendingMessage:(LYRMessage *)message error:(NSError *)error
{
    NSLog(@"Message failed to send with error: %@", error);
}

- (void)conversationViewController:(ATLConversationViewController *)viewController didSelectMessage:(LYRMessage *)message
{
    NSLog(@"Message selected");
    LYRMessagePart *part = message.parts[0];
    
    if([part.MIMEType isEqual: ATLMimeTypeCustomObject])
    {
        NSArray *ips = [self.collectionView indexPathsForSelectedItems];
        NSLog(@"%@", ips);
        
        NSIndexPath *ip = ips[0];
        InviteCollectionViewCell *cell = (InviteCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:ip];

        CGPoint buttonPosition = [cell convertPoint:CGPointZero toView:self.collectionView];
        NSLog(@"%f, %f", buttonPosition.x, buttonPosition.y);
        
        NSLog(@"segue: %@", cell.segueType);
        
        if ([cell.segueType isEqualToString:@"event"]) {
            
        } else {
            
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ExpandedCardVC *vc = [storyboard instantiateViewControllerWithIdentifier:@"expandedCard"];
        vc.event = cell.event;
        vc.eventID = cell.event.objectId;
        //vc.distanceString = cell.distanceLabel.text;
        vc.image = cell.eventImageView.image;
        vc.isFromGroup = YES;
        vc.rsvpObject = cell.rsvpObject;
        vc.groupObject = self.groupObject;
        vc.convo = self.conversation;
        vc.groupEventObject = cell.groupEvent;
        vc.fbids = self.fbids;
        [self.navigationController pushViewController:vc animated:YES];
        //[self.navigationController performSegueWithIdentifier:@"toEvent" sender:self];
        //NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];

    } else if ([part.MIMEType isEqual: ATLMimeTypeSystemObject]) { }

}

#pragma mark - ATLConversationViewControllerDataSource methods

- (id<ATLParticipant>)conversationViewController:(ATLConversationViewController *)conversationViewController participantForIdentifier:(NSString *)participantIdentifier
{
    if ([participantIdentifier isEqualToString:[PFUser currentUser].objectId]) return [PFUser currentUser];
    PFUser *user = [[UserManager sharedManager] cachedUserForUserID:participantIdentifier];
    if (!user) {
        [[UserManager sharedManager] queryAndCacheUsersWithIDs:@[participantIdentifier] completion:^(NSArray *participants, NSError *error) {
            if (participants && error == nil) {
                [self.addressBarController reloadView];
                // TODO: Need a good way to refresh all the messages for the refreshed participants...
                [self reloadCellsForMessagesSentByParticipantWithIdentifier:participantIdentifier];
            } else {
                NSLog(@"Error querying for users: %@", error);
            }
        }];
    }
    return user;
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfDate:(NSDate *)date
{

    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor grayColor] };
    return [[NSAttributedString alloc] initWithString:[self.dateFormatter stringFromDate:date] attributes:attributes];
}

- (NSAttributedString *)conversationViewController:(ATLConversationViewController *)conversationViewController attributedStringForDisplayOfRecipientStatus:(NSDictionary *)recipientStatus
{
    if (recipientStatus.count == 0) return nil;
    NSMutableAttributedString *mergedStatuses = [[NSMutableAttributedString alloc] init];
    
    [[recipientStatus allKeys] enumerateObjectsUsingBlock:^(NSString *participant, NSUInteger idx, BOOL *stop) {
        LYRRecipientStatus status = [recipientStatus[participant] unsignedIntegerValue];
        if ([participant isEqualToString:appDelegate.layerClient.authenticatedUserID]) {
            return;
        }
        
        NSString *checkmark = @"✔︎";
        UIColor *textColor = [UIColor lightGrayColor];
        if (status == LYRRecipientStatusSent) {
            textColor = [UIColor lightGrayColor];
        } else if (status == LYRRecipientStatusDelivered) {
            textColor = [UIColor orangeColor];
        } else if (status == LYRRecipientStatusRead) {
            textColor = [UIColor greenColor];
        }
        NSAttributedString *statusString = [[NSAttributedString alloc] initWithString:checkmark attributes:@{NSForegroundColorAttributeName: textColor}];
        [mergedStatuses appendAttributedString:statusString];
    }];
    return mergedStatuses;
}

#pragma mark - ATLAddressBarViewController Delegate methods methods

- (void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController didTapAddContactsButton:(UIButton *)addContactsButton
{
    [[UserManager sharedManager] queryForAllUsersWithCompletion:^(NSArray *users, NSError *error) {
        if (!error) {
 
        } else {
            NSLog(@"Error querying for All Users: %@", error);
        }
    }];
}

-(void)addressBarViewController:(ATLAddressBarViewController *)addressBarViewController searchForParticipantsMatchingText:(NSString *)searchText completion:(void (^)(NSArray *))completion
{
    [[UserManager sharedManager] queryForUserWithName:searchText completion:^(NSArray *participants, NSError *error) {
        if (!error) {
            if (completion) completion(participants);
        } else {
            NSLog(@"Error search for participants: %@", error);
        }
    }];
}

- (NSString *)conversationViewController:(ATLConversationViewController *)viewController reuseIdentifierForMessage:(LYRMessage *)message
{
    LYRMessagePart *part = message.parts[0];
    
    // if message contains the custom mimetype, then return the custom cell reuse identifier
    if([part.MIMEType isEqual: ATLMimeTypeCustomObject])
    {
        return ATLMIMETypeCustomObjectReuseIdentifier;
    } else if ([part.MIMEType isEqual: ATLMimeTypeSystemObject])
    {
        return ATLMIMETypeSystemObjectReuseIdentifier;
    }
    return nil;
}

- (CGFloat)conversationViewController:(ATLConversationViewController *)viewController heightForMessage:(LYRMessage *)message withCellWidth:(CGFloat)cellWidth
{
    
    LYRMessagePart *part = message.parts[0];
    
    // if message contains the custom mimetype, then grab the cell info from the other message part
    if([part.MIMEType isEqual: ATLMimeTypeCustomObject])
    {
        LYRMessagePart *cellMessagePart = message.parts[1];
        NSData *data = cellMessagePart.data;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        
        // Grab the height value from the JSON
        NSString *height = [json objectForKey:@"height"];
        NSInteger heightInt = [height integerValue];
        return heightInt;
        
    } else if ([part.MIMEType isEqual: ATLMimeTypeSystemObject])
    {
        
        LYRMessagePart *cellMessagePart = message.parts[1];
        NSData *data = cellMessagePart.data;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        
        // Grab the height value from the JSON
        
        NSString *text =  [json objectForKey:@"message"];
        NSUInteger actualLineSize = [text boundingRectWithSize:CGSizeMake(270, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:10.0]}
                                                       context:nil].size.height;
        
        /* useful if I ever want to calculate actual # of lines
        NSUInteger singleLineSize = [@"single line" boundingRectWithSize:CGSizeMake(270, CGFLOAT_MAX)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:10.0]}
                                                                 context:nil].size.height;
    
        NSUInteger numberOfLines = actualLineSize / singleLineSize;
        NSLog(@"%lu", numberOfLines);
        */
        
        // Grab the height value from the JSON
        NSString *height = [json objectForKey:@"height"];
        float heightFloat = [height floatValue];
        
        NSLog(@"%f", heightFloat);
        
        return heightFloat + 8;
        
    }
        
        
    return 0;
}



/*
- (void)viewDidLoad {
    [super viewDidLoad];

    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [self sendMessage:@"Testing 1 2 3"];
    
    
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    //query.predicate = [LYRPredicate predicateWithProperty:@"conversation" predicateOperator:LYRPredicateOperatorIsEqualTo value:self.conversation];
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    query.limit = 20;
    query.offset = 0;
    
    NSError *error;
    NSOrderedSet *messages = [appDelegate.layerClient executeQuery:query error:&error];
    if (!error) {
        NSLog(@"%tu messages in conversation", messages.count);
    } else {
        NSLog(@"Query failed with error %@", error);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)sendMessage:(NSString *)messageText{
    // If no conversations exist, create a new conversation object with two participants
    // For the purposes of this Quick Start project, the 3 participants in this conversation are 'Device'  (the authenticated user id), 'Simulator', and 'Dashboard'.
    if (!self.conversation) {
        NSError *error = nil;
        self.conversation = [appDelegate.layerClient newConversationWithParticipants:[NSSet setWithArray:@[ @"Simulator", @"Dashboard" ]] options:nil error:&error];
        if (!self.conversation) {
            NSLog(@"New Conversation creation failed: %@", error);
        }
    }
    
    // Creates a message part with text/plain MIME Type
    LYRMessagePart *messagePart = [LYRMessagePart messagePartWithText:messageText];
    
    // Creates and returns a new message object with the given conversation and array of message parts
    LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[messagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:nil];
    
    // Sends the specified message
    NSError *error;
    BOOL success = [self.conversation sendMessage:message error:&error];
    if (success) {
        NSLog(@"Message queued to be sent: %@", messageText);
    } else {
        NSLog(@"Message send failed: %@", error);
    }
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"event"]) {
        
        NSArray *ips = [self.collectionView indexPathsForSelectedItems];
        NSIndexPath *ip = ips[0];
        InviteCollectionViewCell *cell = (InviteCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:ip];
        
        ExpandedCardVC *vc = (ExpandedCardVC *)[segue destinationViewController];
        vc.event = cell.event;
        vc.eventID = cell.event.objectId;
        //vc.distanceString = cell.distanceLabel.text;
        vc.image = cell.eventImageView.image;
        
    }
}


@end
