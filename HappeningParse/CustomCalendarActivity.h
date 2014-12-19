//
//  CustomCalendarActivity.h
//  HappeningParse
//
//  Created by Max on 12/18/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <EventKit/EventKit.h>
#import "DraggableView.h"

@interface CustomCalendarActivity : UIActivity

@property (nonatomic, strong) EKEventStore *eventStore;
@property (nonatomic, strong) DraggableView *draggableView;

@end
