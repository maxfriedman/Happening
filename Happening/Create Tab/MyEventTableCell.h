//
//  MyEventTableCell.h
//  Happening
//
//  Created by Max on 12/19/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyEventTableCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *locLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *distance;

@property (strong, nonatomic) NSString *eventID;

- (void)setupCell;

@end
