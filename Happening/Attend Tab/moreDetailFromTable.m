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

@interface moreDetailFromTable ()

@end

@implementation moreDetailFromTable {
    
    CGRect cachedImageViewSize;
    UIVisualEffectView *blurEffectView;
    int cachedHeight;
    MKPointAnnotation *annotation;
    BOOL mapViewExpanded;
    CLLocation *mapLocation;

}

@synthesize  mapView, cardView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    //[self.navigationItem setHidesBackButton:NO];
    
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(15, 376, 254, 133)];
    [cardView addSubview:mapView];
    
    UIView *shadowView = [[UIView alloc] initWithFrame:cardView.frame];
    shadowView.layer.shadowOffset = CGSizeMake(2, 2);
    shadowView.layer.shadowRadius = 5.0;
    shadowView.layer.shadowOpacity = 1.0;
    [shadowView.layer setCornerRadius:10.0];
    [shadowView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
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
    self.subtitleLabel.text = self.subtitleText;
    self.locationLabel.text = self.locationText;
    
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
    
    self.scrollView.contentSize = CGSizeMake(320, 720);
    
    /*
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cachedImageViewSize = self.imageView.frame;
    [self.view sendSubviewToBack:self.imageView];
    //self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 170)];
    */
    
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
        
        if ([eventDate beginningOfDay] == [[NSDate date]beginningOfDay]) {  // TODAY
            
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
            
        } else {
            
            NSString *dateString = [formatter stringFromDate:eventDate];
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            finalString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
            
        }
        
        if ([finalString containsString:@":00"]) {
            
            finalString = [finalString stringByReplacingOccurrencesOfString:@":00" withString:@" "];
            
        }
        
        self.timeLabel.text = finalString;
        
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
            if (zipCode)
                annotation.subtitle = [NSString stringWithFormat:@"%@, %@ %@, %@", streetName, cityName, stateName, zipCode];
            else annotation.subtitle = [NSString stringWithFormat:@"%@, %@, %@", streetName, cityName, stateName];
            
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
        
        [self loadFBFriends];
        
    }];
    
    NSLog(@"%@", self.eventID);
    
}

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
        
        [cardView bringSubviewToFront:mapView];
    
        mapView.scrollEnabled = NO;
        mapView.zoomEnabled = YES;
    
    
        [UIView animateWithDuration:0.05 animations:^{

            mapView.frame = CGRectMake(0, self.mapView.frame.origin.y, cardView.frame.size.width, self.mapView.frame.size.height);

        } completion:^(BOOL finished) {
        
            [UIView animateWithDuration:0.2 animations:^{
                
                mapView.frame = CGRectMake(0, 0, cardView.frame.size.width, self.scrollView.contentSize.height);
                
            } completion:^(BOOL finished) {
                
                [mapView selectAnnotation:annotation animated:YES];
                [self.view addSubview:xButton];
                [self.view addSubview: directionsButton];
                
                mapViewExpanded = YES;
                
            }];

        
        }];
        
    } else {
        
        
        for (UIView *view in self.view.subviews) {
            
            if (view.tag == 99) {
                [view removeFromSuperview];
            }
        }
        
        [cardView bringSubviewToFront:mapView];
        
        mapView.scrollEnabled = NO;
        mapView.zoomEnabled = NO;
        
        
        [UIView animateWithDuration:0.3 animations:^{
            
            mapView.frame = CGRectMake(0, 376, 284, 133);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.1 animations:^{
                
                mapView.frame = CGRectMake(15, 376, 254, 133);
                
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
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
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
        
        for (int i = 0; i < friends.count; i ++) {
            
            NSDictionary<FBGraphUser>* friend = friends[i];
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.objectID);
            
            PFQuery *friendQuery = [PFQuery queryWithClassName:@"Swipes"];
            [friendQuery whereKey:@"FBObjectID" equalTo:friend.objectID];
            [friendQuery whereKey:@"EventID" equalTo:self.eventID];
            [friendQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                
                NSLog(@"%@ with id %@", friend.name, friend.objectID);
                if (object != nil && !error) {
                    NSLog(@"LIKES THIS EVENT");
                    
                    NSString *path = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", friend.objectID];
                    
                    NSURL *url = [NSURL URLWithString:path];
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    
                    //CGSize size = img.size;
                    
                    NSLog(@"IMAGE %@", img);
                    
                    UIImageView *profPicImageView = [[UIImageView alloc] initWithImage:img];
                    profPicImageView.layer.cornerRadius = 20;
                    profPicImageView.layer.masksToBounds = YES;
                    profPicImageView.frame = CGRectMake(50 * friendCount, 0, 40, 40);
                    [self.friendScrollView addSubview:profPicImageView];
                    
                    UILabel *nameLabel = [[UILabel alloc] init];
                    nameLabel.font = [UIFont fontWithName:@"OpenSans" size:7];
                    nameLabel.textColor = [UIColor colorWithRed:(70.0/255.0) green:(70.0/255.0) blue:(70.0/255.0) alpha:1.0];
                    nameLabel.textAlignment = NSTextAlignmentCenter;
                    nameLabel.text = friend.first_name;
                    nameLabel.frame = CGRectMake(5 + (50 * friendCount), 42, 30, 8);
                    [self.friendScrollView addSubview:nameLabel];
                    
                    self.friendScrollView.contentSize = CGSizeMake((50 * friendCount) + 40, self.friendScrollView.frame.size.height);
                    
                    friendCount++;
                    
                    self.friendsInterestedLabel.text = [NSString stringWithFormat:@"%d friends interested", friendCount];
                }
            }];
            
            
            /*
            NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"false", @"url",
                                    @"200", @"height",
                                    @"normal", @"type",
                                    @"200", @"width",
                                    nil
                                    ];
            
            [FBRequestConnection startWithGraphPath:@"/me/picture"
                                         parameters:params
                                         HTTPMethod:@"GET"
                                  completionHandler:^(
                                                      FBRequestConnection *connection,
                                                      id result,
                                                      NSError *error
                                                      ) {
                                  }];
            */
        }
        
    }];
    
    
}

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
                
                
                if (zipCode) {
                    destinationAddress = [NSMutableString stringWithFormat:@"%@ %@, %@ %@, %@", streetName, cityName, stateName, zipCode, country];
                }
                else if (cityName) {
                    destinationAddress = [NSMutableString stringWithFormat:@"%@ %@, %@, %@", streetName, cityName, stateName, country];
                }
                
                destinationAddress = [destinationAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            
                NSString *urlString = [NSString stringWithFormat:@"uber://?client_id=Vmks1LNIHQiiaUYd8Z3FaMNkvD-7s53V&action=setPickup&pickup=my_location&dropoff[latitude]=%f&dropoff[longitude]=%f&dropoff[nickname]=%@&dropoff[formatted_address]=%@", mapLocation.coordinate.latitude, mapLocation.coordinate.longitude, self.locationText, destinationAddress ];
                
                urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
            
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
            
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
                NSMutableString *destinationAddress = [[NSMutableString alloc]init];
                    
                    NSString *streetName = placemark.addressDictionary[@"Street"];
                    NSString *cityName = placemark.addressDictionary[@"City"];
                    NSString *stateName = placemark.addressDictionary[@"State"];
                    NSString *zipCode = placemark.addressDictionary[@"ZIP"];
                    NSString *country = placemark.addressDictionary[@"Country"];
                    
                    
                    if (zipCode) {
                        destinationAddress = [NSMutableString stringWithFormat:@"%@ %@, %@ %@, %@", streetName, cityName, stateName, zipCode, country];
                    }
                    else if (cityName) {
                        destinationAddress = [NSMutableString stringWithFormat:@"%@ %@, %@, %@", streetName, cityName, stateName, country];
                    }
                
                for (int i = 0; i < destinationAddress.length; i++) {
                    
                    if ([destinationAddress characterAtIndex:i] == ' '){
                        
                        [destinationAddress insertString:@"%20" atIndex:i];
                        
                    }
                    
                }
            
                NSLog(@"%@", destinationAddress);
                
            NSString *urlString = [NSString stringWithFormat:@"https://m.uber.com/sign-up?client_id=Vmks1LNIHQiiaUYd8Z3FaMNkvD-7s53V&first_name=%@&last_name=%@&email=%@&country_code=us&&dropoff_latitude=%f&dropoff_longitude=%f&dropoff_nickname=%@", firstName, lastName, userEmail, mapLocation.coordinate.latitude, mapLocation.coordinate.longitude, self.locationText ];
            
                //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionExternalRepresentation];
                
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
            
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

