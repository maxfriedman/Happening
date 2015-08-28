//
//  DraggableView.m
//  Happening
//
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#define ACTION_MARGIN 60 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle

#define SWIPE_DOWN_MARGIN 100 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called


#import "DraggableView.h"
#import "AppDelegate.h"
#import "UIImage+ImageEffects.h"
#import <CoreText/CoreText.h>
#import "UIButton+Extensions.h"
#import "CategoryBubbleView.h"
#import "CupertinoYankee.h"

@interface DraggableView () <RdioDelegate, RDPlayerDelegate, UIScrollViewDelegate>
@end

@implementation DraggableView {
    CGFloat xFromCenter;
    CGFloat yFromCenter;
    
    RDPlayer *_player;
    Rdio *_rdio;
    
    BOOL _playing;
    BOOL _paused;
    BOOL _loggedIn;
    
    BOOL isEditable;
}

//delegate is instance of ViewController
@synthesize delegate;

@synthesize panGestureRecognizer;
@synthesize overlayView;
@synthesize eventImage;
@synthesize title;
@synthesize subtitle;
@synthesize location;
@synthesize date;
@synthesize hashtag;
@synthesize objectID;
@synthesize createdBy;
@synthesize transpBackground;
@synthesize geoLoc;
@synthesize geoPoint;
@synthesize swipesRight;

@synthesize locImage, userImage, shareButton, extraDescHeight;
@synthesize cardBackground, cardView, calImageView, calDayLabel, calDayOfWeekLabel, calMonthLabel, calTimeLabel, moreButton, startPriceNumLabel, avePriceNumLabel, friendArrow, hapLogoButton, friendScrollView, mapView, goingButton, goingLabel, notInterestedButton, notInterestedLabel, interestedButton, interestedLabel, uberBTN, ticketsButton;
@synthesize playPauseButton1, playPauseButton2, musicHeaderLabel, albumCover, albumNameAndArtist, songName;

@synthesize eventStore, blurEffectView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupView:frame];
        
        self.actionMargin = ACTION_MARGIN;
        self.swipeDownMargin = SWIPE_DOWN_MARGIN;
        self.isSwipeable = YES;
        
        /* %%%%%%%%%%%%%%%% TO BE ASSIGNED %%%%%%%%%%%%%%%%% */
        objectID = [[NSString alloc]init];
        geoPoint = [[PFGeoPoint alloc]init];
        eventStore = [[EKEventStore alloc] init];
        /* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */
        
        eventImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 284, 180)];
        //eventImage.layer.cornerRadius = 10.0;
        eventImage.layer.masksToBounds = YES;
        eventImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
        eventImage.layer.borderWidth = 1.0;
        //eventImage.alpha = 0.7;
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:eventImage.bounds
                                         byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                               cornerRadii:CGSizeMake(10.0, 10.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        eventImage.layer.mask = maskLayer;
        [cardView addSubview:eventImage];
        [eventImage setContentMode:UIViewContentModeScaleAspectFill];
        eventImage.autoresizingMask =
        ( UIViewAutoresizingFlexibleBottomMargin
         | UIViewAutoresizingFlexibleHeight
         | UIViewAutoresizingFlexibleLeftMargin
         | UIViewAutoresizingFlexibleRightMargin
         | UIViewAutoresizingFlexibleTopMargin
         | UIViewAutoresizingFlexibleWidth );
        
        CAGradientLayer *l = [CAGradientLayer layer];
        l.frame = eventImage.bounds;
        l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9] CGColor], nil];
        
        //l.startPoint = CGPointMake(0.0, 0.7f);
        //l.endPoint = CGPointMake(0.0f, 1.0f);
        l.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.2],
                       [NSNumber numberWithFloat:0.5],
                       //[NSNumber numberWithFloat:0.9],
                       [NSNumber numberWithFloat:1.0], nil];
        
        [eventImage.layer insertSublayer:l atIndex:0];
        
        
        title = [[UILabel alloc]initWithFrame:CGRectMake(15, 103, eventImage.frame.size.width - 30, 100)];
        [title setTextAlignment:NSTextAlignmentLeft];
        title.textColor = [UIColor whiteColor];
        title.font = [UIFont fontWithName:@"OpenSans-Bold" size:23];
        title.minimumScaleFactor = 0.6;
        title.adjustsFontSizeToFitWidth = YES;
        [cardView addSubview:title];

        
        subtitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 355 + 31, self.frame.size.width - 30, 33)];
        [subtitle setTextAlignment:NSTextAlignmentLeft];
        //subtitle.textColor = [UIColor darkGrayColor];
        //subtitle.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.50 alpha:1.0];
        subtitle.textColor = [UIColor colorWithRed:136.0/255 green:136.0/255 blue:136.0/255 alpha:1.0];
        subtitle.font = [UIFont fontWithName:@"OpenSans-Light" size:12];
        subtitle.numberOfLines = 0;
        [subtitle setLineBreakMode:NSLineBreakByTruncatingTail];
        subtitle.userInteractionEnabled = YES;
        //subtitle.alpha = 0;
        [cardView addSubview:subtitle];

        
        location = [[UILabel alloc]initWithFrame:CGRectMake(15, 150, self.frame.size.width - 30, 100)];
        [location setTextAlignment:NSTextAlignmentLeft];
        //location.textColor = [UIColor colorWithRed:70/255 green:70/255 blue:70/255 alpha:0.7];
        location.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.27 alpha:1.0];
        location.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15];
        location.minimumScaleFactor = 0.6;
        location.adjustsFontSizeToFitWidth = YES;
        //location.shadowColor = [UIColor blackColor];
        [cardView addSubview:location];

        
        date = [[UILabel alloc]initWithFrame:CGRectMake(15, 172, self.frame.size.width - 100, 100)];
        [date setTextAlignment:NSTextAlignmentLeft];
        date.textColor = [UIColor colorWithHue:196.36/360.0 saturation:1.0 brightness:0.949 alpha:0.95];
        date.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12];
        date.minimumScaleFactor = 0.75;
        date.adjustsFontSizeToFitWidth = YES;
        [cardView addSubview:date];


        hashtag = [[UILabel alloc]initWithFrame:CGRectMake(15, 240, self.frame.size.width - 30, 100)];
        [hashtag setTextAlignment:NSTextAlignmentLeft];
        //hashtag.textColor = [UIColor grayColor];
        hashtag.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.50 alpha:1.0];
        hashtag.font = [UIFont fontWithName:@"OpenSans" size:11.0];
        //hashtag.font = [UIFont boldSystemFontOfSize:15];
        //hashtag.shadowColor = [UIColor blackColor];
        //[cardView addSubview:hashtag];
        
        geoLoc = [[UILabel alloc]initWithFrame:CGRectMake(15, 172, self.frame.size.width - 30, 100)];
        [geoLoc setTextAlignment:NSTextAlignmentRight];
        geoLoc.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.50 alpha:1.0];
        geoLoc.font = [UIFont fontWithName:@"OpenSans" size:12.0];
        //[cardView addSubview:geoLoc];

        
        swipesRight = [[UILabel alloc]initWithFrame:CGRectMake(35, 280, 65, 100)];
        [swipesRight setTextAlignment:NSTextAlignmentRight];
        //swipesRight.textColor = [UIColor grayColor];
        swipesRight.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.50 alpha:1.0];
        swipesRight.font = [UIFont fontWithName:@"OpenSans" size:11.0];
        swipesRight.minimumScaleFactor = 0.6;
        swipesRight.adjustsFontSizeToFitWidth = YES;
        //[cardView addSubview:swipesRight];

        
        createdBy = [[UILabel alloc]initWithFrame:CGRectMake(15, 322, 160, 30)];
        [createdBy setUserInteractionEnabled:YES];
        [createdBy setTextAlignment:NSTextAlignmentLeft];
        createdBy.textColor = [UIColor colorWithHue:0 saturation:0 brightness:.50 alpha:1.0];
        createdBy.font = [UIFont fontWithName:@"OpenSans" size:11.0];
        //[cardView addSubview:createdBy];

        
        shareButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 45, 15, 30, 30)];
        [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
        [shareButton setImage:[UIImage imageNamed:@"share pressed"] forState:UIControlStateHighlighted];
        [shareButton setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
        [cardView addSubview:shareButton];
        
        
        transpBackground = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, eventImage.frame.size.width, 60)];
        transpBackground.backgroundColor = [UIColor redColor];
        transpBackground.backgroundColor = [UIColor colorWithHue:196.36/360.0 saturation:1.0 brightness:0.949 alpha:0.95];
        //transpBackground.backgroundColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:0.7 alpha:0.9];
        //transpBackground. = 0.6
        //[cardView addSubview:transpBackground];

        
        locImage = [[UIImageView alloc]initWithFrame:CGRectMake(219, 215, 12, 15)];
        locImage.image = [UIImage imageNamed:@"locationGrey"];
        //[cardView addSubview:locImage];

        
        userImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 322, 18, 18)];
        userImage.image = [UIImage imageNamed:@"interested_face"];
        //[cardView addSubview:userImage];
        
    
        //overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(self.frame.size.width/2-100, 0, 100, 100)];
        overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(0, 0, eventImage.frame.size.width, 70)];
        overlayView.alpha = 0;
        [cardView addSubview:overlayView];
        

        friendScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15 + 46 + 10, 255, 254 - 46 - 10, 50)];
        friendScrollView.scrollEnabled = YES;
        friendScrollView.showsHorizontalScrollIndicator = NO;
        [cardView addSubview:friendScrollView];
        friendScrollView.tag = 33;
        friendScrollView.delegate = self;
        
        
        hapLogoButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 252, 46, 46)];
        //[hapLogoButton setImage:[UIImage imageNamed:@"AppLogoButton"] forState:UIControlStateNormal];
        
        [hapLogoButton setTitle:@"INVITE" forState:UIControlStateNormal];
        [hapLogoButton setTitleColor:[UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0] forState:UIControlStateNormal];
        [hapLogoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        hapLogoButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:9.0];
        
        hapLogoButton.layer.cornerRadius = 23;
        hapLogoButton.layer.masksToBounds = YES;
        hapLogoButton.layer.borderColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
        hapLogoButton.layer.borderWidth = 1.3;
        hapLogoButton.accessibilityIdentifier = @"hap";
        hapLogoButton.userInteractionEnabled = YES;
        [cardView addSubview:hapLogoButton];
        
        [hapLogoButton addTarget:delegate action:@selector(inviteButtonTap) forControlEvents:UIControlEventTouchUpInside];
        [hapLogoButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
        [hapLogoButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
        [hapLogoButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragExit];
        
        
        friendArrow = [[UIImageView alloc] initWithFrame:CGRectMake(268, 270, 10, 10)];
        friendArrow.image = [UIImage imageNamed:@"rightArrow"];
        friendArrow.alpha = 0;
        [cardView addSubview:friendArrow];
        
        
        /*  Unused, but good code --
         
        calImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 230, 25, 25)];
        calImageView.alpha = 0;
        calImageView.userInteractionEnabled = YES;
        [cardView addSubview:calImageView];
    
        UIColor *grayColor = [UIColor colorWithRed:(70.0/255.0) green:(70.0/255.0) blue:(70.0/255.0) alpha:1.0];
        UIColor *lightGrayColor = [UIColor colorWithRed:(164.0/255.0) green:(163.0/255.0) blue:(163.0/255.0) alpha:1.0];
        
        calMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 230, 20, 20)];
        calMonthLabel.textAlignment = NSTextAlignmentCenter;
        calMonthLabel.font = [UIFont fontWithName:@"OpenSans" size:8.0];
        calMonthLabel.textColor = grayColor;
        calMonthLabel.alpha = 0;
        calMonthLabel.userInteractionEnabled = YES;
        [cardView addSubview:calMonthLabel];
        
        calDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 238, 20, 20)];
        calDayLabel.textAlignment = NSTextAlignmentCenter;
        calDayLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:10.0];
        calDayLabel.textColor = grayColor;
        calDayLabel.minimumScaleFactor = 0.75;
        calDayLabel.adjustsFontSizeToFitWidth = YES;
        calDayLabel.alpha = 0;
        calDayLabel.userInteractionEnabled = YES;
        [cardView addSubview:calDayLabel];
        
        calDayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 231, 100, 20)];
        calDayOfWeekLabel.textAlignment = NSTextAlignmentLeft;
        calDayOfWeekLabel.font = [UIFont fontWithName:@"OpenSans" size:10.0];
        calDayOfWeekLabel.textColor = grayColor;
        calDayOfWeekLabel.alpha = 0;
        calDayOfWeekLabel.userInteractionEnabled = YES;
        [cardView addSubview:calDayOfWeekLabel];
        
        calTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 242, 62, 20)];
        calTimeLabel.textAlignment = NSTextAlignmentLeft;
        calTimeLabel.font = [UIFont fontWithName:@"OpenSans" size:8.0];
        calTimeLabel.textColor = grayColor;
        calTimeLabel.minimumScaleFactor = 0.75;
        calTimeLabel.adjustsFontSizeToFitWidth = YES;
        calTimeLabel.alpha = 0;
        calTimeLabel.userInteractionEnabled = YES;
        [cardView addSubview:calTimeLabel];
        */
        
        
        
        /* %%%%%%%%%%%%%%%%% EXPANDED CARD ITEMS -- ALPHA = 0 AND TAG = 3 FOR ALL (EXCEPT BTN) %%%%%%%%%%%%%%%%%% */
        
        moreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 50, 352, 45, 20)];
        [moreButton setTitleColor:[UIColor colorWithRed:0 green:200.0/255 blue:250.0/255 alpha:1.0] forState:UIControlStateNormal];
        [moreButton setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
        moreButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:11.0];
        [moreButton setTitle:@"more..." forState:UIControlStateNormal];
        /*NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"more..."];
        [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                          value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                          range:(NSRange){0,[attString length]}];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] range:NSMakeRange(0, [attString length])];
        [moreButton setAttributedTitle:attString forState:UIControlStateNormal];
        [moreButton setAttributedTitle:attString forState:UIControlStateHighlighted]; */
        moreButton.alpha = 0;
        //moreButton.tag = 3;
        [cardView addSubview:moreButton];
        
        
        CGPoint center = cardView.center;
        
        notInterestedButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 620, 35, 35)];
        notInterestedButton.center = CGPointMake((center.x - 80), notInterestedButton.center.y);
        [notInterestedButton setImage:[UIImage imageNamed:@"letter x"] forState:UIControlStateNormal];
        [notInterestedButton addTarget:self action:@selector(manualSwipeLeft) forControlEvents:UIControlEventTouchUpInside];
        notInterestedButton.tag = 3;
        notInterestedButton.layer.cornerRadius = notInterestedButton.frame.size.height/2;
        notInterestedButton.clipsToBounds = YES;
        notInterestedButton.backgroundColor = [UIColor lightGrayColor];
        [cardView addSubview:notInterestedButton];
        
        notInterestedLabel = [[UILabel alloc] initWithFrame:notInterestedButton.frame];
        notInterestedLabel.text = @"Not Interested";
        notInterestedLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:8.0];
        notInterestedLabel.textColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
        [notInterestedLabel sizeToFit];
        notInterestedLabel.center = CGPointMake(notInterestedButton.center.x, notInterestedButton.center.y + 25);
        notInterestedLabel.tag = 3;
        [cardView addSubview:notInterestedLabel];
        
        
        interestedButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 620, 35, 35)];
        interestedButton.center = CGPointMake((center.x + 80), interestedButton.center.y);
        [interestedButton setImage:[UIImage imageNamed:@"timeline_swipeRight"] forState:UIControlStateNormal];
        [interestedButton addTarget:self action:@selector(manualSwipeRight) forControlEvents:UIControlEventTouchUpInside];
        interestedButton.tag = 3;
        interestedButton.layer.cornerRadius = interestedButton.frame.size.height/2;
        interestedButton.clipsToBounds = YES;
        interestedButton.backgroundColor = [UIColor lightGrayColor];
        [cardView addSubview:interestedButton];

        interestedLabel = [[UILabel alloc] initWithFrame:interestedButton.frame];
        interestedLabel.text = @"Interested";
        interestedLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:8.0];
        interestedLabel.textColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
        [interestedLabel sizeToFit];
        interestedLabel.center = CGPointMake(interestedButton.center.x, interestedButton.center.y + 25);
        interestedLabel.tag = 3;
        [cardView addSubview:interestedLabel];
        
        
        goingButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 620, 35, 35)];
        goingButton.center = CGPointMake(center.x, goingButton.center.y);
        [goingButton setImage:[UIImage imageNamed:@"timeline_going"] forState:UIControlStateNormal];
        [cardView addSubview:goingButton];
        [goingButton addTarget:self action:@selector(manualSwipeDown) forControlEvents:UIControlEventTouchUpInside];
        goingButton.layer.cornerRadius = goingButton.frame.size.height/2;
        goingButton.clipsToBounds = YES;
        goingButton.backgroundColor = [UIColor lightGrayColor];
        goingButton.tag = 3;
        
        goingLabel = [[UILabel alloc] initWithFrame:goingButton.frame];
        goingLabel.text = @"Going";
        goingLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:8.0];
        goingLabel.textColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
        [goingLabel sizeToFit];
        goingLabel.center = CGPointMake(goingButton.center.x, goingButton.center.y + 25);
        goingLabel.tag = 3;
        //goingLabel.alpha = 0;
        [cardView addSubview:goingLabel];
        
        
        startPriceNumLabel = [[UILabel alloc] init];
        avePriceNumLabel = [[UILabel alloc] init];
        
        
        _rdio = [AppDelegate sharedRdio];
        [_rdio setDelegate:self];
        _player = [_rdio preparePlayerWithDelegate:self];
        
        
        self.friendsInterestedCount = 0;

        
        /* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

        
        
        
        
        /* %%%%%%%%%%%%%%%%% DELEGATE METHODS %%%%%%%%%%%%%%%%%% */
        
        [moreButton addTarget:delegate action:@selector(moreButtonTap) forControlEvents:UIControlEventTouchUpInside];
        
        [shareButton addTarget:delegate action:@selector(shareButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        
        [createdBy addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(createdByTap)]];
        
        /* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

        
    }
    
    return self;
}

- (void)loadCardWithData {
    
    [self addSubviewsToCard:self];
    
}

-(CGFloat) moreButtonUpdateFrame {
    
    /*
    if (![self doesString:subtitle.text contain:@"Details: "]) {
        
        UIFont *font = [UIFont fontWithName:@"OpenSans-Bold" size:12.0];
        NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithObject:font
                                                                                  forKey:NSFontAttributeName];
        //[attrsDictionary setObject:[UIColor colorWithRed:0.0/255 green:176.0/255 blue:242.0/255 alpha:1.0] forKey:NSForegroundColorAttributeName];
        [attrsDictionary setObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"Details: " attributes:attrsDictionary];
        
        NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:subtitle.text];
        
        [aAttrString1 appendAttributedString:aAttrString2];
        
        subtitle.attributedText = aAttrString1;
        
    }*/
    
    // Each line = approx 13.5
    CGFloat lineSizeTotal = 0;
    
    NSUInteger actualLineSize = [subtitle.text boundingRectWithSize:CGSizeMake(subtitle.frame.size.width, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:10.0]}
                                                   context:nil].size.height;
    
    
    NSLog(@"line size ^&: %lu", actualLineSize);
    
    if (actualLineSize > 20) // 27 = 2 lines, 13 = 1 line
    {
        // show your more button
        subtitle.numberOfLines = 2;
        CGRect subtitleFrame = subtitle.frame;
        subtitleFrame.origin.y += -12;
        subtitle.frame = subtitleFrame;
        lineSizeTotal = 27;
        
        moreButton.alpha = 1.0;
        moreButton.center = CGPointMake(cardView.frame.size.width/2, subtitle.frame.origin.y + 27 + 9);
        
    } else {
        
        CGRect subtitleFrame = subtitle.frame;
        subtitleFrame.origin.y += -10;
        subtitle.frame = subtitleFrame;
        
        lineSizeTotal = actualLineSize;
    }
    
    //return lineSizeTotal + 7 + moreButton.frame.size.height;
    return 13 + 7 + moreButton.frame.size.height;
    
}

- (void)addSubviewsToCard:(DraggableView *)card {
    
    extraDescHeight = [self moreButtonUpdateFrame];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 440 + extraDescHeight - 60, 284, 133)];
    mapView.layer.borderColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0].CGColor;
    mapView.layer.borderWidth = 1.0;
    [mapView setZoomEnabled:NO];
    mapView.scrollEnabled = NO;
    //mapView.alpha = 0;
    mapView.tag = 3;
    [cardView addSubview:mapView];
    mapView.userInteractionEnabled = YES;
    
    UIButton *clearButton = [[UIButton alloc] initWithFrame:mapView.bounds];
    [clearButton setBackgroundColor:[UIColor clearColor]];
    [clearButton addTarget:delegate action:@selector(mapViewTap) forControlEvents:UIControlEventTouchUpInside];
    [mapView addSubview:clearButton];
    
    
    
    uberBTN = [[BTNDropinButton alloc] initWithButtonId:@"btn-0acf02149a673eb6"];
    
    NSString *locationText = [NSString stringWithString:location.text];
    locationText = [locationText stringByReplacingOccurrencesOfString:@"at " withString:@""];
    
    BTNVenue *venue = [BTNVenue venueWithId:@"abc123" venueName:locationText latitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    NSDate *eventDate = self.eventObject[@"Date"];
    
    if ([eventDate compare:[NSDate dateWithTimeIntervalSinceNow:-3600]] == NSOrderedDescending) { // more than 1 hr before, show reminder
        
        [uberBTN setFrame:CGRectMake(0, 530 + extraDescHeight, 217, 30)];
        uberBTN.center = CGPointMake(142, uberBTN.center.y);
        
        NSDictionary *context = @{
                                  BTNContextApplicableDateKey: eventDate,
                                  BTNContextEndLocationKey:venue.location,
                                  //BTNContextReminderUseDebugIntervalKey: @YES
                                  };
        [uberBTN prepareForDisplayWithContext:context completion:^(BOOL isDisplayable) {
            if (isDisplayable) {
                [cardView addSubview:uberBTN];
            }
        }];
        
    } else {
        
        [uberBTN setFrame:CGRectMake(0, 530 + extraDescHeight, 175, 30)];
        uberBTN.center = CGPointMake(142, uberBTN.center.y);
        
        [uberBTN prepareForDisplayWithVenue:venue completion:^(BOOL isDisplayable) {
            if (isDisplayable) {
                [cardView addSubview:uberBTN];
            }
        }];
    }
    
    ticketsButton = [[UIButton alloc] initWithFrame:CGRectMake((284-230)/2, 360.5 + extraDescHeight - 62, 230, 28)];

    ticketsButton.enabled = YES;
    ticketsButton.userInteractionEnabled = YES;
    ticketsButton.tag = 1;
    UIColor *hapBlue = [UIColor colorWithRed:0.0 green:185.0/255 blue:245.0/255 alpha:1.0];
    [ticketsButton setTitle:@"GET TICKETS (MAY BE SOLD OUT)" forState:UIControlStateNormal];
    //[ticketsButton setTitleColor:hapBlue forState:UIControlStateNormal];
    //[ticketsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [ticketsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [ticketsButton setTitleColor:hapBlue forState:UIControlStateHighlighted];
    [ticketsButton setBackgroundColor:hapBlue];
    
    ticketsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:13.0];
    
    ticketsButton.layer.masksToBounds = YES;
    ticketsButton.layer.borderColor = hapBlue.CGColor;
    ticketsButton.layer.borderWidth = 1.0;
    ticketsButton.layer.cornerRadius = 28/2;
    
    [ticketsButton addTarget:self action:@selector(tixButtonHighlight:) forControlEvents:UIControlEventTouchDown];
    [ticketsButton addTarget:self action:@selector(tixButtonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [ticketsButton addTarget:self action:@selector(tixButtonNormal:) forControlEvents:UIControlEventTouchDragExit];
    
    
    [cardView addSubview:ticketsButton];
    
    NSString *ticketLink = self.eventObject[@"TicketLink"];
    int height = 0;
    
    if (ticketLink != nil && (![ticketLink isEqualToString:@""] || ![ticketLink isEqualToString:@"$0"])) {
        
        height += 20;
        
        ticketsButton.frame = CGRectMake((284-230)/2, 360.5 + extraDescHeight - 62, 230, 28);
        
        ticketsButton.accessibilityIdentifier = ticketLink;
        [ticketsButton addTarget:delegate action:@selector(ticketsButtonTap:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self doesString:ticketLink contain:@"seatgeek.com"]) {
            
            if (![startPriceNumLabel.text isEqualToString:@""] && ![startPriceNumLabel.text isEqualToString:@"$0"] && startPriceNumLabel.text != nil) {
               
                NSString *startingString = [NSString stringWithFormat:@"GET TICKETS - STARTING AT %@", startPriceNumLabel.text];
                [ticketsButton setTitle:startingString forState:UIControlStateNormal];
                ticketsButton.frame = CGRectMake((284-230)/2, 360.5 + extraDescHeight - 62, 230, 28);
                
                NSString *priceString = [startPriceNumLabel.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
                int priceInt = [priceString intValue];
                
                NSLog(@"&&& %d", priceInt);
                
                if (priceInt > 1 && priceInt < 15) {
                    ticketsButton.backgroundColor = [UIColor colorWithRed:230.0/255 green:0/255 blue:0/255 alpha:1.0];
                    NSString *startingString = [NSString stringWithFormat:@"GREAT DEAL - TIX START AT %@", startPriceNumLabel.text];
                    [ticketsButton setTitle:startingString forState:UIControlStateNormal];
                    [ticketsButton setTitleColor:[UIColor colorWithRed:230.0/255 green:0/255 blue:0/255 alpha:1.0] forState:UIControlStateHighlighted];
                    ticketsButton.layer.borderColor = [UIColor colorWithRed:230.0/255 green:0/255 blue:0/255 alpha:1.0].CGColor;
                    ticketsButton.tag = 3;
                    
                } else if (priceInt > 1 && priceInt < 35) {
                    ticketsButton.backgroundColor = [UIColor colorWithRed:245.0/255 green:184.0/255 blue:65.0/255 alpha:1.0];
                    NSString *startingString = [NSString stringWithFormat:@"GOOD  DEAL - TIX START AT %@", startPriceNumLabel.text];
                    [ticketsButton setTitle:startingString forState:UIControlStateNormal];
                    [ticketsButton setTitleColor:[UIColor colorWithRed:245.0/255 green:184.0/255 blue:65.0/255 alpha:1.0] forState:UIControlStateHighlighted];
                    ticketsButton.layer.borderColor = [UIColor colorWithRed:245.0/255 green:184.0/255 blue:65.0/255 alpha:1.0].CGColor;
                    ticketsButton.tag = 2;

                }
                
                
                
                /*
                startPriceNumLabel = [[UILabel alloc] init];
                startPriceNumLabel.textAlignment = NSTextAlignmentCenter;
                startPriceNumLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:13.0];
                startPriceNumLabel.textColor = [UIColor grayColor];
                //startPriceNumLabel.text = @"Starting";
                startPriceNumLabel.tag = 3;
                startPriceNumLabel.alpha = 0;
                [cardView addSubview:startPriceNumLabel];
                
                
                avePriceNumLabel = [[UILabel alloc] init];
                avePriceNumLabel.textAlignment = NSTextAlignmentCenter;
                avePriceNumLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:13.0];
                avePriceNumLabel.textColor = [UIColor grayColor];
                //avePriceNumLabel.text = @"Avg";
                avePriceNumLabel.tag = 3;
                avePriceNumLabel.alpha = 0;
                [cardView addSubview:avePriceNumLabel];
                
                UILabel *startingPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 349 + extraDescHeight - 62, 100, 30)];
                startingPriceLabel.textAlignment = NSTextAlignmentCenter;
                startingPriceLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12.0];
                startingPriceLabel.textColor = [UIColor darkGrayColor];
                startingPriceLabel.text = @"Starting";
                [startingPriceLabel sizeToFit];
                startingPriceLabel.center = CGPointMake(ticketsButton.center.x + 85 , ticketsButton.center.y);
                startingPriceLabel.tag = 3;
                [card.cardView addSubview:startingPriceLabel];
                
                startPriceNumLabel.frame = CGRectMake(startingPriceLabel.frame.size.width + startingPriceLabel.frame.origin.x + 5, startingPriceLabel.frame.origin.y, 50, 30);
                [startPriceNumLabel sizeToFit];
                startPriceNumLabel.center = CGPointMake(startPriceNumLabel.center.x, startingPriceLabel.center.y);
                [card.cardView addSubview:startPriceNumLabel];
                
                if (![avePriceNumLabel.text isEqualToString:@""] && ![avePriceNumLabel.text isEqualToString:@"$0"]) {
                    
                    UILabel *avgPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(startPriceNumLabel.frame.origin.x + startPriceNumLabel.frame.size.width + 10, 349 + extraDescHeight - 62, 100, 30)];
                    avgPriceLabel.textAlignment = NSTextAlignmentCenter;
                    avgPriceLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12.0];
                    avgPriceLabel.textColor = [UIColor darkGrayColor];
                    avgPriceLabel.text = @"Avg";
                    [avgPriceLabel sizeToFit];
                    avgPriceLabel.center = CGPointMake(avgPriceLabel.center.x , ticketsButton.center.y);
                    avgPriceLabel.tag = 3;
                    [card.cardView addSubview:avgPriceLabel];
                    
                    avePriceNumLabel.frame = CGRectMake(avgPriceLabel.frame.size.width + avgPriceLabel.frame.origin.x + 5, avgPriceLabel.frame.origin.y, 50, 30);
                    [avePriceNumLabel sizeToFit];
                    avePriceNumLabel.center = CGPointMake(avePriceNumLabel.center.x, avgPriceLabel.center.y);
                    [card.cardView addSubview:avePriceNumLabel];

                } */
            }
            
        } else if ([self doesString:ticketLink contain:@"facebook.com"]) {
            
            [ticketsButton setTitle:@"RSVP TO FACEBOOK EVENT" forState:UIControlStateNormal];
            ticketsButton.frame = CGRectMake(15, 360.5 + extraDescHeight - 62, 200, 25);
            ticketsButton.center = CGPointMake(self.center.x, ticketsButton.center.y);
            
        } else if ([self doesString:ticketLink contain:@"meetup.com"]) {
            
            [ticketsButton setTitle:@"RSVP ON MEETUP.COM" forState:UIControlStateNormal];
            ticketsButton.frame = CGRectMake(15, 360.5 + extraDescHeight - 62, 200, 25);
            ticketsButton.center = CGPointMake(self.center.x, ticketsButton.center.y);
            
        } else if ([[self.eventObject objectForKey:@"isFreeEvent"] isEqualToNumber:@YES]) {
            
            [ticketsButton setTitle:@"THIS EVENT IS FREE!" forState:UIControlStateNormal];
            ticketsButton.frame = CGRectMake(15, 360.5 + extraDescHeight - 62, 200, 25);
            ticketsButton.center = CGPointMake(self.center.x, ticketsButton.center.y);
            
        }
        
    } else { //no tix
        
        UILabel *noTixLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 360.5 + extraDescHeight - 62, 250, 25)];
        noTixLabel.textAlignment = NSTextAlignmentCenter;
        noTixLabel.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:12.0];
        noTixLabel.textColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0];
        noTixLabel.tag = 3;
        
        if ([[self.eventObject objectForKey:@"isTicketedEvent"] isEqualToNumber:@NO]) {
            noTixLabel.text = @"This event does not have tickets.";
        } else if ([[self.eventObject objectForKey:@"isFreeEvent"] isEqualToNumber:@YES]){
            noTixLabel.text = @"This event is free! No tickets required.";
        } else if ([[self.eventObject objectForKey:@"private"] isEqualToNumber:@YES]) {
        
        } else {
            /*
            noTixLabel.text = @"No ticket information is available.";*/
            noTixLabel.text = @"";
        }
        
        [ticketsButton removeFromSuperview];
        
        noTixLabel.center = CGPointMake(cardView.center.x, noTixLabel.center.y);
        [cardView addSubview:noTixLabel];
        
    }
    
    //[self ticketsAndUberUpdateFrameBy:height + 8];
    
    if ([self.hashtag.text isEqualToString:@"Music"]) {
        //[self checkForMusicForArtist:self.title.text];
    }
    
    [cardView bringSubviewToFront:self.mapView];
    [self loadFBFriends];
    
    [self checkIfEnded];

}


-(BOOL)doesString:(NSString *)first contain:(NSString*)other {
    NSRange range = [first rangeOfString:other];
    return range.length != 0;
}

/*
- (void)noFriendsAddButton:(UIScrollView *)friendScrollView {
    
    friendScrollView.scrollEnabled = NO;
    
    UIButton *noFriendsButton = [[UIButton alloc] initWithFrame:CGRectMake(35, 5, 184, 40)];
    [noFriendsButton setTitle:@"Invite your friends" forState:UIControlStateNormal];
    noFriendsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
    [noFriendsButton setTitleColor:[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [noFriendsButton setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateHighlighted];
    noFriendsButton.layer.masksToBounds = YES;
    noFriendsButton.layer.borderColor = [UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0].CGColor;
    noFriendsButton.layer.borderWidth = 2.0;
    noFriendsButton.layer.cornerRadius = 5.0;
    
    [noFriendsButton setReversesTitleShadowWhenHighlighted:YES];
    [noFriendsButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    
    noFriendsButton.tag = 99; // so we don't show calendar on sharesheet
    
    [friendScrollView addSubview:noFriendsButton];
    
}*/


- (void)checkForMusicForArtist:(NSString *)artistName {
    
    NSLog(@"Searching for: %@", artistName);
    
    [_rdio callAPIMethod:@"search" withParameters:@{@"query":artistName, @"types":@"Artist", @"count":@"1"} success:^(NSDictionary *result) {
        
        NSLog(@"%@", result);
        
        NSArray *results = result[@"results"];
        
        if (results.count > 0) {
            
            NSDictionary *dict = results[0];
            
            if (dict[@"topSongsKey"] != nil) {
                
                CGRect subtitleFrame = subtitle.frame;
                
                playPauseButton2 = [[UIButton alloc] initWithFrame:CGRectMake(subtitleFrame.origin.x + 50, subtitleFrame.origin.y, 100, 25)];
                [playPauseButton2 setTitle:@"Play" forState:UIControlStateNormal];
                playPauseButton2.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
                [playPauseButton2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                [playPauseButton2 addTarget:self action:@selector(playPauseTapped:) forControlEvents:UIControlEventTouchUpInside];
                
                [_player.queue add:dict[@"topSongsKey"]];
                [cardView addSubview:playPauseButton2];
                [subtitle removeFromSuperview];
                
                NSString *urlStr = dict[@"dynamicIcon"];
                if ([self doesString:urlStr contain:@"%"]) {
                    NSRange range = [urlStr rangeOfString:@"%"];
                    urlStr = [urlStr substringWithRange:NSMakeRange(0, range.location)];
                }
                
                NSLog(@"%@",urlStr);
                
                UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(subtitleFrame.origin.x, subtitleFrame.origin.y - 5, 40, 40)];
                NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:urlStr] ];
                imv.image = [UIImage imageWithData:data];
                [cardView addSubview:imv];
                
                [self updateFramesForMusic];
            }
            
        }
        
    } failure:^(NSError *error) {
        
        NSLog(@"Error: %@", error);
        
    }];
    
    
}

- (void)playPauseTapped:(id)sender
{
    NSLog(@"Play/pause button tapped!");
    
    if (!_playing) {
        // Nothing's been "played" yet, so queue up and play something
        
        //NSArray *keys = [@"t15907959,t1992210,t7418766,t8816323" componentsSeparatedByString:@","];
        //[_player.queue add:keys];
        [_player playFromQueue:0];
    } else {
        // Otherwise, just toggle play/pause
        [_player togglePause];
    }
}

-(void)rdioPlayerChangedFromState:(RDPlayerState)oldState toState:(RDPlayerState)newState
{
    NSLog(@"Rdio Player changed from state %u to state %u", oldState, newState);
    
    // Your internal state machine logic may differ, but for the sake of simplicity,
    // this Hello app considers Playing, Paused, and Buffering all as "playing" states.
    _playing = (newState != RDPlayerStateInitializing && newState != RDPlayerStateStopped);
    _paused = (newState == RDPlayerStatePaused);
    
    if (_paused || !_playing) {
        [playPauseButton2 setTitle:@"Play " forState:UIControlStateNormal];
    } else {
        [playPauseButton2 setTitle:@"Pause" forState:UIControlStateNormal];
        
        if (_player.currentTrack != nil) {
            
            NSLog(@"%@", _player.currentTrack);
            
            
            [_rdio callAPIMethod:@"get" withParameters:@{@"keys":_player.currentTrack} success:^(NSDictionary *result) {
                
                NSLog(@"%@", result);
                
                NSDictionary *dict = result[_player.currentTrack];
                
                if (dict != nil) {
                    
                    CGRect playerFrame = playPauseButton2.frame;
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(playerFrame.origin.x + playerFrame.size.width + 10, playerFrame.origin.y, 100, 30)];
                    label.text = dict[@"name"];
                    label.font = [UIFont fontWithName:@"OpenSans-Semibold" size:14.0];
                    [cardView addSubview:label];
                    
                }
                
            } failure:^(NSError *error) {
                
                
            }];
            
            
        }
        
    }
}

- (void)updateFramesForMusic {
    
    CGRect mapRect =  mapView.frame;
    CGRect uberRect = uberBTN.frame;
    CGRect leftButton = notInterestedButton.frame;
    CGRect leftLabel = notInterestedLabel.frame;
    CGRect middleButton = goingButton.frame;
    CGRect middleLabel = goingLabel.frame;
    CGRect rightButton = interestedButton.frame;
    CGRect rightLabel = interestedLabel.frame;
    
    float y = 30;
    mapRect.origin.y = mapRect.origin.y + y;
    uberRect.origin.y = uberRect.origin.y + y;
    leftButton.origin.y = leftButton.origin.y + y;
    leftLabel.origin.y = leftLabel.origin.y + y;
    middleButton.origin.y = middleButton.origin.y + y;
    middleLabel.origin.y = middleLabel.origin.y + y;
    rightButton.origin.y = rightButton.origin.y + y;
    rightLabel.origin.y = rightLabel.origin.y + y;
    
    mapView.frame = mapRect;
    uberBTN.frame = uberRect;
    notInterestedButton.frame = leftButton;
    notInterestedLabel.frame = leftLabel;
    goingButton.frame = middleButton;
    goingLabel.frame = middleLabel;
    interestedButton.frame = rightButton;
    interestedLabel.frame = rightLabel;
    
}

-(void)rdioAuthorizationFailed:(NSError *)error {
    
    NSLog(@"Error: %@", error);
}

-(void)arrangeCornerViews {
    
    if ([self.eventObject[@"private"] boolValue] == YES && self.eventObject[@"CreatedByFBID"] != nil) {
        
        ProfilePictureView *ppview = [[ProfilePictureView alloc] initWithFrame:CGRectMake(10, 10, 40, 40) type:@"create" fbid:self.eventObject[@"CreatedByFBID"]];
        ppview.parseId = self.eventObject[@"CreatedBy"];
        ppview.layer.borderColor = [UIColor whiteColor].CGColor;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(friendProfileTap:)];
        [ppview addGestureRecognizer:gr];
        [self.cardView addSubview:ppview];
        
        NSString *nameString = self.eventObject[@"CreatedByName"];
        NSString *createdByString = @"";
        
        if ([self.eventObject[@"CreatedByFBID"] isEqualToString:[PFUser currentUser][@"FBObjectID"]]) {
            createdByString = @"By You";
        } else {
            NSString *firstWord = [[nameString componentsSeparatedByString:@" "] objectAtIndex:0];
            NSString *secondWord = [[nameString componentsSeparatedByString:@" "] objectAtIndex:1];
            createdByString = [NSString stringWithFormat:@"By %@ %@.", firstWord, [secondWord substringToIndex:1]];
        }
        
        CategoryBubbleView *createdBubble = [[CategoryBubbleView alloc] initWithText:createdByString type:@"createdBy"];
        createdBubble.center = CGPointMake(createdBubble.center.x, createdBubble.frame.size.height + createdBubble.center.y + 25);
        [cardView addSubview:createdBubble];
        
    } else {
    
        if (self.eventObject[@"Hashtag"]) {
            self.hashtag.text = [NSString stringWithFormat:@"%@", self.eventObject[@"Hashtag"]];
            CategoryBubbleView *catView  = [[CategoryBubbleView alloc] initWithText:self.eventObject[@"Hashtag"] type:@"normal"];
            [cardView addSubview:catView];
        } else {
            hashtag.text = @"";
        }
        
        PFQuery *query = [PFQuery queryWithClassName:@"Swipes"];
        [query whereKey:@"EventID" equalTo:self.eventObject.objectId];
        [query fromLocalDatastore];
        //[query getObjectInBackgroundWithId:event.objectId block:^(PFObject *object, NSError *error){
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *swipe, NSError *error) {
            
            if (!error /* && [swipe[@"EventID"] isEqualToString:event.objectId] && [[event[@"Date"] beginningOfDay] isEqualToDate:[[NSDate date] beginningOfDay]]*/) {
                
                if ([swipe[@"isGoing"] boolValue] == YES) {
                    CategoryBubbleView *stillInterestedView = [[CategoryBubbleView alloc] initWithText:@"Still Going?" type:@"repeat-going"];
                    [cardView addSubview:stillInterestedView];
                } else {
                    CategoryBubbleView *stillInterestedView = [[CategoryBubbleView alloc] initWithText:@"Still Interested?" type:@"repeat"];
                    [cardView addSubview:stillInterestedView];
                }
                
                NSMutableArray *views = [NSMutableArray array];
                for (UIView *view in self.cardView.subviews) {
                    if (view.tag == 123) {
                        [views addObject:view];
                    }
                }
                
                if (views.count == 2) {
                    
                    for (CategoryBubbleView *view in views) {
                        
                        if ([view.bubbleType isEqualToString:@"normal"]) {
                            
                            view.center = CGPointMake(view.center.x, view.frame.size.height + view.center.y + 5);
                            
                        }
                    }
                }
                
            } else {
                
            }
            
        }];
    }
}

- (void)checkIfEnded {
    
    NSDate *startDate = self.eventObject[@"Date"];
    NSDate *endDate = self.eventObject[@"EndTime"];
    
    BOOL hasEnded = NO;
    
    if (endDate == nil && [[startDate beginningOfDay] compare:[[NSDate date] beginningOfDay]] == NSOrderedAscending) {
        hasEnded = YES;
    } else if (endDate != nil && [endDate compare:[NSDate date]] == NSOrderedAscending) {
        hasEnded = YES;
    }
    
    if (hasEnded) {
        
        UIImageView *endedImageView = [[UIImageView alloc] initWithFrame:eventImage.bounds];
        endedImageView.image = [UIImage imageNamed:@"event ended"];
        [eventImage addSubview:endedImageView];
        ticketsButton.enabled = NO;
        uberBTN.enabled = NO;
        //[ticketsButton setTitle:@"Tickets no longer available" forState:UIControlStateNormal];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mma"];
        NSString *startTimeString = [formatter stringFromDate:startDate];
        [formatter setDateFormat:@"MMM d"];
        NSString *dateString = [formatter stringFromDate:startDate];
        
        date.text = [NSString stringWithFormat:@"Started at %@ on %@", startTimeString, dateString];
    }
    
}

- (void)loadFBFriends {
    
    self.interestedNames = [NSMutableArray new];
    self.interestedIds = [NSMutableArray new];
    
    NSArray *friends = [PFUser currentUser][@"friends"];
    NSMutableArray *idsArray = [NSMutableArray array];
    NSMutableArray *namesArray = [NSMutableArray array];
    for (NSDictionary *dict in friends) {
        [idsArray addObject:[dict valueForKey:@"id"]];
        [namesArray addObject:[dict valueForKey:@"name"]];
    }
    
    __block int friendCount = 0;
    
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Swipes"];
    //[friendQuery whereKey:@"FBObjectID" containedIn:idsArray];
    [friendQuery whereKey:@"EventID" equalTo:self.objectID];
    [friendQuery whereKey:@"swipedRight" equalTo:@YES];
    
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        // NSLog(@"%lu friends interested", (unsigned long)objects.count);
        
        if (!error) {
            
            NSMutableArray *orderedObjects = [NSMutableArray arrayWithArray:objects];
            
            for (int i = 0; i < orderedObjects.count; i++) {
                PFObject *object = orderedObjects[i];
                if ([idsArray containsObject:object[@"FBObjectID"]]) {
                    [orderedObjects removeObject:object];
                    [orderedObjects insertObject:object atIndex:0];
                }
            }
            
            for (int i = 0; i < orderedObjects.count; i++) {
                PFObject *object = orderedObjects[i];
                if ([object[@"isGoing"] boolValue] == YES) {
                    [orderedObjects removeObject:object];
                    [orderedObjects insertObject:object atIndex:0];
                }
            }
            
            for (int i = 0; i < orderedObjects.count; i++) {
                PFObject *object = orderedObjects[i];
                if ([object[@"FBObjectID"] isEqualToString:[PFUser currentUser][@"FBObjectID"]]) {
                    [orderedObjects removeObject:object];
                    [orderedObjects insertObject:object atIndex:0];
                    break;
                }
            }
            
            
            /*
            for (PFObject *object in objects) {
             
                if ([bestFriendIds containsObject:object[@"FBObjectID"]]) {
                    [orderedObjects removeObject:object];
                    [orderedObjects insertObject:object atIndex:0];
                }
                
            } */
            
            for (int i = 0; i < orderedObjects.count; i++) {
                
                PFObject *object = orderedObjects[i];
                
                NSString *fbid = object[@"FBObjectID"];
                
                if (fbid != nil && ![fbid isEqualToString:@""]) {
                    
                    /*
                    FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(50 * friendCount, 0, 40, 40)]; // initWithProfileID:user[@"FBObjectID"] pictureCropping:FBSDKProfilePictureModeSquare];
                    profPicView.profileID = fbid;
                    //profPicView.pictureMode = FBSDKProfilePictureModeSquare;
                    
                    profPicView.layer.cornerRadius = 20;
                    profPicView.layer.masksToBounds = YES;
                    NSLog(@"$$ %@", object[@"UserID"]);
                    profPicView.accessibilityIdentifier = object[@"UserID"];
                    profPicView.userInteractionEnabled = YES;
                    [friendScrollView addSubview:profPicView];
                    */
                    
                    NSString *type;
                    if ([object[@"isGoing"] boolValue] == YES) {
                        type = @"going";
                    } else {
                        type = @"interested";
                    }
                    
                    ProfilePictureView *ppview = [[ProfilePictureView alloc] initWithFrame:CGRectMake(50 * friendCount, 0, 40, 40) type:type fbid:fbid];
                    ppview.parseId = object[@"UserID"];
                    [friendScrollView addSubview:ppview];
                    
                    
                    if ([fbid isEqualToString:[PFUser currentUser][@"FBObjectID"]]) {

                        [ppview addName:@"You"];
                        ppview.tag = 99;
                        
                        if ([object[@"isGoing"] boolValue] == YES) {
                            
                            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                goingButton.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:120.0/255 alpha:1.0];
                            } completion:nil];
                            
                        } else {
                            
                            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                interestedButton.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:121.0/255 alpha:1.0];
                            } completion:nil];
                            
                        }
                        
                        /*
                        UILabel *maskLabel = [[UILabel alloc] initWithFrame:ppview.bounds];
                        maskLabel.backgroundColor = [UIColor blackColor];
                        maskLabel.alpha = 0.8;
                        maskLabel.text = @"Change";
                        maskLabel.font = [UIFont fontWithName:@"OpenSans" size:8.0];
                        maskLabel.textColor = [UIColor whiteColor];
                        maskLabel.layer.cornerRadius = ppview.frame.size.height / 2;
                        maskLabel.clipsToBounds = YES;
                        maskLabel.textAlignment = NSTextAlignmentCenter;
                        [ppview addSubview:maskLabel];
                        
                        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(changeRSVP)];
                        [maskLabel addGestureRecognizer:gr];
                        */
                        
                    } else {
                        
                        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:delegate action:@selector(friendProfileTap:)];
                        [ppview addGestureRecognizer:gr];
                        for (NSDictionary *dict in friends) {
                            if ([[dict objectForKey:@"id"] isEqualToString:fbid]) {
                                
                                self.friendsInterestedCount++;
                                
                                NSString *fullName = [dict objectForKey:@"name"];
                                NSRange range = [fullName rangeOfString:@" "];
                                [ppview addName:[fullName substringToIndex:range.location]];
                                break;
                            }
                        }
                    }
                    
                    friendScrollView.contentSize = CGSizeMake((50 * friendCount) + 40 + 5, 50);

                    
                    //[self friendsUpdateFrameBy:50];
                    
                    /*
                    if ([bestFriendIds containsObject:object[@"FBObjectID"]]) {
                        
                        UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50 * friendCount + 25, 0, 15, 15)];
                        starImageView.image = [UIImage imageNamed:@"star-blue-bordered"];
                        [friendScrollView addSubview:starImageView];
                    }*/
                    
                    if ([idsArray containsObject:fbid]) {
                        NSUInteger index = [idsArray indexOfObject:fbid];
                        [self.interestedIds addObject:idsArray[index]];
                        [self.interestedNames addObject:namesArray[index]];
                    }
                    //[interestedPics addObject:profPicView];
                    
                    friendCount++;
                    
                    if (friendCount == 1) {
                        self.friendsInterested.text = [NSString stringWithFormat:@"%d friend interested", friendCount - 1];
                    } else {
                        self.friendsInterested.text = [NSString stringWithFormat:@"%d friends interested", friendCount - 1];
                    }
            
                } else {
                    
                    //[orderedObjects removeObject:object];
                }
                
            }
            
            if (friendCount > 4) {
                
                self.friendArrow.alpha = 1;
            }
            
            if (friendCount == 0) {
                // NSLog(@"No new friends");
                
                //[self noFriendsAddButton:friendScrollView];
                
            }
        }
        
    }];
   
}

-(void)manualSwipeLeft {

    if (!self.isExpandedCardView) {
        overlayView.mode = GGOverlayViewModeLeft;
        overlayView.alpha = 1;
    }
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        notInterestedButton.backgroundColor = [UIColor redColor];
        interestedButton.backgroundColor = [UIColor lightGrayColor];
        goingButton.backgroundColor = [UIColor lightGrayColor];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            //cardView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 284, 350);
            
        } completion:^(BOOL finished) {
            
            if (!self.isExpandedCardView)
                [self performSelector:@selector(leftClickAction) withObject:nil afterDelay:0.8];
            
            [delegate cardSwipedLeft:self fromExpandedView:YES];

        }];

    }];

}

-(void)manualSwipeRight {

    if (!self.isExpandedCardView) {
        overlayView.mode = GGOverlayViewModeRight;
        overlayView.alpha = 1;
    }
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        interestedButton.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:121.0/255 alpha:1.0];
        notInterestedButton.backgroundColor = [UIColor lightGrayColor];
        goingButton.backgroundColor = [UIColor lightGrayColor];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            //cardView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 284, 350);
            
        } completion:^(BOOL finished) {
            
            if (!self.isExpandedCardView)
                [self performSelector:@selector(rightClickAction) withObject:nil afterDelay:0.8];
            
            [delegate cardSwipedRight:self fromExpandedView:YES isGoing:NO];
            
        }];
        
    }];
    
}

-(void)manualSwipeDown {

    if (!self.isExpandedCardView) {
        overlayView.mode = GGOverlayViewModeDown;
        overlayView.alpha = 1;
    }
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        goingButton.backgroundColor = [UIColor colorWithRed:0.0 green:1.0 blue:120.0/255 alpha:1.0];
        interestedButton.backgroundColor = [UIColor lightGrayColor];
        notInterestedButton.backgroundColor = [UIColor lightGrayColor];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 animations:^{
            
            //cardView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, 284, 350);
            
        } completion:^(BOOL finished) {
            
            if (!self.isExpandedCardView)
                [self performSelector:@selector(downClickAction) withObject:nil afterDelay:0.8];
            
            [delegate cardSwipedRight:self fromExpandedView:YES isGoing:YES];
            
        }];
        
    }];
}

-(void)setupView:(CGRect)frame
{
    cardView = [[UIView alloc]initWithFrame:frame];
    [self addSubview:cardView];
    cardView.layer.masksToBounds = YES;
    
    [cardView.layer setCornerRadius:10.0];
    [cardView.layer setShadowOpacity:0.05];
    [cardView.layer setShadowOffset:CGSizeMake(1, 1)];
    //UIColor *color = [UIColor colorWithRed:<#(CGFloat)#> green:<#(CGFloat)#> blue:<#(CGFloat)#> alpha:<#(CGFloat)#>]
    [cardView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [cardView.layer setBorderWidth:1.0];
    cardView.backgroundColor = [UIColor whiteColor];

    panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
    [self.cardView addGestureRecognizer:panGestureRecognizer];

    cardBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cardBackground"]];
    cardBackground.frame = CGRectMake(7, 390, 270, cardBackground.image.size.height - 7);
    [self addSubview:cardBackground];
    
    /*
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.1;
    self.layer.shadowOffset = CGSizeMake(0, 5);
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 2.0;
     */
}

-(UIImage *)convertViewToImage: (UIView *)view {
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:cardView].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:cardView].y; //%%% positive for down, negative for up
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = cardView.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngel = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            cardView.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            cardView.transform = scaleTransform;
            [self updateOverlay:xFromCenter :yFromCenter];
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            [self afterSwipeAction];
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)xDistance :(CGFloat)yDistance
{
    
    if (xDistance > 15 && yFromCenter < SWIPE_DOWN_MARGIN && !overlayView.isCreateCard && self.isSwipeable) {
        overlayView.mode = GGOverlayViewModeRight;
        overlayView.alpha = MIN(fabs(xDistance)/100, 1.0); //based on x coordinate

    } else if (xDistance < -15 && yFromCenter < SWIPE_DOWN_MARGIN + 50 && !overlayView.isCreateCard && self.isSwipeable) { //Higher on swipe left b/c of intent for left swipe
        overlayView.mode = GGOverlayViewModeLeft;
        overlayView.alpha = MIN(fabs(xDistance)/100, 1.0); //based on x

    } else if (yDistance > 0 && self.isSwipeable){
        overlayView.mode = GGOverlayViewModeDown;
        overlayView.alpha = MIN(fabs(yDistance)/100, 1.0); //based on y

    } else {
        overlayView.alpha = 0;
    }
    
    /*
    else {
        overlayView.alpha = MIN(fabsf(xDistance)/100, 1.0); //based on x, fixes a bug and makes overlay view go away in middle
    }
     */
}

//%%% called when the card is let go
- (void)afterSwipeAction
{
    if (xFromCenter > self.actionMargin && yFromCenter < self.swipeDownMargin && self.isSwipeable) {
        [self rightAction];
    } else if (xFromCenter < -self.actionMargin && yFromCenter < self.swipeDownMargin + 50 && self.isSwipeable) { //Higher on swipe left b/c of intent for left swipe
        [self leftAction];
    } else if (yFromCenter > self.swipeDownMargin && self.isSwipeable) { //add to cal
        [self downAction];
    } else { //%%% resets the card
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
            cardView.center = self.originalPoint;
            cardView.transform = CGAffineTransformMakeRotation(0);
            overlayView.alpha = 0;
        } completion:nil];
        
        /*
        [UIView animateWithDuration:0.3
                         animations:^{
                             cardView.center = self.originalPoint;
                             cardView.transform = CGAffineTransformMakeRotation(0);
                             overlayView.alpha = 0;
                         }]; */
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction
{
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];

    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         cardView.center = finishPoint;
                     }completion:^(BOOL complete){
                         self.superview.superview.superview.userInteractionEnabled = YES;
                         [self setEnabledSidewaysScrolling:YES];
                         [self removeFromSuperview];
                     }];
    
    [cardBackground removeFromSuperview];
    [delegate cardSwipedRight:self fromExpandedView:NO isGoing:NO];
    
    NSLog(@"YES");
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the left
-(void)leftAction
{
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];

    CGPoint finishPoint = CGPointMake(-300, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         cardView.center = finishPoint;
                     }completion:^(BOOL complete){
                         self.superview.superview.superview.userInteractionEnabled = YES;
                         [self setEnabledSidewaysScrolling:YES];
                         [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedLeft:self fromExpandedView:NO];
    
    NSLog(@"NO");
}

-(void)downAction
{
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];
    
    CGPoint finishPoint = CGPointMake(cardView.frame.size.width / 2, 1000);
    [UIView animateWithDuration:0.5
                     animations:^{
                         cardView.center = finishPoint;
                     }completion:^(BOOL complete){
                         NSLog(@"1");
                         self.superview.superview.superview.userInteractionEnabled = YES;
                         [self setEnabledSidewaysScrolling:YES];
                         if (!isEditable)
                             [self removeFromSuperview];
                     }];
    
    [delegate cardSwipedRight:self fromExpandedView:NO isGoing:YES];
    
    //[delegate checkEventStoreAccessForCalendar];
    
    NSLog(@"DOWN");
}

-(void)downClickAction
{
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];
    
    CGPoint finishPoint = CGPointMake(cardView.frame.size.width / 2, 1000);
    [UIView animateWithDuration:0.5
                     animations:^{
                         cardView.center = finishPoint;
                     }completion:^(BOOL complete){
                         NSLog(@"1");
                         self.superview.superview.superview.userInteractionEnabled = YES;
                         [self setEnabledSidewaysScrolling:YES];
                         [self removeFromSuperview];
                     }];
    
    
    
    //[delegate checkEventStoreAccessForCalendar];
    
    NSLog(@"DOWN");
}

-(void)rightClickAction
{

    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];
    
    CGPoint finishPoint = CGPointMake(900, self.center.y);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardView.center = finishPoint;
        cardView.transform = CGAffineTransformMakeRotation(1);
    }completion:^(BOOL complete){
        self.superview.superview.superview.userInteractionEnabled = YES;
        [self setEnabledSidewaysScrolling:YES];
        [self removeFromSuperview];
    }];

    NSLog(@"YES");
}

-(void)leftClickAction
{
    
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];
    
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        cardView.center = finishPoint;
        cardView.transform = CGAffineTransformMakeRotation(-1);
    }completion:^(BOOL complete){
        self.superview.superview.superview.userInteractionEnabled = YES;
        [self setEnabledSidewaysScrolling:YES];
        [self removeFromSuperview];
    }];
    
    NSLog(@"NO");
}

-(void)cardExpanded:(BOOL)isExpanded
{
    NSLog(@"Drag view tapped");
    
    panGestureRecognizer.enabled = !isExpanded;
    
}

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okaaaay"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}


// Prompt the user for access to their Calendar
-(void)requestCalendarAccess
{
    
    [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             
         }
     }];
}


// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    // Let's get the default calendar associated with our event store
    
}

- (void)setEnabledSidewaysScrolling:(BOOL)enabled {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    [rk scrolling:enabled];
    
}

-(void)buttonNormal:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (self.cardView.frame.size.height < 500)
        panGestureRecognizer.enabled = YES;
    [button setBackgroundColor:[UIColor whiteColor]];
}

-(void)buttonHighlight:(id)sender {
    UIButton *button = (UIButton *)sender;
    panGestureRecognizer.enabled = NO;
    [button setBackgroundColor:[UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0]];
}

-(void)tixButtonNormal:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (self.cardView.frame.size.height < 500)
        panGestureRecognizer.enabled = YES;
    if (button.tag == 3) {
        
        button.backgroundColor = [UIColor colorWithRed:230.0/255 green:0/255 blue:0/255 alpha:1.0];
        
    } else if (button.tag == 2) {
        
        button.backgroundColor = [UIColor colorWithRed:245.0/255 green:184.0/255 blue:65.0/255 alpha:1.0];
        
    } else {
        
        [button setBackgroundColor:[UIColor colorWithRed:0.0 green:185.0/255 blue:245.0/255 alpha:1.0]];
        
    }
}

-(void)tixButtonHighlight:(id)sender {
    UIButton *button = (UIButton *)sender;
    panGestureRecognizer.enabled = NO;
    [button setBackgroundColor:[UIColor whiteColor]];
}

-(void)setEditableCard {
    
    self.actionMargin = 10000;
    isEditable = YES;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.tag == 33) {
        
        if (scrollView.contentOffset.x >= (scrollView.contentSize.width - scrollView.frame.size.width)) {
            
            self.friendArrow.alpha = 0;
            
        } else {
            
            self.friendArrow.alpha = 1;
            
        }
        
    }
    
}

/*
- (BOOL) colorOfPointIsWhite:(CGPoint)point
{
    unsigned char pixel[4] = {0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [self.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    //NSLog(@"pixel: %d %d %d %d", pixel[0], pixel[1], pixel[2], pixel[3]);
    
    //UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    BOOL isWhite = false;
    
    if (pixel[0]/255.0 > 0.75 && pixel[1]/255.0 > 0.75 && pixel[2]/255.0 > 0.75) {
        isWhite = true;
    }
    
    return isWhite;
}
 */


@end
