//
//  CustomAPActivityProvider.h
//  Happening
//
//  Created by Max on 7/9/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "DragViewController.h"
#import <Parse/Parse.h>

@interface CustomAPActivityProvider : UIActivityItemProvider <UIActivityItemSource>

@property (nonatomic, strong) PFObject *eventObject;

@end
