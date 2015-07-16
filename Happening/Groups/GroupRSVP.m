//
//  GroupRSVP.m
//  Happening
//
//  Created by Max on 6/8/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupRSVP.h"
#import <Parse/Parse.h>
#import "inviteHomiesCell.h"
#import "CustomConstants.h"
#import "AppDelegate.h"

@interface GroupRSVP ()

@end

@implementation GroupRSVP {
    
    UIColor *borderColor;
    NSMutableArray *yesImages;
    NSMutableArray *noImages;
    NSMutableArray *maybeImages;
    
    PFUser *currentUser;
    BOOL firstTime;
}

@synthesize myProfPicView, goingButton, notGoingButton, yesUsers, noUsers, maybeUsers, convo, group, titleString;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    firstTime = YES;
    currentUser = [PFUser currentUser];

    borderColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0];
    
    goingButton.layer.masksToBounds = YES;
    goingButton.layer.cornerRadius = 15;
    goingButton.layer.borderColor = borderColor.CGColor;
    goingButton.layer.borderWidth = 1.0;
    goingButton.tag = 0;
    
    notGoingButton.layer.masksToBounds = YES;
    notGoingButton.layer.cornerRadius = 15;
    notGoingButton.layer.borderColor = borderColor.CGColor;
    notGoingButton.layer.borderWidth = 1.0;
    notGoingButton.tag = 0;

    NSLog(@"%@", maybeUsers);
    
    [self loadButtons];
    [self loadPics];
}

- (void)loadPics {
    
    yesImages = [NSMutableArray array];
    noImages = [NSMutableArray array];
    maybeImages = [NSMutableArray array];
    
    for (PFObject *user in yesUsers) {
        
        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
        profPicView.layer.cornerRadius = 15;
        profPicView.layer.masksToBounds = YES;
        profPicView.profileID = user[@"FBObjectID"];
        profPicView.tag = 9;
        profPicView.accessibilityIdentifier = user.objectId;
        [yesImages addObject:profPicView];
    }
    
    for (PFObject *user in noUsers) {
        
        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
        profPicView.layer.cornerRadius = 15;
        profPicView.layer.masksToBounds = YES;
        profPicView.profileID = user[@"FBObjectID"];
        profPicView.tag = 9;
        profPicView.accessibilityIdentifier = user.objectId;
        [noImages addObject:profPicView];
    }
    
    for (PFObject *user in maybeUsers) {
        
        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
        profPicView.layer.cornerRadius = 15;
        profPicView.layer.masksToBounds = YES;
        profPicView.profileID = user[@"FBObjectID"];
        profPicView.tag = 9;
        profPicView.accessibilityIdentifier = user.objectId;
        [maybeImages addObject:profPicView];
    }
    
    [self.tableView reloadData];
}

- (void)loadButtons {
    
    BOOL shouldContinue = YES;
    if (shouldContinue) {
        for (PFObject *user in yesUsers) {
            if ([user.objectId isEqualToString:currentUser.objectId]) {
                goingButton.tag = 0;
                [self goingButtonPressed:nil];
                shouldContinue = NO;
                break;
            }
        }
    }
    
    if (shouldContinue) {
        for (PFObject *user in noUsers) {
            if ([user.objectId isEqualToString:currentUser.objectId]) {
                notGoingButton.tag = 0;
                [self NOTgoingButtonPressed:nil];
                shouldContinue = NO;
                break;
            }
        }
    }
    
    if (shouldContinue) {
        for (PFObject *user in maybeUsers) {
            if ([user.objectId isEqualToString:currentUser.objectId]) {
                goingButton.tag = 0;
                notGoingButton.tag = 0;
                shouldContinue = NO;
                break;
            }
        }
    }
    
    firstTime = NO;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return yesUsers.count;
    } else if (section == 1) {
        return maybeUsers.count;
    } else if (section == 2) {
        return noUsers.count;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    inviteHomiesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friend" forIndexPath:indexPath];
    
    //UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
    //[cell addGestureRecognizer:tap];
    
    PFUser *user = [PFUser user];
    
    if (indexPath.section == 0) {
        
        user = yesUsers[indexPath.row];
        [cell addSubview:yesImages[indexPath.row]];
        
    } else if (indexPath.section == 1) {
        
        user = maybeUsers[indexPath.row];
        [cell addSubview:maybeImages[indexPath.row]];
        
    } else if (indexPath.section == 2) {
        
        user = noUsers[indexPath.row];
        [cell addSubview:noImages[indexPath.row]];

    }
    
    if (![user.objectId isEqualToString:currentUser.objectId])
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
    else
        cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@ (me)", user[@"firstName"], user[@"lastName"]];
    
    /*
    for (UIView *view in cell.subviews) {
        if (view.tag == 9) {
            [view removeFromSuperview];
        }
    }
    
    [cell addSubview:idsArray[indexPath.row]];
    */
     
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    /*
    if (section != 0) {
        return 22;
    }*/
    return 30;
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
    if (section == 0)
        [label setText:@"Going"];
    else if (section == 1)
        [label setText:@"Haven't Decided"];
    else if (section == 2)
        [label setText:@"Not Going"];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 40;
    
}

- (IBAction)goingButtonPressed:(id)sender {
    
    if (goingButton.tag == 0) {
        
        [goingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        goingButton.backgroundColor = borderColor;
        goingButton.tag = 1;
        
        notGoingButton.backgroundColor = [UIColor whiteColor];
        [notGoingButton setTitleColor:borderColor forState:UIControlStateNormal];
        notGoingButton.tag = 0;
        
    } else {
        
        goingButton.backgroundColor = [UIColor whiteColor];
        [goingButton setTitleColor:borderColor forState:UIControlStateNormal];
        goingButton.tag = 0;
        
    }
    
    if (!firstTime) [self reloadRSVPs];
    
}

- (IBAction)NOTgoingButtonPressed:(id)sender {
    
    if (notGoingButton.tag == 0) {
    
        [notGoingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        notGoingButton.backgroundColor = borderColor;
        notGoingButton.tag = 1;
        
        goingButton.backgroundColor = [UIColor whiteColor];
        [goingButton setTitleColor:borderColor forState:UIControlStateNormal];
        goingButton.tag = 0;
        
    } else {
        
        notGoingButton.backgroundColor = [UIColor whiteColor];
        [notGoingButton setTitleColor:borderColor forState:UIControlStateNormal];
        notGoingButton.tag = 0;
        
    }
    
    if (!firstTime) [self reloadRSVPs];
    
}

- (void)reloadRSVPs {
    
    PFObject *rsvpObject = [PFObject objectWithoutDataWithClassName:@"Group_Event" objectId:self.groupEventId];
    
    if (goingButton.tag == 1) {
        
        // ~~~~~~~~~~~ NAMES
        [yesUsers insertObject:currentUser atIndex:0];
        
        for (int i = 0; i < noUsers.count; i++) {
            PFObject *user = noUsers[i];
            if ([user.objectId isEqualToString:currentUser.objectId])
                [noUsers removeObject:user];
        }
        
        for (int i = 0; i < maybeUsers.count; i++) {
            PFObject *user = maybeUsers[i];
            if ([user.objectId isEqualToString:currentUser.objectId])
                [maybeUsers removeObject:user];
        }
        
        // ~~~~~~~~~~ PICS
        for (int i = 0; i < noImages.count; i++) {
            FBSDKProfilePictureView *view = noImages[i];
            if ([view.accessibilityIdentifier isEqualToString:currentUser.objectId]) {
                [yesImages insertObject:view atIndex:0];
                [noImages removeObject:view];
            }
        }
        
        for (int i = 0; i < maybeImages.count; i++) {
            FBSDKProfilePictureView *view = maybeImages[i];
            if ([view.accessibilityIdentifier isEqualToString:currentUser.objectId]) {
                [yesImages insertObject:view atIndex:0];
                [maybeImages removeObject:view];
            }
        }
        
        /* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

    } else if (notGoingButton.tag == 1) {
        
        // ~~~~~~~~~~~ NAMES
        [noUsers insertObject:currentUser atIndex:0];
        
        for (int i = 0; i < yesUsers.count; i++) {
            PFObject *user = yesUsers[i];
            if ([user.objectId isEqualToString:currentUser.objectId])
                [yesUsers removeObject:user];
        }
        
        for (int i = 0; i < maybeUsers.count; i++) {
            PFObject *user = maybeUsers[i];
            if ([user.objectId isEqualToString:currentUser.objectId])
                [maybeUsers removeObject:user];
        }
        
        // ~~~~~~~~~~ PICS
        for (int i = 0; i < yesImages.count; i++) {
            FBSDKProfilePictureView *view = yesImages[i];
            if ([view.accessibilityIdentifier isEqualToString:currentUser.objectId]) {
                [noImages insertObject:view atIndex:0];
                [yesImages removeObject:view];
            }
        }
        
        for (int i = 0; i < maybeImages.count; i++) {
            FBSDKProfilePictureView *view = maybeImages[i];
            if ([view.accessibilityIdentifier isEqualToString:currentUser.objectId]) {
                [noImages insertObject:view atIndex:0];
                [maybeImages removeObject:view];
            }
        }
        
        /* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
        
    } else {
        
        // ~~~~~~~~~~ NAMES
        [maybeUsers insertObject:currentUser atIndex:0];
        
        for (int i = 0; i < noUsers.count; i++) {
            PFObject *user = noUsers[i];
            if ([user.objectId isEqualToString:currentUser.objectId])
                [noUsers removeObject:user];
        }
        
        for (int i = 0; i < yesUsers.count; i++) {
            PFObject *user = yesUsers[i];
            if ([user.objectId isEqualToString:currentUser.objectId])
                [yesUsers removeObject:user];
        }
        
        // ~~~~~~~~~~ PICS
        for (int i = 0; i < noImages.count; i++) {
            FBSDKProfilePictureView *view = noImages[i];
            if ([view.accessibilityIdentifier isEqualToString:currentUser.objectId]) {
                [maybeImages insertObject:view atIndex:0];
                [noImages removeObject:view];
            }
        }
        
        for (int i = 0; i < yesImages.count; i++) {
            FBSDKProfilePictureView *view = yesImages[i];
            if ([view.accessibilityIdentifier isEqualToString:currentUser.objectId]) {
                [maybeImages insertObject:view atIndex:0];
                [yesImages removeObject:view];
            }
        }
        
    }
    
    rsvpObject[@"users_going"] = yesUsers;
    rsvpObject[@"users_not_going"] = noUsers;
    [rsvpObject saveEventually:^(BOOL success, NSError *error){
        
        if (!error && (notGoingButton.tag == 1 || goingButton.tag == 1)) {
            
            NSString *messageText = @"";
            if (goingButton.tag == 1) {
                messageText = [NSString stringWithFormat:@"%@ %@ is going to '%@'", currentUser[@"firstName"], currentUser[@"lastName"], titleString];
            } else if (notGoingButton.tag == 1) {
                messageText = [NSString stringWithFormat:@"%@ %@ is not going to '%@'", currentUser[@"firstName"], currentUser[@"lastName"], titleString];
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
            BOOL success = [convo sendMessage:message error:&error];
            if (success) {
                NSLog(@"Message queued to be sent: %@", message);
            } else {
                NSLog(@"Message send failed: %@", error);
            }
        }
        
    }];

    [self.tableView reloadData];
    //[self loadPics];
}

- (IBAction)xButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
