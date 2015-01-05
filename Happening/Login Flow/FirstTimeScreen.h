//
//  FirstTimeScreen.h
//  HappeningParse
//
//  Created by Max on 11/5/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface FirstTimeScreen : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@property (strong, nonatomic) IBOutlet UIButton *startWalkthrough;

@end
