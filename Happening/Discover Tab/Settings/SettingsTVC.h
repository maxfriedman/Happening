//
//  SettingsTVC.h
//  Happening
//
//  Created by Max on 10/29/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@protocol SettingsTVCDelegate <NSObject>

-(BOOL)didPreferencesChange;

@end

@interface SettingsTVC : UITableViewController

@property (weak) id <SettingsTVCDelegate> delegate;

@property (strong, nonatomic) IBOutlet UINavigationItem *doneButton;

@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;

@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;

@property (strong, nonatomic) IBOutlet UILabel *locTitle;
@property (strong, nonatomic) IBOutlet UILabel *locSubtitle;

@end
