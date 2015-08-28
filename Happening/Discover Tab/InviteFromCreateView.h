//
//  InviteFromCreateView.h
//  Happening
//
//  Created by Max on 8/25/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Atlas/Atlas.h>
#import <Parse/Parse.h>

@protocol InviteFromCreateViewDelegate <NSObject>

//- (void)showBoom;
//- (void)showError:(NSString *)message;

- (void)didInviteHomiesWithPics:(NSArray *)pics ids:(NSArray *)ids;

@end

@interface InviteFromCreateView : UITableViewController

@property (weak) id <InviteFromCreateViewDelegate> delegate;
@property (nonatomic, retain) UIView *namesOnBottomView;
@property LYRConversation *convo;
@property (nonatomic, retain) NSMutableArray *selectedImagesArray;


@end