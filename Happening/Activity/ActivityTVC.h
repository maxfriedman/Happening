//
//  ActivityVC.h
//  Happening
//
//  Created by Max on 7/19/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ActivityTVC : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *meButton;
@property (strong, nonatomic) IBOutlet UIButton *friendsButton;
@property (strong, nonatomic) IBOutlet UIView *sliderView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

-(void)toTop;

@end
