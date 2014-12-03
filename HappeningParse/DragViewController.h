//
//  ViewController.h
//  HappeningParse
//
//  Created by Max on 9/6/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface DragViewController : UIViewController 

- (void)flipCurrentView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property NSString *eventID;
@property (nonatomic, strong) CLLocation *mapLocation;
@property NSString *eventTitle;
@property NSString *locationTitle;

@end

@interface APActivityProvider : UIActivityItemProvider <UIActivityItemSource>
@end

@interface APActivityIcon : UIActivity
@end


