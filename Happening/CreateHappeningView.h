//
//  CreateHappeningView.h
//  Happening
//
//  Created by Max on 8/2/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FastttCamera.h>
#import "DragViewController.h"
#import "InviteFromCreateView.h"

@protocol CreateHappeningViewDelegate <NSObject>

- (void)inviteFromCreateViewTapped;

@end

@interface CreateHappeningView : UIView <InviteFromCreateViewDelegate>

@property (weak) id <CreateHappeningViewDelegate> delegate;

@property (nonatomic, strong) DragViewController *vc;

@property (nonatomic, strong) FastttCamera *fastCamera;

- (void)addDragView;
- (void)animatingDidStop;
- (void)resignAllResponders;

@end
