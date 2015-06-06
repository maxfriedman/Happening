//
//  RKSwipeBetweenViewControllers.m
//  RKSwipeBetweenViewControllers
//
//  Created by Richard Kim on 7/24/14.
//  Copyright (c) 2014 Richard Kim. All rights reserved.
//
//  @cwRichardKim for regular updates

#import "RKSwipeBetweenViewControllers.h"
#import "DragViewController.h"
#import "MyEventsTVC.h"
#import "UIButton+Extensions.h"
#import "AppDelegate.h"
#import "AMPopTip.h"
#import "GroupsTVC.h"
#import "ProfileTVC.h"

//%%% customizeable button attributes
#define X_BUFFER 0 //%%% the number of pixels on either side of the segment
#define Y_BUFFER 7 //%%% number of pixels on top of the segment
#define HEIGHT 30 //%%% height of the segment

//%%% customizeable selector bar attributes (the black bar under the buttons)
#define ANIMATION_SPEED 0.2 //%%% the number of seconds it takes to complete the animation
#define SELECTOR_Y_BUFFER 40 //%%% the y-value of the bar that shows what page you are on (0 is the top)
#define SELECTOR_HEIGHT 4 //%%% thickness of the selector bar

#define X_OFFSET 2 //%%% for some reason there's a little bit of a glitchy offset.  I'm going to look for a better workaround in the future

@interface RKSwipeBetweenViewControllers () {
    
    BOOL leftButtonTapScrolling;
    BOOL middleButtonTapScrolling;
    BOOL rightButtonTapScrolling;
    BOOL longScroll;
    
    DragViewController *dvc;
    
    AMPopTip *popTip;
}

@end

@implementation RKSwipeBetweenViewControllers
@synthesize viewControllerArray;
@synthesize selectionBar;
@synthesize panGestureRecognizer;
@synthesize pageController;
@synthesize navigationView;
@synthesize buttonText;
@synthesize pageScrollView, rightLabel, middleLabel, leftLabel, currentPageIndex, middleButton, middleButton2, rightButton, leftButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.navigationBar.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:53.0/255 green:182.0/255 blue:252.0/255 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:57.0/255 green:222.0/255 blue:253.0/255 alpha:1.0] CGColor], nil];
     
    gradient.startPoint = CGPointMake(0.0, 0.00f);
    gradient.endPoint = CGPointMake(0.0f, 1.0f);
    
    [self.navigationBar.layer insertSublayer:gradient atIndex:0];
    */
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = NO;
    viewControllerArray = [[NSMutableArray alloc]init];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DragViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Discover"];
    
    dvc = vc;
    
    GroupsTVC *gtvc = [storyboard instantiateViewControllerWithIdentifier:@"GroupsTVC"];
    ProfileTVC *ptvc = [storyboard instantiateViewControllerWithIdentifier:@"Create"];

    [viewControllerArray addObjectsFromArray:@[gtvc,vc,ptvc]];
    
    [self updateCurrentPageIndex:1];
    
    leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, Y_BUFFER, 50, 20)];
    //leftLabel.text = @"Events";
    leftLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    leftLabel.textColor = [UIColor whiteColor];
    
    rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(-50, Y_BUFFER, 50, 20)];
    //rightLabel.text = @"Profile";
    rightLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    rightLabel.textColor = [UIColor whiteColor];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.rk = self;
    
    //NSLog(@"===========> %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunched"]);

    
    //[vc refreshData];
    
}

//This stuff here is customizeable: buttons, views, etc
////////////////////////////////////////////////////////////
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%%%    CUSTOMIZEABLE    %%%%%%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//

//%%% color of the status bar
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
    
    //    return UIStatusBarStyleDefault;
}

//%%% sets up the tabs using a loop.  You can take apart the loop to customize individual buttons, but remember to tag the buttons.  (button.tag=0 and the second button.tag=1, etc)
-(void)setupSegmentButtons
{
    navigationView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.navigationBar.frame.size.height)];
    
    //NSInteger numControllers = [viewControllerArray count];
    
    if (!buttonText) {
        buttonText = [[NSArray alloc]initWithObjects: @"Create",@"Discover",@"Attend",nil]; //%%%buttontitle
    }
    
    /*
    for (int i = 0; i<numControllers; i++) {
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(X_BUFFER+i*(self.view.frame.size.width-2*X_BUFFER)/numControllers-X_OFFSET, Y_BUFFER, (self.view.frame.size.width-2*X_BUFFER)/numControllers, HEIGHT)];
        [navigationView addSubview:button];
        
        button.tag = i; //%%% IMPORTANT: if you make your own custom buttons, you have to tag them appropriately
        button.backgroundColor = [UIColor colorWithRed:0.03 green:0.07 blue:0.08 alpha:1];//%%% buttoncolors
        
        [button addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTitle:[buttonText objectAtIndex:i] forState:UIControlStateNormal]; //%%%buttontitle
    }
    */
    
    //%%% example custom buttons example:
    
     //NSInteger width = (self.navigationView.frame.size.width-(2*X_BUFFER))/3;
    NSInteger width = 304/3;
     leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, Y_BUFFER, 25, 30)];
     middleButton = [[UIButton alloc]initWithFrame:CGRectMake(X_BUFFER+width-15, Y_BUFFER + 5, width + 30, 21.5)];
     middleButton2 = [[UIButton alloc]initWithFrame:CGRectMake(width*3/2 - 15, Y_BUFFER, 30, 30)];
     rightButton = [[UIButton alloc]initWithFrame:CGRectMake(75+2*width, Y_BUFFER, 24, HEIGHT)];
     
     [navigationView addSubview:leftButton];
     [navigationView addSubview:middleButton];
     [navigationView addSubview:middleButton2];
     [navigationView addSubview:rightButton];
    
     middleButton2.alpha = 0;
     
     leftButton.tag = 0;
     middleButton.tag = 1;
     middleButton2.tag = 1;
     rightButton.tag = 2;
     
     leftButton.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0];;
     middleButton.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0];;
     rightButton.backgroundColor = [UIColor clearColor]; //[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0];;
     middleButton2.backgroundColor = [UIColor clearColor];
     
     [leftButton addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
     //[middleButton addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
     [middleButton2 addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
     [rightButton addTarget:self action:@selector(tapSegmentButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [leftButton addTarget:self action:@selector(leftButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [middleButton addTarget:self action:@selector(refreshButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [middleButton2 addTarget:self action:@selector(middleButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [rightButton addTarget:self action:@selector(rightButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
     //[leftButton setTitle:@"Create" forState:UIControlStateNormal];
     //[middleButton setTitle:@"Happening" forState:UIControlStateNormal];
     //[rightButton setTitle:@"Attend" forState:UIControlStateNormal];
    
    [leftButton setImage:[UIImage imageNamed:@"profile_white"] forState:UIControlStateNormal];
    [middleButton setImage:[UIImage imageNamed:@"happening text logo"] forState:UIControlStateNormal];
    [middleButton2 setImage:[UIImage imageNamed:@"happening logo"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"attend_white"] forState:UIControlStateNormal];

    //[leftButton setFrame: CGRectMake(leftButton.frame.origin.x, leftButton.frame.origin.y, 60, 30)];
    //leftButton.imageEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [leftButton setTitle:@"TESTING" forState:UIControlStateNormal];
    //[leftButton sizeToFit];
    
    [leftButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -30)];
    [rightButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -30, -10, -10)];
    [middleButton2 setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    leftLabel.alpha = 0;
    rightLabel.alpha = 0;
    [leftButton addSubview:leftLabel];
    [rightButton addSubview:rightLabel];
    
    pageController.navigationController.navigationBar.topItem.titleView = navigationView;
    
    [self setupSelector];
}


//%%% sets up the selection bar under the buttons on the navigation bar
-(void)setupSelector
{
    if (currentPageIndex == 1) {
    
    selectionBar = [[UIView alloc]initWithFrame:CGRectMake(98, SELECTOR_Y_BUFFER,(self.view.frame.size.width-2*X_BUFFER)/[viewControllerArray count], SELECTOR_HEIGHT)];
        
    } else {
        
        selectionBar = [[UIView alloc]initWithFrame:CGRectMake(X_BUFFER-X_OFFSET, SELECTOR_Y_BUFFER,(self.view.frame.size.width-2*X_BUFFER)/[viewControllerArray count], SELECTOR_HEIGHT)];
        
    }
    selectionBar.backgroundColor = [UIColor greenColor]; //%%% sbcolor
    selectionBar.alpha = 0.8; //%%% sbalpha
    //[navigationView addSubview:selectionBar];
}

//                                                        //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%%%    CUSTOMIZEABLE    %%%%%%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
////////////////////////////////////////////////////////////





//generally, this shouldn't be changed unless you know what you're changing
////////////////////////////////////////////////////////////
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%%%%        SETUP       %%%%%%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//                                                        //

-(void)viewWillAppear:(BOOL)animated
{
    [self setupPageViewController];
    [self setupSegmentButtons];
}

//%%% generic setup stuff for a pageview controller.  Sets up the scrolling style and delegate for the controller
-(void)setupPageViewController
{
    pageController = (UIPageViewController*)self.topViewController;
    pageController.delegate = self;
    pageController.dataSource = self;
    [pageController setViewControllers:@[[viewControllerArray objectAtIndex:currentPageIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    pageController.view.backgroundColor = [UIColor whiteColor];
    [self syncScrollView];
}

//%%% this allows us to get information back from the scrollview, namely the coordinate information that we can link to the selection bar.
-(void)syncScrollView
{
    for (UIView* view in pageController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]])
        {
            pageScrollView = (UIScrollView *)view;
            pageScrollView.delegate = self;
            //pageScrollView.scrollEnabled = NO;
        }
    }
}

-(void)setScrollEnabled:(BOOL)enabled forPageViewController:(UIPageViewController*)pageViewController{
    for(UIView* view in pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]){
            UIScrollView* scrollView=(UIScrollView*)view;
            [scrollView setScrollEnabled:enabled];
            return;
        }
    }
}

- (void)scrolling:(BOOL)enabled {
    
    [self setScrollEnabled:enabled forPageViewController:pageController];
}


//                                                        //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%%%%        SETUP       %%%%%%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
////////////////////////////////////////////////////////////




//%%% methods called when you tap a button or scroll through the pages
// generally shouldn't touch this unless you know what you're doing or
// have a particular performance thing in mind
//////////////////////////////////////////////////////////
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%        MOVEMENT         %%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//                                                      //

//%%% when you tap one of the buttons, it shows that page,
//but it also has to animate the other pages to make it feel like you're crossing a 2d expansion,
//so there's a loop that shows every view controller in the array up to the one you selected
//eg: if you're on page 1 and you click tab 3, then it shows you page 2 and then page 3
-(void)tapSegmentButtonAction:(UIButton *)button
{
    NSInteger tempIndex = currentPageIndex;
    
    __weak typeof(self) weakSelf = self;
    
    //%%% check to see if you're going left -> right or right -> left
    if (button.tag > tempIndex) {
        
        //%%% scroll through all the objects between the two points
        for (int i = (int)tempIndex+1; i<=button.tag; i++) {
            [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL complete){
                
                //%%% if the action finishes scrolling (i.e. the user doesn't stop it in the middle),
                //then it updates the page that it's currently on
                if (complete) {
                    [weakSelf updateCurrentPageIndex:i];
                }
            }];
        }
    }
    
    //%%% this is the same thing but for going right -> left
    else if (button.tag < tempIndex) {
        for (int i = (int)tempIndex-1; i >= button.tag; i--) {
            [pageController setViewControllers:@[[viewControllerArray objectAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL complete){
                if (complete) {
                    [weakSelf updateCurrentPageIndex:i];
                }
            }];
        }
    }
    
}

//%%% makes sure the nav bar is always aware of what page you're on
//in reference to the array of view controllers you gave
-(void)updateCurrentPageIndex:(int)newIndex
{
    //NSLog(@"1. current page index: %lu", currentPageIndex);
    currentPageIndex = newIndex;
    //NSLog(@"2. current page index: %lu", currentPageIndex);

}

//%%% method is called when any of the pages moves.
//It extracts the xcoordinate from the center point and instructs the selection bar to move accordingly
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat xFromCenter = self.view.frame.size.width-pageScrollView.contentOffset.x; //%%% positive for right swipe, negative for left
    
    //%%% checks to see what page you are on and adjusts the xCoor accordingly.
    //i.e. if you're on the second page, it makes sure that the bar starts from the frame.origin.x of the
    //second tab instead of the beginning
    NSInteger xCoor = X_BUFFER+selectionBar.frame.size.width*currentPageIndex-X_OFFSET;
    
    selectionBar.frame = CGRectMake(xCoor-xFromCenter/[viewControllerArray count], selectionBar.frame.origin.y, selectionBar.frame.size.width, selectionBar.frame.size.height);
    
    //NSLog(@"%f", xFromCenter);
    
    if (leftButtonTapScrolling) {
        [self fadeLabels:0];
    } else if (middleButtonTapScrolling) {
        [self fadeLabels:1];
    } else if (rightButtonTapScrolling) {
        [self fadeLabels:2];
    }
    /*
     leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, Y_BUFFER, 25, 30)];
     middleButton = [[UIButton alloc]initWithFrame:CGRectMake(X_BUFFER+width-15, Y_BUFFER + 5, width + 30, 21.5)];
     middleButton2 = [[UIButton alloc]initWithFrame:CGRectMake(width*3/2 - 15, Y_BUFFER, 30, 30)];
     rightButton = [[UIButton alloc]initWithFrame:CGRectMake(75+2*width, Y_BUFFER, 24, HEIGHT)];
     */
    
    float zeroToOne = abs((int)xFromCenter) / 320.0;
    float oneToZero = 1 - abs((int)xFromCenter) / 320.0;
    
    if (xCoor == -2) {
        
        if (abs((int)xFromCenter) > 0) {
        
           // NSLog (@"Left label");
            
            leftLabel.alpha = oneToZero;
            middleButton2.alpha = oneToZero;
            middleButton.alpha = zeroToOne;
            
            NSInteger width = 304/3;
            leftButton.frame = CGRectMake((width*3/2 - 15)*oneToZero, Y_BUFFER, 25, 30);
            //middleButton.frame = CGRectMake(X_BUFFER+width-15 + (width+35)*zeroToOne, Y_BUFFER + 5, width + 30, 21.5);
            //middleButton2.frame = CGRectMake(width*3/2 - 15 + (width/2+90)*zeroToOne, Y_BUFFER, 30, 30);
            middleButton.frame = CGRectMake(X_BUFFER+width+width+20 - (width+35)*zeroToOne, Y_BUFFER + 5, width + 30, 21.5);
            middleButton2.frame = CGRectMake(75+2*width - (width/2+90)*zeroToOne, Y_BUFFER, 30, 30);
            rightButton.frame = CGRectMake(75+3*width - width*zeroToOne, Y_BUFFER, 24, HEIGHT);

        }
        
    } else if (xCoor == 104) {
        
       // NSLog (@"Middle Label");
        
        if (xFromCenter > 0) {

            leftLabel.alpha = zeroToOne;
            middleButton2.alpha = zeroToOne;
            middleButton.alpha = oneToZero;
            
            NSInteger width = 304/3;
            leftButton.frame = CGRectMake((width*3/2 - 15) * zeroToOne, Y_BUFFER, 25, 30);
            middleButton.frame = CGRectMake(X_BUFFER+width-15 + (width+35) * zeroToOne, Y_BUFFER + 5, width + 30, 21.5);
            middleButton2.frame = CGRectMake((width*3/2 - 15) + (90+width/2)* zeroToOne, Y_BUFFER, 30, 30);
            rightButton.frame = CGRectMake(75+2*width + zeroToOne*width, Y_BUFFER, 24, HEIGHT);
        
             
        } else {
            
            rightLabel.alpha = zeroToOne;
            middleButton2.alpha = zeroToOne;
            middleButton.alpha = oneToZero;
            
            NSInteger width = 304/3;
            leftButton.frame = CGRectMake(-width * zeroToOne, Y_BUFFER, 25, 30);
            middleButton.frame = CGRectMake(X_BUFFER+width-15 - (width + 25)*zeroToOne , Y_BUFFER + 5, width + 30, 21.5);
            middleButton2.frame = CGRectMake((width*3/2 - 15) * oneToZero, Y_BUFFER, 30, 30);
            rightButton.frame = CGRectMake(75+2*width - (width/2 + 90) * zeroToOne, Y_BUFFER, 24, 30);
            
        }
        
        
        
    } else if (xCoor == 211) {
     
        //NSLog (@"Right Label");
        
        if (abs((int)xFromCenter) > 0) {
            
            rightLabel.alpha = oneToZero;
            middleButton2.alpha = oneToZero;
            middleButton.alpha = zeroToOne;
            
            NSInteger width = 304/3;
            leftButton.frame = CGRectMake(-width*oneToZero, Y_BUFFER, 25, 30);
            middleButton.frame = CGRectMake(X_BUFFER-40 + (width + 25)*zeroToOne, Y_BUFFER + 5, width + 30, 21.5);
            middleButton2.frame = CGRectMake(0 + (width*3/2 - 15)*zeroToOne, Y_BUFFER, 30, 30);
            rightButton.frame = CGRectMake(width*3/2 - 15 + (width/2 + 90)*zeroToOne, Y_BUFFER, 24, 30);

        }
        
    }
    
    
}

//                                                      //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%         MOVEMENT         %%%%%%%%%%%%%//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//////////////////////////////////////////////////////////




//%%% the delegate functions for UIPageViewController.
//Pretty standard, but generally, don't touch this.
////////////////////////////////////////////////////////////
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//%%%%%%       UIPageViewController Delegate       %%%%%%%//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfController:viewController];
    
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    index--;
    return [viewControllerArray objectAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self indexOfController:viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    
    if (index == [viewControllerArray count]) {
        return nil;
    }
    return [viewControllerArray objectAtIndex:index];
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        currentPageIndex = [self indexOfController:[pageViewController.viewControllers lastObject]];
        
        if (currentPageIndex == 1) {

            DragViewController *vc = viewControllerArray[1];
            vc.pageScrollView = pageScrollView;
        }
    }
}


//%%% checks to see which item we are currently looking at from the array of view controllers.
// not really a delegate method, but is used in all the delegate methods, so might as well include it here
-(NSInteger)indexOfController:(UIViewController *)viewController
{
    for (int i = 0; i<[viewControllerArray count]; i++) {
        if (viewController == [viewControllerArray objectAtIndex:i])
        {
            return i;
        }
    }
    return NSNotFound;
}

//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//%%%%%%       UIPageViewController Delegate       %%%%%%%//
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
////////////////////////////////////////////////////////////

/*
 leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, Y_BUFFER, 25, 30)];
 middleButton = [[UIButton alloc]initWithFrame:CGRectMake(X_BUFFER+width-15, Y_BUFFER + 5, width + 30, 21.5)];
 middleButton2 = [[UIButton alloc]initWithFrame:CGRectMake(width*3/2 - 15, Y_BUFFER, 30, 30)];
 rightButton = [[UIButton alloc]initWithFrame:CGRectMake(75+2*width, Y_BUFFER, 24, HEIGHT)];
 */


- (void)leftButtonTapped {

    if (currentPageIndex == 2) {
        longScroll = YES;
    } else longScroll = NO;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"refreshData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /*
    [UIView animateWithDuration:0.5 animations:^{
        
        NSInteger width = 304/3;
        leftButton.frame = CGRectMake(width*3/2 - 15, Y_BUFFER, 25, 30);
        middleButton.frame = CGRectMake(X_BUFFER+width+width+20, Y_BUFFER + 5, width + 30, 21.5);
        middleButton2.frame = CGRectMake(75+2*width, Y_BUFFER, 30, 30);
        rightButton.frame = CGRectMake(75+3*width, Y_BUFFER, 24, HEIGHT);
        
    } completion:^(BOOL finished) {
        //<#code#>
    }];
     */
    
}

- (void)middleButtonTapped {
    
    //NSLog(@"middle button tapped");
    
    CGFloat xFromCenter = self.view.frame.size.width-pageScrollView.contentOffset.x; //%%% positive for right swipe, negative for left
    
    NSInteger xCoor = X_BUFFER+selectionBar.frame.size.width*currentPageIndex-X_OFFSET;
    
    selectionBar.frame = CGRectMake(xCoor-xFromCenter/[viewControllerArray count], selectionBar.frame.origin.y, selectionBar.frame.size.width, selectionBar.frame.size.height);
    
    
    if (xCoor != 104) {
                
        middleButtonTapScrolling = YES;
        
        //middleButton2.alpha = abs((int)xFromCenter) / 320.0;
        
    } else {
        middleButtonTapScrolling = NO;
    }
    
    /*
    [UIView animateWithDuration:0.5 animations:^{
        
        NSInteger width = 304/3;
        leftButton.frame = CGRectMake(0, Y_BUFFER, 25, 30);
        middleButton.frame = CGRectMake(X_BUFFER+width-15, Y_BUFFER + 5, width + 30, 21.5);
        middleButton2.frame = CGRectMake(width*3/2 - 15, Y_BUFFER, 30, 30);
        rightButton.frame = CGRectMake(75+2*width, Y_BUFFER, 24, HEIGHT);
        
    } completion:^(BOOL finished) {
        //<#code#>
    }]; */
    
}

- (void)rightButtonTapped {
    
    [self hideCallout];
    
    if (currentPageIndex == 0) {
        longScroll = YES;
    } else longScroll = NO;
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"refreshData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /*
    [UIView animateWithDuration:0.5 animations:^{
        
        NSInteger width = 304/3;
        leftButton.frame = CGRectMake(-width, Y_BUFFER, 25, 30);
        middleButton.frame = CGRectMake(X_BUFFER-40, Y_BUFFER + 5, width + 30, 21.5);
        middleButton2.frame = CGRectMake(0, Y_BUFFER, 30, 30);
        rightButton.frame = CGRectMake(width*3/2 - 15, Y_BUFFER, 24, 30);
        
    } completion:^(BOOL finished) {
        //<#code#>
    }]; */
       
}

- (void)fadeLabels:(NSInteger)num {

    CGFloat xFromCenter = self.view.frame.size.width-pageScrollView.contentOffset.x; //%%% positive for right swipe, negative for left
    
    NSInteger xCoor = X_BUFFER+selectionBar.frame.size.width*currentPageIndex-X_OFFSET;
    
    selectionBar.frame = CGRectMake(xCoor-xFromCenter/[viewControllerArray count], selectionBar.frame.origin.y, selectionBar.frame.size.width, selectionBar.frame.size.height);
    
    if ((num == 0) && (xCoor != -2)) {
        
        //NSLog (@"Left label");
        
        leftButtonTapScrolling = YES;
        
        leftLabel.alpha = abs((int)xFromCenter) / 320.0;
        
    } else {
        leftButtonTapScrolling = NO;
        longScroll = NO;
    }
    
    
    
    if ((num == 2) & (xCoor != 211)) {
        
        //NSLog (@"Right label");
        
        rightButtonTapScrolling = YES;
        
        rightLabel.alpha = abs((int)xFromCenter) / 320.0;
        
    } else {
        rightButtonTapScrolling= NO;
        longScroll = NO;
    }


}

-(void)refreshButtonTapped {
    
    if (dvc.dropdownExpanded) {
        
        [dvc dropdownPressed];
    }
    
    [dvc refreshData];
}

- (void)showCallout {
    
    popTip = [AMPopTip popTip];
    
    popTip.shouldDismissOnTap = YES;
    popTip.edgeMargin = 5;
    popTip.offset = 2;
    popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    popTip.tapHandler = ^{
        NSLog(@"Tap!");
    };
    popTip.dismissHandler = ^{
        NSLog(@"Dismiss!");
    };
    
    //popTip.popoverColor = [UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0];
    popTip.popoverColor = [UIColor colorWithRed:0.0 green:184.0/255.0 blue:245.0/255.0 alpha:1.0]; //0,184,245
    
    [popTip showText:@"Your events are saved here" direction:AMPopTipDirectionDown maxWidth:200 inView:self.navigationView fromFrame:rightButton.frame];
    
}

- (void)hideCallout {
    
    [popTip hide];
    
}

@end
