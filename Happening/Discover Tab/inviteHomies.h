//
//  inviteHomies.h
//  Happening
//
//  Created by Max on 5/26/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragViewController.h"

@protocol inviteHomiesDelegate <NSObject>

- (void)showBoom;
- (void)showError:(NSString *)message;

@end


@interface inviteHomies : UITableViewController

@property (weak) id <inviteHomiesDelegate> delegate;

@property (assign) NSString *objectID;
@property (assign) NSString *eventTitle;
@property (assign) NSString *eventLocation;
@property (nonatomic, retain) UIView *namesOnBottomView;
@property PFObject *event;

@property (retain, nonatomic)NSMutableArray *interestedNames;
@property (retain, nonatomic)NSMutableArray *interestedIds;

@end
