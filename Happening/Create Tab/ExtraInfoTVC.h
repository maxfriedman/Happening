//
//  ExtraInfoTVC.h
//  Happening
//
//  Created by Max on 12/8/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "NewEventFrequencyTVC.h"

@protocol ExtraInfoTVCDelegate

-(void)eventRepeats:(int)repeats url:(NSString *)url description:(NSString *)desc email:(NSString *)email frequency:(int)freq;

@end

@interface ExtraInfoTVC : UITableViewController <UITextViewDelegate, NewEventFrequencyTVCDelegate>

@property (nonatomic, weak) id<ExtraInfoTVCDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextField *urlField;

@property (strong, nonatomic) IBOutlet UITextView *descriptionScrollField;

@property (strong, nonatomic) PFObject *passedEvent;

@property (strong, nonatomic) IBOutlet UITextField *nameField;

@property (strong, nonatomic) IBOutlet UITextField *emailField;

@property (assign) int frequency;
@property (assign) int repeatsInt;
@property (assign) NSString *urlString;
@property (assign) NSString *descriptionString;
@property (assign) NSString *emailString;
@property (assign) NSString *createdByNameString;


@end
