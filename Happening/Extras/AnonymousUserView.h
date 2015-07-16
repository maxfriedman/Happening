//
//  AnonymousUserView.h
//  Happening
//
//  Created by Max on 7/9/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AnonymousUserViewDelegate <NSObject>

-(void)facebookSuccessfulSignup;

@end

@interface AnonymousUserView : UIView

@property (weak) id<AnonymousUserViewDelegate> delegate;

-(void)setImage:(UIImage *)image;
-(void)setMessage:(NSString *)message;

@end
