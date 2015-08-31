
/*
 * Copyright (c) 2015 Martin Hartl
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "MHCustomTabBarController.h"
#import "AppDelegate.h"
#import "MHTabBarSegue.h"
#import "GroupsTVC.h"
#import "DragViewController.h"
#import "SwipeableCardVC.h"
#import "AMPopTip.h"
#import "ActivityTVC.h"

NSString *const MHCustomTabBarControllerViewControllerChangedNotification = @"MHCustomTabBarControllerViewControllerChangedNotification";
NSString *const MHCustomTabBarControllerViewControllerAlreadyVisibleNotification = @"MHCustomTabBarControllerViewControllerAlreadyVisibleNotification";

@interface MHCustomTabBarController ()

@property (nonatomic, strong) NSMutableDictionary *viewControllersByIdentifier;
@property (strong, nonatomic) NSString *destinationIdentifier;
@property (nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (strong, nonatomic) IBOutlet UIView *tabBarContainerView;

@end

@implementation MHCustomTabBarController {
    
    BOOL viewLoaded;
    NSArray *bluePics;
    NSArray *grayPics;
    AMPopTip *popTip;
}

@synthesize groupHub, profileHub, activityHub;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewControllersByIdentifier = [NSMutableDictionary dictionary];
    viewLoaded = YES;
    
    bluePics = [NSArray arrayWithObjects:[UIImage imageNamed:@"cards_tab_pressed"], [UIImage imageNamed:@"heart_pressed"], [UIImage imageNamed:@"groups_tab_pressed"], [UIImage imageNamed:@"profile_tab_pressed"], nil];
    
    grayPics = [NSArray arrayWithObjects: [UIImage imageNamed:@"cards_tab"], [UIImage imageNamed:@"heart"], [UIImage imageNamed:@"groups_tab"], [UIImage imageNamed:@"profile_tab"], nil];

}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.mh = self;
    
    if (!groupHub) {
        
        groupHub = [[RKNotificationHub alloc]initWithView:[self.buttons objectAtIndex:2]]; // sets the count to 0
        
        //%%% CIRCLE FRAME
        //[hub setCircleAtFrame:CGRectMake(-10, -10, 30, 30)]; //frame relative to the view you set it to
        
        //%%% MOVE FRAME
        [groupHub moveCircleByX:-10 Y:8]; // moves the circle 5 pixels left and down from its current position
        
        //%%% CIRCLE SIZE
        [groupHub scaleCircleSizeBy:0.5]; // doubles the size of the circle, keeps the same center
        
        [groupHub setCircleColor:[UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0] labelColor:[UIColor whiteColor]];
        
        [groupHub setCountLabelFont:[UIFont fontWithName:@"OpenSans" size:6.0]];
        
    }
    
    if (!activityHub) {
        
        activityHub = [[RKNotificationHub alloc]initWithView:[self.buttons objectAtIndex:1]]; // sets the count to 0
        
        //%%% CIRCLE FRAME
        //[hub setCircleAtFrame:CGRectMake(-10, -10, 30, 30)]; //frame relative to the view you set it to
        
        //%%% MOVE FRAME
        [activityHub moveCircleByX:-11 Y:8]; // moves the circle 5 pixels left and down from its current position
        
        //%%% CIRCLE SIZE
        [activityHub scaleCircleSizeBy:0.3]; // doubles the size of the circle, keeps the same center
        
        [activityHub setCircleColor:[UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0] labelColor:[UIColor whiteColor]];
        
        //[groupHub setCountLabelFont:[UIFont fontWithName:@"OpenSans" size:6.0]];
        [activityHub hideCount];
        
    }
    
    if (self.childViewControllers.count < 1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSegueWithIdentifier:@"viewController1" sender:[self.buttons objectAtIndex:0]];
    }
    
    if (self.eventIdForSegue != nil) {
        NSLog(@"TO SWIPE VC");
        [self performSegueWithIdentifier:@"toSwipeVC" sender:self];
    }
    
    /*
    // Fetches all LYRConversation objects
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    NSError *error;
    NSOrderedSet *conversations = [appDelegate.layerClient executeQuery:query error:&error];
    if (!error) {
        NSLog(@"%tu conversations", conversations.count);
        
        int notiNumber = 0;
        for (LYRConversation *convo in conversations) {
            
            if (convo.hasUnreadMessages) {
                
                notiNumber++;
                //[convo markAllMessagesAsRead:nil];
            }
        }
        
        if (notiNumber > 0) {
            NSLog(@"%d unread messages", notiNumber);
    
            [groupHub incrementBy:notiNumber];
            [groupHub bump];
            
        }
        
    } else {
        NSLog(@"Query failed with error %@", error);
    } */
    
    // Fetches the count of all unread messages for the authenticated user
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
    
    // Messages must be unread
    LYRPredicate *unreadPredicate =[LYRPredicate predicateWithProperty:@"isUnread" predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    
    // Messages must not be sent by the authenticated user
    LYRPredicate *userPredicate = [LYRPredicate predicateWithProperty:@"sender.userID" predicateOperator:LYRPredicateOperatorIsNotEqualTo value:appDelegate.layerClient.authenticatedUserID];
    
    query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[unreadPredicate, userPredicate]];
    query.resultType = LYRQueryResultTypeCount;
    NSError *error = nil;
    NSUInteger unreadMessageCount = [appDelegate.layerClient countForQuery:query error:&error];
    
    if (unreadMessageCount > 0) {
        NSLog(@"%lu unread messages", unreadMessageCount);
        
        if (unreadMessageCount > 100) {
            unreadMessageCount = 1;
        }
        
        [groupHub setCount:unreadMessageCount];
        [groupHub bump];
        
    }

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.destinationViewController.view.frame = self.container.bounds;
}

- (void)hideTabBar:(BOOL)shouldHide {
    
    if (shouldHide) {
        self.tabBarContainerView.alpha = 0;
        self.container.frame = CGRectMake(0, 0, 320, 568);
    } else {
        self.tabBarContainerView.alpha = 1;
        self.container.frame = CGRectMake(0, 0, 320, 519);
    }
    
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"^^");
    
    if (![segue isKindOfClass:[MHTabBarSegue class]]) {
        
        if ([segue.identifier isEqualToString:@"toSwipeVC"]) {
            
            SwipeableCardVC *vc = (SwipeableCardVC *)[[segue destinationViewController] topViewController];
            NSLog(@"%@", self.eventIdForSegue);
            vc.eventID = [NSString stringWithString:self.eventIdForSegue];
            self.eventIdForSegue = nil;
            
        } else {
            [super prepareForSegue:segue sender:sender];
        }
        return;
    }
    
    self.oldViewController = self.destinationViewController;
    
    //if view controller isn't already contained in the viewControllers-Dictionary
    if (![self.viewControllersByIdentifier objectForKey:segue.identifier]) {
        [self.viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
    } else {
        NSLog(@"Made it");
    }
    
    [self.buttons setValue:@NO forKeyPath:@"selected"];
    //[sender setSelected:YES];
    self.selectedIndex = [self.buttons indexOfObject:sender];
    [self selectedButton];

    self.destinationIdentifier = segue.identifier;
    self.destinationViewController = [self.viewControllersByIdentifier objectForKey:self.destinationIdentifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MHCustomTabBarControllerViewControllerChangedNotification object:nil]; 

    if ([segue.identifier isEqualToString:@"viewController3"]) {
        
        if ([[[segue destinationViewController] topViewController] isKindOfClass:[GroupsTVC class]]) {
            GroupsTVC *tvc = (GroupsTVC *)[[segue destinationViewController] topViewController];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            if (tvc.layerClient == nil) {
                tvc.layerClient = appDelegate.layerClient;
                tvc.navigationItem.title = @"Groups";
                //tvc.deletionModes = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:LYRDeletionModeLocal], nil];
            }
        }
    } else if ([segue.identifier isEqualToString:@"viewController1"]) {
        
        if ([[[segue destinationViewController] topViewController] isKindOfClass:[DragViewController class]]) {
            DragViewController *vc = (DragViewController *)[[segue destinationViewController] topViewController];
            if (self.shouldCreateHappening == YES) {
                vc.directToCreateHappening = YES;
                //self.shouldCreateHappening = NO;
            }
        }
        
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.destinationIdentifier isEqual:identifier]) {
        //Dont perform segue, if visible ViewController is already the destination ViewController
        NSLog(@"View controller exists");
        [[NSNotificationCenter defaultCenter] postNotificationName:MHCustomTabBarControllerViewControllerAlreadyVisibleNotification object:nil];
        id vc = [self.viewControllersByIdentifier objectForKey:identifier];
        
        if ([vc isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *nvc = (UINavigationController *)vc;
            if ([[nvc topViewController] isKindOfClass:[ActivityTVC class]]) {
                ActivityTVC *activityVC = (ActivityTVC *)[vc topViewController];
                [activityVC toTop];
            } else if ([[nvc topViewController] isKindOfClass:[DragViewController class]]) {
                DragViewController *dvc = (DragViewController *)[vc topViewController];
                [dvc refreshData];
            } else {
                [nvc popToRootViewControllerAnimated:YES];
            }
            
        } else if ([vc isKindOfClass:[UIViewController class]]) {
            UIViewController *theVC = (UIViewController *)vc;
            [theVC.navigationController popToRootViewControllerAnimated:YES];
        }
        
        return NO;
    }
    
    return YES;
}

-(void)selectedButton {
    
    for (int i = 0; i < self.buttons.count; i++) {
        
        UIButton *button = self.buttons[i];
        UIImageView *imv = self.imageViews[i];
        UIColor *hapBlue = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0];
        UIColor *gray = [UIColor colorWithRed:190.0/255 green:190.0/255 blue:190.0/255 alpha:1.0];
        
        if (i == self.selectedIndex) {
            
            imv.image = bluePics[i];
            [button setTitleColor:hapBlue forState:UIControlStateNormal];
            
        } else {
            
            imv.image = grayPics[i];
            [button setTitleColor:gray forState:UIControlStateNormal];
            
        }
        
    }
    
}

- (void)showCallout {
    
    popTip = [AMPopTip popTip];
    
    popTip.shouldDismissOnTap = YES;
    //popTip.edgeMargin = 300;
    popTip.offset = -5;
    popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    popTip.tapHandler = ^{
        NSLog(@"Tap!");
    };
    popTip.dismissHandler = ^{
        NSLog(@"Dismiss!");
    };
    
    //popTip.popoverColor = [UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0];
    popTip.popoverColor = [UIColor colorWithRed:0.0 green:130.0/255.0 blue:250.0/255.0 alpha:1.0]; //0,184,245
    
    UIButton *meButton = self.buttons[3];
    CGRect rect = CGRectMake(320-80, 568-50, 80, 50);
    [popTip showText:@"Your events are saved here" direction:AMPopTipDirectionUp maxWidth:200 inView:self.view fromFrame:rect];
    
}

- (void)hideCallout {
    
    [popTip hide];
    
}

- (void)createButtonPressed {
    
    self.shouldCreateHappening = YES;
    UIButton *button = self.buttons[0];
    [button sendActionsForControlEvents: UIControlEventTouchUpInside];
}

#pragma mark - Memory Warning

- (void)didReceiveMemoryWarning {
    [[self.viewControllersByIdentifier allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (![self.destinationIdentifier isEqualToString:key]) {
            [self.viewControllersByIdentifier removeObjectForKey:key];
        }
    }];
    [super didReceiveMemoryWarning];
}

@end
