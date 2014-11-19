//
//  ViewController.h
//  HappeningParse
//
//  Created by Max on 9/6/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsTVC.h"

@interface ViewController : UIViewController <SettingsTVCDelegate>

-(BOOL)didPreferencesChange;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end

@interface APActivityProvider : UIActivityItemProvider <UIActivityItemSource>
@end

@interface APActivityIcon : UIActivity
@end


