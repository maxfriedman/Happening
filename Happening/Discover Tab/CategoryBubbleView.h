//
//  CategoryBubbleView.h
//  Happening
//
//  Created by Max on 7/8/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryBubbleView : UIView

- (id)initWithText:(NSString *)text type:(NSString *)type;

@property (nonatomic, strong) NSString *bubbleType;
@property (nonatomic, strong) UILabel *textLabel;


@end
