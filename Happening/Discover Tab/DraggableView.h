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

@protocol DraggableViewDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card fromFlippedView:(BOOL)flippedBool;
-(void)cardSwipedRight:(UIView *)card fromFlippedView:(BOOL)flippedBool;
-(void)checkEventStoreAccessForCalendar;

- (UIImage *) imageWithView:(UIView *)view;

-(void)afterSwipeAction;

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
@property (nonatomic,strong)UILabel* time;
@property (nonatomic,strong)UILabel* hashtag;
@property (nonatomic,strong)NSString* objectID;
@property (nonatomic,strong)UILabel* createdBy;

@property (nonatomic,strong)UILabel* transpBackground;

@property (nonatomic, strong)UIImage* cardPics;

@property (nonatomic,strong)UIImageView* eventImage;

@property (nonatomic,strong)NSDate* eventDate;

@property (nonatomic,strong)UILabel* geoLoc;
@property (nonatomic, strong)PFGeoPoint *geoPoint;

@property (nonatomic,strong)UILabel* swipesRight;
@property (nonatomic,strong)UILabel* friendsInterested;

@property (nonatomic,strong)UIImageView* locImage;
@property (nonatomic,strong)UIImageView* userImage;

@property (nonatomic,strong)MFActivityIndicatorView *activityView;

@property (nonatomic, strong)UIButton* checkButton;
@property (nonatomic, strong)UIButton* xButton;

@property (nonatomic, strong)EKEventStore *eventStore;

@property (nonatomic, strong)UIImageView *cardBackground;
@property (nonatomic, strong)UIImageView *greyLocImageView;

@property (nonatomic, strong)UIVisualEffectView *blurEffectView;

@property (nonatomic, strong)UIView *cardView;

@property (assign)int actionMargin;
@property (assign)int swipeDownMargin;

-(void)leftClickAction;
-(void)rightClickAction;

-(void)cardExpanded:(BOOL)b;

@end
