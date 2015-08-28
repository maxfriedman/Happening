//
//  InviteCollectionViewCell.h
//  Happening
//
//  Created by Max on 6/16/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Atlas/Atlas.h>
#import <Parse/Parse.h>
#import "CustomConstants.h"

@interface InviteCollectionViewCell : UICollectionViewCell <ATLMessagePresenting>

@property (strong, nonatomic) PFObject *groupEvent;
@property (strong, nonatomic) PFObject *event;
@property (strong, nonatomic) PFObject *rsvpObject;
@property (strong, nonatomic) NSString *segueType;
@property (strong,nonatomic) UIImageView *eventImageView;

@end
