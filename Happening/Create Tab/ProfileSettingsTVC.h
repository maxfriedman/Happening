//
//  ProfileSettingsTVC.h
//  Happening
//
//  Created by Max on 3/19/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileTVC.h"

@interface ProfileSettingsTVC : UITableViewController

@property (strong, nonatomic) IBOutlet UIView *bottomView;

@property (strong, nonatomic) ProfileTVC *profileVC;

@end


@interface ProfActivityProvider : UIActivityItemProvider <UIActivityItemSource>
@end

@interface ProfActivityIcon : UIActivity
@end

