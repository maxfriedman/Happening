//
//  SettingsTVC.h
//  HappeningParse
//
//  Created by Max on 10/29/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SettingsTVC : UITableViewController

@property (strong, nonatomic) IBOutlet UINavigationItem *doneButton;

@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;

@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;


@end
