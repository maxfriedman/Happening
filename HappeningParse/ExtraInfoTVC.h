//
//  ExtraInfoTVC.h
//  HappeningParse
//
//  Created by Max on 12/8/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ExtraInfoTVC : UITableViewController <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *urlField;

@property (strong, nonatomic) IBOutlet UITextView *descriptionScrollField;

@property (strong, nonatomic) PFObject *passedEvent;

@property (strong, nonatomic) IBOutlet UITextField *nameField;

@property (strong, nonatomic) IBOutlet UITextField *emailField;

@end
