//
//  ModalPopup.m
//  Happening
//
//  Created by Max on 7/30/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ModalPopup.h"
#import "ShareableCardView.h"
#import <Hoko/Hoko.h>
#import "CustomAPActivityProvider.h"
#import "CustomCalendarActivity.h"
#import "RKDropdownAlert.h"
#import "SVProgressHUD.h"

@interface ModalPopup () <ShareableCardViewDelegate>

@end

@implementation ModalPopup {

    ShareableCardView *shareableCard;
}

@synthesize topLabel,subHeaderLabel, messageLabel, containerView, subContainerView, CallToActionButton, eventObject, eventDateString, eventImage, cardContainerView, showCalendar, lineView;

-(void)viewDidLoad {
    
    if ([self.type isEqualToString:@"create"]) {
        [self userCreatedEvent];
        showCalendar = NO;
    } else if ([self.type isEqualToString:@"share"]) {
        [self shareEventFromCard];
        showCalendar = YES; // ??
    }
    
}

- (void)shareEventFromCard {
    
    NSArray *headers = @[@"Events are better with friends.", @"\"Sharing is caring.\"", @"Tell your friends!", @"Tell EVERYONE!", @"Psst... you rock.", @"Share like it's 1999."];
    NSArray *subheaders = @[@"Lots of friends.", @"(shoutout to mom <3)", @"Send 'em some Happening love.", @"Every. One.", @"Just saying.", @"I'm not even sure what that means."];
    NSUInteger randomIndex = arc4random() % [headers count];
    
    topLabel.text = headers[randomIndex];
    subHeaderLabel.text = subheaders[randomIndex];
    messageLabel.text = @"";
    
    [self addShareableCard];
    
}

- (void)userCreatedEvent {
    
    topLabel.text = @"You rock.";
    subHeaderLabel.text = @"Rally friends to come to your event!";
    messageLabel.text = @"";
    [self addShareableCard];
    
}

- (void) addShareableCard {
    
    [CallToActionButton setTitle:@"SHARE" forState:UIControlStateNormal];
    CallToActionButton.tag = 99;
    [CallToActionButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    CallToActionButton.layer.cornerRadius = 5.0;
    CallToActionButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
    CallToActionButton.layer.masksToBounds = YES;
    CallToActionButton.layer.borderWidth = 1.0;
    CallToActionButton.layer.borderColor = [UIColor colorWithRed:0 green:140.0/242 blue:245.0/255 alpha:1.0].CGColor;
    [CallToActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [CallToActionButton setBackgroundColor:[UIColor colorWithRed:0 green:140.0/242 blue:245.0/255 alpha:1.0]];
    [CallToActionButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [CallToActionButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragExit];
    CGRect buttonFrame = CallToActionButton.frame;
    buttonFrame.size.width += -20;
    CallToActionButton.frame = buttonFrame;
    CallToActionButton.center = CGPointMake(subContainerView.center.x, CallToActionButton.center.y - 10);
    [self.subContainerView sendSubviewToBack:CallToActionButton];
    
    
    shareableCard = [[ShareableCardView alloc] initWithFrame:CGRectMake(self.subContainerView.center.x - (150 / 2), 5, 150, 150)];
    shareableCard.shareDelegate = self;
    shareableCard.title.text = eventObject[@"Title"];
    shareableCard.date.text = eventDateString;
    
    if (eventImage == nil) {
        shareableCard.eventImage.image = [UIImage imageNamed:eventObject[@"Hashtag"]];
    } else {
        shareableCard.eventImage.image = eventImage;
    }
    
    shareableCard.cachedImage = shareableCard.eventImage.image;
    
    shareableCard.hapLogoButton.alpha = 0;
    shareableCard.shareButton.alpha = 0;
    if (eventObject[@"Location"] != nil) {
        shareableCard.location.text = eventObject[@"Location"];
    }
    
    [subContainerView addSubview:shareableCard];
    
}

- (void)shareAction:(id)sender {
    
    [shareableCard zoomCard];

    [UIView animateWithDuration:0.3 animations:^{
        CallToActionButton.alpha = 0;
        lineView.alpha = 0;
        topLabel.alpha = 0;
        subHeaderLabel.alpha = 0;
    }];
    
}

// Shareable card delegate method
- (void)cardImageGenerated:(UIImage *)image {

    [SVProgressHUD setViewForExtension:[UIApplication sharedApplication].keyWindow];
    [SVProgressHUD show];
    
    HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithRoute:@"events/:EventID"
                                           routeParameters:@{@"EventID": self.eventObject.objectId}
                                           queryParameters:@{@"referrer": [PFUser currentUser].objectId}];
    /*  metadata:@{@"coupon": @"20"}]; */
    [[Hoko deeplinking] generateSmartlinkForDeeplink:deeplink success:^(NSString *smartlink) {
        NSURL *myWebsite = [NSURL URLWithString:smartlink];
        [self shareEventWithURL:myWebsite image:image];
        [SVProgressHUD dismiss];
        
    } failure:^(NSError *error) {
        // Share web link instead
        NSURL *myWebsite = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.happening.city/events/%@", self.eventObject.objectId]];
        [self shareEventWithURL:myWebsite image:image];
        [SVProgressHUD dismiss];
        
    }];

}

- (void)shareEventWithURL:(NSURL *)link image:(UIImage *)image {
    
    CustomAPActivityProvider *ActivityProvider = [[CustomAPActivityProvider alloc] init];
    ActivityProvider.eventObject = self.eventObject;
    
    NSArray *itemsToShare = @[ActivityProvider, link, image];
    
    UIActivityViewController *activityVC;
    
#warning show calendar is broken
    if (showCalendar) {
        
        CustomCalendarActivity *addToCalendar = [[CustomCalendarActivity alloc]init];
        //addToCalendar.draggableView = self;
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
             ServiceMsg = @"Boom!";
         }
         if ( done && (calendarAction == NO) )
         {
             // Custom action for other activity types... ???
             
             PFObject *timelineObject = [PFObject objectWithClassName:@"Timeline"];
             
             timelineObject[@"type"] = @"share";
             
             timelineObject[@"userId"] = [PFUser currentUser].objectId;
             timelineObject[@"eventId"] = self.eventObject.objectId;
             timelineObject[@"createdDate"] = [NSDate date];
             timelineObject[@"eventTitle"] = self.eventObject[@"Title"];
             [timelineObject pinInBackground];
             [timelineObject saveEventually];
             
             [[PFUser currentUser] incrementKey:@"score" byAmount:@15];
             [[PFUser currentUser] saveEventually];
             
             [RKDropdownAlert title:ServiceMsg backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
             [self.delegate userFinishedAction:YES type:self.type];
             [self mh_dismissSemiModalViewController:self animated:YES];
             
         }
         
         // insert delegate callback method
         
     }];
    
}

- (IBAction)continueButton:(id)sender {
    
    [self.delegate userFinishedAction:NO type:self.type];
    [self mh_dismissSemiModalViewController:self animated:YES];
}

-(void)buttonNormal:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setBackgroundColor:[UIColor colorWithRed:0 green:140.0/242 blue:245.0/255 alpha:1.0]];
}

-(void)buttonHighlight:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setBackgroundColor:[UIColor colorWithRed:0 green:120.0/242 blue:255.0/255 alpha:1.0]];
}

@end
