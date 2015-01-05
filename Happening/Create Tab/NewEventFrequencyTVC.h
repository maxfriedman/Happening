//
//  NewEventFrequencyTVC.h
//  Happening
//
//  Created by Max on 1/3/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NewEventFrequencyTVCDelegate

- (void) passFrequencyData:(int)frequency;

@end

@interface NewEventFrequencyTVC : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (assign) int repeats;

@property (assign) int frequencyInt; // TOTAL number of events

@property (nonatomic, weak) id<NewEventFrequencyTVCDelegate> delegate;

@end
