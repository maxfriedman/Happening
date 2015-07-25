//
//  TutorialDragView.m
//  Happening
//
//  Created by Max on 2/1/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define ACTION_MARGIN 60 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called
#define SCALE_STRENGTH 4 //%%% how quickly the card shrinks. Higher = slower shrinking
#define SCALE_MAX .93 //%%% upper bar for how much the card shrinks. Higher = shrinks less
#define ROTATION_MAX 1 //%%% the maximum rotation allowed in radians.  Higher = card can keep rotating longer
#define ROTATION_STRENGTH 320 //%%% strength of rotation. Higher = weaker rotation
#define ROTATION_ANGLE M_PI/8 //%%% Higher = stronger rotation angle

#define SWIPE_DOWN_MARGIN 100 //%%% distance from center where the action applies. Higher = swipe further in order for the action to be called

#import "TutorialDragView.h"
#import "CupertinoYankee.h"
#import "UIImage+ImageEffects.h"
#import "RKDropdownAlert.h"
#import "AppDelegate.h"
#import "PermissionsView.h"

#define MCANIMATE_SHORTHAND
#import <POP+MCAnimate.h>

@interface TutorialDragView() <UIAlertViewDelegate, UIApplicationDelegate, PermissionsViewDelegate>

@property (assign)int actionMargin;
@property (assign)int swipeDownMargin;

@property (nonatomic, strong)UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic)CGPoint originalPoint;
//@property (nonatomic,strong)OverlayView* overlayView;

@property (nonatomic, strong) EKEventStore *eventStore;

@end


@implementation TutorialDragView {
    
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    
    
    CGFloat xFromCenter;
    CGFloat yFromCenter;
    
    BOOL frontViewIsVisible;
    
    UILabel *DCLabel;
    UILabel *bostonLabel;
    UISlider *slider;
    UIButton *continueButton;
    UILabel *sliderLabel;
    
    UIImageView *cardBackground;
    
}

//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 350; //%%% height of the draggable card
static const float CARD_WIDTH = 284; //%%% width of the draggable card

@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

@synthesize imageArray;

@synthesize dragView; //CURRENT CARD!
@synthesize eventStore;
@synthesize locManager;
@synthesize delegate;


- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [super layoutSubviews];
        [self setupView];
        self.myViewController.frontViewIsVisible = YES; // Cards start off with front view visible
        
        
        // %%%%%%%%%% SO I CAN REMOVE FROM SUPERVIEW %%%%%%%%%
        self.tag = 999;
        // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        eventStore = [[EKEventStore alloc] init];
                
        self.actionMargin = ACTION_MARGIN;
        self.swipeDownMargin = SWIPE_DOWN_MARGIN;
        
        self.allowCardExpand = NO;
        self.allowCardSwipe = YES;
        
        cardBackground = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"cardBackground"]];
        cardBackground.frame = CGRectMake(7, 349, 270, cardBackground.image.size.height - 5);
        [self addSubview:cardBackground];
        
        // %%%%   LOAD TUTORIAL IMAGES   %%%%%%
        
        UIImageView *swipeRightImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SwipeRight"]];
        UIImageView *swipeLeftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SwipeLeft"]];
        UIImageView *swipeDownImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SwipeDown"]];
        //UIImageView *tapToExpandImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dotted arrow"]];
        //UIImageView *currentLocImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"interested_face"]];
        //UIView *cityAndRadiusView = [[UIView alloc] init];
        
        imageArray = [[NSArray alloc] initWithObjects:swipeRightImageView, swipeLeftImageView, swipeDownImageView, /*tapToExpandImageView, /*currentLocImageView,*/ nil];
        
        for (UIImageView *view in imageArray) {
            
            view.frame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
        }
        

        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        [self loadCards];
    }
    
    return self;
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{

    
}

//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(UIView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    
    UIView *tutorialView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT)];

    //[tutorialView addSubview:[imageArray objectAtIndex:index]];
    tutorialView.layer.masksToBounds = YES;
    tutorialView.backgroundColor = [UIColor whiteColor];
    tutorialView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tutorialView.layer.cornerRadius = 10.0;
    tutorialView.layer.borderWidth = 1.0;
    //tutorialView.layer.shadowOpacity = 0.2;
    //tutorialView.layer.shadowOffset = CGSizeMake(1, 1);
    
    OverlayView *overlayView = [[OverlayView alloc]initWithFrame:CGRectMake(0, 0, CARD_WIDTH, 70)];
    overlayView.alpha = 0;
    overlayView.tag = 99;
    //[tutorialView addSubview:overlayView];
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(beingDragged:)];
    [tutorialView addGestureRecognizer:self.panGestureRecognizer];
    
    tutorialView.tag = index;
    
    UIColor *color = [UIColor colorWithRed:77.0/255.0 green:78.0/255.0 blue:77.0/255.0 alpha:1.0];

    if (index == 0) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CARD_WIDTH, 100)];
        [label setText:@"Swipe right to"];
        [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:26.0]];
        [label setTextColor:color];
        [label setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, CARD_WIDTH, 100)];
        [label2 setText:@"save an event"];
        [label2 setFont:[UIFont fontWithName:@"OpenSans-Bold" size:26.0]];
        [label2 setTextColor:color];
        [label2 setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label2];
        
        UIImageView *imv = [[UIImageView alloc] init]; //WithFrame:CGRectMake(30, 200, 224, 55.6)];
        imv = imageArray[index];
        imv.frame = CGRectMake(30, 180, 224, 55.6);
        [tutorialView addSubview:imv];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(15, 270, CARD_WIDTH - 30, 100)];
        [label3 setText:@"We'll notify you before the event starts and when your friends swipe right as well."];
        [label3 setFont:[UIFont fontWithName:@"OpenSans" size:12.0]];
        [label3 setNumberOfLines:0];
        [label3 setTextColor:color];
        [label3 setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label3];
        
        /*
        UIImageView *imv2 = [[UIImageView alloc] initWithFrame:self.bounds];
        imv2.image = [UIImage imageNamed:@"Card Screenshot"];
        [tutorialView insertSubview:imv2 atIndex:0];
        imv2.alpha = 0.1;
        
        UIView *maskView = [[UIView alloc] initWithFrame:imv2.bounds];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.6;
        [imv2 addSubview:maskView]; */
        
    } else if (index == 1) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CARD_WIDTH, 100)];
        [label setText:@"Swipe left if"];
        [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:24.0]];
        [label setTextColor:color];
        [label setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, CARD_WIDTH, 100)];
        [label2 setText:@"you're not interested"];
        [label2 setFont:[UIFont fontWithName:@"OpenSans-Bold" size:24.0]];
        [label2 setTextColor:color];
        [label2 setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label2];
        
        UIImageView *imv = [[UIImageView alloc] init]; //WithFrame:CGRectMake(30, 200, 224, 55.6)];
        imv = imageArray[index];
        imv.frame = CGRectMake(30, 180, 224, 55.6);
        [tutorialView addSubview:imv];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(15, 270, CARD_WIDTH - 30, 100)];
        //[label3 setText:@"This permanently removes the event. Over time, we'll recommend events based on your swipes!"];
        [label3 setFont:[UIFont fontWithName:@"OpenSans" size:11.0]];
        [label3 setNumberOfLines:0];
        [label3 setTextColor:color];
        [label3 setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label3];
        
    } else if (index == 2) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, CARD_WIDTH, 100)];
        [label setText:@"Down to go?"];
        [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:26.0]];
        [label setTextColor:color];
        [label setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, CARD_WIDTH, 100)];
        [label2 setText:@"Swipe down if you're"];
        [label2 setFont:[UIFont fontWithName:@"OpenSans-Bold" size:24.0]];
        [label2 setTextColor:color];
        [label2 setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, CARD_WIDTH, 100)];
        [label3 setText:@"going to an event."];
        [label3 setFont:[UIFont fontWithName:@"OpenSans-Bold" size:24.0]];
        [label3 setTextColor:color];
        [label3 setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label3];
        
        UIImageView *imv = [[UIImageView alloc] init]; //WithFrame:CGRectMake(30, 170, 46.6, 90)];
        imv = imageArray[index];
        imv.frame = CGRectMake(118.7, 190, 46.6, 90);
        [tutorialView addSubview:imv];
        
        tutorialView.tag = 123;
        
    } else if (index == 3) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, CARD_WIDTH, 100)];
        [label setText:@"Tap the card"];
        [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:26.0]];
        [label setTextColor:color];
        [label setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, CARD_WIDTH, 100)];
        [label2 setText:@"for more information"];
        [label2 setFont:[UIFont fontWithName:@"OpenSans-Bold" size:26.0]];
        [label2 setTextColor:color];
        [label2 setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label2];
        
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(121.5, 160, 40, 40)];
        imv.image = [UIImage imageNamed:@"click"];
        [tutorialView addSubview:imv];
        imv.tag = 9;
        
        UIImageView *imv2 = [[UIImageView alloc] init]; //WithFrame:CGRectMake(30, 170, 46.6, 90)];
        imv2 = imageArray[index];
        imv2.frame = CGRectMake(110.5, 210, 63, 370);
        [tutorialView addSubview:imv2];
        imv2.tag = 9;
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 565, CARD_WIDTH, 50)];
        [label3 setText:@"Hey there! Tap to go back."];
        [label3 setFont:[UIFont fontWithName:@"OpenSans-Bold" size:19.0]];
        [label3 setTextColor:color];
        [label3 setTextAlignment:NSTextAlignmentCenter];
        [tutorialView addSubview:label3];
        label3.tag = 9;
        
        self.allowCardExpand = YES;
        self.cardExpanded = NO;
        
        /*
        // Forces user to tap card first
        for (UIPanGestureRecognizer *pgr in [tutorialView gestureRecognizers]) {
            pgr.enabled = NO;
        }
         */
        
    } else if (index == 4) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, CARD_WIDTH - 30, 50)];
        [label setText:@"Happening works best with your current location"];
        [label setTextColor:[UIColor blackColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        label.numberOfLines = 0;
        [tutorialView addSubview:label];
        
        UILabel *sublabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 250, CARD_WIDTH - 30, 50)];
        [sublabel setText:@"We only use your location while the app is open"];
        [sublabel setTextColor:[UIColor blackColor]];
        [sublabel setTextAlignment:NSTextAlignmentCenter];
        sublabel.numberOfLines = 0;
        [tutorialView addSubview:sublabel];
        
        self.allowCardExpand = NO;
        self.cardExpanded = NO;
            
    }/* else if (index == 5) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, CARD_WIDTH - 30, 50)];
        [label setText:@"Choose the city closest to you:"];
        [label setTextColor:[UIColor blackColor]];
        [label setTextAlignment:NSTextAlignmentLeft];
        [tutorialView addSubview:label];
        
        DCLabel = [[UILabel alloc] init]; //WithFrame:CGRectMake(50, 150, 220, 50)];
        [DCLabel setText:@"Washington DC"];
        [DCLabel setTextColor:[UIColor darkGrayColor]];
        [DCLabel setFont:[UIFont fontWithName:@"OpenSans" size:19.0]];
        [DCLabel sizeToFit];
        [DCLabel setCenter: CGPointMake(147, 80)];
        [DCLabel setUserInteractionEnabled:YES];
        DCLabel.alpha = 0.7;
        DCLabel.tag = 1;
        
        bostonLabel = [[UILabel alloc] init]; //WithFrame:CGRectMake(50, 150, 220, 50)];
        [bostonLabel setText:@"Boston"];
        [bostonLabel setFont:[UIFont fontWithName:@"OpenSans" size:19.0]];
        [bostonLabel setTextColor:[UIColor darkGrayColor]];
        [bostonLabel sizeToFit];
        [bostonLabel setCenter: CGPointMake(147, 110)];
        [bostonLabel setUserInteractionEnabled:YES];
        bostonLabel.alpha = 0.7;
        bostonLabel.tag = 2;
        
        UITapGestureRecognizer *DCGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cityTapped:)];
        [DCLabel addGestureRecognizer:DCGR];
        UITapGestureRecognizer *BostonGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cityTapped:)];
        [bostonLabel addGestureRecognizer:BostonGR];
        
        [tutorialView addSubview:DCLabel];
        [tutorialView addSubview:bostonLabel];
        
        slider = [[UISlider alloc] initWithFrame:CGRectMake(15, 165, 254, 30)];
        slider.maximumTrackTintColor = [UIColor whiteColor];
        slider.minimumTrackTintColor = [UIColor colorWithRed:9.0/255 green:80.0/255 blue:208.0/255 alpha:1.0];
        slider.minimumValue = 0;
        slider.maximumValue = 10.0;
        slider.value = 5.0;
        [slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [tutorialView addSubview:slider];

        
        sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(108, 210, 78, 30)];
        [sliderLabel setText:@"25 mi. away"];
        [sliderLabel setFont:[UIFont fontWithName:@"OpenSans" size:14.0]];
        [sliderLabel setTextColor:[UIColor darkTextColor]];
        [sliderLabel sizeToFit];
        //[sliderLabel setCenter: CGPointMake(147, 215)];
        [sliderLabel setTextAlignment:NSTextAlignmentRight];
        [tutorialView addSubview:sliderLabel];
        
        continueButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 250, 75, 30)];
        [continueButton setTitle:@"Leggo" forState:UIControlStateNormal];
        [continueButton setBackgroundColor:[UIColor colorWithRed:9.0/255 green:80.0/255 blue:208.0/255 alpha:1.0]];
        [continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [continueButton addTarget:self action:@selector(didClickContinue:) forControlEvents:UIControlEventTouchUpInside];
        continueButton.layer.masksToBounds = YES;
        continueButton.layer.cornerRadius = 3.0;
        continueButton.layer.borderColor = [UIColor clearColor].CGColor;
        continueButton.layer.borderWidth = 2.0;
        //[continueButton sizeToFit];
        //continueButton.center = CGPointMake(147, 265);
        [tutorialView addSubview:continueButton];

        // Forces user to tap card first
        for (UIPanGestureRecognizer *pgr in [tutorialView gestureRecognizers]) {
            [tutorialView removeGestureRecognizer:pgr];
        }
        
    } */
    
    
    return tutorialView;
}

/*
- (void)cityTapped:(UITapGestureRecognizer *)gr {
    
    UILabel *label = (UILabel *)gr.view;
    
    if (label.tag == 1) {
        NSLog(@"Washington DC selected");
        
        DCLabel.textColor = [UIColor darkTextColor];
        bostonLabel.textColor = [UIColor darkGrayColor];
        
        DCLabel.font = [UIFont fontWithName:@"OpenSans" size:21.0];
        bostonLabel.font = [UIFont fontWithName:@"OpenSans" size:19.0];
        
        DCLabel.alpha = 1.0;
        bostonLabel.alpha = 0.7;
        
    } else if (label.tag == 2) {
        NSLog(@"Boston selected");
        
        DCLabel.textColor = [UIColor darkGrayColor];
        bostonLabel.textColor = [UIColor darkTextColor];
        
        DCLabel.font = [UIFont fontWithName:@"OpenSans" size:19.0];
        bostonLabel.font = [UIFont fontWithName:@"OpenSans" size:21.0];
        
        DCLabel.alpha = 0.7;
        bostonLabel.alpha = 1.0;
    }
    
    [DCLabel sizeToFit];
    [DCLabel setCenter: CGPointMake(147, 80)];
    [bostonLabel sizeToFit];
    [bostonLabel setCenter: CGPointMake(147, 110)];
    

}

- (void)sliderValueChanged {
    
    NSString *distanceString = [[NSString alloc]init];
    float sliderVal = 0;
    
    if (slider.value > 1) {
        
        sliderVal = (int)slider.value * 5;
        distanceString = [NSString stringWithFormat:@"%ld mi. away", (long)sliderVal];
        sliderLabel.text = distanceString;
        
    } else if (slider.value > 0.2) {
        
        sliderVal = slider.value * 5;
        distanceString = [NSString stringWithFormat:@"%ld mi. away", (long)sliderVal];
        sliderLabel.text = distanceString;
        
    } else {
        
        sliderVal = 1;
        distanceString = @"1 mi. away";
        sliderLabel.text = distanceString;
        
    }
    
}
*/

-(void)nowScrollDown {
    
    for (UIView *view in dragView.subviews) {
        
        if (view.tag == 3) {
            [view removeFromSuperview];
        }
        
    }
    
    UIColor *color = [UIColor colorWithRed:77.0/255.0 green:78.0/255.0 blue:77.0/255.0 alpha:1.0];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, CARD_WIDTH, 100)];
    [label setText:@"Scroll down for"];
    [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:23.0]];
    [label setTextColor:color];
    [label setTextAlignment:NSTextAlignmentCenter];
    [dragView addSubview:label];
    label.tag = 9;
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, CARD_WIDTH, 100)];
    [label2 setText:@"more information"];
    [label2 setFont:[UIFont fontWithName:@"OpenSans-Bold" size:23.0]];
    [label2 setTextColor:color];
    [label2 setTextAlignment:NSTextAlignmentCenter];
    [dragView addSubview:label2];
    label2.tag = 9;
    
    
}

-(void)tapButtons {
    
    self.allowCardExpand = NO;
    self.allowCardSwipe = NO;
    
    for (UIView *view in dragView.subviews) {
        
        if (view.tag == 9) {
            [view removeFromSuperview];
        }
        
    }
    
    UIColor *color = [UIColor colorWithRed:77.0/255.0 green:78.0/255.0 blue:77.0/255.0 alpha:1.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -5, CARD_WIDTH, 100)];
    [label setText:@"Nice!"];
    [label setFont:[UIFont fontWithName:@"OpenSans-Bold" size:25.0]];
    [label setTextColor:color];
    [label setTextAlignment:NSTextAlignmentCenter];
    [dragView addSubview:label];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, CARD_WIDTH, 100)];
    [label2 setText:@"You can also tap these buttons"];
    [label2 setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16.0]];
    [label2 setTextColor:color];
    [label2 setTextAlignment:NSTextAlignmentCenter];
    [dragView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, CARD_WIDTH, 100)];
    [label3 setText:@"to swipe a card right or left"];
    [label3 setFont:[UIFont fontWithName:@"OpenSans-Bold" size:16.0]];
    [label3 setTextColor:color];
    [label3 setTextAlignment:NSTextAlignmentCenter];
    [dragView addSubview:label3];
    
    UIImageView *imv = [[UIImageView alloc] init]; //WithFrame:CGRectMake(30, 200, 224, 55.6)];
    imv.image = [UIImage imageNamed:@"sideboth"];
    imv.frame = CGRectMake(25, 180, 234, 100);
    [dragView addSubview:imv];
    
    [self showButtons];
}

-(void)showButtons {
    
    [self.myViewController.xButton addTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
    [self.myViewController.checkButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];

    
    [UIView animateWithDuration:0.7 animations:^{
        
        self.myViewController.xButton.center = CGPointMake(21.75, self.myViewController.xButton.center.y);
        self.myViewController.checkButton.center = CGPointMake(302.25, self.myViewController.checkButton.center.y);
        
    } completion:^(BOOL finished) {
        //code
    }];
}


//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    NSInteger cardCount = [imageArray count];
        
    NSLog(@"%lu cards loaded",(unsigned long)cardCount);
        

    if(cardCount > 0) {
            NSInteger numLoadedCardsCap =((cardCount > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:cardCount);
            //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
            
            //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
            for (int i = 0; i<cardCount; i++) {
                UIView* newCard = [self createDraggableViewWithDataAtIndex:i];
                [allCards addObject:newCard];
                
                if (i<numLoadedCardsCap) {
                    //%%% adds a small number of cards to be loaded
                    [loadedCards addObject:newCard];
                }
            }
            
            
            
            //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
            // are showing at once and clogging a ton of data
            for (int i = 0; i<[loadedCards count]; i++) {
                if (i>0) {
                    [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
                } else {
                    [self addSubview:[loadedCards objectAtIndex:i]];
                }
                cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
            }
        }
        
        if (loadedCards.count > 0) {
            dragView = [loadedCards objectAtIndex:0]; // Make dragView the current card
            //[dragView.cardBackground removeFromSuperview];
        }
    
    
}

//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card fromExpandedView:(BOOL)expandedBool
{
    //do whatever you want with the card that was swiped

    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        //[self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
    dragView = [loadedCards firstObject]; // Make dragView the current card
    //[dragView.cardBackground removeFromSuperview];

    if (dragView.tag == 3 || dragView.tag == 5) {
        [self setEnabledSidewaysScrolling:NO];
        [cardBackground removeFromSuperview];
    } else {
        [self setEnabledSidewaysScrolling:YES];
    }
    
    [cardBackground removeFromSuperview];
    
}

//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card fromExpandedView:(BOOL)expandedBool
{
    //do whatever you want with the card that was swiped
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
    dragView = [loadedCards firstObject]; // Make dragView the current card
    
    if (dragView.tag == 3 || dragView.tag == 5) {
        [self setEnabledSidewaysScrolling:NO];
        [cardBackground removeFromSuperview];
    } else {
        [self setEnabledSidewaysScrolling:YES];
    }
    
}

-(void)rightClick
{
    
    if (self.myViewController.tutIsShown) {
    
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];
    
    CGPoint finishPoint = CGPointMake(900, self.center.y);
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        dragView.center = finishPoint;
        dragView.transform = CGAffineTransformMakeRotation(1);
    }completion:^(BOOL complete){

        [self setEnabledSidewaysScrolling:YES];
        [self removeFromSuperview];
        
        //[checkButton removeTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
        //[xButton removeTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
        
        //if (dragView.tag == 50 || dragView.tag == 3) {
            NSLog(@"Last card swiped");
            [self.myViewController dropdownPressedFromTut:YES];
            [self.myViewController dropdownPressed];
        //}
    }];
    
    
    [self cardSwipedRight:self fromExpandedView:NO];
    
    NSLog(@"YES");
        
    }
}

-(void)leftClick
{
    
    if (self.myViewController.tutIsShown) {
    
    //self.superview.superview.superview.userInteractionEnabled = NO; // BE CAREFUL... disables UI during button click
    [self setEnabledSidewaysScrolling:NO];
    
    CGPoint finishPoint = CGPointMake(-600, self.center.y);
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        dragView.center = finishPoint;
        dragView.transform = CGAffineTransformMakeRotation(-1);
    }completion:^(BOOL complete){

        [self setEnabledSidewaysScrolling:YES];
        [self removeFromSuperview];
        
        //[checkButton removeTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
        //[xButton removeTarget:self action:@selector(leftClick) forControlEvents:UIControlEventTouchUpInside];
        
        //if (dragView.tag == 50 || dragView.tag == 3) {
            NSLog(@"Last card swiped");
            [self.myViewController dropdownPressedFromTut:YES];
            [self.myViewController dropdownPressed];
        //}
    }];
    
    [self cardSwipedLeft:self fromExpandedView:NO];
    
    NSLog(@"NO");
        
    }
}

-(void)cardExpanded:(BOOL)b
{
    NSLog(@"Drag view tapped");
    
    if (b) {
        self.panGestureRecognizer.enabled = NO;
    } else {
        self.panGestureRecognizer.enabled = YES;
    }
    
    
}

- (void)setEnabledSidewaysScrolling:(BOOL)enabled {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RKSwipeBetweenViewControllers *rk = appDelegate.rk;
    [rk scrolling:enabled];
    
}

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status)
    {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar:YES];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message card the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied: [self accessGrantedForCalendar:NO];
        case EKAuthorizationStatusRestricted: [self accessGrantedForCalendar:NO];
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Calendar"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Oops"
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
         
         UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
         
         if (granted)
         {
             //[self accessGrantedForCalendar];
         }
         
         /*
         UILabel *boomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
         boomLabel.center = CGPointMake(-self.center.x, self.center.y - 100);
         
         boomLabel.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:30.0];
         boomLabel.textColor = [UIColor colorWithRed:70.0/255 green:70.0/255 blue:70.0/255 alpha:1.0];
         [self addSubview:boomLabel];
         boomLabel.text = @"Boom";
         boomLabel.textAlignment = NSTextAlignmentCenter;
         
         UILabel *simpleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
         simpleLabel.center = CGPointMake(self.center.x * 3, self.center.y - 50);
         simpleLabel.font = [UIFont fontWithName:@"OpenSans" size:25.0];
         simpleLabel.textColor = [UIColor colorWithRed:70.0/255 green:70.0/255 blue:70.0/255 alpha:1.0];
         [self addSubview:simpleLabel];
         simpleLabel.text = @"It's that simple.";
         simpleLabel.textAlignment = NSTextAlignmentCenter;
         
         
         [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.67 options:UIViewAnimationOptionTransitionNone animations:^{
             
             boomLabel.center = CGPointMake(self.center.x - 18, self.center.y - 100);
             simpleLabel.center = CGPointMake(self.center.x - 18, self.center.y - 50);
             
         } completion:^(BOOL finished) {
             
             [UIView animateWithDuration:0.5 delay:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                 
                 boomLabel.center = CGPointMake(self.center.x*3, self.center.y - 100);
                 simpleLabel.center = CGPointMake(-self.center.x, self.center.y - 50);
                 
             } completion:^(BOOL finished) {
                 
                 [self.myViewController dropdownPressedFromTut:YES];
                 [self.myViewController dropdownPressed];
             }];
             
         }]; */
         dispatch_async(dispatch_get_main_queue(), ^{

             [self.myViewController dropdownPressedFromTut:YES];
             [self.myViewController dropdownPressed];
         });
         
     }];
}


// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar:(BOOL)granted
{
    
    [self.myViewController dropdownPressedFromTut:YES];
    [self.myViewController dropdownPressed];

}


//%%% called when you move your finger across the screen.
// called many times a second
-(void)beingDragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    UIView *view = gestureRecognizer.view;
    //%%% this extracts the coordinate data from your swipe movement. (i.e. How much did you move?)
    xFromCenter = [gestureRecognizer translationInView:dragView].x; //%%% positive for right swipe, negative for left
    yFromCenter = [gestureRecognizer translationInView:dragView].y; //%%% positive for down, negative for up
    
    // Marker check to ensure correct tutorial swipe action
    BOOL shouldSwipe = YES;
    if (view.tag == 0) {
        if (xFromCenter < 0) {
            shouldSwipe = NO;
            //view.center = CGPointMake(self.originalPoint.x, self.originalPoint.y);
        }
    } else if (view.tag == 1) {
        if (xFromCenter > 0) {
            shouldSwipe = NO;
            //view.center = CGPointMake(self.originalPoint.x, self.originalPoint.y);
        }
    } else if (view.tag == 2 || view.tag == 123) {
        if (yFromCenter < 0) {
            shouldSwipe = NO;
            //view.center = CGPointMake(self.originalPoint.x, self.originalPoint.y);
        }
    }
    
    // View does not move
    if ( !( (view.tag == 3) || (view.tag == 5) ) && self.allowCardSwipe ) {
    
    //%%% checks what state the gesture is in. (are you just starting, letting go, or in the middle of a swipe?)
    switch (gestureRecognizer.state) {
            //%%% just started swiping
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = view.center;
            break;
        };
            //%%% in the middle of a swipe
        case UIGestureRecognizerStateChanged:{
            //%%% dictates rotation (see ROTATION_MAX and ROTATION_STRENGTH for details)
            CGFloat rotationStrength = MIN(xFromCenter / ROTATION_STRENGTH, ROTATION_MAX);
            
            //%%% degree change in radians
            CGFloat rotationAngle = (CGFloat) (ROTATION_ANGLE * rotationStrength);
            
            //%%% amount the height changes when you move the card up to a certain point
            CGFloat scale = MAX(1 - fabsf(rotationStrength) / SCALE_STRENGTH, SCALE_MAX);
            
            //%%% move the object's center by center + gesture coordinate
            view.center = CGPointMake(self.originalPoint.x + xFromCenter, self.originalPoint.y + yFromCenter);
            
            //%%% rotate by certain amount
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngle);
            
            //%%% scale by certain amount
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            
            //%%% apply transformations
            view.transform = scaleTransform;
            
            OverlayView *ov = (OverlayView *)[view viewWithTag:99];
            [self updateOverlay:xFromCenter :yFromCenter overlayView:ov cardNumber:view.tag];
            
            
            break;
        };
            //%%% let go of the card
        case UIGestureRecognizerStateEnded: {
            
            [self afterSwipeAction:view shouldSwipe:shouldSwipe];
            
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:break;
        case UIGestureRecognizerStateFailed:break;
    }
        
    }

}

//%%% checks to see if you are moving right or left and applies the correct overlay image
-(void)updateOverlay:(CGFloat)xDistance :(CGFloat)yDistance overlayView:(OverlayView *)overlayView cardNumber:(NSInteger)num
{
    if (xDistance > 0 && (num == 0 || num > 2)) {
        overlayView.mode = GGOverlayViewModeRight;
        overlayView.alpha = MIN(fabsf(xDistance)/100, 1.0); //based on x coordinate
        
    } else if (xDistance < 0 && (num == 1 || num > 2)) { //Higher on swipe left b/c of intent for left swipe
        overlayView.mode = GGOverlayViewModeLeft;
        overlayView.alpha = MIN(fabsf(xDistance)/100, 1.0); //based on x
        
    } else if (yDistance > 0 && (num == 2)){
        overlayView.mode = GGOverlayViewModeDown;
        overlayView.alpha = MIN(fabsf(yDistance)/100, 1.0); //based on y
        
    }
    
     else {
         overlayView.alpha = 0;
     }
    
    
}

//%%% called when the card is let go
- (void)afterSwipeAction:(UIView *)card shouldSwipe:(BOOL)b
{
    if (card.tag == 0) {
        
        self.swipeDownMargin = 1000;
        
    } else if (card.tag == 1) {
        
        self.swipeDownMargin = 1000;
        
    } else if (card.tag == 2 || card.tag == 123) {
        
        self.swipeDownMargin = 100;
        self.actionMargin = 1000;
        
    } else if (card.tag > 2) {
        
        self.actionMargin = 60;
        self.swipeDownMargin = 1000;
        
    }
    
    if (b) {
    
        if (xFromCenter > self.actionMargin && yFromCenter < self.swipeDownMargin) {
            [self rightAction:card];
        } else if (xFromCenter < -self.actionMargin && yFromCenter < self.swipeDownMargin + 50) { //Higher on swipe left b/c    of intent for left swipe
            [self leftAction:card];
        } else if (yFromCenter > self.swipeDownMargin) { //add to cal
            [self downAction:card];
        } else {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 dragView.center = self.originalPoint;
                                 dragView.transform = CGAffineTransformMakeRotation(0);
                             
                                 OverlayView *ov = (OverlayView *)[dragView viewWithTag:99];
                                 ov.alpha = 0;
                                 
                             } completion:^(BOOL finished) {
                                 
                             }];

        }
    } else { //%%% resets the card
        [UIView animateWithDuration:0.3
                        animations:^{
                            dragView.center = self.originalPoint;
                            dragView.transform = CGAffineTransformMakeRotation(0);
                             
                            OverlayView *ov = (OverlayView *)[dragView viewWithTag:99];
                            ov.alpha = 0;
                        }];
    }
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the right
-(void)rightAction:(UIView *)card
{
    
    /*
    if (card.tag == 4) {
        [self didChooseCurrentLoc];
    } */
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //appDelegate
    
    CGPoint finishPoint = CGPointMake(500, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         card.center = finishPoint;
                     }completion:^(BOOL complete){
                         [card removeFromSuperview];
                         
                         
                         if (card.tag == 50 || card.tag == 3) {
                             NSLog(@"Last card swiped");

                             [self.myViewController dropdownPressedFromTut:YES];
                             [self.myViewController dropdownPressed];
                         }
                     }];
    
    //[dragView removeFromSuperview];
    [self cardSwipedRight:card fromExpandedView:NO];
    
    NSLog(@"YES");
}

//%%% called when a swipe exceeds the ACTION_MARGIN to the left
-(void)leftAction:(UIView *)card
{
    
    CGPoint finishPoint = CGPointMake(-200, 2*yFromCenter +self.originalPoint.y);
    [UIView animateWithDuration:0.3
                     animations:^{
                         card.center = finishPoint;
                     }completion:^(BOOL complete){
                         [card removeFromSuperview];
                     }];
     
                         
                         
    
    [self cardSwipedLeft:card fromExpandedView:NO];
    
    NSLog(@"NO");
}

-(void)downAction:(UIView *)card
{

    CGPoint finishPoint = CGPointMake(dragView.frame.size.width / 2, 700);
    [UIView animateWithDuration:0.3
                     animations:^{
                         card.center = finishPoint;
                     }completion:^(BOOL complete){
                         [card removeFromSuperview];
                         
                         if (card.tag == 123) {
                             
                             NSLog(@"Last card swiped");
                             
                             BOOL notisEnabled = NO;
                             BOOL locEnabled = NO;
                             
                             if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                                 NSLog(@" ====== iOS 7 ====== ");
                                 UIRemoteNotificationType enabledTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
                                 if (enabledTypes) notisEnabled = YES;
                                 //if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) locEnabled = YES;
                             } else {
                                 NSLog(@" ====== iOS 8 ====== ");
                                 if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) notisEnabled = YES;
                                 if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) locEnabled = YES;
                             }
                             
                             if (!notisEnabled || !locEnabled) {
                             
                                 PermissionsView *permissionsView = [[PermissionsView alloc] initWithFrame:CGRectMake(0, 0, 300, 360)];
                                 permissionsView.center = CGPointMake(self.center.x - 18, self.center.y - 80);
                                 [self addSubview:permissionsView];
                                 self.userInteractionEnabled = YES;
                                 permissionsView.delegate = self;
                             
                             } else {
                                 
                                 [self.myViewController dropdownPressedFromTut:YES];
                                 [self.myViewController dropdownPressed];
                             }
                             
                         }
                         
                         /*
                          if (card.tag == 50 || card.tag == 3) {
                          NSLog(@"Last card swiped");
                          [self.myViewController dropdownPressedFromTut:YES];
                          [self.myViewController dropdownPressed];
                          }*/
                     }];
    
    //[self checkEventStoreAccessForCalendar];
    
    [self cardSwipedRight:card fromExpandedView:NO];
    
    NSLog(@"DOWN");
}

- (void)didChooseCurrentLoc {
    
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Uh-oh" message:@"Please turn on your location services! Go to Settings -> Privacy -> Location Services -> On" delegate:self cancelButtonTitle:@"I'm on it" otherButtonTitles:nil, nil];
        [alert show];
    } else if(self.locManager==nil){
        locManager = [[CLLocationManager alloc] init];
        locManager.delegate=self;
        [locManager requestWhenInUseAuthorization];
        locManager.desiredAccuracy=kCLLocationAccuracyBest;
        locManager.distanceFilter=50;
        [locManager startUpdatingLocation];
    } else {
        // peace out -- already authorized CL
        // Never show this again
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunched"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        //[delegate setLocationSegue];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        
        //[delegate setLocationSegue];
        [self.locManager startUpdatingLocation];
    }
}

-(void)userEnabledNotis {
    
        //AppDelegate *ad = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            
            NSLog(@" ====== iOS 7 ====== ");
            
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
            
        } else {
            
            NSLog(@" ====== iOS 8 ====== ");
            
            UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                            UIUserNotificationTypeBadge |
                                                            UIUserNotificationTypeSound);
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                     categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didRegister)
                                                         name:@"moveAlong"
                                                       object:nil];
        }
    
}

-(void)userEnabledLoc {
 
    
    
}

-(void)moveOn {
    
    [self.myViewController dropdownPressedFromTut:YES];
    [self.myViewController dropdownPressed];
    
}

-(void)didRegister {
    
    BOOL locEnabled = NO;
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        NSLog(@" ====== iOS 7 ====== ");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) locEnabled = YES;
    } else {
        NSLog(@" ====== iOS 8 ====== ");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) locEnabled = YES;
    }
    
    if ([[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        //[self requestCalendarAccess];
    } else {
        //[self.myViewController dropdownPressedFromTut:YES];
        //[self.myViewController dropdownPressed];
    }
}

#warning BE CAREFUL --- fix this later. updates literally every second... unnecessary
/*
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    PFUser *user = [PFUser currentUser];
    
    
    PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:locManager.location];
    user[@"userLoc"] = loc;
    user[@"userLocTitle"] = @"Current Location";
    [user saveEventually];
     
    // Peace out!
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults setBool:YES forKey:@"hasLaunched"];
    [defaults setObject:@"Current Location" forKey:@"userLocTitle"];
    [defaults setObject:@"" forKey:@"userLocSubtitle"];
    [defaults synchronize];
    
    //[delegate setLocationSegue];
} */

- (void)didClickContinue:(id)sender {
    
    // Never show this again
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunched"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshData"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Peace out
    [delegate refreshData];
    //[self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
