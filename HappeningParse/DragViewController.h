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

@protocol DragViewControllerDelegate <NSObject>

- (void)swipeRight;
- (void)swipeLeft;

@end

@interface DragViewController : UIViewController 

- (void)flipCurrentView;

@property (weak) id <DragViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property NSString *eventID;
@property (nonatomic, strong) CLLocation *mapLocation;
@property NSString *eventTitle;
@property NSString *locationTitle;
@property (nonatomic, strong)UIButton* checkButton;
@property (nonatomic, strong)UIButton* xButton;

@end

#import "DraggableView.h"
@interface APActivityProvider : UIActivityItemProvider <UIActivityItemSource>
@property (nonatomic, strong)DraggableView *APdragView;
@end

@interface APActivityIcon : UIActivity
@end


