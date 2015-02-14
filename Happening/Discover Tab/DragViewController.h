//
//  ViewController.h
//  Happening
//
//  Created by Max on 9/6/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "dropdownSettingsView.h"

@protocol DragViewControllerDelegate <NSObject>

- (void)swipeRight;
- (void)swipeLeft;

- (void)refreshData;
- (void)setLocationSegue;

@end

@interface DragViewController : UIViewController <UIScrollViewDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate>

- (void)refreshData;
- (void)flipCurrentView;
- (void)tutorialCardTapped:(UIView *)view ;
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;
- (void)shareAction;
- (void)showCreatedByProfile;

@property (weak) id <DragViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@property NSString *eventID;
@property (nonatomic, strong) CLLocation *mapLocation;
@property NSString *eventTitle;
@property NSString *locationTitle;
@property (nonatomic, strong)UIButton* checkButton;
@property (nonatomic, strong)UIButton* xButton;

@property (strong, nonatomic) IBOutlet UIView *cardView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIScrollView *pageScrollView;

@property (assign) BOOL frontViewIsVisible;
@property (assign) BOOL userSwipedFromFlippedView;

-(void)testing;
-(void)stopPanning;

@end

#import "DraggableView.h"
@interface APActivityProvider : UIActivityItemProvider <UIActivityItemSource>
@property (nonatomic, strong)DraggableView *APdragView;
@end

@interface APActivityIcon : UIActivity
@end


