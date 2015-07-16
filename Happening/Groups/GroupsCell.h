//
//  GroupsCell.h
//  Happening
//
//  Created by Max on 6/2/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *membersLabel;

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (strong, nonatomic) IBOutlet UIView *checkView;
@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;

@property (assign) NSIndexPath *indexPath;

@end
