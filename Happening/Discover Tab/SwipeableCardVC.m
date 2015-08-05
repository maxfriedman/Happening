//
//  SwipeableCardVC.m
//  Happening
//
//  Created by Max on 7/2/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "SwipeableCardVC.h"
#import "DraggableView.h"
#import <CoreText/CoreText.h>
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "inviteHomies.h"
#import <Button/Button.h>

#import "DragMapViewController.h"
#import "ExternalProfileTVC.h"
#import "CustomCalendarActivity.h"
#import "webViewController.h"
#import "moreDetailFromCard.h"
#import "ChecklistModalVC.h"

#define MCANIMATE_SHORTHAND
#import <POP+MCAnimate.h>

@interface SwipeableCardVC () <inviteHomiesDelegate, UINavigationControllerDelegate, DraggableViewDelegate>

@property DraggableView *dragView;
@property UIView *draggableBackground;
@property UIButton *smileButton;
@property UIButton *frownButton;
@property NSArray *bestFriendIds;
@property PFUser *currentUser;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MKMapView *mapView;
@property (nonatomic, strong) EKEventStore *eventStore;

@end

@implementation SwipeableCardVC {

    CGFloat extraDescHeight;
    MKPointAnnotation *annotation;
    UIButton *uberButton;
    UIButton *ticketsButton;
    
    EKEvent *calEvent;
    EKEventStore *calEventStore;
    NSString *friendObjectID;
    NSString *urlString;
    
    BOOL isExpanded;
}

static const float CARD_HEIGHT = 350; //%%% height of the draggable card
static const float CARD_WIDTH = 284; //%%% width of the draggable card

@synthesize dragView, draggableBackground, scrollView, smileButton, frownButton, bestFriendIds, currentUser, event, mapView, eventStore;

- (void)viewWillAppear:(BOOL)animated {
    
    if (!dragView) {
        
        self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.translucent = NO;
        
        eventStore = [[EKEventStore alloc] init];
        
        currentUser = [PFUser currentUser];
        bestFriendIds = currentUser[@"BestFriends"];
        
        smileButton.enabled = NO;
        frownButton.enabled = NO;
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [scrollView setCanCancelContentTouches:YES];
        [scrollView setDelaysContentTouches:NO];
        [scrollView setBouncesZoom:YES];
        [self.view addSubview:scrollView];
        
        dragView = [[DraggableView alloc]initWithFrame:CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT)];
        dragView.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
        [dragView.cardBackground removeFromSuperview];
        dragView.cardView.layer.masksToBounds = YES;
        dragView.userInteractionEnabled = YES;
        [dragView.cardView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandCurrentView)]];
        [self createDraggableView];
        
        draggableBackground = [[UIView alloc] initWithFrame:self.view.bounds];
        [draggableBackground addSubview:dragView];
        
        [scrollView addSubview:draggableBackground];
        
        
        
        isExpanded = NO;
    
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void) createDraggableView {
    
    if (!event) {
        
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
        [eventQuery getObjectInBackgroundWithId:self.eventID block:^(PFObject *eventObject, NSError *error) {
            
            if (!error) {
                event = eventObject;
                
                PFGeoPoint *loc = event[@"GeoLoc"];
                
                if (loc.latitude == 0) {
                    self.distanceString = @"";
                } else {
                    PFGeoPoint *userLoc = currentUser[@"userLoc"];
                    NSNumber *meters = [NSNumber numberWithDouble:([loc distanceInMilesTo:userLoc])];
                    if (meters.floatValue >= 100.0) {
                        self.distanceString = [NSString stringWithFormat:(@"100+ mi")];
                    } else if (meters.floatValue >= 10.0) {
                        self.distanceString = [NSString stringWithFormat:(@"%.f mi"), meters.floatValue];
                    } else {
                        self.distanceString = [NSString stringWithFormat:(@"%.1f mi"), meters.floatValue];
                    }
                }
                
                if (event[@"Image"] != nil) {
                    
                    PFFile *imageFile = event[@"Image"];
                    [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                        
                        if (!error) {
                            dragView.eventImage.image = [UIImage imageWithData:imageData];
                        } else {
                            NSLog(@"Error retrieving image");
                        }
                        [self createDraggableView];
                        
                    }];
                    
                } else {
                    
                    dragView.eventImage.image = [UIImage imageNamed:event[@"Hashtag"]];
                    [self createDraggableView];
                }
            }
        }];
        
    } else {
        
        NSLog(@"EVENT: %@", event);
        dragView.objectID = event.objectId;
        dragView.eventObject = event;
        
        NSString *titleString = event[@"Title"];
        
        if (titleString.length > 33) {
            dragView.title.numberOfLines = 2;
            dragView.title.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
            dragView.title.minimumScaleFactor = 0.6;
            
        }
        
        dragView.title.text = titleString;
        self.navigationItem.title = titleString;
        
        if (event[@"Description"])
            dragView.subtitle.text = event[@"Description"];
        else
            dragView.subtitle.text = @"";
        
        dragView.location.text = [NSString stringWithFormat:@"at %@", event[@"Location"]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE, MMM d"];
        NSDate *eventDate = [[NSDate alloc]init];
        eventDate = event[@"Date"];
        
        NSString *finalString;
        
        // FORMAT FOR MULTI-DAY EVENT
        NSDate *endDate = event[@"EndTime"];
        
        if ([eventDate compare:[NSDate date]] == NSOrderedAscending) {
            
            finalString = [NSString stringWithFormat:@"Happening NOW!"];
            
        } else if ([[eventDate beginningOfDay] isEqualToDate:[[NSDate date]beginningOfDay]]) {  // TODAY
            
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            finalString = [NSString stringWithFormat:@"Today at %@", timeString];
            
        } else if ([[eventDate beginningOfDay] isEqualToDate:[[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]]) { // TOMORROW
            
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            finalString = [NSString stringWithFormat:@"Tomorrow at %@", timeString];
            
        } else if ([[eventDate endOfWeek] isEqualToDate:[[NSDate date]endOfWeek]]) { // SAME WEEK
            
            [formatter setDateFormat:@"EEEE"];
            NSString *dayOfWeekString = [formatter stringFromDate:eventDate];
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            finalString = [NSString stringWithFormat:@"%@ at %@", dayOfWeekString, timeString];
            
        } else if (![[eventDate beginningOfDay] isEqualToDate:[endDate beginningOfDay]]) { //MULTI-DAY EVENT
            
            [formatter setDateFormat:@"MMM d"];
            NSString *dateString = [formatter stringFromDate:eventDate];
            NSString *endDateString = [formatter stringFromDate:endDate];
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            NSString *endTimeString = [formatter stringFromDate:endDate];
            
            finalString = [NSString stringWithFormat:@"%@ at %@ to %@ at %@", dateString, timeString, endDateString, endTimeString];
            
        } else { // Past this week- uses abbreviated date format
            
            NSString *dateString = [formatter stringFromDate:eventDate];
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            finalString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
            
        }
        
        finalString = [finalString stringByReplacingOccurrencesOfString:@":00" withString:@" "];
        dragView.date.text = finalString;
        
        
        dragView.hashtag.text = [NSString stringWithFormat:@"%@", event[@"Hashtag"]];
        
        dragView.geoPoint = event[@"GeoLoc"];
        
        NSNumber *swipe = event[@"swipesRight"];
        NSString *swipeString = [NSString stringWithFormat:@"%@ interested", [swipe stringValue]];
        dragView.swipesRight.text = swipeString;
        
        if (dragView.eventImage.image == nil) {
            dragView.eventImage.image = self.image;
        }
        
        dragView.geoLoc.text = self.distanceString;
        
        NSString *name = event[@"CreatedByName"];
        dragView.createdBy.text = name;
        
        NSString *urlStr = event[@"URL"];
        if (urlStr == nil || [urlString isEqualToString:@""])
            dragView.URL = @"";
        else
            dragView.URL = urlStr;
        
        NSString *ticketLinkString = event[@"TicketLink"];
        if (ticketLinkString == nil || [ticketLinkString isEqualToString:@""])
            dragView.ticketLink = @"";
        else
            dragView.ticketLink = ticketLinkString;
        
        NSNumber *lowPriceNumber = event[@"lowest_price"];
        if (![lowPriceNumber isKindOfClass:[NSNull class]] && lowPriceNumber != nil) {
            dragView.startPriceNumLabel.text = [NSString stringWithFormat:@"$%d", [lowPriceNumber intValue]];
        } else {
            dragView.startPriceNumLabel.text = @"";
        }
        
        
        NSNumber *avePriceNumber = event[@"average_price"];
        if (![avePriceNumber isKindOfClass:[NSNull class]] && lowPriceNumber != nil) {
            dragView.avePriceNumLabel.text = [NSString stringWithFormat:@"$%d", [avePriceNumber intValue]];
        } else {
            dragView.avePriceNumLabel.text = @"";
        }
        
        [self addExtrasToCard];
        
    }
    
}

- (void)addExtrasToCard {
    
    UIScrollView *friendScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(15 + 46 + 10, 255, 254 - 46 - 10, 50)];
    friendScrollView.scrollEnabled = YES;
    friendScrollView.showsHorizontalScrollIndicator = NO;
    [dragView.cardView addSubview:friendScrollView];
    friendScrollView.delegate = self;
    
    UIButton *hapLogoButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 252, 46, 46)];
    //[hapLogoButton setImage:[UIImage imageNamed:@"AppLogoButton"] forState:UIControlStateNormal];
    
    [hapLogoButton setTitle:@"INVITE" forState:UIControlStateNormal];
    [hapLogoButton setTitleColor:[UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0] forState:UIControlStateNormal];
    [hapLogoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    hapLogoButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:9.0];
    
    hapLogoButton.layer.cornerRadius = 23;
    hapLogoButton.layer.masksToBounds = YES;
    hapLogoButton.layer.borderColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
    hapLogoButton.layer.borderWidth = 1;
    hapLogoButton.accessibilityIdentifier = @"hap";
    hapLogoButton.userInteractionEnabled = YES;
    [dragView.cardView addSubview:hapLogoButton];
    
    [hapLogoButton addTarget:self action:@selector(inviteHomies) forControlEvents:UIControlEventTouchUpInside];
    [hapLogoButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [hapLogoButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
    [hapLogoButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragExit];
    
    
    [self loadFBFriends:friendScrollView withCard:dragView];
    //[draggableView.cardView addSubview:friendScrollView];
    friendScrollView.tag = 33;
    
    extraDescHeight = [self moreButtonUpdateFrame];
    [self addSubviewsToCard];
}


- (void)expandCurrentView {
    
    if (isExpanded == NO) {
        
        extraDescHeight = [self moreButtonUpdateFrame];
                
        dragView.panGestureRecognizer.enabled = NO;
        
        NSLog(@"EXTRA DESC HEIGHT ==== %f", extraDescHeight);
        
        scrollView.scrollEnabled = YES;
        
        //dragView.spring.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y - 45, draggableBackground.frame.size.width, 320 + 235 + extraDescHeight);
        
        [UIView animateWithDuration:0.5 animations:^{
            
            dragView.frame = CGRectMake(dragView.frame.origin.x, dragView.frame.origin.y, dragView.frame.size.width, 320 + 235 + 16 + 60 + extraDescHeight);
            
            dragView.cardView.frame = CGRectMake(dragView.cardView.frame.origin.x, dragView.cardView.frame.origin.y, dragView.cardView.frame.size.width, 320 + 235 + 16 + 60 + extraDescHeight);
            
            CGRect frame = self.tabBarController.tabBar.frame;
            CGFloat offsetY = frame.origin.y;
            self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
            
            //xButton.center = CGPointMake(-1000, xButton.center.y);
            //checkButton.center = CGPointMake(1300, checkButton.center.y);
            
            // %%% ANIMATES CARD ELEMENTS:

            
        } completion:^(BOOL finished) {
            
            //dragView.cardView.layer.masksToBounds = NO;
            
        }];
        
        
    } else {
        
        [UIView animate:^{
            [scrollView viewWithTag:90].alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
        
        dragView.panGestureRecognizer.enabled = YES;
        
        //dragView.cardView.layer.masksToBounds = YES;
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        scrollView.scrollEnabled = NO;
        
        /*
        draggableBackground.spring.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y + 45, draggableBackground.frame.size.width, 350);
        draggableBackground.springBounciness = 10;
        draggableBackground.springSpeed = 10; */
        
        [UIView animateWithDuration:0.5 animations:^{
            
            dragView.frame = CGRectMake(dragView.frame.origin.x, dragView.frame.origin.y, dragView.frame.size.width, 350);
            dragView.cardView.frame = CGRectMake(dragView.cardView.frame.origin.x, dragView.cardView.frame.origin.y, dragView.cardView.frame.size.width, 350);
            
            //xButton.center = CGPointMake(21.75, xButton.center.y);
            //checkButton.center = CGPointMake(302.25, checkButton.center.y);
            
            CGRect frame = self.tabBarController.tabBar.frame;
            self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, -519);
            
            // %%% CONTRACTS CARD ELEMENTS:
            
            dragView.moreButton.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            for (UIView *view in dragView.cardView.subviews) {
                
                if (view.tag == 3)
                    [view removeFromSuperview];
            }
            
            dragView.subtitle.alpha = 0;
            dragView.cardView.layer.masksToBounds = NO;
            
        }];
        
    }
    
    isExpanded =! isExpanded;
    
}


-(CGFloat) moreButtonUpdateFrame {
    
    dragView.subtitle.numberOfLines = 0;
    dragView.subtitle.alpha = 1.0;
    
    if (![self doesString:dragView.subtitle.text contain:@"Details: "]) {
        
        UIFont *font = [UIFont fontWithName:@"OpenSans-Bold" size:12.0];
        NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithObject:font
                                                                                  forKey:NSFontAttributeName];
        //[attrsDictionary setObject:[UIColor colorWithRed:0.0/255 green:176.0/255 blue:242.0/255 alpha:1.0] forKey:NSForegroundColorAttributeName];
        [attrsDictionary setObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:@"Details: " attributes:attrsDictionary];
        
        NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:dragView.subtitle.text];
        
        [aAttrString1 appendAttributedString:aAttrString2];
        
        dragView.subtitle.attributedText = aAttrString1;
        
    }
    
    // Each line = approx 16.5
    CGFloat lineSizeTotal = 0;
    
    CGRect rect = [dragView.subtitle.attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    CGSize actualSize = rect.size;
    
    if (actualSize.height > 65) // > 4 lines
    {
        // show your more button
        dragView.subtitle.numberOfLines = 4;
        lineSizeTotal = actualSize.height;
        dragView.moreButton.alpha = 1.0;
        
    } else {
        
        lineSizeTotal = actualSize.height;
    }
    
    [dragView.subtitle sizeToFit];
    dragView.moreButton.center = CGPointMake(dragView.center.x, dragView.subtitle.frame.origin.y + actualSize.height + 7);
    
    //NSLog(@"linesize ==== %f", lineSizeTotal);
    return lineSizeTotal + 7 + dragView.moreButton.frame.size.height;
    
}

- (void)addSubviewsToCard {
    
    scrollView.contentSize = CGSizeMake(320, 600 + 17 + 60 + extraDescHeight);
    
    scrollView.delaysContentTouches = YES;
    
    dragView.cardView.userInteractionEnabled = YES;
    dragView.cardView.layer.masksToBounds = YES;

    BTNDropinButton *uberBTN =[[BTNDropinButton alloc] initWithButtonId:@"btn-0acf02149a673eb6"];
    uberBTN.tag = 90;
    //[uberBTN setFrame:CGRectMake(0, 555 + extraDescHeight, 180, 24)];// scroll view
    //uberBTN.center = CGPointMake(142, uberBTN.center.y);
    
    NSString *locationText = [NSString stringWithString:dragView.location.text];
    locationText = [locationText stringByReplacingOccurrencesOfString:@"at " withString:@""];
    
    BTNVenue *venue = [BTNVenue venueWithId:@"abc123" venueName:locationText latitude:dragView.geoPoint.latitude longitude:dragView.geoPoint.longitude];
    
    NSDate *eventDate = dragView.eventObject[@"Date"];
    
    if ([eventDate compare:[NSDate dateWithTimeIntervalSinceNow:-3600]] == NSOrderedDescending) { // more than 1 hr before, show reminder
        
        [uberBTN setFrame:CGRectMake(0, 552 + extraDescHeight - 28, 217, 30)];
        uberBTN.center = CGPointMake(dragView.center.x - 18, uberBTN.center.y);
        
        NSDictionary *context = @{
                                  BTNContextApplicableDateKey: eventDate,
                                  BTNContextEndLocationKey:venue.location,
                                  BTNContextReminderUseDebugIntervalKey: @YES
                                  };
        [uberBTN prepareForDisplayWithContext:context completion:^(BOOL isDisplayable) {
            if (isDisplayable) {
                [dragView addSubview:uberBTN];
            }
        }];
        
    } else {
        
        [uberBTN setFrame:CGRectMake(0, 552 + extraDescHeight - 28, 175, 30)];
        uberBTN.center = CGPointMake(dragView.center.x - 18, uberBTN.center.y);
        
        [uberBTN prepareForDisplayWithVenue:venue completion:^(BOOL isDisplayable) {
            if (isDisplayable) {
                [dragView addSubview:uberBTN];
            }
        }];
    }
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(15, 440 + extraDescHeight - 60, 254, 133)];
    [dragView.cardView addSubview:mapView];
    mapView.tag = 3;
    
    mapView.delegate = self;
    mapView.layer.masksToBounds = YES;
    
    mapView.layer.cornerRadius = 10.0;
    //self.layer.shadowRadius = 0.1;
    mapView.layer.shadowOpacity = 0.1;
    mapView.layer.shadowOffset = CGSizeMake(0, 5);
    mapView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    mapView.layer.borderWidth = 0.5;
    mapView.scrollEnabled = NO;
    mapView.zoomEnabled = YES; // Change???
    
    PFGeoPoint *loc = event[@"GeoLoc"];
    CLLocation *mapLocation = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
    
    annotation = [[MKPointAnnotation alloc]init];
    [annotation setCoordinate:mapLocation.coordinate];
    [annotation setTitle:dragView.location.text];
    
    [[[CLGeocoder alloc]init] reverseGeocodeLocation:mapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks[0];
        
        NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
        NSString *addressString = [lines componentsJoinedByString:@" "];
        NSLog(@"Address: %@", addressString);
        
        NSString *streetName = placemark.addressDictionary[@"Street"];
        NSString *cityName = placemark.addressDictionary[@"City"];
        NSString *stateName = placemark.addressDictionary[@"State"];
        NSString *zipCode = placemark.addressDictionary[@"ZIP"];
        
        if (streetName && zipCode && cityName) {
            annotation.subtitle = [NSString stringWithFormat:@"%@ %@, %@ %@", streetName, cityName, stateName, zipCode];
        } else if (zipCode && !streetName) {
            annotation.subtitle = [NSString stringWithFormat:@"%@, %@ %@", cityName, stateName, zipCode];;
        } else if (cityName && streetName) {
            annotation.subtitle = [NSString stringWithFormat:@"%@ %@, %@", streetName, cityName, stateName];
        } else
            annotation.subtitle = dragView.location.text;
        
    }];
    
    [mapView setZoomEnabled:NO];
    [mapView addAnnotation:annotation];
    [mapView viewForAnnotation:annotation];
    [mapView selectAnnotation:annotation animated:YES];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapLocation.coordinate, 750, 750);
    [mapView setRegion:region animated:NO];
    [mapView setUserTrackingMode:MKUserTrackingModeNone];
    [mapView regionThatFits:region];
    
    UITapGestureRecognizer *mapTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(mapViewTapped)];
    [mapView addGestureRecognizer:mapTap];
    
    /*
     UIButton *mapButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 254, 133)];
     [mapButton addTarget:self action:@selector(mapViewTapped) forControlEvents:UIControlEventTouchUpInside];
     [mapView addSubview:mapButton];
     //[mapButton setBackgroundColor:[UIColor whiteColor]];
     */
    
    NSString *ticketLink = [NSString stringWithFormat:@"%@", event[@"TicketLink"]];
    int height = 0;
    
    if (ticketLink != nil && (![ticketLink isEqualToString:@""] || ![ticketLink isEqualToString:@"$0"])) {
        
        height += 20;
        
        ticketsButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 360.5 + extraDescHeight - 62, 100, 25)];
        ticketsButton.enabled = YES;
        ticketsButton.userInteractionEnabled = YES;
        ticketsButton.tag = 3;
        UIColor *hapBlue = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0];
        [ticketsButton setTitle:@"GET TICKETS" forState:UIControlStateNormal];
        [ticketsButton setTitleColor:hapBlue forState:UIControlStateNormal];
        [ticketsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [ticketsButton setBackgroundColor:[UIColor whiteColor]];
        
        ticketsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:12.0];
        
        ticketsButton.layer.masksToBounds = YES;
        ticketsButton.layer.borderColor = hapBlue.CGColor;
        ticketsButton.layer.borderWidth = 1.0;
        ticketsButton.layer.cornerRadius = 25/2;
        
        [ticketsButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
        [ticketsButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
        [ticketsButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragExit];
        
        
        /*
         if ([self doesString:ticketLink contain:@"eventbrite"]) {  //[ticketLink containsString:@"eventbrite"]) {
         
         [ticketsButton setImage:[UIImage imageNamed:@"buy tickets"] forState:UIControlStateNormal];
         [ticketsButton setImage:[UIImage imageNamed:@"buy tickets pressed"] forState:UIControlStateHighlighted];
         
         } else if ([self doesString:ticketLink contain:@"facebook"]) {  //[ticketLink containsString:@"eventbrite"]) {
         
         ticketsButton.frame = CGRectMake(15, 360 + extraDescHeight - 62, 136.9, 25);
         [ticketsButton setImage:[UIImage imageNamed:@"join facebook"] forState:UIControlStateNormal];
         [ticketsButton setImage:[UIImage imageNamed:@"join facebook pressed"] forState:UIControlStateHighlighted];
         
         } else if ([self doesString:ticketLink contain:@"meetup"]) {  //[ticketLink containsString:@"eventbrite"]) {
         
         ticketsButton.frame = CGRectMake(15, 360 + extraDescHeight - 62, 145, 20);
         [ticketsButton setImage:[UIImage imageNamed:@"rsvp to meetup"] forState:UIControlStateNormal];
         [ticketsButton setImage:[UIImage imageNamed:@"rsvp to meetup pressed"] forState:UIControlStateHighlighted];
         
         } else {
         
         ticketsButton.frame = CGRectMake(15, 360 + extraDescHeight - 62, 121.25, 25);
         [ticketsButton setImage:[UIImage imageNamed:@"get tickets"] forState:UIControlStateNormal];
         [ticketsButton setImage:[UIImage imageNamed:@"get tickets pressed"] forState:UIControlStateHighlighted];
         
         } */
        
        [dragView.cardView addSubview:ticketsButton];
        
        ticketsButton.accessibilityIdentifier = ticketLink;
        [ticketsButton addTarget:self action:@selector(ticketsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([self doesString:ticketLink contain:@"seatgeek.com"]) {
            
            if (![dragView.startPriceNumLabel.text isEqualToString:@""] && ![dragView.startPriceNumLabel.text isEqualToString:@"$0"]) {
                
                UILabel *startingPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 349 + extraDescHeight - 62, 100, 30)];
                startingPriceLabel.textAlignment = NSTextAlignmentCenter;
                startingPriceLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12.0];
                startingPriceLabel.textColor = [UIColor darkGrayColor];
                startingPriceLabel.text = @"Starting";
                [startingPriceLabel sizeToFit];
                startingPriceLabel.center = CGPointMake(ticketsButton.center.x + 85 , ticketsButton.center.y);
                startingPriceLabel.tag = 3;
                [dragView.cardView addSubview:startingPriceLabel];
                
                dragView.startPriceNumLabel.frame = CGRectMake(startingPriceLabel.frame.size.width + startingPriceLabel.frame.origin.x + 5, startingPriceLabel.frame.origin.y, 50, 30);
                [dragView.startPriceNumLabel sizeToFit];
                dragView.startPriceNumLabel.center = CGPointMake(dragView.startPriceNumLabel.center.x, startingPriceLabel.center.y);
                [dragView.cardView addSubview:dragView.startPriceNumLabel];
                //draggableBackground.dragView.startPriceNumLabel.text = @"$19";
                
                if (![dragView.avePriceNumLabel.text isEqualToString:@""] && ![dragView.avePriceNumLabel.text isEqualToString:@"$0"]) {
                    
                    UILabel *avgPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(dragView.startPriceNumLabel.frame.origin.x + dragView.startPriceNumLabel.frame.size.width + 10, 349 + extraDescHeight - 62, 100, 30)];
                    avgPriceLabel.textAlignment = NSTextAlignmentCenter;
                    avgPriceLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:12.0];
                    avgPriceLabel.textColor = [UIColor darkGrayColor];
                    avgPriceLabel.text = @"Avg";
                    [avgPriceLabel sizeToFit];
                    avgPriceLabel.center = CGPointMake(avgPriceLabel.center.x , ticketsButton.center.y);
                    avgPriceLabel.tag = 3;
                    [dragView.cardView addSubview:avgPriceLabel];
                    
                    dragView.avePriceNumLabel.frame = CGRectMake(avgPriceLabel.frame.size.width + avgPriceLabel.frame.origin.x + 5, avgPriceLabel.frame.origin.y, 50, 30);
                    [dragView.avePriceNumLabel sizeToFit];
                    dragView.avePriceNumLabel.center = CGPointMake(dragView.avePriceNumLabel.center.x, avgPriceLabel.center.y);
                    [dragView.cardView addSubview:dragView.avePriceNumLabel];
                    //draggableBackground.dragView.avePriceNumLabel.text = @"$33";
                }
            }
        } else if ([self doesString:ticketLink contain:@"facebook.com"]) {
            
            [ticketsButton setTitle:@"RSVP TO FACEBOOK EVENT" forState:UIControlStateNormal];
            ticketsButton.frame = CGRectMake(15, 360.5 + extraDescHeight - 62, 200, 25);
            ticketsButton.center = CGPointMake(dragView.center.x, ticketsButton.center.y);
            
        } else if ([self doesString:ticketLink contain:@"meetup.com"]) {
            
            [ticketsButton setTitle:@"RSVP ON MEETUP.COM" forState:UIControlStateNormal];
            ticketsButton.frame = CGRectMake(15, 360.5 + extraDescHeight - 62, 200, 25);
            ticketsButton.center = CGPointMake(dragView.center.x, ticketsButton.center.y);
            
        } else if ([[dragView.eventObject objectForKey:@"isFreeEvent"] isEqualToNumber:@YES]) {
            
            [ticketsButton setTitle:@"THIS EVENT IS FREE!" forState:UIControlStateNormal];
            ticketsButton.frame = CGRectMake(15, 360.5 + extraDescHeight - 62, 200, 25);
            ticketsButton.center = CGPointMake(dragView.center.x, ticketsButton.center.y);
            
        }
        
    } else { //no tix
        
        UILabel *noTixLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 360.5 + extraDescHeight - 62, 250, 25)];
        noTixLabel.textAlignment = NSTextAlignmentCenter;
        noTixLabel.font = [UIFont fontWithName:@"OpenSans-Extrabold" size:12.0];
        noTixLabel.textColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0];
        noTixLabel.tag = 3;
        
        if ([[dragView.eventObject objectForKey:@"isTicketedEvent"] isEqualToNumber:@NO]) {
            noTixLabel.text = @"This event does not have tickets.";
        } else if ([[dragView.eventObject objectForKey:@"isFreeEvent"] isEqualToNumber:@YES]){
            noTixLabel.text = @"This event is free! No tickets required.";
        } else {
            noTixLabel.text = @"No ticket information is available.";
        }
        
        noTixLabel.center = CGPointMake(dragView.center.x, noTixLabel.center.y);
        [self.dragView.cardView addSubview:noTixLabel];
        
    }
    
    CGPoint center = dragView.cardView.center;
    
    UIButton *notInterestedButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 620, 35, 35)];
    notInterestedButton.center = CGPointMake((center.x - 80), notInterestedButton.center.y);
    [notInterestedButton setImage:[UIImage imageNamed:@"frown"] forState:UIControlStateNormal];
    [dragView.cardView addSubview:notInterestedButton];
    [notInterestedButton addTarget:self action:@selector(expandedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    notInterestedButton.tag = -1;
    
    UILabel *notInterestedLabel = [[UILabel alloc] initWithFrame:notInterestedButton.frame];
    notInterestedLabel.text = @"Not Interested";
    notInterestedLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:8.0];
    notInterestedLabel.textColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
    [notInterestedLabel sizeToFit];
    notInterestedLabel.center = CGPointMake(notInterestedButton.center.x, notInterestedButton.center.y + 25);
    notInterestedLabel.tag = 3;
    [dragView.cardView addSubview:notInterestedLabel];
    
    UIButton *interestedButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 620, 35, 35)];
    interestedButton.center = CGPointMake((center.x + 80), interestedButton.center.y);
    [interestedButton setImage:[UIImage imageNamed:@"smile"] forState:UIControlStateNormal];
    [dragView.cardView addSubview:interestedButton];
    [interestedButton addTarget:self action:@selector(expandedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    interestedButton.tag = 1;
    
    UILabel *interestedLabel = [[UILabel alloc] initWithFrame:interestedButton.frame];
    interestedLabel.text = @"Interested";
    interestedLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:8.0];
    interestedLabel.textColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
    [interestedLabel sizeToFit];
    interestedLabel.center = CGPointMake(interestedButton.center.x, interestedButton.center.y + 25);
    interestedLabel.tag = 3;
    [dragView.cardView addSubview:interestedLabel];
    
    UIButton *upButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 620, 35, 35)];
    upButton.center = CGPointMake(center.x, upButton.center.y);
    [upButton setImage:[UIImage imageNamed:@"upArrow"] forState:UIControlStateNormal];
    [dragView.cardView addSubview:upButton];
    [upButton addTarget:self action:@selector(expandedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    upButton.tag = 2;
    
    UILabel *upLabel = [[UILabel alloc] initWithFrame:upButton.frame];
    upLabel.text = @"Go Back";
    upLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:8.0];
    upLabel.textColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
    [upLabel sizeToFit];
    upLabel.center = CGPointMake(upButton.center.x, upButton.center.y + 25);
    upLabel.tag = 3;
    [dragView.cardView addSubview:upLabel];
    
    [dragView.cardView bringSubviewToFront:mapView];
    
}

- (void)loadFBFriends:(UIScrollView *)friendScrollView withCard:(DraggableView *)card {
    
    card.interestedNames = [NSMutableArray new];
    card.interestedIds = [NSMutableArray new];
    
    if ([FBSDKAccessToken currentAccessToken]) {
        
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"/me/friends?limit=1000" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            //code
            
            NSArray* friends = [result objectForKey:@"data"];
            //NSLog(@"Found: %lu friends", (unsigned long)friends.count);
            
            __block int friendCount = 0;
            
            NSMutableArray *friendObjectIDs = [[NSMutableArray alloc] init];
            for (int i = 0; i < friends.count; i ++) {
                NSDictionary *friend = friends[i];
                [friendObjectIDs addObject:[friend objectForKey:@"id"]];
            }
            
            PFQuery *friendQuery = [PFQuery queryWithClassName:@"Swipes"];
            [friendQuery whereKey:@"FBObjectID" containedIn:friendObjectIDs];
            [friendQuery whereKey:@"EventID" equalTo:card.objectID];
            [friendQuery whereKey:@"swipedRight" equalTo:@YES];
            
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"objectId" matchesKey:@"UserID" inQuery:friendQuery];
            
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                // NSLog(@"%lu friends interested", (unsigned long)objects.count);
                
                if (!error) {
                    
                    NSMutableArray *orderedObjects = [NSMutableArray arrayWithArray:objects];
                    
                    for (PFObject *object in objects) {
                        
                        if ([bestFriendIds containsObject:object[@"FBObjectID"]]) {
                            [orderedObjects removeObject:object];
                            [orderedObjects insertObject:object atIndex:0];
                        }
                        
                    }
                    
                    for (PFObject *object in orderedObjects) {
                        
                        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(50 * friendCount, 0, 40, 40)]; // initWithProfileID:user[@"FBObjectID"] pictureCropping:FBSDKProfilePictureModeSquare];
                        profPicView.profileID = object[@"FBObjectID"];
                        profPicView.pictureMode = FBSDKProfilePictureModeSquare;
                        
                        profPicView.layer.cornerRadius = 20;
                        profPicView.layer.masksToBounds = YES;
                        profPicView.accessibilityIdentifier = object.objectId;
                        profPicView.userInteractionEnabled = YES;
                        [friendScrollView addSubview:profPicView];
                        
                        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFriendProfile:)];
                        [profPicView addGestureRecognizer:gr];
                        
                        UILabel *nameLabel = [[UILabel alloc] init];
                        nameLabel.font = [UIFont fontWithName:@"OpenSans" size:7];
                        nameLabel.textColor = [UIColor blackColor];
                        nameLabel.textAlignment = NSTextAlignmentCenter;
                        nameLabel.text = object[@"firstName"];
                        nameLabel.frame = CGRectMake(5 + (50 * friendCount), 42, 30, 8);
                        [friendScrollView addSubview:nameLabel];
                        
                        friendScrollView.contentSize = CGSizeMake((50 * friendCount) + 40, 50);
                        
                        //[self friendsUpdateFrameBy:50];
                        
                        if ([bestFriendIds containsObject:object[@"FBObjectID"]]) {
                            
                            UIImageView *starImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50 * friendCount + 25, 0, 15, 15)];
                            starImageView.image = [UIImage imageNamed:@"star-blue-bordered"];
                            [friendScrollView addSubview:starImageView];
                        }
                        
                        [card.interestedIds addObject:object[@"FBObjectID"]];
                        [card.interestedNames addObject:[NSString stringWithFormat:@"%@ %@", object[@"firstName"], object[@"lastName"]]];
                        //[interestedPics addObject:profPicView];
                        
                        friendCount++;
                        
                        if (friendCount == 1) {
                            card.friendsInterested.text = [NSString stringWithFormat:@"%d friend interested", friendCount - 1];
                        } else {
                            card.friendsInterested.text = [NSString stringWithFormat:@"%d friends interested", friendCount - 1];
                        }
                        
                    }
                    
                    if (objects.count > 4) {
                        
                        card.friendArrow.alpha = 1;
                    }
                    
                    if (objects.count == 0) {
                        // NSLog(@"No new friends");
                        
                        //[self noFriendsAddButton:friendScrollView];
                        
                    }
                }
                
            }];
            
        }];
        
    } else {
        
        NSLog(@"no token......");
    }
    
}

-(void)showFriendProfile:(UITapGestureRecognizer *)gr {
    
    UIView *view = gr.view;
    friendObjectID = view.accessibilityIdentifier;
    [self performSegueWithIdentifier:@"showFriendProfile" sender:self];
    
}

-(void)inviteHomies {
    [self performSegueWithIdentifier:@"toInviteHomies" sender:self];
}

-(BOOL)doesString:(NSString *)first contain:(NSString*)other {
    NSRange range = [first rangeOfString:other];
    return range.length != 0;
}

- (void)ticketsButtonTapped:(UIButton *)button {
    
    urlString = button.accessibilityIdentifier;
    [self performSegueWithIdentifier:@"toWebView" sender:self];
    
}

- (void)mapViewTapped {
    
    [self performSegueWithIdentifier:@"toMapView" sender:self];
}

-(void)buttonNormal:(id)sender {
    UIButton *button = (UIButton *)sender;
    dragView.panGestureRecognizer.enabled = YES;
    [button setBackgroundColor:[UIColor whiteColor]];
}

-(void)buttonHighlight:(id)sender {
    UIButton *button = (UIButton *)sender;
    dragView.panGestureRecognizer.enabled = NO;
    [button setBackgroundColor:[UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0]];
}


- (void)expandedButtonTapped:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    [dragView cardExpanded:!isExpanded];
    [self expandCurrentView];
    
    if (button.tag == -1) { // not interested
        
        NSLog(@"swipe left from expanded view");
        [self performSelector:@selector(swipeLeftDVC) withObject:nil afterDelay:0.5];
        
    } else if (button.tag == 1) { // interested
        
        NSLog(@"swipe right from expanded view");
        [self performSelector:@selector(swipeRightDVC) withObject:nil afterDelay:0.5];
        
    } else { // go back
        
        NSLog(@"go back up from expanded view");
        
    }
    
}

-(void)swipeLeftDVC
{
    NSLog(@"Left click");
    [self swipeLeft];
}

-(void)swipeRightDVC
{
    NSLog(@"Right click");
    [self swipeRight];
}

-(void)swipeLeft
{
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    //[UIView animateWithDuration:0.2 animations:^{
    dragView.overlayView.alpha = 1;
    //}];
    [dragView leftClickAction];
}

-(void)swipeRight
{
    dragView.overlayView.mode = GGOverlayViewModeRight;
    //[UIView animateWithDuration:0.2 animations:^{
    dragView.overlayView.alpha = 1;
    //}];
    [dragView rightClickAction];
}

//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card fromExpandedView:(BOOL)expandedBool
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    
    [c.eventObject unpinInBackground];
    [c.eventObject incrementKey:@"swipesLeft"];
    [c.eventObject saveEventually];
    
    PFUser *user = [PFUser currentUser];
    
    [PFCloud callFunctionInBackground:@"swipeAnalytics"
                       withParameters:@{@"userID":user.objectId, @"eventID":dragView.objectID, @"swiped":@"left"}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        // result is @"Hello world!"
                                        //NSLog(@"%@", result);
                                    }
                                }];
    
    PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    [swipesQuery whereKey:@"EventID" equalTo:dragView.objectID];
    [swipesQuery whereKey:@"UserID" equalTo:user.objectId];
    
    PFObject *swipesObject = [PFObject objectWithClassName:@"Swipes"];
    
    [swipesQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        
        if (count > 0) {
            
            NSLog(@"SECOND time Swiping");
            
            [swipesQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                
                object[@"swipedAgain"] = @YES;
                object[@"swipedRight"] = @NO;
                object[@"swipedLeft"] = @YES;
                    
                [object saveInBackground];
                
            }];
            
            
        } else {
            
            NSLog(@"FIRST time Swiping");
            
            swipesObject[@"UserID"] = user.objectId;
            if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
                swipesObject[@"username"] = user.username;
            }
            swipesObject[@"EventID"] = c.objectID;
            swipesObject[@"swipedRight"] = @NO;
            swipesObject[@"swipedLeft"] = @YES;
            
            //never show again if Swiped left
            swipesObject[@"swipedAgain"] = @YES;
            
            
            if ([[PFUser currentUser][@"socialMode"] isEqualToNumber:@YES] && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
                swipesObject[@"FBObjectID"] = user[@"FBObjectID"];
            }
            
            [swipesObject saveInBackground];
            
        }
        
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card fromExpandedView:(BOOL)expandedBool isGoing:(BOOL)isGoing
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    
    PFUser *user = [PFUser currentUser];
    
    [c.eventObject pinInBackground];
    [c.eventObject incrementKey:@"swipesRight"];
    [c.eventObject saveEventually];
    
    NSString *tag = [NSString stringWithFormat:@"%@", c.eventObject[@"Hashtag"]];
    if ([tag isEqualToString:@"Happy Hour"]) {
        [user incrementKey:@"HappyHour"];
    } else {
        [user incrementKey:tag];
    }
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The currentUser saved successfully.
        } else {
            // There was an error saving the currentUser.
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"Parse error: %@", errorString);
        }
    }];
    
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        [PFCloud callFunctionInBackground:@"swipeRight"
                           withParameters:@{@"user":user.objectId, @"event":dragView.objectID, @"fbID":user[@"FBObjectID"], @"fbToken":[FBSDKAccessToken currentAccessToken].tokenString, @"title":dragView.title.text, @"loc":dragView.location.text}
                                    block:^(NSString *result, NSError *error) {
                                        if (!error) {
                                            // result is @"Hello world!"
                                            //NSLog(@"%@", result);
                                        }
                                    }];
    }
    
    [PFCloud callFunctionInBackground:@"swipeAnalytics"
                       withParameters:@{@"userID":user.objectId, @"eventID":dragView.objectID, @"swiped":@"right"}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        // result is @"Hello world!"
                                        NSLog(@"%@", result);
                                    }
                                }];
    
    //swipeAnalytics(userID,eventID,swiped)
    
    //PFObject *analyticsObject = [PFObject objectWithClassName:@"Analytics"];
    //analyticsObject[@"Age"] = user[@"]
    
    PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
    [swipesQuery whereKey:@"EventID" equalTo:dragView.objectID];
    [swipesQuery whereKey:@"UserID" equalTo:user.objectId];
    
    PFObject *swipesObject = [PFObject objectWithClassName:@"Swipes"];
    
    [swipesQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        
        if (count > 0) {
            
            NSLog(@"SECOND time Swiping");
            
            [swipesQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                
                object[@"swipedAgain"] = @YES;
                object[@"swipedAgain"] = @NO;
                object[@"swipedRight"] = @YES;
                object[@"isGoing"] = @(isGoing);
                
                [object saveInBackground];
                
            }];
            
            
        } else {
            
            NSLog(@"FIRST time Swiping");
            
            PFObject *swipesObject = [PFObject objectWithClassName:@"Swipes"];
            swipesObject[@"UserID"] = user.objectId;
            if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
                swipesObject[@"username"] = user.username;
            }
            swipesObject[@"EventID"] = c.objectID;
            swipesObject[@"swipedRight"] = @YES;
            swipesObject[@"swipedLeft"] = @NO;
            swipesObject[@"isGoing"] = @(isGoing);
            
            /*
            if (shouldLimit) {
                swipesObject[@"swipedAgain"] = @YES;
            } */
            
            if ([[PFUser currentUser][@"socialMode"] isEqualToNumber:@YES] && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
                swipesObject[@"FBObjectID"] = user[@"FBObjectID"];
            }
            
            [swipesObject saveInBackground];
            
        }
        
    }];
    
    if ([[PFUser currentUser][@"hasSwipedRight"] isEqualToNumber:@NO] ) {
        NSLog(@"First swipe right");
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        RKSwipeBetweenViewControllers *rk = appDelegate.rk;
        [rk showCallout];
        
        [PFUser currentUser][@"hasSwipedRight"] = @YES;
        [user saveEventually];
    }
    
    if (isGoing) {
        [self swipeDownForWhat:c];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(void)swipeDownForWhat:(UIView *)card {
    
    DraggableView *c = (DraggableView *)card;
    
    PFObject *checklist = [PFObject objectWithClassName:@"Checklist"];
    checklist[@"userId"] = currentUser.objectId;
    checklist[@"eventId"] = c.objectID;
    checklist[@"tix"] = @NO;
    checklist[@"cal"] = @NO;
    checklist[@"invite"] = @NO;
    checklist[@"share"] = @NO;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ChecklistModalVC *controller = [storyboard instantiateViewControllerWithIdentifier:@"checklist"];
    controller.event = c.eventObject;
    [self mh_presentSemiModalViewController:controller animated:YES];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)anno
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else  // use whatever annotation class you used when creating the annotation
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"tag"];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"Annotation"];
        annotationView.frame = CGRectMake(0, 0, 20, 25);
        annotationView.centerOffset = CGPointMake(0, -5);
        //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
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
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aw, man" message:@"Swiping down saves an event to your calendar, and it seems you've disabled this permission. To change this, go to Settings -> Happening -> Calendars -> On"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Okey dokey"
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
             [self accessGrantedForCalendar];
         }
     }];
}


// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    PFObject *object = event;
    
    EKEvent *ekEvent = [EKEvent eventWithEventStore:eventStore];
    
    ekEvent.title = dragView.title.text;
    
    NSDate *startDate = object[@"Date"];
    NSDate *endDate = object[@"EndTime"];
    
    ekEvent.startDate = startDate;
    ekEvent.endDate = endDate;
    
    //get address REMINDER 76597869876
    PFGeoPoint *geoPoint = object[@"GeoLoc"];
    CLLocation *eventLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    NSString *ticketLink = object[@"TicketLink"];
    NSString *description = dragView.subtitle.text;
    
    if ((description == nil || [description isEqualToString:@""]) && (ticketLink == nil || [ticketLink isEqualToString:@""])) {
        ekEvent.notes = [NSString stringWithFormat:@"Venue name: %@", dragView.location.text];
    } else if (ticketLink == nil || [ticketLink isEqualToString:@""]) {
        ekEvent.notes = [NSString stringWithFormat:@"Venue name: %@ // %@", dragView.location.text, description];
    } else if (description == nil || [description isEqualToString:@""]) {
        ekEvent.notes = [NSString stringWithFormat:@"Venue name: %@ // Get tickets at: %@", dragView.location.text, ticketLink];
    } else {
        ekEvent.notes = [NSString stringWithFormat:@"Venue name: %@ // Get tickets at: %@ // %@", dragView.location.text, ticketLink, description];
    }
    
    
    NSString *url = object[@"URL"];
    NSURL *urlFromString = [NSURL URLWithString:url];
    
    if (urlFromString != nil)
        ekEvent.URL = urlFromString;
    else
        ekEvent.URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.happening.city/events/%@", object.objectId]];
    
    
    //[event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 24]];
    //[event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];
    
    
    [[[CLGeocoder alloc]init] reverseGeocodeLocation:eventLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks[0];
        
        NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
        NSString *addressString = [lines componentsJoinedByString:@" "];
        NSLog(@"Address: %@", addressString);
        
        //NSString *name = placemark.addressDictionary[@"Name"];
        NSString *streetName = placemark.addressDictionary[@"Street"];
        NSString *cityName = placemark.addressDictionary[@"City"];
        NSString *stateName = placemark.addressDictionary[@"State"];
        NSString *zipCode = placemark.addressDictionary[@"ZIP"];
        //NSString *country = placemark.addressDictionary[@"Country"];
        
        if (streetName && zipCode && cityName) {
            ekEvent.location = [NSString stringWithFormat:@"%@ %@, %@ %@", streetName, cityName, stateName, zipCode];
        } else if (zipCode && !streetName) {
            ekEvent.location = [NSString stringWithFormat:@"%@, %@ %@", cityName, stateName, zipCode];
        } else if (cityName && streetName) {
            ekEvent.location = [NSString stringWithFormat:@"%@ %@, %@", streetName, cityName, stateName];
        } else
            ekEvent.location = dragView.location.text;
        
        
        //[RKDropdownAlert title:@"Event added to your main calendar!" backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
        
        [ekEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
        //NSError *err;
        //[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        //NSLog(@"Added %@ to calendar. Object ID: %@", dragView.title.text, dragView.objectID);
        
        [self showEditEventVCWithEvent:ekEvent eventStore:eventStore];
    }];
}

-(void)showEditEventVCWithEvent:(EKEvent *)ev eventStore:(EKEventStore *)es {
    calEvent = ev;
    calEventStore = es;
    //[self performSegueWithIdentifier:@"toEKEventEdit" sender:self];
    
    EKEventEditViewController *vc = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    vc.eventStore = calEventStore;
    vc.event = ev;
    
    vc.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [vc.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    vc.navigationBar.translucent = NO;
    vc.navigationBar.barStyle = UIBarStyleBlack;
    vc.navigationBar.tintColor =[UIColor whiteColor];
    vc.navigationItem.title = @"Add to Calendar";
    
    [self presentViewController:vc animated:YES completion:nil];
    vc.editViewDelegate = self;
}

-(void)showBoom {
    
    NSLog(@"Boom");
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -66)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
            [SVProgressHUD showSuccessWithStatus:@"Boom"];
            [SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
        });
    });
    
}

-(void)showError:(NSString *)message {
    
    NSLog(@"Error");
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -66)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
            [SVProgressHUD showErrorWithStatus:message];
            [SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
        });
    });
    
}

- (IBAction)xButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toInviteHomies"]) {
        
        inviteHomies *vc = (inviteHomies *)[[segue destinationViewController] topViewController];
        vc.objectID = dragView.objectID;
        vc.eventTitle = dragView.title.text;
        vc.eventLocation = dragView.location.text;
        vc.event = event;
        vc.interestedNames = dragView.interestedNames;
        vc.interestedIds = dragView.interestedIds;
        vc.delegate = self;
        
    } else if ([segue.identifier isEqualToString:@"toMapView"]) {
        
        DragMapViewController *vc = (DragMapViewController *)[segue destinationViewController];
        //vc.mapView = mapView;
        vc.event = dragView.eventObject;
        vc.locationTitle = annotation.title;
        vc.locationSubtitle = annotation.subtitle;
        
    } else if ([segue.identifier isEqualToString:@"showFriendProfile"]) {
        
        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.userID = friendObjectID;
        
    } else if ([segue.identifier isEqualToString:@"toWebView"]) {
        
        webViewController *vc = (webViewController *)[[segue destinationViewController] topViewController];
        vc.urlString = urlString;
        vc.titleString = dragView.title.text;
        
    } else if ([segue.identifier isEqualToString:@"toEKEventEdit"]) {
        
        EKEventEditViewController *vc = (EKEventEditViewController *)[segue destinationViewController];
        vc.delegate = self;
        vc.event = calEvent;
        vc.eventStore = calEventStore;
        
    } else if ([segue.identifier isEqualToString:@"toMoreDetail"]) {
        
        moreDetailFromCard *vc = (moreDetailFromCard *)[[segue destinationViewController] topViewController];
        vc.eventID = dragView.objectID;
        vc.titleText = dragView.title.text;
        vc.subtitleText = dragView.subtitle.text;
        vc.locationText = dragView.location.text;
    }
    
}


@end
