//
//  TimelineCell.h
//  Happening
//
//  Created by Max on 7/31/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface TimelineCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imv;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (strong, nonatomic) IBOutlet UIView *imageContainerView;

-(void)setImageForType:(NSString *)type;
-(void)formatCellForObject:(PFObject *)object;

@end
