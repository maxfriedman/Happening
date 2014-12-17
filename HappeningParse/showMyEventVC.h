//
//  showMyEventVC.h
//  HappeningParse
//
//  Created by Max on 12/2/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditEventTVC.h"

@interface showMyEventVC : UIViewController

@property (assign) NSString *eventID;

@property (strong, nonatomic) IBOutlet UILabel *eventIDLabel;

@end
