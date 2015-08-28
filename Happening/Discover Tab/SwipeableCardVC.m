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

#import "CustomConstants.h"
#import "ModalPopup.h"
#import "ProfilePictureView.h"

#define MCANIMATE_SHORTHAND
#import <POP+MCAnimate.h>

@interface SwipeableCardVC () <inviteHomiesDelegate, UINavigationControllerDelegate, DraggableViewDelegate, ModalPopupDelegate>

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

static const float CARD_HEIGHT = 390; //%%% height of the draggable card
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
        
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 400, 320, 100)];
        messageLabel.text = @"You can swipe this card!";
        messageLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
        //[self.view insertSubview:messageLabel belowSubview:scrollView];
        
        dragView = [[DraggableView alloc]initWithFrame:CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT)];
        dragView.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
        [dragView.cardBackground removeFromSuperview];
        dragView.cardView.layer.masksToBounds = YES;
        dragView.userInteractionEnabled = YES;
        [dragView.cardView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(expandCurrentView)]];
        [self createDraggableView];
        
        draggableBackground = [[UIView alloc] initWithFrame:self.view.bounds];
        [draggableBackground addSubview:messageLabel];
        [draggableBackground addSubview:dragView];
        
        [scrollView addSubview:draggableBackground];
        
        isExpanded = NO;
    
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    dragView.cardView.clipsToBounds = YES;
}

- (FBSDKProfilePictureView *)ppViewForId:(NSString *)fbid {
    
    FBSDKProfilePictureView *profPic = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    profPic.profileID = fbid;
    profPic.layer.cornerRadius = 20.0;
    profPic.layer.masksToBounds = YES;
    return profPic;
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
            
        } else if (![[eventDate beginningOfDay] isEqualToDate:[endDate beginningOfDay]] && endDate != nil) { //MULTI-DAY EVENT
            
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
        
        [self.dragView arrangeCornerViews];
        
        self.dragView.friendScrollView.delegate = self;
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
    
    scrollView.contentSize = CGSizeMake(320, 600 + 17 + 60 + extraDescHeight);
    
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
    
}

- (void)expandCurrentView {
    
    if (isExpanded == NO) {
        
        extraDescHeight = dragView.extraDescHeight;
        
        [self addSubviewsToCard];
        
        dragView.panGestureRecognizer.enabled = NO;
        
        dragView.eventImage.autoresizingMask = UIViewAutoresizingNone;
        
        NSLog(@"EXTRA DESC HEIGHT ==== %f", extraDescHeight);
        
        scrollView.scrollEnabled = YES;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            dragView.frame = CGRectMake(dragView.frame.origin.x, dragView.frame.origin.y, dragView.frame.size.width, 320 + 235 + 16 + 60 + extraDescHeight);
            
            dragView.cardView.frame = CGRectMake(dragView.cardView.frame.origin.x, dragView.cardView.frame.origin.y, dragView.cardView.frame.size.width, 320 + 235 + 16 + 60 + extraDescHeight);
            
            dragView.subtitle.alpha = 1.0;
            
        } completion:^(BOOL finished) {
            
        }];
        
        
    } else {
        
        [UIView animate:^{
            [scrollView viewWithTag:90].alpha = 0;
        } completion:^(BOOL finished) {
            
        }];
        
        dragView.panGestureRecognizer.enabled = YES;
        
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        scrollView.scrollEnabled = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            dragView.frame = CGRectMake(dragView.frame.origin.x, dragView.frame.origin.y, dragView.frame.size.width, 390);
            dragView.cardView.frame = CGRectMake(dragView.cardView.frame.origin.x, dragView.cardView.frame.origin.y, dragView.cardView.frame.size.width, 390);
            
            CGRect frame = self.tabBarController.tabBar.frame;
            self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, -519);
            
            dragView.moreButton.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            dragView.subtitle.alpha = 0;
            
        }];
        
    }
    
    isExpanded =! isExpanded;
    
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

- (void)showModalPopup:(ModalPopup *)popup {
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //ModalPopup *controller = [storyboard instantiateViewControllerWithIdentifier:@"ModalPopup"];
    //controller.event = c.eventObject;
    NSLog(@"Presenting popup...");
    popup.delegate = self;
    [self mh_presentSemiModalViewController:popup animated:YES];
    
}

- (void)shareButtonTap:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModalPopup *popup = [storyboard instantiateViewControllerWithIdentifier:@"ModalPopup"];
    popup.eventObject = dragView.eventObject;
    popup.eventDateString = dragView.date.text;
    popup.eventImage = dragView.eventImage.image;
    popup.type = @"share";
    [self showModalPopup:popup];
}

#pragma DraggableView delegate methods

- (void)createdByTap {
    /*
     [self performSegueWithIdentifier:@"showProfile" sender:self];
     */
}

- (void)subtitleTap {
    [self performSegueWithIdentifier:@"toMoreDetail" sender:self];
}

- (void)moreButtonTap {
    [self performSegueWithIdentifier:@"toMoreDetail" sender:self];
}

-(void)inviteButtonTap {
    [self performSegueWithIdentifier:@"toInviteHomies" sender:self];
}

-(void)mapViewTap {
    [self performSegueWithIdentifier:@"toMapView" sender:self];
}

-(void)ticketsButtonTap:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    urlString = button.accessibilityIdentifier;
    [self performSegueWithIdentifier:@"toWebView" sender:self];
}


-(void)friendProfileTap:(id)sender {
    
    UITapGestureRecognizer *gr = (UITapGestureRecognizer *)sender;
    ProfilePictureView *ppview = (ProfilePictureView *)gr.view;
    friendObjectID = ppview.parseId;
    [self performSegueWithIdentifier:@"showFriendProfile" sender:self];
}

-(BOOL)doesString:(NSString *)first contain:(NSString*)other {
    NSRange range = [first rangeOfString:other];
    return range.length != 0;
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
    
    [self performSelector:@selector(dismissVC) withObject:nil afterDelay:0.4];
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
    
    if (isGoing) [user incrementKey:@"score" byAmount:@3];
    else [user incrementKey:@"score" byAmount:@1];
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // The currentUser saved successfully.
        } else {
            // There was an error saving the currentUser.
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"Parse error: %@", errorString);
        }
    }];
    
    PFObject *timelineObject = [PFObject objectWithClassName:@"Timeline"];
    
    if (isGoing) timelineObject[@"type"] = @"going";
    else timelineObject[@"type"] = @"swipeRight";
    
    timelineObject[@"userId"] = user.objectId;
    timelineObject[@"eventId"] = dragView.objectID;
    timelineObject[@"createdDate"] = [NSDate date];
    timelineObject[@"eventTitle"] = dragView.title.text;
    [timelineObject pinInBackground];
    [timelineObject saveEventually];
    
    if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
        
        NSString *locString = [dragView.location.text stringByReplacingOccurrencesOfString:@"at " withString:@""];
        NSString *name = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
        
        [PFCloud callFunctionInBackground:@"swipeRight"
                           withParameters:@{@"user":user.objectId, @"event":dragView.objectID, @"fbID":user[@"FBObjectID"], @"fbToken":[FBSDKAccessToken currentAccessToken].tokenString, @"title":dragView.title.text, @"loc":locString, @"isGoing":@(isGoing), @"name":name, @"eventDate":dragView.eventObject[@"Date"]}
                                    block:^(NSString *result, NSError *error) {
                                        if (!error) {
                                            
                                            NSLog(@"%@", result);
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
    [swipesQuery fromLocalDatastore];
    
    [swipesQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        if (!error) {
            
            NSLog(@"SECOND time Swiping");
            
            object[@"swipedAgain"] = @YES;
            object[@"swipedLeft"] = @NO;
            object[@"swipedRight"] = @YES;
            object[@"isGoing"] = @(isGoing);
            object[@"friendCount"] = @(self.dragView.friendsInterestedCount);
            
            [object saveEventually];
            
        } else {
            
            NSLog(@"FIRST time Swiping");
            
            [user incrementKey:@"eventCount" byAmount:@1];
            [user saveEventually];
            
            PFObject *swipesObject = [PFObject objectWithClassName:@"Swipes"];
            swipesObject[@"UserID"] = user.objectId;
            if (![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
                swipesObject[@"username"] = user.username;
            }
            swipesObject[@"EventID"] = c.objectID;
            swipesObject[@"swipedRight"] = @YES;
            swipesObject[@"swipedLeft"] = @NO;
            swipesObject[@"isGoing"] = @(isGoing);
            swipesObject[@"friendCount"] = @(self.dragView.friendsInterestedCount);
            [swipesObject pinInBackground];
            
            swipesObject[@"swipedAgain"] = @NO;
            
            if ([[PFUser currentUser][@"socialMode"] isEqualToNumber:@YES] && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
                swipesObject[@"FBObjectID"] = user[@"FBObjectID"];
            }
            
            [swipesObject pinInBackground];
            [swipesObject saveEventually];
        }
        
    }];
    
    if (isGoing) {
        [self swipeDownForWhat:c];
    } else {
        [self performSelector:@selector(dismissVC) withObject:nil afterDelay:0.4];
    }
    
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
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
