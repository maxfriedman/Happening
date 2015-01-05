//
//  FlippedDVB.h
//  Happening
//
//  Created by Max on 12/1/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DragViewController.h"

@protocol FlippedDVBDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card fromFlippedView:(BOOL)flippedBool;
-(void)cardSwipedRight:(UIView *)card fromFlippedView:(BOOL)flippedBool;
-(void)checkEventStoreAccessForCalendar;
-(void)addLabels;

@end

@interface FlippedDVB : UIView <MKMapViewDelegate, MKAnnotation>

-(void)addLabels;
-(void)removeLabels;

@property (weak) id <FlippedDVBDelegate> delegate;

@property (nonatomic, weak) DragViewController *viewController;

@property NSString *eventID;
@property NSString *eventTitle;
@property NSString *eventLocationTitle;
@property (nonatomic, strong) CLLocation *mapLocation;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic)CGPoint originalPoint;
@property (nonatomic,strong)OverlayView* overlayView;

@property (nonatomic, strong)DraggableView *dragView;

@property BOOL userSwipedFromFlippedView;

@property (assign)int actionMargin;
@property (assign)int swipeDownMargin;

@end
