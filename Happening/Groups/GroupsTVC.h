//
//  GroupsTVC.h
//  Happening
//
//  Created by Max on 6/1/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Atlas/Atlas.h>
#import "PFUser+ATLParticipant.h"

@interface GroupsTVC : ATLConversationListViewController

- (void)refreshData;

@end
