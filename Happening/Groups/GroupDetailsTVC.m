//
//  GroupDetailsTVC.m
//  Happening
//
//  Created by Max on 6/15/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupDetailsTVC.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import "CustomConstants.h"
#import "GroupAddFriendsTVC.h"

@interface GroupDetailsTVC () <UIAlertViewDelegate>

@end

@implementation GroupDetailsTVC {
    
    NSMutableArray *namesArray;
    NSMutableArray *picsArray;
}

@synthesize group, groupImageView, groupNameLabel, users;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(groupImageView.frame.origin.x - 2, groupImageView.frame.origin.y - 2, groupImageView.frame.size.width + 4, groupImageView.frame.size.height + 4)];
    borderView.backgroundColor = [UIColor clearColor];
    borderView.layer.cornerRadius = 52;
    borderView.layer.borderColor = [UIColor whiteColor].CGColor;
    borderView.layer.borderWidth = 3.0;
    [self.view addSubview:borderView];
    
    //groupImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    //groupImageView.layer.borderWidth = 3.0f;
    groupImageView.layer.cornerRadius = 50.0f;
    groupImageView.clipsToBounds = YES;
    
    NSString *name = group[@"name"];
    
    if ([name isEqualToString:@"_indy_"]) {
        groupNameLabel.text = self.groupNameString;
    } else {
        groupNameLabel.text = name;
    }
    
    PFFile *file = group[@"avatar"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if (!error)
            groupImageView.image = [UIImage imageWithData:data];
    }];
    
    namesArray = [NSMutableArray new];
    picsArray = [NSMutableArray new];
    for (PFUser *user in users) {
        [namesArray addObject:[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]]];

        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10, 7, 36, 36)];
        profPicView.layer.cornerRadius = 20;
        profPicView.layer.masksToBounds = YES;
        profPicView.profileID = user[@"FBObjectID"];
        profPicView.tag = 9;
        profPicView.accessibilityIdentifier = user.objectId;
        [picsArray addObject:profPicView];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    else if (section == 1)
        return [group[@"memberCount"] integerValue];
    else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"add" forIndexPath:indexPath];
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"peeps" forIndexPath:indexPath];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:5];
        nameLabel.text = namesArray[indexPath.row];
        
        [[cell viewWithTag:9] removeFromSuperview];
        [cell addSubview:[picsArray objectAtIndex:indexPath.row]];
        
        return cell;
        
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leave" forIndexPath:indexPath];
        return cell;
    }
    
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((int)indexPath.section == 0) {
     
        NSLog(@"Add participants selected - show friend picker");
        
    } else if (indexPath.section == 1) {
        
        NSLog(@"User selected - Do nothing");

        
    } else if (indexPath.section == 2) {
        
        NSLog(@"Leave group selected - show alert view");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"This action is permanent, and cannot be undone." delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Leave Group", nil];
        alert.delegate = self;
        [alert show];

    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        NSLog(@"Nevermind");
        
    } else if (buttonIndex == 1) {
        
        NSLog(@"Leave group - Peace!");
        
        PFUser *currentUser = [PFUser currentUser];
        /*
        [self.convo removeParticipants:[NSSet setWithObject:currentUser.objectId] error:nil];
        
        //NSMutableArray *users = group[@"user_objects"];
        
        for (int i = 0; i < users.count; i++) {
            
            PFUser *user = users[i];
            
            if ([user.objectId isEqualToString:currentUser.objectId]) {
                NSLog(@"Made it!");
                [users removeObjectAtIndex:i];
                break;
            }
        }
        
        NSLog(@"users = %@", users);
        
        group[@"user_objects"] = [NSArray arrayWithArray:users];
        [group incrementKey:@"memberCount" byAmount:@(-1)];
        [group saveInBackground];
        
        
        PFQuery *groupUserQuery = [PFQuery queryWithClassName:@"Group_User"];
        [groupUserQuery whereKey:@"user_id" equalTo:currentUser.objectId];
        [groupUserQuery whereKey:@"group_id" equalTo:group.objectId];
        
        [groupUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
           
            [object deleteInBackground];
            
        }]; */
        
        [self sendMessage:[NSString stringWithFormat:@"%@ %@ has left the group.", currentUser[@"firstName"], currentUser[@"lastName"]] type:@"leave"];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] animated:YES];
    
}

- (void)sendMessage:(NSString *)messageText type:(NSString *)type {
    
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //Send message w data
    NSDictionary *dataDictionary = @{@"message":messageText,
                                     @"type":type,
                                     @"groupId":group.objectId,
                                     };
    NSError *JSONSerializerError;
    NSData *dataDictionaryJSON = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
    LYRMessagePart *dataMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemObject data:dataDictionaryJSON];
    // Create messagepart with info about cell
    float actualLineSize = [messageText boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:10.0]}
                                                          context:nil].size.height;
    NSDictionary *cellInfoDictionary = @{@"height": [NSString stringWithFormat:@"%f", actualLineSize]};
    NSData *cellInfoDictionaryJSON = [NSJSONSerialization dataWithJSONObject:cellInfoDictionary options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
    LYRMessagePart *cellInfoMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemCellInfo data:cellInfoDictionaryJSON];
    // Add message to ordered set.  This ordered set messages will get sent to the participants
    NSError *error = nil;
    LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart,cellInfoMessagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:&error];
    
    // Creates and returns a new message object with the given conversation and array of message parts
    //LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[messagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:nil];
    
    // Sends the specified message
    BOOL success = [self.convo sendMessage:message error:&error];
    if (success) {
        NSLog(@"Message queued to be sent: %@", message);
    } else {
        NSLog(@"Message send failed: %@", error);
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    
    if ([segue.identifier isEqualToString:@"toAddFriends"]) {
        
        NSLog(@"%@", group);
        GroupAddFriendsTVC *vc = (GroupAddFriendsTVC *)[[segue destinationViewController] topViewController];
        vc.convo = self.convo;
        vc.group = self.group;

    }
    
}


@end
