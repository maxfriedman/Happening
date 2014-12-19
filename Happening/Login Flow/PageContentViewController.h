//
//  PageContentViewController.h
//  HappeningParse
//
//  Created by Max on 11/5/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;

@end
