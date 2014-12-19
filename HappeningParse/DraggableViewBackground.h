//
//  DraggableViewBackground.h
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening, LLC. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DraggableView.h"
#import "DragViewController.h"
#import <EventKit/EventKit.h>


@interface DraggableViewBackground : UIView <DraggableViewDelegate, CLLocationManagerDelegate, DragViewControllerDelegate>

@property (retain, nonatomic) DraggableView *dragView;

@property (nonatomic, weak) DragViewController *myViewController;

//methods called in DraggableView
-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;

-(void)swipeLeft;
-(void)swipeRight;
-(void)swipeDown;

@property (retain,nonatomic)NSMutableArray* exampleCardLabels; //%%% the labels the cards
@property (retain,nonatomic)NSMutableArray* allCards; //%%% the labels the cards

@property (retain,nonatomic)NSMutableArray* titleArray;
@property (retain,nonatomic)NSMutableArray* subtitleArray;
@property (retain,nonatomic)NSMutableArray* locationArray;
@property (retain,nonatomic)NSMutableArray* dateArray;
@property (retain,nonatomic)NSMutableArray* timeArray;
@property (retain,nonatomic)NSMutableArray* hashtagArray;
@property (retain,nonatomic)NSArray* someArray;
@property (retain,nonatomic)NSMutableArray* geoLocArray;
@property (retain,nonatomic)CLLocationManager* locManager;
@property (retain,nonatomic)NSMutableArray* objectIDs;
@property (retain,nonatomic)NSMutableArray* swipesRightArray;
@property (retain,nonatomic)NSMutableArray* swipes;
@property (retain,nonatomic)NSMutableArray* imageArray;
@property (retain,nonatomic)NSMutableArray* createdByArray;

@property (retain, nonatomic)CLLocation *mapLocation;

@property NSInteger storedIndex;

@end
