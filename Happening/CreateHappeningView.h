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

@interface CreateHappeningView : UIView

@property (nonatomic, strong) DragViewController *vc;

@property (nonatomic, strong) FastttCamera *fastCamera;

- (void)addDragView;
- (void)animatingDidStop;
- (void)resignAllResponders;

@end
