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
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "DraggableView.h"

@protocol DragViewControllerDelegate <NSObject>

- (void)swipeRight;
- (void)swipeLeft;

- (void)refreshData;
- (void)setLocationSegue;

- (void)dropdownPressedFromTut:(BOOL)var;
- (void)dropdownPressed;

@end

@interface DragViewController : UIViewController <UIScrollViewDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, EKEventEditViewDelegate>

- (void)refreshData;
- (void)expandCurrentView;
- (void)dropdownPressed;
- (void)dropdownPressedFromTut:(BOOL)var;
- (void)tutorialCardTapped:(UIView *)view ;
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;
- (void)shareAction:(id)sender;
- (void)ticketsButtonTapped:(id)sender;
- (void)showCreatedByProfile;
- (void)showMoreDetail;
- (void)showEditEventVCWithEvent:(EKEvent *)event eventStore:(EKEventStore *)es;
- (void)updateMainTixButton;
- (void)showFriendProfile:(UITapGestureRecognizer *)gr;
- (void)inviteHomies;
- (void)updateTopLabel;
- (void)swipeDown:(UIView *)card;
- (void)mapViewTap;

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
@property (assign) BOOL userSwipedFromExpandedView;
@property (assign) BOOL dropdownExpanded;
@property (assign) BOOL tutIsShown;
@property (assign) NSString *friendObjectID;


-(void)testing;
-(void)stopPanning;

@end
