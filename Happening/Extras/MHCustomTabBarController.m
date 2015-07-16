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

NSString *const MHCustomTabBarControllerViewControllerChangedNotification = @"MHCustomTabBarControllerViewControllerChangedNotification";
NSString *const MHCustomTabBarControllerViewControllerAlreadyVisibleNotification = @"MHCustomTabBarControllerViewControllerAlreadyVisibleNotification";

@interface MHCustomTabBarController ()

@property (nonatomic, strong) NSMutableDictionary *viewControllersByIdentifier;
@property (strong, nonatomic) NSString *destinationIdentifier;
@property (nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (strong, nonatomic) IBOutlet UIView *tabBarContainerView;

@end

@implementation MHCustomTabBarController {
    
    BOOL viewLoaded;
    NSArray *bluePics;
    NSArray *grayPics;
}

@synthesize groupHub, profileHub;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewControllersByIdentifier = [NSMutableDictionary dictionary];
    viewLoaded = YES;
    
    bluePics = [NSArray arrayWithObjects:[UIImage imageNamed:@"groups_tab_pressed"], [UIImage imageNamed:@"cards_tab_pressed"], [UIImage imageNamed:@"profile_tab_pressed"], nil];
    
    grayPics = [NSArray arrayWithObjects:[UIImage imageNamed:@"groups_tab"], [UIImage imageNamed:@"cards_tab"], [UIImage imageNamed:@"profile_tab"], nil];

}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.mh = self;
    
    if (self.childViewControllers.count < 1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSegueWithIdentifier:@"viewController2" sender:[self.buttons objectAtIndex:1]];
    }
    
    if (self.eventIdForSegue != nil) {
        NSLog(@"TO SWIPE VC");
        [self performSegueWithIdentifier:@"toSwipeVC" sender:self];
    }
    
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
            groupHub = [[RKNotificationHub alloc]initWithView:[self.buttons objectAtIndex:0]]; // sets the count to 0

            //%%% CIRCLE FRAME
            //[hub setCircleAtFrame:CGRectMake(-10, -10, 30, 30)]; //frame relative to the view you set it to
            
            //%%% MOVE FRAME
            [groupHub moveCircleByX:-17 Y:10]; // moves the circle 5 pixels left and down from its current position
            
            //%%% CIRCLE SIZE
            [groupHub scaleCircleSizeBy:0.65]; // doubles the size of the circle, keeps the same center
            
            [groupHub setCircleColor:[UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0] labelColor:[UIColor whiteColor]];
            [groupHub incrementBy:notiNumber];
            [groupHub bump];
            
            
        }
        
    } else {
        NSLog(@"Query failed with error %@", error);
    }

}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    self.destinationViewController.view.frame = self.container.bounds;
}

- (void)hideTabBar:(BOOL)shouldHide {
    
    if (shouldHide) {
        self.tabBarContainerView.alpha = 0;
        self.container.frame = CGRectMake(0, 0, 320, 560);
    } else {
        self.tabBarContainerView.alpha = 1;
        self.container.frame = CGRectMake(0, 0, 320, 519);
    }
    
}


#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
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
    }
    
    [self.buttons setValue:@NO forKeyPath:@"selected"];
    //[sender setSelected:YES];
    self.selectedIndex = [self.buttons indexOfObject:sender];
    [self selectedButton];

    self.destinationIdentifier = segue.identifier;
    self.destinationViewController = [self.viewControllersByIdentifier objectForKey:self.destinationIdentifier];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MHCustomTabBarControllerViewControllerChangedNotification object:nil]; 

    if ([segue.identifier isEqualToString:@"viewController1"]) {
        
        if ([[[segue destinationViewController] topViewController] isKindOfClass:[GroupsTVC class]]) {
            GroupsTVC *tvc = (GroupsTVC *)[[segue destinationViewController] topViewController];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            if (tvc.layerClient == nil) {
                tvc.layerClient = appDelegate.layerClient;
                tvc.navigationItem.title = @"Friends";
                //tvc.deletionModes = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:LYRDeletionModeLocal], nil];
            }
        }
    } else if ([segue.identifier isEqualToString:@"viewController2"]) {
        
        if ([[[segue destinationViewController] topViewController] isKindOfClass:[GroupsTVC class]]) {
            DragViewController *vc = (DragViewController *)[[segue destinationViewController] topViewController];
            
        }
        
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.destinationIdentifier isEqual:identifier]) {
        //Dont perform segue, if visible ViewController is already the destination ViewController
        [[NSNotificationCenter defaultCenter] postNotificationName:MHCustomTabBarControllerViewControllerAlreadyVisibleNotification object:nil];
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
