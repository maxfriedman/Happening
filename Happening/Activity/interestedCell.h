//
//  interestedCell.h
//  Happening
//
//  Created by Max on 7/20/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface interestedCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventLocLabel;
@property (strong, nonatomic) IBOutlet UILabel *eventDateLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;

@property (strong, nonatomic) IBOutlet UIButton *likeButton;

@property (strong, nonatomic) PFObject *eventObject;

@end
