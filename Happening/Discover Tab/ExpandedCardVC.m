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
    
    dragView.panGestureRecognizer.enabled = NO;
    
    if (!dragView) {
        
        if (self.presentedAsModal == YES) {
            self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
            self.navigationController.navigationBar.translucent = NO;
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(xButtonPressed:)];
            self.navigationItem.leftBarButtonItem = item;
        }
    
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
    
    if (!event || !event.isDataAvailable) {
        
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
        [eventQuery getObjectInBackgroundWithId:self.eventID block:^(PFObject *eventObject, NSError *error) {
            
            if (!error) {
                event = eventObject;
                
                PFGeoPoint *loc = event[@"GeoLoc"];
                
                if (loc.latitude == 0) {
                    self.distanceString = @"";
                } else {
                    PFGeoPoint *userLoc = currentUser[@"userLoc"];
                    NSNumber *miles = [NSNumber numberWithDouble:([loc distanceInMilesTo:userLoc])];
                    if (miles.floatValue >= 100.0) {
                        self.distanceString = [NSString stringWithFormat:(@"100+ mi")];
                        CGRect locFrame = dragView.locImage.frame;
                        locFrame.origin.x = locFrame.origin.x - 10;
                        dragView.locImage.frame = locFrame;
                    } else if (miles.floatValue >= 10.0) {
                        self.distanceString = [NSString stringWithFormat:(@"%.f mi"), miles.floatValue];
                    } else {
                        self.distanceString = [NSString stringWithFormat:(@"%.1f mi"), miles.floatValue];
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
                    
                    NSString *tag = event[@"Hashtag"];
                    dragView.eventImage.image = [UIImage imageNamed:tag];
                    [self createDraggableView];
                }
            }
        }];
        
    } else {
        
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
        
        if (!self.distanceString) {
            PFGeoPoint *loc = event[@"GeoLoc"];
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
        dragView.geoLoc.text = self.distanceString;
        
        if ([self.distanceString isEqualToString:@"100+ mi"]) {
            CGRect locFrame = dragView.locImage.frame;
            locFrame.origin.x = locFrame.origin.x - 10;
            dragView.locImage.frame = locFrame;
        }
        
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
        
        self.dragView.friendScrollView.delegate = self;
        [self loadFBFriends:dragView.friendScrollView withCard:dragView];
        
        dragView.delegate = self;

        [self addExtrasToCard];
        
    }
    
}

- (void)addExtrasToCard {
    
    [dragView loadCardWithData];
    extraDescHeight = dragView.extraDescHeight;
    [self addSubviewsToCard];
}

- (void)addSubviewsToCard {
    
    scrollView.contentSize = CGSizeMake(320, 588 + 12 + 45 + extraDescHeight);
    
    scrollView.delaysContentTouches = YES;
    
    dragView.cardView.userInteractionEnabled = YES;
    dragView.cardView.layer.masksToBounds = YES;
    
    dragView.mapView.delegate = self;
    
    PFGeoPoint *loc = dragView.geoPoint;
    CLLocation *mapLocation = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
    
    annotation = [[MKPointAnnotation alloc]init];
    [annotation setCoordinate:mapLocation.coordinate];
    [annotation setTitle:[dragView.location.text stringByReplacingOccurrencesOfString:@"at " withString:@""]];
    
    [dragView.mapView addAnnotation:annotation];
    [dragView.mapView viewForAnnotation:annotation];
    [dragView.mapView selectAnnotation:annotation animated:YES];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapLocation.coordinate, 750, 750);
    [dragView.mapView setRegion:region animated:NO];
    [dragView.mapView setUserTrackingMode:MKUserTrackingModeNone];
    [dragView.mapView regionThatFits:region];
    
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
    
    //[self ticketsAndUberUpdateFrameBy:28 + 8];
    
    //mapViewExpanded = NO;

    
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

- (void)xButtonPressed:(id)sender {
    
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
        vc.urlString = ticketsButton.accessibilityIdentifier;
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
