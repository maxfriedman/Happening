//
//  ChecklistModalVC.h
//  Happening
//
//  Created by Max on 7/22/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MHSemiModal.h"
#import <Parse/Parse.h>

@interface ChecklistModalVC : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIButton *checklistButton;


@property PFObject *event;

@end
