//
//  friendJoinedCell.h
//  Happening
//
//  Created by Max on 7/20/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface friendJoinedCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) PFObject *activityObject;

@end
