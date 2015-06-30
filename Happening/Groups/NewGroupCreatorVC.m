//
//  NewGroupCreatorVC.m
//  Happening
//
//  Created by Max on 6/4/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "NewGroupCreatorVC.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import <Atlas/Atlas.h>
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "CustomConstants.h"

@interface NewGroupCreatorVC ()

@property (strong, nonatomic) IBOutlet UIView *snapshotView;

@end

@implementation NewGroupCreatorVC

@synthesize avatarContainerView, bigProfPicView, smallTopProfPicView,smallBottomProfPicView, eventId, userIdArray, numberLabel, textField, createButton, memCount, snapshotView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    avatarContainerView.layer.cornerRadius = 90;
    avatarContainerView.layer.masksToBounds = YES;
    avatarContainerView.layer.borderWidth = 2.0;
    avatarContainerView.layer.borderColor = [UIColor clearColor].CGColor;

    bigProfPicView.profileID = userIdArray[0];
    
    smallBottomProfPicView.profileID = userIdArray[1];
    
    smallTopProfPicView.profileID = userIdArray[2];
    
    [avatarContainerView sendSubviewToBack:smallBottomProfPicView];
    [avatarContainerView sendSubviewToBack:smallTopProfPicView];
    [avatarContainerView sendSubviewToBack:bigProfPicView];
    
    numberLabel.text = [NSString stringWithFormat:@"%d", memCount];
    numberLabel.layer.cornerRadius = 35;
    numberLabel.layer.masksToBounds = YES;
    numberLabel.backgroundColor = [UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:0.9];
    createButton.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [textField becomeFirstResponder];
}

- (IBAction)textFieldChanged:(UITextField *)sender {
    
    if ([textField.text isEqualToString:@""]) {
        createButton.tintColor = [UIColor lightTextColor];
        createButton.style = UIBarButtonItemStylePlain;
        createButton.enabled = NO;
    } else {
        createButton.tintColor = [UIColor whiteColor];
        createButton.style = UIBarButtonItemStyleDone;
        createButton.enabled = YES;
    }
}

- (IBAction)createButtonTapped:(id)sender {
    [self createGroup];
}

- (void)createGroup {
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD show];
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSLog(@"%@", userIdArray);
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"FBObjectID" containedIn:userIdArray];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
        
        if (!error) {
            
            PFObject *group = [PFObject objectWithClassName:@"Group"];
            group[@"user_objects"] = users;
            group[@"name"] = textField.text;
            group[@"memberCount"] = [NSNumber numberWithInt:memCount];
            
            UIImage *avatarImage = [NewGroupCreatorVC imageWithView:snapshotView];
            NSData *imageData = UIImagePNGRepresentation(avatarImage);
            PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
            group[@"avatar"] = imageFile;
            
            [group saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                
                if (success) {
                    
                    PFObject *groupEvent = [PFObject objectWithClassName:@"Group_Event"];
                    groupEvent[@"EventID"] = self.eventId;
                    groupEvent[@"GroupID"] = group.objectId;
                    groupEvent[@"invitedByName"] = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstName"], currentUser[@"lastName"]];
                    groupEvent[@"invitedByID"] = currentUser.objectId;
                    groupEvent[@"users_going"] = [NSArray arrayWithObject:currentUser];
                    [groupEvent saveInBackground];
                
                    
                    NSString *pushMessage = @"";
                    if (memCount == 3) {
                        pushMessage = [NSString stringWithFormat:@"%@ %@ added you and one other to the group \"%@\" and invited you both to an event - check it out!", currentUser[@"firstName"], currentUser[@"lastName"], group[@"name"]];
                    } else {
                        pushMessage = [NSString stringWithFormat:@"%@ %@ added you and %d others to the group \"%@\" and invited you all to an event - check it out!", currentUser[@"firstName"], currentUser[@"lastName"],  memCount - 2, group[@"name"]];
                    }
                    
                    /*
                    PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
                    notification[@"Type"] = @"group";
                    notification[@"Subtype"] = @"new_group";
                    notification[@"EventID"] = self.eventId;
                    notification[@"UserID"] = currentUser.objectId;  // THIS IS THE DIFFERENCE
                    notification[@"GroupID"] = group.objectId;
                    notification[@"InviterID"] = currentUser.objectId;
                    notification[@"Seen"] = @NO;
                    notification[@"Message"] = pushMessage;
                    //notification[@"AllUserObjects"] = users;
                    [notification saveInBackground];
                    */
                    
                    PFObject *groupUser = [PFObject objectWithClassName:@"Group_User"];
                    groupUser[@"user_id"] = currentUser.objectId;
                    groupUser[@"group_id"] = group.objectId;
                    [groupUser saveInBackground];
                    
                    for (PFObject *user in users) {
                        
                        if (![user.objectId isEqualToString:currentUser.objectId]) {
                        
                            PFObject *groupUser = [PFObject objectWithClassName:@"Group_User"];
                            groupUser[@"user_id"] = user.objectId;
                            groupUser[@"group_id"] = group.objectId;
                            [groupUser saveInBackground];
                            
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
                            
                            /*
                            PFQuery *pushQuery = [PFInstallation query];
                            [pushQuery whereKey:@"userID" equalTo:user.objectId];
                            
                            // Send push notification to query
                            PFPush *push = [[PFPush alloc] init];
                            [push setQuery:pushQuery]; // Set our Installation query
                            
                            NSDictionary *data = @{
                                                   @"alert" : pushMessage,
                                                   @"badge" : @"Increment",
                                                   @"eventID" : self.eventId,
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
                            
                            
                            // %%%%%%%%%%%%%%%%%% SAVE NOTIFICATIONS DATA %%%%%%%%%%%%%%%%%%
                            
                            PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
                            notification[@"Type"] = @"group";
                            notification[@"Subtype"] = @"new_group";
                            notification[@"EventID"] = self.eventId;
                            notification[@"UserID"] = user.objectId;
                            notification[@"GroupID"] = group.objectId;
                            notification[@"InviterID"] = currentUser.objectId;
                            notification[@"Seen"] = @NO;
                            notification[@"Message"] = pushMessage;
                            //notification[@"AllUserObjects"] = users;
                            
                            [notification saveInBackground];
                            */
                        }
                    }
                
                    [self setupConversationWithMessage:[NSString stringWithFormat:@"%@ %@ created \"%@\" and invited the group to an event.", currentUser[@"firstName"], currentUser[@"lastName"], group[@"name"]] forGroup:group];
                
                
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                        [SVProgressHUD showSuccessWithStatus:@"Boom"];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }];
                
                } else {
                    [SVProgressHUD showErrorWithStatus:@"Group creation failed :("];
                }

            }];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Group creation failed :("];
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
        
        NSArray *userObjects = group[@"user_objects"];
        NSMutableArray *idArray = [NSMutableArray new];
        for (PFUser *user in userObjects) {
            [idArray addObject:user.objectId];
        }
        
        conversation = [appDelegate.layerClient newConversationWithParticipants:[NSSet setWithArray:idArray] options:nil error:&error];
        [conversation setValue:group[@"name"] forMetadataAtKeyPath:@"title"];
        [conversation setValue:group.objectId forMetadataAtKeyPath:@"groupId"];
        
        group[@"chatId"] = conversation.identifier.absoluteString;
        [group saveInBackground];
        
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
    float actualLineSize = [messageText boundingRectWithSize:CGSizeMake(280, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:10.0]}
                                                     context:nil].size.height;
    NSDictionary *cellInfoDictionary = @{@"height": [NSString stringWithFormat:@"%f", actualLineSize]};
    NSData *cellInfoDictionaryJSON = [NSJSONSerialization dataWithJSONObject:cellInfoDictionary options:
                                            NSJSONWritingPrettyPrinted error:&JSONSerializerError];
    LYRMessagePart *cellInfoMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemCellInfo data:cellInfoDictionaryJSON];
    // Add message to ordered set.  This ordered set messages will get sent to the participants
    LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart,cellInfoMessagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:&error];
    // Sends the specified message
    
    BOOL success = [conversation sendMessage:message error:&error];
    if (success) {
        NSLog(@"Message queued to be sent: %@", message);
    } else {
        NSLog(@"Message send failed: %@", error);
        
        [self dismissViewControllerAnimated:YES completion:^{
            [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    
    
    /* %%%%%%%%%%%%%%% Embedded RSVP Invite %%%%%%%%%%%%%%%%%% */
    NSDictionary *dataDictionary2 = @{@"message":messageText,
                                      @"eventId":self.eventId,
                                      @"groupId":group.objectId,
                                      };
    NSError *JSONSerializerError2;
    NSData *dataDictionaryJSON2 = [NSJSONSerialization dataWithJSONObject:dataDictionary2 options:NSJSONWritingPrettyPrinted error:&JSONSerializerError2];
    LYRMessagePart *dataMessagePart2 = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeCustomObject data:dataDictionaryJSON2];
    // Create messagepart with info about cell
    NSDictionary *cellInfoDictionary2 = @{@"height":@"180"};
    NSData *cellInfoDictionaryJSON2 = [NSJSONSerialization dataWithJSONObject:cellInfoDictionary2 options:NSJSONWritingPrettyPrinted error:&JSONSerializerError2];
    LYRMessagePart *cellInfoMessagePart2 = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeCustomCellInfo data:cellInfoDictionaryJSON2];
    // Add message to ordered set.  This ordered set messages will get sent to the participants
    LYRMessage *message2 = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart2,cellInfoMessagePart2] options:nil error:&error];
    
    // Sends the specified message
    NSLog(@"%@", conversation);
    BOOL success2 = [conversation sendMessage:message2 error:&error];
    if (success2) {
        NSLog(@"Message queued to be sent: %@", message);
    } else {
        NSLog(@"Message send failed: %@", error);
        
        [self dismissViewControllerAnimated:YES completion:^{
            [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
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
