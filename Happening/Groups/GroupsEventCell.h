//
//  GroupsEventCell.h
//  Happening
//
//  Created by Max on 6/4/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

@interface GroupsEventCell : UITableViewCell

@property (strong, nonatomic) IBOutlet FXBlurView *blurView;
@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

@end
