//
//  FirstTimeScreen.m
//  HappeningParse
//
//  Created by Max on 11/5/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "FirstTimeScreen.h"

@interface FirstTimeScreen ()

@end

@implementation FirstTimeScreen{
    
    AppDelegate *appDelegate;
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser && (currentUser[@"userLoc"] != nil)) {
        //[self performSegueWithIdentifier:@"goToMain" sender:self];
        NSLog(@"User exists. LEGGO");
        
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:currentUser.username];
        
        // Reload user preferences from previous session
        //int sliderVal = [userPF[@"radius"] intValue];
        //NSLog(@"Loading preferences... slider value = %d", sliderVal);
        //appDelegate.sliderValue = sliderVal;
        
        // Sets user's location for use in settings
        PFGeoPoint *userLoc = currentUser[@"userLoc"];
        double latitude = userLoc.latitude;
        double longitude = userLoc.longitude;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        appDelegate.userLocation = mapItem;

        [self performSegueWithIdentifier:@"goToMain" sender:self];
    
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Create the data model
    //_pageTitles = @[@"Currently being designed!", @"Have fun, save money", @"Spend more time with friends", @":)"];
    _pageTitles = @[@"", @"", @"", @"", @""];
    _pageImages = @[@"interested_face", @"interested_face", @"interested_face", @"interested_face", @"interested_face"];
    
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 50);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    NSArray *subviews = self.pageViewController.view.subviews;
    UIPageControl *thisControl = nil;
    for (int i=0; i<[subviews count]; i++) {
        if ([[subviews objectAtIndex:i] isKindOfClass:[UIPageControl class]]) {
            thisControl = (UIPageControl *)[subviews objectAtIndex:i];
        }
    }
    
    thisControl.userInteractionEnabled = NO;
    UIPageControl *pageControl = thisControl;
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.pageIndicatorTintColor = [UIColor lightTextColor];
    thisControl.backgroundColor = [UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0]; //happening blue!
    //self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+40);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.titleText = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
