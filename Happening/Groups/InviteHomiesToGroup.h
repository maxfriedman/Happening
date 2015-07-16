//
//  InviteHomiesToGroup.h
//  Happening
//
//  Created by Max on 7/14/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol InviteHomiesToGroupDelegate <NSObject>

- (void)showBoom;
- (void)showError:(NSString *)message;

@end

@interface InviteHomiesToGroup : UITableViewController

@property (weak) id <InviteHomiesToGroupDelegate> delegate;

@property (nonatomic, retain) UIView *namesOnBottomView;
@property PFObject *event;

@property (retain, nonatomic)NSMutableArray *interestedNames;
@property (retain, nonatomic)NSMutableArray *interestedIds;

@end
