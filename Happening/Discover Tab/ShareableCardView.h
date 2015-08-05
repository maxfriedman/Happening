//
//  ShareableCardView.h
//  Happening
//
//  Created by Max on 8/3/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableView.h"

@protocol ShareableCardViewDelegate <NSObject>

- (void)cardImageGenerated:(UIImage *)image;

@end


@interface ShareableCardView : DraggableView

@property (weak) id<ShareableCardViewDelegate>shareDelegate;

@property (nonatomic, strong) UIImage *cachedImage;

- (void)zoomCard;

@end
