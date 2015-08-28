//
//  FBSDKProfilePictureView+Type.h
//  Happening
//
//  Created by Max on 8/10/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilePictureView : UIView

- (instancetype)initWithFrame:(CGRect)frame type:(NSString *)type fbid:(NSString *)fbid;
- (void)addName:(NSString *)name;
- (void)changeCornerImvToType:(NSString *)type;

@property (nonatomic, retain) NSString *parseId;

@property (nonatomic, strong) UIImageView *cornerImv;

@end
