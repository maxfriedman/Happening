//
//  TutorialDragView.h
//  Happening
//
//  Created by Max on 2/1/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DraggableView.h"
#import <EventKit/EventKit.h>
#import "FlippedDVB.h" // imports drag view controller
#import "FXBlurView.h"

@protocol TutorialDragViewDelegate <NSObject>

-(void) refreshData;
-(void) setLocationSegue;
-(void) stopPanning;

@end

@interface TutorialDragView : UIView <CLLocationManagerDelegate, FlippedDVBDelegate>

@property (retain, nonatomic) UIView *dragView;

@property (nonatomic, weak) DragViewController *myViewController;

//methods called in DraggableView
-(void)cardSwipedLeft:(UIView *)card fromFlippedView:(BOOL)flippedBool;
-(void)cardSwipedRight:(UIView *)card fromFlippedView:(BOOL)flippedBool;
- (UIImage *) imageWithView:(UIView *)view;

-(void)swipeLeft;
-(void)swipeRight;
-(void)swipeDown;

-(void) tapButtons;
-(void) nowScrollDown;

@property (weak) id <TutorialDragViewDelegate> delegate;

@property (retain,nonatomic)NSMutableArray* exampleCardLabels; //%%% the labels the cards
@property (retain,nonatomic)NSMutableArray* allCards; //%%% the labels the cards

@property (retain,nonatomic)CLLocationManager* locManager;

@property (retain,nonatomic)NSArray* imageArray;

@property (retain, nonatomic)FXBlurView *blurView;

@property (nonatomic, assign) BOOL allowCardExpand;
@property (nonatomic, assign) BOOL cardExpanded;
@property (nonatomic, assign) BOOL allowCardSwipe;


-(void)cardExpanded:(BOOL)b;

@end
