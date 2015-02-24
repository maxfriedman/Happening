//
//  moreDetailFromTable.m
//  Happening
//
//  Created by Max on 12/1/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "moreDetailFromTable.h"
#import "CustomCalendarActivity.h"
#import "RKDropdownAlert.h"
#import "webViewController.h"
#import <CoreText/CoreText.h>
#import "ExternalProfileTVC.h"
#import "moreDetailFromCard.h"

@interface moreDetailFromTable ()

@property (nonatomic, strong) EKEventStore *eventStore;


@end

@implementation moreDetailFromTable {
    
    CGRect cachedImageViewSize;
    UIVisualEffectView *blurEffectView;
    int cachedHeight;
    MKPointAnnotation *annotation;
    BOOL mapViewExpanded;
    CLLocation *mapLocation;
    NSString *urlString;
    int friendScrollHeight;
    NSString *friendObjectID;

}

@synthesize  mapView, cardView, ticketsButton, uberButton, scrollView, friendScrollView, createdBy, calDayLabel, calDayOfWeekLabel, calMonthLabel, calTimeLabel, eventStore;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    eventStore = [[EKEventStore alloc] init];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(15, 398, 254, 133)];
    [cardView addSubview:mapView];
    
    UIView *shadowView = [[UIView alloc] initWithFrame:cardView.frame];
    shadowView.layer.shadowOffset = CGSizeMake(1, 1);
    shadowView.layer.shadowRadius = 1.0;
    shadowView.layer.shadowOpacity = 0.5;
    [shadowView.layer setCornerRadius:10.0];
    [shadowView.layer setBorderColor:[UIColor clearColor].CGColor];
    [shadowView.layer setBorderWidth:1.0];
    //shadowView.backgroundColor = [UIColor whiteColor];
    
    [self.scrollView addSubview: shadowView];
    [self.scrollView sendSubviewToBack:shadowView];
    
    //cardView = [[UIView alloc]initWithFrame:CGRectMake(15, 15, 290, 900)];
    cardView.layer.masksToBounds = YES;
   // cardView.backgroundColor = [UIColor whiteColor];
    [cardView.layer setCornerRadius:10.0];
    [cardView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [cardView.layer setBorderWidth:1.0];
    //[self.view sendSubviewToBack:cardView];
    
    self.navigationItem.title = self.titleText;
    
    self.eventIDLabel.text = self.eventID;
    self.titleLabel.text = self.titleText;
    self.distanceLabel.text = self.distanceText;
    self.imageView.image = self.image;
    self.locationLabel.text = self.locationText;

    self.subtitleLabel.text = self.subtitleText;
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendToMoreInfo)];
    [self.subtitleLabel addGestureRecognizer:tgr];
    
    /*
    [self.imageView addSubview:self.titleLabel];
    [self.imageView addSubview:self.timeLabel];
    [self.imageView addSubview:self.distanceLabel];
    [self.imageView addSubview:self.locationImageView];
    */
     
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y + 113, self.imageView.frame.size.width, self.imageView.frame.size.height - 100);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];
    
    //[self.imageView.layer insertSublayer:gradient atIndex:0];
    
    CAGradientLayer *l = [CAGradientLayer layer];
    l.frame = self.imageView.bounds;
    l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], nil];
    
    l.startPoint = CGPointMake(0.0, 1.00f);
    l.endPoint = CGPointMake(0.0f, 0.8f);
    
    //you can change the direction, obviously, this would be top to bottom fade
    self.imageView.layer.mask = l;

    [cardView addSubview:self.imageView];
    
    cachedHeight = self.subtitleLabel.frame.size.height;
    
    self.scrollView.contentSize = CGSizeMake(320, 580);
    ticketsButton.alpha = 0;
    uberButton.alpha = 0;
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = CGRectMake(0, 149, self.imageView.frame.size.width, 70);
    //[self.imageView addSubview:blurEffectView];
    //[self.imageView sendSubviewToBack:blurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.frame = blurEffectView.bounds;
    
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *object, NSError *error) {
        
        NSString *interestedNumberText = [object[@"swipesRight"] stringValue];
        self.interestedLabel.text = [NSString stringWithFormat: @"%@ interested", interestedNumberText];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE, MMM d"];
        NSDate *eventDate = [[NSDate alloc]init];
        eventDate = object[@"Date"];
        
        NSString *finalString;
        
        NSDate *endDate = object[@"EndTime"];
        
        if ([eventDate beginningOfDay] <= [[NSDate date]beginningOfDay]) {  // TODAY

            calDayOfWeekLabel.text = @"Today";
            
        } else if ([eventDate beginningOfDay] == [[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]) { // TOMORROW
            
            calDayOfWeekLabel.text = @"Tomorrow";
            
        } else if ([eventDate endOfWeek] == [[NSDate date]endOfWeek]) { // SAME WEEK
            
            [formatter setDateFormat:@"EEEE"];
            calDayOfWeekLabel.text = [formatter stringFromDate:eventDate];
            
        } else if ([eventDate beginningOfDay] != [endDate beginningOfDay]) { //MULTI-DAY EVENT
            
            [formatter setDateFormat:@"EEEE"];
             calDayOfWeekLabel.text = [formatter stringFromDate:eventDate];
            
        } else { // Past this week- uses abbreviated date format
            
            [formatter setDateFormat:@"EEEE"];
             calDayOfWeekLabel.text = [formatter stringFromDate:eventDate];
            
        }
        
        [formatter setDateFormat:@"MMM"];
         calMonthLabel.text = [formatter stringFromDate:eventDate];
        [formatter setDateFormat:@"d"];
        calDayLabel.text =[formatter stringFromDate:eventDate];
        
        [formatter setDateFormat:@"h:mma"];
        NSString *calTimeString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:eventDate], [formatter stringFromDate:endDate]];
        
        if ([calTimeString containsString:@":00"]) {
            
            calTimeString = [calTimeString stringByReplacingOccurrencesOfString:@":00" withString:@" "];
            
        }
        
        calTimeLabel.text = calTimeString;

        UIGestureRecognizer *gr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkEventStoreAccessForCalendar)];
        [calMonthLabel addGestureRecognizer:gr2];
        UIGestureRecognizer *gr3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkEventStoreAccessForCalendar)];
        [calDayLabel addGestureRecognizer:gr3];
        UIGestureRecognizer *gr4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkEventStoreAccessForCalendar)];
        [calDayOfWeekLabel addGestureRecognizer:gr4];
        UIGestureRecognizer *gr5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkEventStoreAccessForCalendar)];
        [calTimeLabel addGestureRecognizer:gr5];
        
        
        PFGeoPoint *loc = object[@"GeoLoc"];
        mapLocation = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
        
        annotation = [[MKPointAnnotation alloc]init];
        [annotation setCoordinate:mapLocation.coordinate];
        [annotation setTitle:self.locationText];
        
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
                annotation.subtitle = self.locationText;
            
        }];
        
        [mapView setZoomEnabled:NO];
        [mapView addAnnotation:annotation];
        [mapView viewForAnnotation:annotation];
        [mapView selectAnnotation:annotation animated:YES];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapLocation.coordinate, 750, 750);
        [mapView setRegion:region animated:NO];
        [mapView setUserTrackingMode:MKUserTrackingModeNone];
        [mapView regionThatFits:region];
       
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(mapViewTapped)];
        [mapView addGestureRecognizer:singleFingerTap];
        
        mapViewExpanded = NO;
        
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:object[@"CreatedByName"]];
        [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                          value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                          range:(NSRange){0,[attString length]}];
        createdBy.attributedText = attString;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCreatedByProfile)];
        [createdBy addGestureRecognizer:gr];
        
        
        
        NSString *ticketLink = [NSString stringWithFormat:@"%@", object[@"TicketLink"]];
        int height = 0;
        
        if ([object objectForKey:@"TicketLink"]) {
            
            height += 30;
            ticketsButton.alpha = 1.0;
            
            NSLog(@"ticket link::: %@", ticketLink);
            
            ticketsButton = [[UIButton alloc] initWithFrame:CGRectMake(79, 552, 126, 20)];
            ticketsButton.enabled = YES;
            ticketsButton.userInteractionEnabled = YES;
            ticketsButton.tag = 3;
            
            if ([ticketLink containsString:@"eventbrite"]) {
                
                //ticketsButton = [[UIButton alloc] initWithFrame:CGRectMake(79, 500, 126, 20)];
                [ticketsButton setImage:[UIImage imageNamed:@"buy tickets"] forState:UIControlStateNormal];
                [ticketsButton setImage:[UIImage imageNamed:@"buy tickets pressed"] forState:UIControlStateSelected];
                
                //[self ticketsUpdateFrameBy:20];
            } else {
                
                //ticketsButton = [[UIButton alloc] initWithFrame:CGRectMake(79, 500, 126, 20)];
                [ticketsButton setImage:[UIImage imageNamed:@"buy tickets"] forState:UIControlStateNormal];
                [ticketsButton setImage:[UIImage imageNamed:@"buy tickets pressed"] forState:UIControlStateSelected];
                
                //[self ticketsUpdateFrameBy:20];
            }
            
            ticketsButton.accessibilityIdentifier = ticketLink;
            [ticketsButton addTarget:self action:@selector(ticketsButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cardView addSubview:ticketsButton];
            
        }
        
        NSDate *startDate = object[@"Date"];
        //NSDate *endDate = object[@"EndTime"];
        
        // Show call uber button if the event is today or if the end date is later than now
        if ( /*[defaults boolForKey:@"today"] */ [startDate beginningOfDay] <= [[NSDate date] beginningOfDay] ) {
            
            height += 30;
            uberButton.alpha = 1.0;

            // adding "height" variable allows flexibility if there is no tickets button
            if (height == 30) {
                
                uberButton = [[UIButton alloc] initWithFrame:CGRectMake(86.5, 552, 111, 20)];
                
            } else {
                
                uberButton = [[UIButton alloc] initWithFrame:CGRectMake(86.5, 520 + height, 111, 20)];
                
            }
            NSLog(@"%@", uberButton.constraints);
            [uberButton setImage:[UIImage imageNamed:@"call uber"] forState:UIControlStateNormal];
            [uberButton setImage:[UIImage imageNamed: @"call uber pressed"] forState:UIControlStateSelected];
            [uberButton addTarget:self action:@selector(grabAnUberButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            uberButton.tag = 3;
            
            [cardView addSubview:uberButton];
            
            //[self uberUpdateFrameBy:20];
        }
        
        [self ticketsAndUberUpdateFrameBy:height + 8];
        
        mapViewExpanded = NO;
    
        [self loadFBFriends];
        
    }];
    
    NSLog(@"%@", self.eventID);
    
}
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self ticketsAndUberUpdateFrameBy:40 + 8];
    });
    
}
*/


- (void)mapViewTapped {
    
    if (!mapViewExpanded) {
    
        //mapView.layer.masksToBounds = NO;
        UIButton *xButton = [[UIButton alloc] initWithFrame:CGRectMake(240, 30, 50, 50)];
        [xButton setImage:[UIImage imageNamed:@"noButton"] forState:UIControlStateNormal];
        xButton.tag = 99;
        [xButton addTarget:self action:@selector(mapViewTapped) forControlEvents:UIControlEventTouchUpInside];
    
        UIButton *directionsButton = [[UIButton alloc] initWithFrame:CGRectMake(85, 400, 150, 30)];
        //[directionsButton setImage:[UIImage imageNamed:@"noButton"] forState:UIControlStateNormal];
        [directionsButton setTitle:@"Get Directions" forState:UIControlStateNormal];
        [directionsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        directionsButton.backgroundColor = [UIColor blueColor];
        directionsButton.layer.cornerRadius = 5.0;
        directionsButton.reversesTitleShadowWhenHighlighted = YES;
        directionsButton.layer.masksToBounds = YES;
        directionsButton.tag = 99;
        [directionsButton addTarget:self action:@selector(redirectToMaps) forControlEvents:UIControlEventTouchUpInside];
        
        //[cardView bringSubviewToFront:mapView];
        mapView.center = self.view.center;
        [self.view addSubview:mapView];
    
        mapView.scrollEnabled = NO;
        mapView.zoomEnabled = YES;
    
    
        [UIView animateWithDuration:0.2 animations:^{

            //mapView.frame = CGRectMake(0, self.mapView.frame.origin.y, self.view.frame.size.width, self.mapView.frame.size.height);
            mapView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);


        } completion:^(BOOL finished) {
        
            [UIView animateWithDuration:0.2 animations:^{
                
                //mapView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
                
            } completion:^(BOOL finished) {
                
                [mapView selectAnnotation:annotation animated:YES];
                [self.view addSubview:xButton];
                [self.view addSubview: directionsButton];
                
                mapViewExpanded = YES;
                
            }];

        
        }];
        
    } else {
        
        [cardView addSubview:mapView];
        
        for (UIView *view in self.view.subviews) {
            
            if (view.tag == 99) {
                [view removeFromSuperview];
            }
        }
        
        [cardView bringSubviewToFront:mapView];
        
        mapView.scrollEnabled = NO;
        mapView.zoomEnabled = NO;
        
        
        [UIView animateWithDuration:0.3 animations:^{
            
            //mapView.frame = CGRectMake(0, 376, 284, 133);
            mapView.frame = CGRectMake(15, 376, 254, 133);

            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.1 animations:^{
                
                //mapView.frame = CGRectMake(15, 376, 254, 133);
                
            } completion:^(BOOL finished) {
                
                [mapView selectAnnotation:annotation animated:YES];
                mapViewExpanded = NO;
                
            }];
            
        }];
        
    }
    
    
    
}

- (void)loadFBFriends {
    
    NSLog(@"Loading FB Friends");
    
    if (!FBSession.activeSession.isOpen) {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_friends"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"That's odd"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              NSLog(@"Session open, recurse");

                                              [self loadFBFriends];
                                          } else {
                                              NSLog(@"Made it");
                                          }
                                      }];
    }
    
    NSLog(@"%@", self.eventID);
    
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                  NSDictionary* result,
                                                  NSError *error) {
        NSArray* friends = [result objectForKey:@"data"];
        NSLog(@"Found: %lu friends", (unsigned long)friends.count);
        
        __block int friendCount = 0;
        
        NSMutableArray *friendObjectIDs = [[NSMutableArray alloc] init];
        for (int i = 0; i < friends.count; i ++) {
            NSDictionary<FBGraphUser>* friend = friends[i];
            [friendObjectIDs addObject:friend.objectID];
        }
        
        PFQuery *friendQuery = [PFQuery queryWithClassName:@"Swipes"];
        [friendQuery whereKey:@"FBObjectID" containedIn:friendObjectIDs];
        [friendQuery whereKey:@"EventID" equalTo:self.eventID];
        [friendQuery whereKey:@"swipedRight" equalTo:@YES];
        
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" matchesKey:@"UserID" inQuery:friendQuery];
        
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

                    
                    if (!error) {
                        
                        for (PFObject *object in objects) {
                        
                    
                            FBProfilePictureView *profPicView = [[FBProfilePictureView alloc] initWithProfileID:object[@"FBObjectID"] pictureCropping:FBProfilePictureCroppingSquare];
                            profPicView.layer.cornerRadius = 20;
                            profPicView.layer.masksToBounds = YES;
                            profPicView.accessibilityIdentifier = object.objectId;
                            profPicView.frame = CGRectMake(50 * friendCount, 0, 40, 40);
                            profPicView.userInteractionEnabled = YES;
                            [self.friendScrollView addSubview:profPicView];
                    
                            UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showFriendProfile:)];
                            [profPicView addGestureRecognizer:gr];
                            
                            UILabel *nameLabel = [[UILabel alloc] init];
                            nameLabel.font = [UIFont fontWithName:@"OpenSans" size:7];
                            nameLabel.textColor = [UIColor colorWithRed:(70.0/255.0) green:(70.0/255.0) blue:(70.0/255.0) alpha:    1.0];
                            nameLabel.textAlignment = NSTextAlignmentCenter;
                            nameLabel.text = object[@"firstName"];
                            nameLabel.frame = CGRectMake(5 + (50 * friendCount), 42, 30, 8);
                            [self.friendScrollView addSubview:nameLabel];
                    
                            self.friendScrollView.contentSize = CGSizeMake((50 * friendCount) + 40, self.friendScrollView.frame.size.height);
                    
                            friendCount++;
                    
                            if (friendCount == 1) {
                                self.friendsInterestedLabel.text = [NSString stringWithFormat:@"%d friend interested", friendCount];
                            } else {
                                self.friendsInterestedLabel.text = [NSString stringWithFormat:@"%d friends interested", friendCount];
                            }
                            
                        }
                    
                        if (objects.count == 0) {
                            NSLog(@"No new friends");
                            [self noFriendsAddButton];
                        }
                        
                    }
                    
            
        
        }];
    }];
    
    
    
}

- (void)noFriendsAddButton {
    
    friendScrollView.scrollEnabled = NO;
    
    UIButton *noFriendsButton = [[UIButton alloc] initWithFrame:CGRectMake(35, 5, 184, 40)];
    [noFriendsButton setTitle:@"Invite your friends" forState:UIControlStateNormal];
    noFriendsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
    [noFriendsButton setTitleColor:[UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    noFriendsButton.layer.masksToBounds = YES;
    noFriendsButton.layer.borderColor = [UIColor colorWithRed:41.0/255 green:181.0/255 blue:1.0 alpha:1.0].CGColor;
    noFriendsButton.layer.borderWidth = 2.0;
    noFriendsButton.layer.cornerRadius = 5.0;
    
    [friendScrollView addSubview:noFriendsButton];
    
}

- (void)ticketsAndUberUpdateFrameBy:(int)height {
    
    NSLog(@"height: %d   %s", height, __FUNCTION__);
    
    
    [UIView animateWithDuration:0.2 animations:^{
            
            //uberButton.center = CGPointMake(uberButton.center.x, uberButton.center.y + height);
            //ticketsButton.center = CGPointMake(ticketsButton.center.x, ticketsButton.center.y + height);

        NSLayoutConstraint *constraint = scrollView.constraints[3];
        constraint.constant = cardView.frame.size.height + height;
        
        scrollView.contentSize = CGSizeMake(320, scrollView.contentSize.height + height);
            
            
        } completion:^(BOOL finished) {

        }];
    
}

/*
- (void)uberUpdateFrameBy:(int)height {
    
    if (!self.frontViewIsVisible) {
        
        [UIView animateWithDuration:0.2 animations:^{
            
            draggableBackground.frame = CGRectMake(draggableBackground.frame.origin.x, draggableBackground.frame.origin.y, draggableBackground.frame.size.width, draggableBackground.frame.size.height + height);
            
            scrollView.contentSize = CGSizeMake(320, scrollView.contentSize.height + height);
            
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
}
*/

- (void)redirectToMaps {
    
    [[[CLGeocoder alloc]init] reverseGeocodeLocation:mapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = placemarks[0];
        
        MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate: mapLocation.coordinate addressDictionary: placemark.addressDictionary];

        MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
        destination.name = self.locationText;
        NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
        NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 MKLaunchOptionsDirectionsModeWalking,
                                 MKLaunchOptionsDirectionsModeKey, nil];
        [MKMapItem openMapsWithItems: items launchOptions: options];
    }];
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"Made it 1");
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else  // use whatever annotation class you used when creating the annotation
    {
        NSLog(@"Made it 2");
        
        MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"tag"];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"Annotation"];
        annotationView.centerOffset = CGPointMake(0, -18);
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)grabAnUberButtonTapped:(id)sender {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        // Do something awesome - the app is installed! Launch App.
        NSLog(@"Uber button tapped- app exists! Opening app...");
        
        /*
        PFQuery *query = [PFQuery queryWithClassName:@"Event"];
        [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *object, NSError *error) {

            PFGeoPoint *loc = object[@"GeoPoint"];
            NSString *locationName = object[@"Location"];
        */
         
            [[[CLGeocoder alloc]init] reverseGeocodeLocation:mapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = placemarks[0];
                NSString *destinationAddress = [[NSString alloc]init];
                
                NSString *streetName = placemark.addressDictionary[@"Street"];
                NSString *cityName = placemark.addressDictionary[@"City"];
                NSString *stateName = placemark.addressDictionary[@"State"];
                NSString *zipCode = placemark.addressDictionary[@"ZIP"];
                NSString *country = placemark.addressDictionary[@"Country"];
                
                
                if (streetName && zipCode && cityName) {
                    destinationAddress = [NSString stringWithFormat:@"%@ %@, %@, %@ %@", streetName, cityName, stateName, zipCode, country];
                } else if (zipCode && !streetName) {
                    destinationAddress = [NSString stringWithFormat:@"%@, %@ %@ %@", cityName, stateName, zipCode, country];
                } else if (cityName && streetName) {
                    destinationAddress = [NSString stringWithFormat:@"%@, %@, %@ %@", streetName, cityName, stateName, country];
                } else
                    destinationAddress = self.locationText;
                
                destinationAddress = [destinationAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            
                NSString *urlStringUber = [NSString stringWithFormat:@"uber://?client_id=Vmks1LNIHQiiaUYd8Z3FaMNkvD-7s53V&action=setPickup&pickup=my_location&dropoff[latitude]=%f&dropoff[longitude]=%f&dropoff[nickname]=%@&dropoff[formatted_address]=%@", mapLocation.coordinate.latitude, mapLocation.coordinate.longitude, self.locationText, destinationAddress ];
                
                urlStringUber = [urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
            
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlStringUber]];
            
            //}];
            
        }];
    }
    else {
        // No Uber app! Open Mobile Website.
        NSLog(@"Uber button tapped- app does not exist! Opening mobile website...");
        
        PFUser *currentUser = [PFUser currentUser];
        
            NSString *firstName = currentUser[@"firstName"];
            NSString *lastName = currentUser[@"lastName"];
            NSString *userEmail = currentUser.email;
            if (!userEmail) {
                userEmail = @"";
            }
            
            
            [[[CLGeocoder alloc]init] reverseGeocodeLocation:mapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = placemarks[0];
                NSString *destinationAddress = [[NSString alloc]init];
                    
                    NSString *streetName = placemark.addressDictionary[@"Street"];
                    NSString *cityName = placemark.addressDictionary[@"City"];
                    NSString *stateName = placemark.addressDictionary[@"State"];
                    NSString *zipCode = placemark.addressDictionary[@"ZIP"];
                    NSString *country = placemark.addressDictionary[@"Country"];
                    
                    
                if (streetName && zipCode && cityName) {
                    destinationAddress = [NSString stringWithFormat:@"%@ %@, %@, %@ %@", streetName, cityName, stateName, zipCode, country];
                } else if (zipCode && !streetName) {
                    destinationAddress = [NSString stringWithFormat:@"%@, %@ %@ %@", cityName, stateName, zipCode, country];
                } else if (cityName && streetName) {
                    destinationAddress = [NSString stringWithFormat:@"%@, %@, %@ %@", streetName, cityName, stateName, country];
                } else
                    destinationAddress = self.locationText;
                
                [destinationAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
                NSLog(@"%@", destinationAddress);
                
            NSString *urlStringUber = [NSString stringWithFormat:@"https://m.uber.com/sign-up?client_id=Vmks1LNIHQiiaUYd8Z3FaMNkvD-7s53V&first_name=%@&last_name=%@&email=%@&country_code=us&&dropoff_latitude=%f&dropoff_longitude=%f&dropoff_nickname=%@", firstName, lastName, userEmail, mapLocation.coordinate.latitude, mapLocation.coordinate.longitude, self.locationText ];
            
                //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
                
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlStringUber]];
            
        }];
        
    }
    
    
    /* https://m.uber.com/sign-up?client_id=YOUR_CLIENT_ID
    &first_name=myFirstName&last_name=myLastName&email=test@example.com
    &country_code=us&mobile_country_code=%2B1&mobile_phone=123-456-7890
    &zipcode=94111&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d&pickup_latitude=37.775818
    &pickup_longitude=-122.418028&pickup_nickname=Uber%20HQ
    &pickup_address=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103
    &dropoff_latitude=37.802374&dropoff_longitude=-122.405818
    &dropoff_nickname=Coit%20Tower
    &dropoff_address=1%20Telegraph%20Hill%20Blvd%2C%20San%20Francisco%2C%20CA%2094133
     */
    
}

- (void)ticketsButtonTapped:(UIButton *)button {
    
    urlString = button.accessibilityIdentifier;
    
    [self performSegueWithIdentifier:@"toWebVC" sender:self];
    
    // IN APP EXPERIENCE
    
    /*
     UIWebView *webView = [[UIWebView alloc] init];
     [webView setFrame:CGRectMake(0, 0, 320, 460)];
     [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gethappeningapp.com"]]];
     [[self view] addSubview:webView];
     */
    
    // OPENS IN SAFARI
    
    //NSURL *url = [[NSURL alloc] initWithString:urlString];
    //[[UIApplication sharedApplication] openURL:url];
    
}



/*
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 
 CGFloat y = -scrollView.contentOffset.y;
 if (y > 0) {
 
 float scale = 1.0f + fabsf(scrollView.contentOffset.y)  / scrollView.frame.size.height;
 
 float alphaScale = 1.0f - 5.0f * (fabsf(scrollView.contentOffset.y)  / scrollView.frame.size.height);
 
 self.titleLabel.alpha = alphaScale;
 self.timeLabel.alpha = alphaScale;
 self.distanceLabel.alpha = alphaScale;
 self.locationImageView.alpha = alphaScale;
 blurEffectView.alpha = alphaScale;
 
 alpha for all views in scroll view....
 for (UIView *view in scrollView.subviews) {
 view.alpha = alphaScale;
 }
 
 //Cap the scaling between zero and 1
 scale = MAX(0.0f, scale);
 
 // Set the scale to the imageView
 self.imageView.transform = CGAffineTransformMakeScale(scale, scale);
 
 } else if (y < 0) {
 
 float scale = 1.0f - 3.0f * (fabsf(-scrollView.contentOffset.y)  / scrollView.frame.size.height);
 
 //Cap the scaling between zero and 1
 scale = MAX(0.0f, scale);
 
 self.imageView.alpha = scale;
 self.imageView.transform = CGAffineTransformMakeTranslation(0, y);
 //self.titleLabel.transform = CGAffineTransformMakeTranslation(0, y);
 //self.timeLabel.transform = CGAffineTransformMakeTranslation(0, y);
 //self.distanceLabel.transform = CGAffineTransformMakeTranslation(0, y);
 //self.locationImageView.transform = CGAffineTransformMakeTranslation(0, y);
 
 
 }
 }
 
 */

- (IBAction)backButtonAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

-(void)showCreatedByProfile {
    [self performSegueWithIdentifier:@"showProf" sender:self];
}

-(void)showFriendProfile:(UITapGestureRecognizer *)gr {
    UIView *view = gr.view;
    friendObjectID = view.accessibilityIdentifier;
    [self performSegueWithIdentifier:@"showFriendProf" sender:self];
}

-(void)sendToMoreInfo {
    [self performSegueWithIdentifier:@"toMoreInfo" sender:self];
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
                                                  cancelButtonTitle:@"Okaaay"
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    PFObject *object = [query getObjectWithId:self.eventID];
    
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    EKEventViewController *evc = [[EKEventViewController alloc] init];
    
    event.title = self.titleText;
    
    event.startDate = object[@"Date"];
    event.endDate = object[@"EndTime"];
    
    //get address REMINDER 76597869876
    PFGeoPoint *geoPoint = object[@"GeoLoc"];
    CLLocation *eventLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    NSString *ticketLink = object[@"TicketLink"];
    NSString *description = self.subtitleText;
    
    if ((description == nil || [description isEqualToString:@""]) && (ticketLink == nil || [ticketLink isEqualToString:@""])) {
        event.notes = [NSString stringWithFormat:@"Venue name: %@", self.locationText];
    } else if (ticketLink == nil || [ticketLink isEqualToString:@""]) {
        event.notes = [NSString stringWithFormat:@"Venue name: %@ // %@", self.locationText, description];
    } else if (description == nil || [description isEqualToString:@""]) {
        event.notes = [NSString stringWithFormat:@"Venue name: %@ // Get tickets at: %@", self.locationText, ticketLink];
    } else {
        event.notes = [NSString stringWithFormat:@"Venue name: %@ // Get tickets at: %@ // %@", self.locationText, ticketLink, description];
    }
    
    
    NSString *url = object[@"URL"];
    NSURL *urlFromString = [NSURL URLWithString:url];
    
    if (urlFromString != nil)
        event.URL = urlFromString;
    else
        event.URL = [NSURL URLWithString:@"http://www.gethappeningapp.com"];
    
    
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
            event.location = [NSString stringWithFormat:@"%@ %@, %@ %@", streetName, cityName, stateName, zipCode];
        } else if (zipCode && !streetName) {
            event.location = [NSString stringWithFormat:@"%@, %@ %@", cityName, stateName, zipCode];
        } else if (cityName && streetName) {
            event.location = [NSString stringWithFormat:@"%@ %@, %@", streetName, cityName, stateName];
        } else
            event.location = self.locationText;
        
        
        //[RKDropdownAlert title:@"Event added to your main calendar!" backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        //[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        //NSLog(@"Added %@ to calendar. Object ID: %@", dragView.title.text, dragView.objectID);
        
        [self showEditEventVCWithEvent:event eventStore:eventStore];
    }];
    
}

-(void)showEditEventVCWithEvent:(EKEvent *)event eventStore:(EKEventStore *)es {

    //[self performSegueWithIdentifier:@"toEKEventEdit" sender:self];
    
    EKEventEditViewController *vc = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
    vc.eventStore = es;
    vc.event = event;
    
    vc.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [vc.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    vc.navigationBar.translucent = NO;
    vc.navigationBar.barStyle = UIBarStyleBlack;
    vc.navigationBar.tintColor =[UIColor whiteColor];
    vc.navigationItem.title = @"Add to Calendar";
    
    [self presentViewController:vc animated:YES completion:nil];
    vc.editViewDelegate = self;
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
    
    if (action == EKEventEditViewActionCancelled || action == EKEventEditViewActionCanceled) {
        NSLog(@"Clicked Cancel");
    } else if (action == EKEventEditViewActionSaved) {
        NSLog(@"Clicked Add -- event saved to calendar");
        [RKDropdownAlert title:@"Event added to your main calendar!" backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)shareAction:(id)sender {
    
    DraggableView *dragView = [[DraggableView alloc] init];
    dragView.title.text = self.titleText;
    dragView.location.text = self.locationText;
    dragView.subtitle.text = self.subtitleText;
    dragView.objectID = self.eventID;
    
    APActivityProvider2 *ActivityProvider = [[APActivityProvider2 alloc] init];
    ActivityProvider.APdragView = dragView;
    
    NSURL *myWebsite = [NSURL URLWithString:@"http://www.gethappeningapp.com/"]; //Make this custom when Liran makes unique pages
    
    CustomCalendarActivity *addToCalendar = [[CustomCalendarActivity alloc]init];
    addToCalendar.draggableView = dragView;
    
    NSArray *itemsToShare = @[ActivityProvider, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:itemsToShare applicationActivities:[NSArray arrayWithObject:addToCalendar]];
    
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
         if ( [act isEqualToString:UIActivityTypeMail] )           ServiceMsg = @"Mail sent!";
         if ( [act isEqualToString:UIActivityTypePostToTwitter] )  ServiceMsg = @"Your tweet has been posted!";
         if ( [act isEqualToString:UIActivityTypePostToFacebook] ) ServiceMsg = @"Your Facebook status has been updated!";
         if ( [act isEqualToString:UIActivityTypeMessage] )        ServiceMsg = @"Message sent!";
         if ( done )
         {
             
             // Custom action for other activity types...
             [RKDropdownAlert title:ServiceMsg backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
             
         }
     }];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toWebVC"]) {
        
        webViewController *vc = (webViewController *)[[segue destinationViewController] topViewController];
        vc.urlString = urlString;
        vc.titleString = self.titleText;
        
    } else if ([segue.identifier isEqualToString:@"showProf"]) {
        
        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.eventID = self.eventID;
        
    } else if ([segue.identifier isEqualToString:@"showFriendProf"]) {
        
        ExternalProfileTVC *vc = (ExternalProfileTVC *)[segue destinationViewController];
        vc.userID = friendObjectID;
        NSLog(@"friend oID = %@", friendObjectID);
        
    } else if ([segue.identifier isEqualToString:@"toMoreInfo"]) {
        
        moreDetailFromCard *vc = (moreDetailFromCard *)[[segue destinationViewController] topViewController];
        vc.eventID = self.eventID;
        vc.titleText = self.titleText;
        vc.subtitleText = self.subtitleText;
        vc.locationText = self.locationText;
    }
    
}


@end

@implementation APActivityProvider2

@synthesize APdragView;

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    
    PFUser *user = [PFUser currentUser];
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    PFObject *eventObject = [eventQuery getObjectWithId:APdragView.objectID];
    
    NSString *title = APdragView.title.text;
    NSString *subtitle = APdragView.subtitle.text;
    NSString* loc = APdragView.location.text;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM d"];
    NSDate *eventDate = [[NSDate alloc]init];
    eventDate = eventObject[@"Date"];
    NSString *dateString = [formatter stringFromDate:eventDate];
    
    [formatter setDateFormat:@"h:mm a"];
    NSString *startTimeString = [formatter stringFromDate:eventObject[@"Date"]];
    NSString *endTimeString = [formatter stringFromDate:eventObject[@"EndTime"]];
    NSString *eventTimeString = [[NSString alloc]init];
    if (endTimeString) {
        eventTimeString = [NSString stringWithFormat:@"from %@ to %@",startTimeString, endTimeString];
    } else {
        eventTimeString = [NSString stringWithFormat:@"at %@", startTimeString];
    }
    
    NSString *shareText = [[NSString alloc]init];
    if ([subtitle isEqualToString:@""]) {
        shareText = [NSString stringWithFormat:@"Check out this awesome event: %@ at %@ on %@ %@", title, loc, dateString, eventTimeString];
    } else {
        shareText = [NSString stringWithFormat:@"Check out this awesome event: %@, %@ at %@ on %@ %@", title, subtitle, loc, dateString, eventTimeString];
    }
    
    NSLog(@"%@", shareText);
    
    [user addObject:eventObject.objectId forKey:@"sharedEvents"];
    [user saveInBackground];
    
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] ) {
        shareText = [NSString stringWithFormat:@"Check this out: %@ at %@ on %@ %@", title, loc, dateString, eventTimeString];
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypeMessage] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypeMail] ) {
        return shareText;
    } else
        return shareText;
    //if ( [activityType isEqualToString:@"it.albertopasca.myApp"] )
    //return @"OpenMyapp custom text";
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @"Testing"; }
@end

