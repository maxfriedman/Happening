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
#import "CustomConstants.h"
#import "ProfilePictureView.h"

#import "ModalPopup.h"


@interface ExpandedCardVC () <inviteHomiesDelegate, UINavigationControllerDelegate, DraggableViewDelegate, ModalPopupDelegate>

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
    
    UIButton *yesButton;
    UIButton *noButton;
    UIImageView *cornerImageView1;
    UIImageView *cornerImageView2;
    UIColor *borderColor;
    
    EKEvent *calEvent;
    EKEventStore *calEventStore;
    NSString *friendObjectID;
    NSString *urlString;
}

static const float CARD_HEIGHT = 672; //%%% height of the draggable card
static const float CARD_WIDTH = 284; //%%% width of the draggable card

@synthesize dragView, scrollView, smileButton, frownButton, bestFriendIds, currentUser, event, mapView, rsvpObject, fbids;

- (void)viewWillAppear:(BOOL)animated {
    
    dragView.panGestureRecognizer.enabled = NO;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.mh hideTabBar:NO];
    
    currentUser = [PFUser currentUser];
    
    if (!dragView) {
        
        if (self.presentedAsModal == YES) {
            self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
            [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
            self.navigationController.navigationBar.translucent = NO;
            UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(xButtonPressed:)];
            self.navigationItem.leftBarButtonItem = item;
        }
    
        bestFriendIds = currentUser[@"BestFriends"];
        
        smileButton.enabled = NO;
        frownButton.enabled = NO;
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 568-49-64)];
        [self.view addSubview:scrollView];
        
        dragView = [[DraggableView alloc] initWithFrame:CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT)];
        dragView.frame = CGRectMake(18, 18, CARD_WIDTH, CARD_HEIGHT);
        [dragView.cardBackground removeFromSuperview];
        dragView.delegate = self;
        dragView.isExpandedCardView = YES;
        [self createDraggableView];
        [scrollView addSubview:dragView];
        dragView.panGestureRecognizer.enabled = NO;
        
        scrollView.contentSize = CGSizeMake(320, dragView.frame.size.height + 36);
        
        if (self.isFromGroup) {
            
            borderColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0];
            
            UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
            
            yesButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 15, 100, 30)];
            [yesButton setTitle:@"I'm in" forState:UIControlStateNormal];
            yesButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
            yesButton.layer.masksToBounds = YES;
            yesButton.layer.cornerRadius = 15;
            yesButton.layer.borderColor = borderColor.CGColor;
            yesButton.layer.borderWidth = 1.0;
            yesButton.tag = 0;
            [yesButton addTarget:self action:@selector(goingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            noButton = [[UIButton alloc] initWithFrame:CGRectMake(200, 15, 100, 30)];
            [noButton setTitle:@"I'm out" forState:UIControlStateNormal];
            noButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
            noButton.layer.masksToBounds = YES;
            noButton.layer.cornerRadius = 15;
            noButton.layer.borderColor = borderColor.CGColor;
            noButton.layer.borderWidth = 1.0;
            noButton.tag = 0;
            [noButton addTarget:self action:@selector(NOTgoingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 5, 50, 50)];
            FBSDKProfilePictureView *ppView = [[FBSDKProfilePictureView alloc] initWithFrame:picViewContainer.bounds];
            ppView.clipsToBounds = YES;
            ppView.layer.cornerRadius = picViewContainer.frame.size.height/2;
            
            [picViewContainer addSubview:ppView];
            picViewContainer.tag = 9;
            
            cornerImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(35, 0, 15, 15)];
            cornerImageView1.image = [UIImage imageNamed:@"question"];
            cornerImageView1.layer.cornerRadius = 7.5;
            cornerImageView1.layer.borderColor = [UIColor whiteColor].CGColor;
            cornerImageView1.layer.borderWidth = 1.0;
            [picViewContainer addSubview:cornerImageView1];
            
            [topView addSubview:yesButton];
            [topView addSubview:noButton];
            [topView addSubview:picViewContainer];
            
            CGRect scrollViewFrame = scrollView.frame;
            scrollViewFrame.origin.y += 60;
            scrollViewFrame.size.height += -60;
            scrollView.frame = scrollViewFrame;
            
            CGRect cardFrame = self.dragView.frame;
            cardFrame.origin.y += -10;
            self.dragView.frame = cardFrame;
            
            UIScrollView *groupScrollView = [[UIScrollView alloc] initWithFrame:self.dragView.friendScrollView.frame];
            groupScrollView.scrollEnabled = YES;
            groupScrollView.showsHorizontalScrollIndicator = NO;
            [dragView.cardView addSubview:groupScrollView];
            groupScrollView.tag = 33;
            
            FBSDKProfilePictureView *pp = [self ppViewForId:currentUser[@"FBObjectID"]];
            UIView *ppContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
            pp.frame = ppContainer.bounds;
            
            [ppContainer addSubview:pp];
            ppContainer.tag = 9;
            
            cornerImageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
            cornerImageView2.image = [UIImage imageNamed:@"question"];
            cornerImageView2.layer.cornerRadius = 7.5;
            cornerImageView2.layer.borderColor = [UIColor whiteColor].CGColor;
            cornerImageView2.layer.borderWidth = 1.0;
            [ppContainer addSubview:cornerImageView2];
            
            [groupScrollView addSubview:ppContainer];
            
            NSString *goingType = self.rsvpObject[@"GoingType"];
            if ([goingType isEqualToString:@"yes"]) {
                
                cornerImageView1.image = [UIImage imageNamed:@"check75"];
                cornerImageView2.image = [UIImage imageNamed:@"check75"];
                
                [yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                yesButton.backgroundColor = borderColor;
                yesButton.tag = 1;
                
                noButton.backgroundColor = [UIColor whiteColor];
                [noButton setTitleColor:borderColor forState:UIControlStateNormal];
                noButton.tag = 0;
                
            } else if ([goingType isEqualToString:@"no"]) {
                
                cornerImageView1.image = [UIImage imageNamed:@"X"];
                cornerImageView2.image = [UIImage imageNamed:@"X"];
                
                [noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                noButton.backgroundColor = borderColor;
                noButton.tag = 1;
                
                yesButton.backgroundColor = [UIColor whiteColor];
                [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
                yesButton.tag = 0;
                
            } else {
                
                cornerImageView1.image = [UIImage imageNamed:@"question"];
                cornerImageView2.image = [UIImage imageNamed:@"question"];
                
                [noButton setTitleColor:borderColor forState:UIControlStateNormal];
                noButton.backgroundColor = [UIColor whiteColor];
                noButton.tag = 0;
                
                [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
                yesButton.backgroundColor = [UIColor whiteColor];
                yesButton.tag = 0;
            }
            
            [self.view addSubview:topView];
            
            [self.dragView.friendScrollView removeFromSuperview];
            [self.dragView.hapLogoButton removeFromSuperview];
            
            UIImageView *avatar = [[UIImageView alloc] initWithFrame:self.dragView.hapLogoButton.frame];
            PFFile *file = self.groupObject[@"avatar"];
            if (file) {
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    avatar.image = [UIImage imageWithData:data];
                }];
            }
            [self.dragView.cardView addSubview:avatar];
            avatar.layer.masksToBounds = YES;
            avatar.backgroundColor = [UIColor whiteColor];
            avatar.layer.cornerRadius = avatar.frame.size.height/2;
            
            PFQuery *groupRSVPQuery = [PFQuery queryWithClassName:@"Group_RSVP"];
            [groupRSVPQuery whereKey:@"EventID" equalTo:self.event.objectId];
            [groupRSVPQuery whereKey:@"GroupID" equalTo:self.groupObject.objectId];
            [groupRSVPQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                
                NSMutableArray *yesUsers = [NSMutableArray array];
                NSMutableArray *noUsers = [NSMutableArray array];
                NSMutableArray *maybeUsers = [NSMutableArray arrayWithArray:fbids];
                
                for (PFObject *ob in objects) {
                    
                    NSString *userFBID = ob[@"UserFBID"];
                    
                    if ([ob[@"GoingType"] isEqualToString:@"yes"]) {
                        [yesUsers addObject:userFBID];
                        [maybeUsers removeObject:userFBID];
                        
                    } else if ([ob[@"GoingType"] isEqualToString:@"no"]) {
                        [noUsers addObject:userFBID];
                        [maybeUsers removeObject:userFBID];
                        
                    } else if ([rsvpObject[@"GoingType"] isEqualToString:@"maybe"]) {
                        //[maybeUsers addObject:rsvpObject[@"User_Object"]];
                    }
                }
                
                int userCount = 0;
                
                for (int i = 0; i < yesUsers.count; i++) {
                    
                    NSString *fbId = yesUsers[i];
                    
                    if (![fbId isEqualToString:currentUser[@"FBObjectID"]]) {
                        
                        FBSDKProfilePictureView *ppview = [self ppViewForId:fbId];
                        UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(50 + 50 * userCount, 0, 40, 40)];
                        ppview.frame = picViewContainer.bounds;
                        
                        [picViewContainer addSubview:ppview];
                        picViewContainer.tag = 9;
                        
                        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
                        imv.image = [UIImage imageNamed:@"check75"];
                        imv.layer.cornerRadius = 7.5;
                        imv.layer.borderColor = [UIColor whiteColor].CGColor;
                        imv.layer.borderWidth = 1.0;
                        [picViewContainer addSubview:imv];
                        
                        [groupScrollView addSubview:picViewContainer];
                        
                        userCount++;
                        
                    }
                    
                }
                
                for (int i = 0; i < maybeUsers.count; i++) {
                    
                    NSString *fbId = maybeUsers[i];
                    
                    if (![fbId isEqualToString:currentUser[@"FBObjectID"]]) {
                        
                        FBSDKProfilePictureView *ppview = [self ppViewForId:fbId];
                        UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(50 + 50 * userCount, 0, 40, 40)];
                        ppview.frame = picViewContainer.bounds;
                        
                        [picViewContainer addSubview:ppview];
                        picViewContainer.tag = 9;
                        
                        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
                        imv.image = [UIImage imageNamed:@"question"];
                        imv.layer.cornerRadius = 7.5;
                        imv.layer.borderColor = [UIColor whiteColor].CGColor;
                        imv.layer.borderWidth = 1.0;
                        [picViewContainer addSubview:imv];
                        
                        [groupScrollView addSubview:picViewContainer];
                        
                        userCount++;
                        
                    }
                }
                
                for (int i = 0; i < noUsers.count; i++) {
                    
                    NSString *fbId = noUsers[i];
                    
                    if (![fbId isEqualToString:currentUser[@"FBObjectID"]]) {
                        
                        FBSDKProfilePictureView *ppview = [self ppViewForId:fbId];
                        UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(50 + 50 * userCount, 0, 40, 40)];
                        ppview.frame = picViewContainer.bounds;
                        
                        [picViewContainer addSubview:ppview];
                        picViewContainer.tag = 9;
                        
                        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(25, 0, 15, 15)];
                        imv.image = [UIImage imageNamed:@"X"];
                        imv.layer.cornerRadius = 7.5;
                        imv.layer.borderColor = [UIColor whiteColor].CGColor;
                        imv.layer.borderWidth = 1.0;
                        [picViewContainer addSubview:imv];
                        
                        [groupScrollView addSubview:picViewContainer];
                        
                        userCount++;
                        
                    }
                }
                
                groupScrollView.contentSize = CGSizeMake((50 * userCount) + 40 + 5, 50);
                
                
            }];
            
        }
    }
    
}

- (FBSDKProfilePictureView *)ppViewForId:(NSString *)fbid {
    
    FBSDKProfilePictureView *profPic = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    profPic.profileID = fbid;
    profPic.layer.cornerRadius = 20.0;
    profPic.layer.masksToBounds = YES;
    return profPic;
}

- (void)goingButtonPressed:(id)sender {
    
    if (yesButton.tag == 0) {
        
        cornerImageView1.image = [UIImage imageNamed:@"check75"];
        cornerImageView2.image = [UIImage imageNamed:@"check75"];
        
        [yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        yesButton.backgroundColor = borderColor;
        yesButton.tag = 1;
        
        noButton.backgroundColor = [UIColor whiteColor];
        [noButton setTitleColor:borderColor forState:UIControlStateNormal];
        noButton.tag = 0;
        
    } else {
        
        cornerImageView1.image = [UIImage imageNamed:@"question"];
        cornerImageView2.image = [UIImage imageNamed:@"question"];
        
        yesButton.backgroundColor = [UIColor whiteColor];
        [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
        yesButton.tag = 0;
        
    }
    
    [self reloadRSVPs];
    
}

- (void)NOTgoingButtonPressed:(id)sender {
    
    if (noButton.tag == 0) {
        
        cornerImageView1.image = [UIImage imageNamed:@"X"];
        cornerImageView2.image = [UIImage imageNamed:@"X"];
        
        [noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        noButton.backgroundColor = borderColor;
        noButton.tag = 1;
        
        yesButton.backgroundColor = [UIColor whiteColor];
        [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
        yesButton.tag = 0;
        
    } else {
        
        cornerImageView1.image = [UIImage imageNamed:@"question"];
        cornerImageView2.image = [UIImage imageNamed:@"question"];
        
        noButton.backgroundColor = [UIColor whiteColor];
        [noButton setTitleColor:borderColor forState:UIControlStateNormal];
        noButton.tag = 0;
        
    }
    
    [self reloadRSVPs];
    
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
        
        if ([eventDate compare:[NSDate date]] == NSOrderedAscending && endDate != nil) {
            
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

            //funkyDates = YES;
            //calTimeString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:eventDate], [formatter stringFromDate:endDate]];
            
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
        
        [self addExtrasToCard];
        
        self.dragView.friendScrollView.delegate = self;
        
        dragView.delegate = self;
        
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

- (void)showModalPopup:(ModalPopup *)popup {
    
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //ModalPopup *controller = [storyboard instantiateViewControllerWithIdentifier:@"ModalPopup"];
    //controller.event = c.eventObject;
    NSLog(@"Presenting popup...");
    popup.delegate = self;
    [self mh_presentSemiModalViewController:popup animated:YES];
    
}

- (void)userFinishedAction:(BOOL)wasSuccessful type:(NSString *)t {
    
    // Callback from share popup
    
}

- (void)swipeDownForWhat {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ModalPopup *popup = [storyboard instantiateViewControllerWithIdentifier:@"ModalPopup"];
    popup.eventObject = dragView.eventObject;
    popup.eventDateString = dragView.date.text;
    popup.eventImage = dragView.eventImage.image;
    popup.type = @"going";
    [self showModalPopup:popup];
    
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

- (void)reloadRSVPs {
    
    NSString *currentFBID = currentUser[@"FBObjectID"];
    
    if (self.rsvpObject == nil) {
        
        rsvpObject[@"EventID"] = self.event.objectId;
        rsvpObject[@"GroupID"] = self.groupObject.objectId;
        rsvpObject[@"Group_Event_ID"] = self.groupEventObject.objectId;
        rsvpObject[@"UserID"] = currentUser.objectId;
        rsvpObject[@"UserFBID"] = currentUser[@"FBObjectID"];
        rsvpObject[@"User_Object"] = currentUser;
        //rsvpObject[@"GoingType"] = @"yes"; SET BELOW
        [rsvpObject pinInBackground];
            
    }
        
    if (yesButton.tag == 1) {
        rsvpObject[@"GoingType"] = @"yes";
    } else if (noButton.tag == 1) {
        rsvpObject[@"GoingType"] = @"no";
    } else {
        rsvpObject[@"GoingType"] = @"maybe";
    }
    
    [rsvpObject saveEventually:^(BOOL success, NSError *error){
        
        if (!error && (noButton.tag == 1 || yesButton.tag == 1)) {
            
            NSString *messageText = @"";
            if (yesButton.tag == 1) {
                messageText = [NSString stringWithFormat:@"%@ %@ is going to '%@'", currentUser[@"firstName"], currentUser[@"lastName"], self.event[@"Title"]];
            } else if (noButton.tag == 1) {
                messageText = [NSString stringWithFormat:@"%@ %@ is not going to '%@'", currentUser[@"firstName"], currentUser[@"lastName"], self.event[@"Title"]];
            }
            
            NSDictionary *dataDictionary = @{@"message":messageText,
                                             @"type":@"RSVP",
                                             @"groupId":self.groupObject.objectId,
                                             };
            NSError *JSONSerializerError;
            NSData *dataDictionaryJSON = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
            LYRMessagePart *dataMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemObject data:dataDictionaryJSON];
            // Create messagepart with info about cell
            float actualLineSize = [messageText boundingRectWithSize:CGSizeMake(270, CGFLOAT_MAX)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:10.0]}
                                                             context:nil].size.height;
            NSDictionary *cellInfoDictionary = @{@"height": [NSString stringWithFormat:@"%f", actualLineSize]};
            NSData *cellInfoDictionaryJSON = [NSJSONSerialization dataWithJSONObject:cellInfoDictionary options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
            LYRMessagePart *cellInfoMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemCellInfo data:cellInfoDictionaryJSON];
            // Add message to ordered set.  This ordered set messages will get sent to the participants
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart,cellInfoMessagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:&error];
            
            // Sends the specified message
            BOOL success = [self.convo sendMessage:message error:&error];
            if (success) {
                //NSLog(@"Message queued to be sent: %@", message);
            } else {
                NSLog(@"Message send failed: %@", error);
            }
        }
        
    }];
    
    //[self.tableView reloadData];
    //[self loadPics];
}

- (void)cardSwipedRight:(UIView *)card fromExpandedView:(BOOL)expandedBool isGoing:(BOOL)isGoing {
    
    ProfilePictureView *ppview = (ProfilePictureView *)[dragView.friendScrollView viewWithTag:99];
    if (isGoing)
        [ppview changeCornerImvToType:@"going"];
    else
        [ppview changeCornerImvToType:@"interested"];
    
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
            
            if ([[event[@"Date"] beginningOfDay] compare:[NSDate date]] == NSOrderedSame) {
                swipesObject[@"swipedAgain"] = @YES;
            }
            
            if ([[PFUser currentUser][@"socialMode"] isEqualToNumber:@YES] && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
                swipesObject[@"FBObjectID"] = user[@"FBObjectID"];
            }
            
            [swipesObject pinInBackground];
            [swipesObject saveEventually];
            
            
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
                                                
                                                //NSLog(@"%@", result);
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
            
        }
        
        [self.delegate didChangeRSVP];
        
    }];
    
    if (isGoing) {
        [self swipeDownForWhat];
    }
    
    
    if ([[PFUser currentUser][@"hasSwipedRight"] isEqualToNumber:@NO] ) {
        NSLog(@"First swipe right");
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        RKSwipeBetweenViewControllers *rk = appDelegate.rk;
        [rk showCallout];
        
        [PFUser currentUser][@"hasSwipedRight"] = @YES;
        [user saveEventually];
    }

}

- (void)cardSwipedLeft:(UIView *)card fromExpandedView:(BOOL)expandedBool {
    
    ProfilePictureView *ppview = (ProfilePictureView *)[dragView.friendScrollView viewWithTag:99];
    [ppview changeCornerImvToType:@"notInterested"];
    
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
        
        [self.delegate didChangeRSVP];
        
    }];
    
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
