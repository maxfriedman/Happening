//
//  LoginButton.h
//  Happening
//
//  Created by Max on 7/22/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoginButtonDelegate <NSObject>

-(void)buttonPressStart;
-(void)buttonPressEnd;

-(void)loginSuccessful;
-(void)loginUnsuccessful;

@end

@interface LoginButton : UIButton

@property (assign) BOOL wasUserAnonymous;
@property (weak) id <LoginButtonDelegate> delegate;
@property (assign) BOOL userExists;

-(void)setButtonType:(NSString *)type;

@end