//
//  AttendTableCell.h
//  Happening
//
//  Created by Max on 10/8/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FXBlurView.h"

@interface AttendTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *locLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eventImageView;
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UILabel *subtitle;
@property (strong, nonatomic) IBOutlet UILabel *interestedLabel;
@property (strong, nonatomic) NSString *eventID;

@property (strong, nonatomic) PFObject *eventObject;

@property (strong, nonatomic) IBOutlet FXBlurView *blurView;
@property (strong, nonatomic) IBOutlet UIView *lineView;


- (void)setupCell;


@end
