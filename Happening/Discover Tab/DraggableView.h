//
//  DraggableView.h
//  Happening
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayView.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>
#import "MFActivityIndicatorView.h"
#import <MapKit/MapKit.h>
#import <Button/Button.h>

@protocol DraggableViewDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card fromExpandedView:(BOOL)expandedBool;
-(void)cardSwipedRight:(UIView *)card fromExpandedView:(BOOL)expandedBool isGoing:(BOOL)isGoing;
-(void)checkEventStoreAccessForCalendar;

- (UIImage *) imageWithView:(UIView *)view;

-(void)afterSwipeAction;

-(void)shareButtonTap:(id)sender;
-(void)moreButtonTap;
-(void)createdByTap;
-(void)inviteButtonTap;
-(void)mapViewTap;
-(void)ticketsButtonTap:(id)sender;
-(void)friendProfileTap:(id)sender;

@end

@interface DraggableView : UIView

@property (weak) id <DraggableViewDelegate> delegate;

@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic)CGPoint originalPoint;
@property (nonatomic,strong)OverlayView* overlayView;

@property (nonatomic,strong)UILabel* title;
@property (nonatomic,strong)UILabel* subtitle;
@property (nonatomic,strong)UILabel* location;
@property (nonatomic,strong)UILabel* date;
@property (nonatomic,strong)UILabel* hashtag;
@property (nonatomic,strong)NSString* objectID;
@property (nonatomic,strong)UILabel* createdBy;
@property (nonatomic,strong)UILabel* transpBackground;
@property (nonatomic,strong)UIImageView* eventImage;
@property (nonatomic,strong)UILabel* geoLoc;
@property (nonatomic, strong)PFGeoPoint *geoPoint;
@property (nonatomic,strong)UILabel* swipesRight;
@property (nonatomic,strong)UILabel* friendsInterested;
@property (nonatomic,strong)UIImageView* friendArrow;

@property (nonatomic,strong)UIImageView* locImage;
@property (nonatomic,strong)UIImageView* userImage;

@property (nonatomic, strong)EKEventStore *eventStore;

@property (nonatomic, strong)UIImageView *cardBackground;
@property (nonatomic, strong)UIVisualEffectView *blurEffectView;

@property (nonatomic, strong)UIButton *shareButton;
@property (nonatomic, strong)UIButton *moreButton;

@property (nonatomic, strong)UIView *cardView;

@property (nonatomic, strong)UIImageView *calImageView;
@property (nonatomic,strong)UILabel* calDayLabel;
@property (nonatomic,strong)UILabel* calMonthLabel;
@property (nonatomic,strong)UILabel* calDayOfWeekLabel;
@property (nonatomic,strong)UILabel* calTimeLabel;

@property (nonatomic,strong)UILabel* startPriceNumLabel;
@property (nonatomic,strong)UILabel* avePriceNumLabel;

@property (assign) NSString *URL;
@property (assign) NSString *ticketLink;

@property (assign)int actionMargin;
@property (assign)int swipeDownMargin;

@property (nonatomic, strong) NSMutableArray *interestedIds;
@property (nonatomic, strong) NSMutableArray *interestedNames;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) BTNDropinButton *uberBTN;
@property (nonatomic, strong) UIButton *hapLogoButton;
@property (nonatomic, strong) UIScrollView *friendScrollView;

@property (nonatomic, strong) UIButton *notInterestedButton;
@property (nonatomic, strong) UILabel *notInterestedLabel;
@property (nonatomic, strong) UIButton *interestedButton;
@property (nonatomic, strong) UILabel *interestedLabel;
@property (nonatomic, strong) UIButton *goingButton;
@property (nonatomic, strong) UILabel *goingLabel;

@property (strong, nonatomic) UIButton *playPauseButton1;
@property (strong, nonatomic) UIButton *playPauseButton2;
@property (strong, nonatomic) UIImageView *albumCover;
@property (strong, nonatomic) UILabel *musicHeaderLabel;
@property (strong, nonatomic) UILabel *songName;
@property (strong, nonatomic) UILabel *albumNameAndArtist;

@property (strong, nonatomic) UIButton *ticketsButton;

@property (assign) CGFloat extraDescHeight;

@property (assign) BOOL isSwipeable;

@property PFObject *eventObject;

- (void)leftClickAction;
- (void)rightClickAction;
- (BOOL) colorOfPointIsWhite:(CGPoint)point;
- (void)arrangeCornerViews;
- (void)cardExpanded:(BOOL)b;
- (void)loadCardWithData;
- (void)setEditableCard;

@end
