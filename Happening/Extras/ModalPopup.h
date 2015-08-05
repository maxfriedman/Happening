//
//  ModalPopup.h
//  Happening
//
//  Created by Max on 7/30/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MHSemiModal.h"
#import <Parse/Parse.h>

@protocol ModalPopupDelegate <NSObject>

-(void)userFinishedAction:(BOOL)wasSuccessful type:(NSString *)t;

@end

@interface ModalPopup : UIViewController

@property (weak) id<ModalPopupDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *subContainerView;
@property (strong, nonatomic) IBOutlet UIButton *CallToActionButton;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UILabel *subHeaderLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIView *lineView;

@property PFObject *eventObject;
@property (strong, nonatomic) NSString *eventDateString;
@property (strong, nonatomic) UIImage *eventImage;

@property (strong, nonatomic) UIView *cardContainerView;

@property (strong, nonatomic) NSString *type;

@property (assign) BOOL showCalendar;


-(void)userCreatedEvent;

@end
