//
//  ChecklistModalVC.m
//  Happening
//
//  Created by Max on 7/22/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ChecklistModalVC.h"
#import "CustomAPActivityProvider.h"
#import "CustomCalendarActivity.h"
#import <Hoko/Hoko.h>
#import "RKDropdownAlert.h"

@interface ChecklistModalVC () <UITableViewDataSource, UITableViewDelegate>
@end

@implementation ChecklistModalVC

@synthesize containerView, event, tableView, messageLabel, shareButton, checklistButton;

-(void)viewDidLoad {
    
    containerView.layer.masksToBounds = YES;
    containerView.layer.cornerRadius = 5;

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = containerView.bounds;
    [containerView insertSubview:blurEffectView atIndex:0];
    
    //tableView.alpha = 0;
    
    shareButton.layer.masksToBounds = YES;
    shareButton.layer.cornerRadius = 10;
    shareButton.layer.borderColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
    shareButton.layer.borderWidth = 1.5;
    
    messageLabel.text = event[@"Title"];
    
}

- (IBAction)checklistButtonTapped:(id)sender {
    
    [containerView bringSubviewToFront:tableView];
    
    [UIView animateWithDuration:0.5 animations:^{
        tableView.alpha = 1;
        shareButton.alpha = 0;
        checklistButton.alpha = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
}

- (IBAction)shareAction:(id)sender {
    
    __block BOOL showCalendar = YES;
    
    if ([sender isKindOfClass:[UIButton class]]) {
        
        UIButton *sharingButton = sender;
        
        if (sharingButton.tag == 99) {
            
            showCalendar = NO;
        }
    }
    
    HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithRoute:@"events/:EventID"
                                           routeParameters:@{@"EventID": event.objectId}
                                           queryParameters:@{@"referrer": [PFUser currentUser].objectId}];
    /*  metadata:@{@"coupon": @"20"}]; */
    [[Hoko deeplinking] generateSmartlinkForDeeplink:deeplink success:^(NSString *smartlink) {
        NSURL *myWebsite = [NSURL URLWithString:smartlink];
        [self shareEventWithURL:myWebsite shouldShowCalendar:showCalendar];
        
    } failure:^(NSError *error) {
        // Share web link instead
        NSURL *myWebsite = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.happening.city/events/%@", event.objectId]];
        [self shareEventWithURL:myWebsite shouldShowCalendar:showCalendar];
    }];
    
}

- (void)shareEventWithURL:(NSURL *)link shouldShowCalendar:(BOOL)showCalendar {
    
    CustomAPActivityProvider *ActivityProvider = [[CustomAPActivityProvider alloc] init];
    ActivityProvider.eventObject = event;
    
    NSArray *itemsToShare = @[ActivityProvider, link];
    
    UIActivityViewController *activityVC;
    
    if (showCalendar) {
        
        CustomCalendarActivity *addToCalendar = [[CustomCalendarActivity alloc]init];
        //addToCalendar.draggableView = draggableBackground.dragView;
        //addToCalendar.myViewController = self;
        
        activityVC = [[UIActivityViewController alloc]initWithActivityItems:itemsToShare applicationActivities:[NSArray arrayWithObject:addToCalendar]];
    } else {
        
        activityVC = [[UIActivityViewController alloc]initWithActivityItems:itemsToShare applicationActivities:nil];
    }
    
    activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                         UIActivityTypePrint,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypeCopyToPasteboard,
                                         ];
    
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    [activityVC setCompletionHandler:^(NSString *act, BOOL done)
     {
         NSString *ServiceMsg = @"Done!";
         BOOL calendarAction = NO;
         
         if ( [act isEqualToString:UIActivityTypeMail] ) {
             ServiceMsg = @"Mail sent!";
         }
         else if ( [act isEqualToString:UIActivityTypePostToTwitter] ) {
             ServiceMsg = @"Your tweet has been posted!";
         }
         else if ( [act isEqualToString:UIActivityTypePostToFacebook] ){
             ServiceMsg = @"Your Facebook status has been updated!";
         }
         else if ( [act isEqualToString:UIActivityTypeMessage] ) {
             ServiceMsg = @"Message sent!";
         } else {
             calendarAction = YES;
         }
         if ( done && (calendarAction == NO) )
         {
             
             // Custom action for other activity types...
             [RKDropdownAlert title:ServiceMsg backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
             
         }
     }];
    
}

- (IBAction)dismissAction
{
    [self mh_dismissSemiModalViewController:self animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UILabel *label = (UILabel *)[cell viewWithTag:4];
    UIImageView *imv = (UIImageView *)[cell viewWithTag:3];

    cell.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row == 0) {
        
        label.text = @"Buy tickets from Seatgeek";
        imv.image = nil;
        
    } else if (indexPath.row == 1) {
        
        label.text = @"Invite friends";
        imv.image =  [UIImage imageNamed:@"userImage"];
        
    } else if (indexPath.row == 2) {
        
        label.text = @"Add to calendar";
        imv.image =  [UIImage imageNamed:@"calendar"];
        
    } else if (indexPath.row == 3) {
        
        label.text = @"Call Uber";
        imv.image =  [UIImage imageNamed:@""];
        
    }
    
    
    return cell;
}

@end
