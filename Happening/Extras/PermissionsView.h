//
//  PermissionsView.h
//  Happening
//
//  Created by Max on 7/21/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PermissionsViewDelegate <NSObject>

-(void)moveOn;

@end

@interface PermissionsView : UIView

@property (weak) id <PermissionsViewDelegate> delegate;

@end
