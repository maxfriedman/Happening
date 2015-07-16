//
//  ExpandedCardVC.m
//  Happening
//
//  Created by Max on 7/2/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ExpandedCardVC.h"
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


@interface ExpandedCardVC () <inviteHomiesDelegate, UINavigationControllerDelegate, DraggableViewDelegate>

@property DraggableView *dragView;
@property UIButton *smileButton;
@property UIButton *frownButton;
@property NSArray *bestFriendIds;
@property PFUser *currentUser;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) MKMapView *mapView;

@end

@implementation ExpandedCardVC {
    
    CGFloat extraDescHeight;
    MKPointAnnotation *annotation;
    UIButton *uberButton;
    UIButton *ticketsButton;
    
    EKEvent *calEvent;
    EKEventStore *calEventStore;
    NSString *friendObjectID;
    NSString *urlString;
}

static const float CARD_HEIGHT = 620; //%%% height of the draggable card
static const float CARD_WIDTH = 284; //%%% width of the draggable card

@synthesize dragView, scrollView, smileButton, frownButton, bestFriendIds, currentUser, event, mapView;

- (void)viewWillAppear:(BOOL)animated {
    
    if (!dragView) {
    
        currentUser = [PFUser currentUser];
        bestFriendIds = currentUser[@"BestFriends"];
        
        smileButton.enabled = NO;
        frownButton.enabled = NO;
        
        scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:scrollView];
        
        dragView = [[DraggableView alloc] initWithFrame:CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT)];
        dragView.frame = CGRectMake(18, 18, CARD_WIDTH, CARD_HEIGHT);
        [dragView.cardBackground removeFromSuperview];
        dragView.delegate = self;
        [self createDraggableView];
        [scrollView addSubview:dragView];
        dragView.panGestureRecognizer.enabled = NO;
        
        scrollView.contentSize = CGSizeMake(320, dragView.frame.size.height + 36);
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
        
        dragView.objectID = event.objectId;
        
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
            
        } else if ([eventDate beginningOfDay] == [[NSDate date]beginningOfDay]) {  // TODAY
            
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            finalString = [NSString stringWithFormat:@"Today at %@", timeString];
            
        } else if ([eventDate beginningOfDay] == [[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]) { // TOMORROW
            
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            finalString = [NSString stringWithFormat:@"Tomorrow at %@", timeString];
            
        } else if ([eventDate endOfWeek] == [[NSDate date]endOfWeek]) { // SAME WEEK
            
            [formatter setDateFormat:@"EEEE"];
            NSString *dayOfWeekString = [formatter stringFromDate:eventDate];
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            finalString = [NSString stringWithFormat:@"%@ at %@", dayOfWeekString, timeString];
            
        } else if ([eventDate beginningOfDay] != [endDate beginningOfDay]) { //MULTI-DAY EVENT
            
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
        
        CAGradientLayer *l = [CAGradientLayer layer];
        l.frame = dragView.eventImage.bounds;
        l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9] CGColor], nil];

        l.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.2],
                       [NSNumber numberWithFloat:0.5],
                       [NSNumber numberWithFloat:1.0], nil];
        
        [dragView.eventImage.layer insertSublayer:l atIndex:0];
        
        NSString *name = event[@"CreatedByName"];
        dragView.createdBy.text = name;
        
        NSString *urlString = event[@"URL"];
        if (urlString == nil || [urlString isEqualToString:@""])
            dragView.URL = @"";
        else
            dragView.URL = urlString;
        
        NSString *ticketLinkString = event[@"TicketLink"];
        if (ticketLinkString == nil || [ticketLinkString isEqualToString:@""])
            dragView.ticketLink = @"";
        else
            dragView.ticketLink = ticketLinkString;
        
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
    
    
    [self loadFBFriends:friendScrollView];
    //[draggableView.cardView addSubview:friendScrollView];
    friendScrollView.tag = 33;
    
    extraDescHeight = [self moreButtonUpdateFrame];
    [self addSubviewsToCard];
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
    
    scrollView.contentSize = CGSizeMake(320, 588 + 12 + 45 + extraDescHeight);
    
    scrollView.delaysContentTouches = YES;
    
    dragView.cardView.userInteractionEnabled = YES;
    dragView.cardView.layer.masksToBounds = YES;
    
    UILabel *startingPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 349 + extraDescHeight - 62, 100, 30)];
    startingPriceLabel.textAlignment = NSTextAlignmentCenter;
    startingPriceLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:11.0];
    startingPriceLabel.textColor = [UIColor darkGrayColor];
    startingPriceLabel.text = @"Starting";
    startingPriceLabel.tag = 3;
    [dragView.cardView addSubview:startingPriceLabel];
    
    UILabel *avgPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 349 + extraDescHeight - 62, 100, 30)];
    avgPriceLabel.textAlignment = NSTextAlignmentCenter;
    avgPriceLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:11.0];
    avgPriceLabel.textColor = [UIColor darkGrayColor];
    avgPriceLabel.text = @"Avg";
    avgPriceLabel.tag = 3;
    [dragView.cardView addSubview:avgPriceLabel];
    
    dragView.startPriceNumLabel.frame = CGRectMake(0, 0, 50, 30);
    dragView.startPriceNumLabel.center = CGPointMake(startingPriceLabel.center.x, startingPriceLabel.center.y + 15);
    [dragView.cardView addSubview:dragView.startPriceNumLabel];
    dragView.startPriceNumLabel.text = @"$19";
    
    dragView.avePriceNumLabel.frame = CGRectMake(0, 0, 50, 30);
    dragView.avePriceNumLabel.center = CGPointMake(avgPriceLabel.center.x, avgPriceLabel.center.y + 15);
    [dragView.cardView addSubview:dragView.avePriceNumLabel];
    dragView.avePriceNumLabel.text = @"$33";
    [[dragView.cardView viewWithTag:90] removeFromSuperview];
    BTNDropinButton *uberBTN =[[BTNDropinButton alloc] initWithButtonId:@"btn-0acf02149a673eb6"];
    uberBTN.tag = 90;
    [uberBTN setFrame:CGRectMake(0, 529 + extraDescHeight, 180, 24)];// scroll view
    //[uberBTN setFrame:CGRectMake(36, 400 + extraDescHeight, 210, 40)];
    uberBTN.center = CGPointMake(dragView.cardView.center.x, uberBTN.center.y);
    //uberBTN.center = CGPointMake(142, uberBTN.center.y);
    [dragView.cardView addSubview:uberBTN];
    
    BTNVenue *venue = [BTNVenue venueWithId:@"abc123" venueName:dragView.location.text latitude:dragView.geoPoint.latitude longitude:dragView.geoPoint.longitude];
    [uberBTN prepareForDisplayWithVenue:venue completion:^(BOOL isDisplayable) {
        if (!isDisplayable) {
            // If you want to hide a Button that has nothing to offer, remove it here.
        }
    }];
    
    
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
    
    if ([event objectForKey:@"TicketLink"]) {
        
        height += 20;
        
        NSLog(@"ticket link::: %@", ticketLink);
        
        ticketsButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 360.5 + extraDescHeight - 62, 120, 25)];
        ticketsButton.enabled = YES;
        ticketsButton.userInteractionEnabled = YES;
        ticketsButton.tag = 3;
        UIColor *hapBlue = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0];
        [ticketsButton setTitle:@"GET TICKETS" forState:UIControlStateNormal];
        [ticketsButton setTitleColor:hapBlue forState:UIControlStateNormal];
        [ticketsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [ticketsButton setBackgroundColor:[UIColor whiteColor]];
        
        ticketsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:13.0];
        
        ticketsButton.layer.masksToBounds = YES;
        ticketsButton.layer.borderColor = hapBlue.CGColor;
        ticketsButton.layer.borderWidth = 1.0;
        ticketsButton.layer.cornerRadius = 25/2;
        
        [ticketsButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
        [ticketsButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
        [ticketsButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragExit];
        
        [dragView.cardView addSubview:ticketsButton];
        
        ticketsButton.accessibilityIdentifier = ticketLink;
        [ticketsButton addTarget:self action:@selector(ticketsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    
    [dragView.cardView bringSubviewToFront:mapView];
    
}

- (void)loadFBFriends:(UIScrollView *)friendScrollView {
    
    // NSLog(@"Loading FB Friends");
    
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
            [friendQuery whereKey:@"EventID" equalTo:dragView.objectID];
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
                        
                        friendCount++;
                        
                        if (friendCount == 1) {
                            dragView.friendsInterested.text = [NSString stringWithFormat:@"%d friend interested", friendCount - 1];
                        } else {
                            dragView.friendsInterested.text = [NSString stringWithFormat:@"%d friends interested", friendCount - 1];
                        }
                        
                    }
                    
                    if (objects.count > 4) {
                        
                        dragView.friendArrow.alpha = 1;
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


-(void)inviteHomies {
    
    [self performSegueWithIdentifier:@"toInviteHomies" sender:self];
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
