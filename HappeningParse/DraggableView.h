//
//  DraggableView.h
//  testing swiping
//
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayView.h"
#import <Parse/Parse.h>

@protocol DraggableViewDelegate <NSObject>

-(void)cardSwipedLeft:(UIView *)card;
-(void)cardSwipedRight:(UIView *)card;

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

@property (nonatomic,strong)UILabel* swipesRight;

@property (nonatomic,strong)UIImageView* locImage;
@property (nonatomic,strong)UIImageView* userImage;

@property (nonatomic,strong)UIActivityIndicatorView *activityView;


-(void)leftClickAction;
-(void)rightClickAction;

-(void)tapAction;

@end
