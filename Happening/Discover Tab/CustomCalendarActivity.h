//
//  CustomCalendarActivity.h
//  Happening
//
//  Created by Max on 12/18/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <EventKit/EventKit.h>
#import "DraggableView.h"
#import "DragViewController.h"

@interface CustomCalendarActivity : UIActivity

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) DraggableView *draggableView;
@property (nonatomic, strong) PFObject *eventObject;
@property (nonatomic, strong) DragViewController *myViewController;

@end
