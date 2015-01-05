//
//  EditExtraInfoTVC.h
//  Happening
//
//  Created by Max on 1/3/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol EditExtraInfoTVCDelegate

-(void)setUrl:(NSString *)url description:(NSString *)desc email:(NSString *)email;

@end

@interface EditExtraInfoTVC : UITableViewController <UITextViewDelegate>

@property (nonatomic, weak) id<EditExtraInfoTVCDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextField *urlField;

@property (strong, nonatomic) IBOutlet UITextView *descriptionScrollField;

@property (strong, nonatomic) PFObject *passedEvent;

@property (strong, nonatomic) IBOutlet UITextField *nameField;

@property (strong, nonatomic) IBOutlet UITextField *emailField;

@property (strong, nonatomic) IBOutlet UILabel *repeatsLabel;

//@property (assign) int frequency;

@property (assign) NSString *urlString;
@property (assign) NSString *descString;
@property (assign) NSString *emailString;


@end
