//
//  GroupChatVC.h
//  Happening
//
//  Created by Max on 6/9/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFUser+ATLParticipant.h"
#import <Parse/Parse.h>

@interface GroupChatVC : ATLConversationViewController

@property (nonatomic) NSArray *usersArray;
@property (assign) NSString *groupEventId;
@property PFObject *groupEventObject;
@property PFObject *groupObject;

@end
