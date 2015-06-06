//
//  NewGroupCreatorVC.m
//  Happening
//
//  Created by Max on 6/4/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "NewGroupCreatorVC.h"
#import <Parse/Parse.h>

@interface NewGroupCreatorVC ()

@end

@implementation NewGroupCreatorVC

@synthesize avatarContainerView, bigProfPicView, smallTopProfPicView,smallBottomProfPicView, eventId, userIdArray, numberLabel, textField, createButton, memCount;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    avatarContainerView.layer.cornerRadius = 90;
    avatarContainerView.layer.masksToBounds = YES;
    avatarContainerView.layer.borderWidth = 3.0;
    avatarContainerView.layer.borderColor = [UIColor clearColor].CGColor;

    bigProfPicView.profileID = userIdArray[0];
    
    smallBottomProfPicView.layer.borderWidth = 2.0;
    smallBottomProfPicView.layer.borderColor = [UIColor whiteColor].CGColor;
    smallBottomProfPicView.profileID = userIdArray[1];
    
    smallTopProfPicView.layer.borderWidth = 2.0;
    smallTopProfPicView.layer.borderColor = [UIColor whiteColor].CGColor;
    smallTopProfPicView.profileID = userIdArray[2];

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
    
    PFUser *currentUser = [PFUser currentUser];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"FBObjectID" containedIn:userIdArray];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
        
        if (!error) {
            
            PFObject *group = [PFObject objectWithClassName:@"Group"];
            group[@"user_objects"] = users;
            group[@"name"] = textField.text;
            group[@"memberCount"] = @(users.count + 1);
            [group saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                
                if (success) {
                    
                    PFObject *groupUser = [PFObject objectWithClassName:@"Group_User"];
                    groupUser[@"user_id"] = currentUser.objectId;
                    groupUser[@"group_id"] = group.objectId;
                    [groupUser saveInBackground];
                    
                    NSString *pushMessage = @"";
                    int count = (int)(users.count - 1.0);
                    pushMessage = [NSString stringWithFormat:@"%@ %@ added you and %d others to the group \"%@\" and invited you all to an event - check it out!", currentUser[@"firstName"], currentUser[@"lastName"],  count, group[@"name"]];
                    
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
                    
                    for (PFObject *user in users) {
                        
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
                        notification[@"Subtype"] = @"new_group";
                        notification[@"EventID"] = self.eventId;
                        notification[@"UserID"] = user.objectId;
                        notification[@"GroupID"] = group.objectId;
                        notification[@"InviterID"] = currentUser.objectId;
                        notification[@"Seen"] = @NO;
                        notification[@"Message"] = pushMessage;
                        //notification[@"AllUserObjects"] = users;
                        
                        [notification saveInBackground];
                        
                    }
                }
            }];
            
            [self dismissViewControllerAnimated:YES completion:^{
                //
            }];
        }
    }];

    
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
