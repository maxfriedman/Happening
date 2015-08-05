//
//  OverlayView.h
//  Happening
//
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger , GGOverlayViewMode) {
    GGOverlayViewModeLeft,
    GGOverlayViewModeRight,
    GGOverlayViewModeDown
};

@interface OverlayView : UIView

@property (nonatomic) GGOverlayViewMode mode;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@property (assign) BOOL forDragView;
@property (assign) BOOL forFlippedDVB;

@property (assign) BOOL isCreateCard;

@end
