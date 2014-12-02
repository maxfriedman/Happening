//
//  FlippedDVB.h
//  HappeningParse
//
//  Created by Max on 12/1/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DragViewController.h"

@interface FlippedDVB : UIView

@property (nonatomic, weak) DragViewController *viewController;

@property NSString *eventID;

@property (nonatomic, strong) UILabel *eventIDLabel;

@end
