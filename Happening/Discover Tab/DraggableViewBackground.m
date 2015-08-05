//
//  DraggableViewBackground.m
//  Happening
//
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "CupertinoYankee.h"
#import "UIImage+ImageEffects.h"
#import "RKDropdownAlert.h"
#import <CoreText/CoreText.h>
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "CategoryBubbleView.h"
#import "LocationConstants.h"

@interface DraggableViewBackground() <UIScrollViewDelegate>

@property (nonatomic, strong) EKEventStore *eventStore;

@end

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    
    PFQuery *eventQuery;
    PFQuery *finalQuery;
    
    BOOL shouldRefresh;
    BOOL shouldLimit;
    
    int evCount;
    
    NSArray *bestFriendIds;
    NSArray *events;

}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 390; //%%% height of the draggable card
static const float CARD_WIDTH = 284; //%%% width of the draggable card

@synthesize allCards;//%%% all the cards

@synthesize dateArray;
@synthesize locManager;
@synthesize storedIndex;
@synthesize calDayArray, calDayOfWeekArray, calMonthArray, calTimeArray;

@synthesize dragView; //CURRENT CARD!
@synthesize eventStore;
@synthesize blurView, isLoaded;

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [super layoutSubviews];
        [self setupView];
        
        //self.superview.superview.userInteractionEnabled = YES;
        //self.myViewController.view.userInteractionEnabled = YES;
        
        self.myViewController.isCardExpanded = NO; // Cards start off with front view visible
        
        eventStore = [[EKEventStore alloc] init];
        
        self.myViewController = nil;
        
        isLoaded = NO;
        
        PFUser *user = [PFUser currentUser];
        
        bestFriendIds = [[NSArray alloc] initWithArray:user[@"BestFriends"]];
        
        evCount = 0;
        
        if(locManager && [CLLocationManager locationServicesEnabled]) {
            [self.locManager startUpdatingLocation];
            CLLocation *currentLocation = locManager.location;
            user[@"userLoc"] = [PFGeoPoint geoPointWithLocation:currentLocation];
            NSLog(@"Current Location is: %@", currentLocation);
            [user saveEventually];
        }
        
        dateArray = [[NSMutableArray alloc]init];
        calTimeArray = [[NSMutableArray alloc]init];
        calMonthArray = [[NSMutableArray alloc]init];
        calDayOfWeekArray = [[NSMutableArray alloc]init];
        calDayArray = [[NSMutableArray alloc]init];
        
        eventQuery = [PFQuery queryWithClassName:@"Event"];
        
        // Sorts the query by categories chosen in settings... Default = ALL categories (set on first launch)
        NSArray *categories = [[NSArray alloc]init];
        categories = [self setCategories];
        [eventQuery whereKey:@"Hashtag" containedIn:categories];
        
        // Sorts the query by most recent event and only shows those after today's date
        
        shouldLimit =! [[NSUserDefaults standardUserDefaults] boolForKey:@"noMoreEvents"];
        
        if ([user[@"time"] isEqualToString:@"today"]) {
            
            NSLog(@"today");
            
            [eventQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]]; // show today's events, must be at least 30 minutes left in the event (END)
            if (shouldLimit) {
                [eventQuery whereKey:@"Date" lessThan:[[NSDate date]endOfDay]];
            }
            
            
        } else if ([user[@"time"] isEqualToString:@"tomorrow"]) {
            
            NSLog(@"tomorrow");

            NSDate *tomorrowDate = [[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay];
            [eventQuery whereKey:@"Date" greaterThan:tomorrowDate]; // show tomorrow's events -- must START after beginning of tomorrow or later
            if (shouldLimit) {
                [eventQuery whereKey:@"Date" lessThan:[tomorrowDate endOfDay]];
            }
            
        } else {
            
            NSDate *nextWeekDate = [[NSDate date] dateByAddingTimeInterval:604800];
            NSDate *sundayDate = [nextWeekDate beginningOfWeek];
            
            /*
            NSLog(@"%@", [[NSDate date] endOfDay]);
            NSLog(@"%@", [[NSDate date] endOfWeek]);
            NSLog(@"%@", [[NSDate date] beginningOfDay]);// dateByAddingTimeInterval:-18000]);
             */
            
            if ([[NSDate date] beginningOfDay] == sundayDate) { // Person chose "This weekend" on a sunday
                
                NSLog(@"sunday");
                
                [eventQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]]; // show Sunday's events, must be at least 30 minutes left in the event (END)
                if (shouldLimit) {
                    [eventQuery whereKey:@"Date" lessThan:[sundayDate endOfDay]];
                }
                
            } else if ([[NSDate date] beginningOfDay] == [sundayDate dateByAddingTimeInterval:-86400]) {
            
                NSLog(@"saturday middle of day");
                
                [eventQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]]; // show ONLY events from now (Saturday) to Sunday
                if (shouldLimit) {
                    [eventQuery whereKey:@"Date" lessThan:[sundayDate endOfDay]];
                }
            
            } else {
                
                NSLog(@"weekday");
                
                [eventQuery whereKey:@"Date" greaterThan:[sundayDate dateByAddingTimeInterval:-86400]]; // show ALL events that start after this SATURDAY
                if (shouldLimit) {
                    [eventQuery whereKey:@"Date" lessThan:[sundayDate endOfDay]];
                }
            
            }
            
            //NSLog(@"Beg of week: %@", [sundayDate dateByAddingTimeInterval:-86400]);
            
        }
        
        //[eventQuery orderByDescending:@"weight"];
        
        /*
        PFGeoPoint *userLoc = user[@"userLoc"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger radius = [defaults integerForKey:@"sliderValue"];
        [eventQuery whereKey:@"GeoLoc" nearGeoPoint:userLoc withinMiles:radius];
         */
        
        PFQuery *weightedQuery = [PFQuery queryWithClassName:@"Event"];
        [weightedQuery whereKey:@"globalWeight" greaterThan:@0];
        [weightedQuery whereKey:@"Date" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-60*60*4]];
        

        finalQuery = [PFQuery orQueryWithSubqueries:@[eventQuery, weightedQuery]];
        
        PFGeoPoint *userLoc = user[@"userLoc"];
        NSInteger radius = [user[@"radius"] integerValue];
        
        
        NSArray *friends = [[PFUser currentUser] objectForKey:@"friends"];
        NSMutableArray *idsArray = [NSMutableArray new];
        for (NSDictionary *dict in friends) {
            [idsArray addObject:[dict valueForKey:@"parseId"]];
        }
        
        PFQuery *friendQuery = finalQuery;
        PFQuery *mySwipesQuery = [PFQuery queryWithClassName:@"Swipes"];
        //PFQuery *friendSwipesQuery = [PFQuery queryWithClassName:@"Swipes"];
        
        if (shouldLimit && ([user[@"time"] isEqualToString:@"today"])) {
            //[eventQuery addDescendingOrder:@"swipesRight"];
            
            NSLog(@"LIMIT");
            
            mySwipesQuery.limit = 1000;
            [mySwipesQuery whereKey:@"UserID" equalTo:user.objectId];
            [mySwipesQuery whereKey:@"swipedAgain" equalTo:@YES];
            [mySwipesQuery whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-(60*60*24*28)]];
            //[mySwipesQuery whereKey:@"UserID" notContainedIn:idsArray];
            
            [finalQuery whereKey:@"objectId" doesNotMatchKey:@"EventID" inQuery:mySwipesQuery];
            //eventQuery = [PFQuery orQueryWithSubqueries:@[eventQuery, yesQuery]];
            
            
            //[friendSwipesQuery whereKey:@"UserID" containedIn:idsArray];
            
        } else {
            //[eventQuery addAscendingOrder:@"Date"];

            NSLog(@"DO NOT LIMIT");
            
            mySwipesQuery.limit = 1000;
            [mySwipesQuery whereKey:@"UserID" equalTo:user.objectId];
            [mySwipesQuery whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-(60*60*24*28)]];
            [finalQuery whereKey:@"objectId" doesNotMatchKey:@"EventID" inQuery:mySwipesQuery];
            
        }
        
        LocationConstants *locConstants = [[LocationConstants alloc] init];
        
        NSString *selectedCity = user[@"userLocTitle"];
        CLLocation *theCityLoc = [locConstants getLocForCity:selectedCity];
        CLLocation *theUserLoc = [[CLLocation alloc] initWithLatitude:userLoc.latitude longitude:userLoc.longitude];
        
        CLLocationDistance distance = [theUserLoc distanceFromLocation:theCityLoc];
        
        //NSLog(@"%f", distance);
        
        CLLocationCoordinate2D finalLoc;
        
        if (distance > 20 * 1609.344 || distance == 0) { // User's current location is > 20 miles outside of the city, use default
            
            NSLog(@"User's current location is > 20 miles outside of the city, use default");
            finalLoc = theCityLoc.coordinate;
            
        } else {
            
            NSLog(@"Use the user's current location!");
            finalLoc = theUserLoc.coordinate;
        }
        
        //Earth’s radius, sphere
        float earthRadius = 6378137.0;
        
        //offsets in meters
        //float dn = radius * 1609.344;
        //float de = radius * 1609.344;
        float dn = radius * 1609.344;
        float de = radius * 1609.344;
        
        //Coordinate offsets in radians
        float dLat = dn/earthRadius;
        float dLon = de/(earthRadius*cosf(M_PI*finalLoc.latitude/180));
        
        //OffsetPosition, decimal degrees
        float lat1 = finalLoc.latitude - dLat * 180/M_PI;
        float lon1 = finalLoc.longitude - dLon * 180/M_PI;
        
        float lat2 = finalLoc.latitude + dLat * 180/M_PI;
        float lon2 = finalLoc.longitude + dLon * 180/M_PI;
        
        PFGeoPoint *swc = [PFGeoPoint geoPointWithLatitude:lat1 longitude:lon1];
        PFGeoPoint *nwc = [PFGeoPoint geoPointWithLatitude:lat2 longitude:lon2];
        [finalQuery whereKey:@"GeoLoc" withinGeoBoxFromSouthwest:swc toNortheast:nwc];

        // F this query, screws up the entire logic
        //[finalQuery whereKey:@"GeoLoc" nearGeoPoint:userLoc withinMiles:radius];
        
        //finalQuery.limit = 500;
        
        // %%%%%%%%% THE MAGIC FORMULA %%%%%%%%%%%%%%% \\
        
        [finalQuery orderByDescending:@"globalWeight"];
        [finalQuery addDescendingOrder:@"weight"];
        [finalQuery addDescendingOrder:@"swipesRight"];
        [finalQuery addAscendingOrder:@"Date"];
        
        finalQuery.limit = 10;
        
        NSLog(@"=======  1  ========");

        [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *eventObjects, NSError *error) {

            NSLog(@"=======  2  ========");
            evCount = (unsigned)(long)eventObjects.count;
            
            if (eventObjects.count == 0 && shouldLimit) {
                // Do something?
                NSLog(@"~~~~~~~~~~~~ RUN ONE MORE TIME ~~~~~~~~~~~~~~~~~");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreEvents"]; //allows shouldLimit to = no
                [[NSUserDefaults standardUserDefaults] synchronize];
    
            } else if (eventObjects.count == 0 && !shouldLimit) {
                
                NSLog(@"~~~~~~~~~~~~ NO MORE EVENTS ~~~~~~~~~~~~~~~~~");
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"noMoreEvents"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            for (int i = 0; i < eventObjects.count; i++) {

                PFObject *eventObject = eventObjects[i];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                
                [formatter setDateFormat:@"EEE, MMM d"];
                NSDate *eventDate = [[NSDate alloc]init];
                
                eventDate = eventObject[@"Date"];
                
                NSString *finalString;
                BOOL funkyDates = NO;
                NSString *calTimeString = @"";
                
                // FORMAT FOR MULTI-DAY EVENT
                NSDate *endDate = eventObject[@"EndTime"];
                
                if ([eventDate compare:[NSDate date]] == NSOrderedAscending) {
                  
                    finalString = [NSString stringWithFormat:@"Happening NOW!"];
                    [calDayOfWeekArray addObject:@"Happening now!"];
                    funkyDates = YES;
                    [formatter setDateFormat:@"h:mma"];
                    calTimeString = [NSString stringWithFormat:@"Now - %@", [formatter stringFromDate:endDate]];
                    
                } else if ([[eventDate beginningOfDay] isEqualToDate:[[NSDate date]beginningOfDay]]) {  // TODAY
                    
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    finalString = [NSString stringWithFormat:@"Today at %@", timeString];
                    [calDayOfWeekArray addObject:@"Today"];
                    
                } else if ([[eventDate beginningOfDay] isEqualToDate:[[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]]) { // TOMORROW
                    
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    finalString = [NSString stringWithFormat:@"Tomorrow at %@", timeString];
                    
                    [calDayOfWeekArray addObject:@"Tomorrow"];
                    
                } else if ([[eventDate endOfWeek] isEqualToDate:[[NSDate date]endOfWeek]]) { // SAME WEEK
                    
                    [formatter setDateFormat:@"EEEE"];
                    NSString *dayOfWeekString = [formatter stringFromDate:eventDate];
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    finalString = [NSString stringWithFormat:@"%@ at %@", dayOfWeekString, timeString];
                    
                    [formatter setDateFormat:@"EEEE"];
                    [calDayOfWeekArray addObject:[formatter stringFromDate:eventDate]];
                    
                } else if (![[eventDate beginningOfDay] isEqualToDate:[endDate beginningOfDay]] && endDate != nil) { //MULTI-DAY EVENT
                    
                    [formatter setDateFormat:@"MMM d"];
                    NSString *dateString = [formatter stringFromDate:eventDate];
                    NSString *endDateString = [formatter stringFromDate:endDate];
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    NSString *endTimeString = [formatter stringFromDate:endDate];
                    
                    finalString = [NSString stringWithFormat:@"%@ at %@ to %@ at %@", dateString, timeString, endDateString, endTimeString];
                    
                    [formatter setDateFormat:@"EEE"];
                    [calDayOfWeekArray addObject:[NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:eventDate], [formatter stringFromDate:endDate]]];
                    //funkyDates = YES;
                    //calTimeString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:eventDate], [formatter stringFromDate:endDate]];
                
                } else { // Past this week- uses abbreviated date format
                
                    NSString *dateString = [formatter stringFromDate:eventDate];
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    finalString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
                    
                    [formatter setDateFormat:@"EEEE"];
                    [calDayOfWeekArray addObject:[formatter stringFromDate:eventDate]];
                    
                }
                
                if (funkyDates) {
                    
                    [formatter setDateFormat:@"MMM"];
                    [calMonthArray addObject:[formatter stringFromDate:eventDate]];
                    
                    [formatter setDateFormat:@"d"];
                    NSString *dateSpan = @"";
                    
                    NSString *startDay =[formatter stringFromDate:eventDate];
                    NSString *endDay = [formatter stringFromDate:endDate];
                    
                    if (![startDay isEqualToString:endDay]) {
                        dateSpan = [NSString stringWithFormat:@"%@-%@",startDay,endDay];
                    } else {
                        dateSpan = startDay;

                    }
                    
                    [calDayArray addObject:dateSpan];
                    
                } else {
                    
                    [formatter setDateFormat:@"MMM"];
                    [calMonthArray addObject:[formatter stringFromDate:eventDate]];
                    [formatter setDateFormat:@"d"];
                    [calDayArray addObject:[formatter stringFromDate:eventDate]];
                    [formatter setDateFormat:@"h:mma"];
                    calTimeString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:eventDate], [formatter stringFromDate:endDate]];
                }

                calTimeString = [calTimeString stringByReplacingOccurrencesOfString:@":00" withString:@" "];
                
                [calTimeArray addObject:calTimeString];
                
                
                finalString = [finalString stringByReplacingOccurrencesOfString:@":00" withString:@" "];

                [dateArray addObject:finalString];
                
                /*
                [formatter setDateFormat:@"h:mm a"];
                NSString *startTimeString = [formatter stringFromDate:eventObject[@"Date"]];
                
                NSString *endTimeString = [formatter stringFromDate:eventObject[@"EndTime"]];
                NSString *eventTimeString = [[NSString alloc]init];
                if (endTimeString) {
                    eventTimeString = [NSString stringWithFormat:@"%@ to %@",startTimeString, endTimeString];
                } else {
                    eventTimeString = [NSString stringWithFormat:@"%@", startTimeString];
                }
                 */

            
            }
            
            if (!error) {
                
                loadedCards = [[NSMutableArray alloc] init];
                allCards = [[NSMutableArray alloc] init];
                cardsLoadedIndex = 0;
                events = [NSArray arrayWithArray:eventObjects];
                [self loadCards];
                isLoaded = YES;
                
            } else {
                NSLog(@"Error--- perform action");
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // time-consuming task
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[SVProgressHUD setViewForExtension:self];
                        [SVProgressHUD showErrorWithStatus:@"Houston, we have a problem." maskType:SVProgressHUDMaskTypeGradient];
                    });
                });
                
                UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
                refreshButton.center = CGPointMake(self.center.x - self.frame.origin.x, self.center.y - self.frame.origin.y);
                refreshButton.tag = 321;
                UIColor *hapBlue = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0];
                [refreshButton setTitle:@"REFRESH" forState:UIControlStateNormal];
                [refreshButton setTitleColor:hapBlue forState:UIControlStateNormal];
                [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [refreshButton setBackgroundColor:[UIColor whiteColor]];
                refreshButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
                
                refreshButton.layer.cornerRadius = 8;
                refreshButton.layer.masksToBounds = YES;
                refreshButton.layer.borderColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
                refreshButton.layer.borderWidth = 2;
                
                [refreshButton addTarget:self.myViewController action:@selector(refreshData) forControlEvents:UIControlEventTouchUpInside];
                [refreshButton addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
                //[refreshButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpInside];
                [refreshButton addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchDragExit];
                
                [self addSubview:refreshButton];
            }
            
        }];
    
    }
    return self;
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{
    //self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
    
    /*
     menuButton = [[UIButton alloc]initWithFrame:CGRectMake(17, 15, 45, 45)];
     [menuButton setImage:[UIImage imageNamed:@"Settings"] forState:UIControlStateNormal];
     messageButton = [[UIButton alloc]initWithFrame:CGRectMake(260, 15, 45, 45)];
     [messageButton setImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
     
     xButton = [[UIButton alloc]initWithFrame:CGRectMake(60, 360, 59, 59)];
     [xButton setImage:[UIImage imageNamed:@"xButton"] forState:UIControlStateNormal];
     [xButton addTarget:self action:@selector(swipeLeft) forControlEvents:UIControlEventTouchUpInside];
     checkButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 360, 59, 59)];
     [checkButton setImage:[UIImage imageNamed:@"checkButton"] forState:UIControlStateNormal];
     [checkButton addTarget:self action:@selector(swipeRight) forControlEvents:UIControlEventTouchUpInside];
    
    xButton.userInteractionEnabled = YES;
    
    [self addSubview:xButton];
    [self bringSubviewToFront:xButton];
    [self addSubview:checkButton];
    [self bringSubviewToFront:checkButton];
    
     //[self addSubview:menuButton];
     //[self addSubview:messageButton];
     //[self addSubview:xButton];
     //[self addSubview:checkButton];
    */
    
}

//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT)];
    
    self.myViewController.checkButton.userInteractionEnabled = NO;
    self.myViewController.xButton.userInteractionEnabled = NO;

    PFObject *event = events[index];
    draggableView.eventObject = event;
    draggableView.objectID = event.objectId;
    NSString *titleString = event[@"Title"];
    if (titleString.length > 33) {
        draggableView.title.numberOfLines = 2;
        draggableView.title.font = [UIFont fontWithName:@"OpenSans-Bold" size:18];
        draggableView.title.minimumScaleFactor = 0.6;
    }
    draggableView.title.text = titleString;
    
    if (event[@"Description"])
        draggableView.subtitle.text = event[@"Description"];
    else
        draggableView.subtitle.text = @"";
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query fromLocalDatastore];
    [query getObjectInBackgroundWithId:event.objectId block:^(PFObject *object, NSError *error){
        
        if (!error && [object.objectId isEqualToString:event.objectId] && [[event[@"Date"] beginningOfDay] isEqualToDate:[[NSDate date] beginningOfDay]]) {
            
            CategoryBubbleView *stillInterestedView = [[CategoryBubbleView alloc] initWithText:@"Still Interested?" type:@"repeat"];
            [draggableView.cardView addSubview:stillInterestedView];
            [draggableView arrangeCornerViews];
        
        } else {
            
        }
        
    }];
    
    if (event[@"Hashtag"]) {
        draggableView.hashtag.text = [NSString stringWithFormat:@"%@", event[@"Hashtag"]];
        CategoryBubbleView *catView  = [[CategoryBubbleView alloc] initWithText:event[@"Hashtag"] type:@"normal"];
        [draggableView.cardView addSubview:catView];
    } else {
        draggableView.hashtag.text = @"";
    }
    
    NSString *createdByString = event[@"CreatedByName"];
    if (createdByString == nil || [createdByString isEqualToString:@""])
        draggableView.createdBy.text = @"";
    else
        draggableView.createdBy.text = createdByString;
    
    NSString *urlString = event[@"URL"];
    if (urlString == nil || [urlString isEqualToString:@""])
        draggableView.URL = @"";
    else
        draggableView.URL = urlString;
    
    NSString *ticketLinkString = event[@"TicketLink"];
    if (ticketLinkString == nil || [ticketLinkString isEqualToString:@""])
        draggableView.ticketLink = @"";
    else
        draggableView.ticketLink = ticketLinkString;
    
    NSString *locationString = event[@"Location"];
    if (locationString == nil || [locationString isEqualToString:@""])
        draggableView.location.text = @"";
    else
        draggableView.location.text = [NSString stringWithFormat:@"at %@", locationString];
    
    NSNumber *swipe = event[@"swipesRight"];
    draggableView.swipesRight.text = [NSString stringWithFormat:@"%@ interested", [swipe stringValue]];
    
    draggableView.date.text = dateArray[index];
    
    draggableView.eventImage.image = [UIImage imageNamed:event[@"Hashtag"]];
    
    // Only allow interaction once all data is loaded
    draggableView.userInteractionEnabled = YES;
    self.userInteractionEnabled = YES;
    self.myViewController.checkButton.userInteractionEnabled = YES;
    self.myViewController.xButton.userInteractionEnabled = YES;
    
    NSNumber *lowPriceNumber = event[@"lowest_price"];
    if (![lowPriceNumber isKindOfClass:[NSNull class]] && lowPriceNumber != nil) {
        draggableView.startPriceNumLabel.text = [NSString stringWithFormat:@"$%d", [lowPriceNumber intValue]];
    } else {
        draggableView.startPriceNumLabel.text = @"";
    }
    
    
    NSNumber *avePriceNumber = event[@"average_price"];
    if (![avePriceNumber isKindOfClass:[NSNull class]] && lowPriceNumber != nil) {
        draggableView.avePriceNumLabel.text = [NSString stringWithFormat:@"$%d", [avePriceNumber intValue]];
    } else {
        draggableView.avePriceNumLabel.text = @"";
    }
    

    /*
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:event[@"CreatedByName"]];
    [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                      value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                      range:(NSRange){0,[attString length]}];
    draggableView.createdBy.attributedText = attString;
    [draggableView.createdBy sizeToFit];
    if (draggableView.createdBy.frame.size.width > 160) {
        draggableView.createdBy.frame = CGRectMake(draggableView.createdBy.frame.origin.x, draggableView.createdBy.frame.origin.y, 160, draggableView.createdBy.frame.size.height);
    } */

    PFGeoPoint *loc = event[@"GeoLoc"];
    draggableView.geoPoint = loc;
    if (loc.latitude == 0) {
        draggableView.geoLoc.text = @"";
        draggableView.locImage.image = nil;
    } else {
        PFUser *user = [PFUser currentUser];
        PFGeoPoint *userLoc = user[@"userLoc"];
        NSNumber *miles = [NSNumber numberWithDouble:([loc distanceInMilesTo:userLoc])];
        if (miles.floatValue >= 100.0) {
            NSString *distance = [NSString stringWithFormat:(@"100+ mi")];
            draggableView.geoLoc.text = distance;
            CGRect locFrame = draggableView.locImage.frame;
            locFrame.origin.x = locFrame.origin.x - 10;
            draggableView.locImage.frame = locFrame;
        } else if ([miles integerValue] >= 10) {
            NSString *distance = [NSString stringWithFormat:(@"%ld mi"), (long)miles.integerValue];
            draggableView.geoLoc.text = distance;
        } else {
            NSString *distance = [NSString stringWithFormat:(@"%.1f mi"), miles.floatValue];
            draggableView.geoLoc.text = distance;
        }
    }
    
    if (event[@"Image"] != nil) {
        
        PFFile *imageFile = event[@"Image"];
    
        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                
                //draggableView.eventImage.contentMode = UIViewContentModeScaleAspectFill;
                
                /*
                draggableView.eventImage.autoresizingMask =
                ( UIViewAutoresizingFlexibleBottomMargin
                 | UIViewAutoresizingFlexibleHeight
                 | UIViewAutoresizingFlexibleLeftMargin
                 | UIViewAutoresizingFlexibleRightMargin
                 | UIViewAutoresizingFlexibleTopMargin
                 | UIViewAutoresizingFlexibleWidth );
                */

                draggableView.eventImage.image = [UIImage imageWithData:imageData];
                
                //[draggableView.cardView insertSubview:draggableView.transpBackground belowSubview:draggableView.locImage];
                
                //blurView.layer.mask = l;
                

                //UIImage *blurredImage = [draggableView.eventImage.image applyLightEffect];
                /*
                 CGRect clippedRect  = CGRectMake(0, 240, 480, 140);
                 CGImageRef imageRef = CGImageCreateWithImageInRect([draggableView CGImage], clippedRect);
                UIImage *newImage   = [UIImage imageWithCGImage:imageRef];
                 CGImageRelease(imageRef);
            
                 //UIImage *blurImage = draggableView.eventImage.image;
                 UIImageView *imView = [[UIImageView alloc]initWithImage:[newImage applyLightEffect]];
                 imView.frame = CGRectMake(0, 120, 290, 70);
                 [draggableView.eventImage addSubview:imView];
                 */
            
            } else {
            
                NSLog(@"Error retrieving image");
            }
        
            storedIndex = index;
        }];
        
    } else {
     
        // Use default image
    }

    //draggableView.transpBackground.backgroundColor = [UIColor blackColor];
    //draggableView.transpBackground.backgroundColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:0 alpha:0.5];
    
    /*
    UIImage *calImage = [UIImage imageNamed:@"calendar light grey"];
    draggableView.calImageView.image = calImage;
    draggableView.calMonthLabel.text = calMonthArray[index];
    draggableView.calDayLabel.text = calDayArray[index];
    draggableView.calDayOfWeekLabel.text = calDayOfWeekArray[index];
    [draggableView.calDayOfWeekLabel sizeToFit];
    draggableView.calTimeLabel.text = calTimeArray[index];
    [draggableView.calTimeLabel sizeToFit];
    
    UIGestureRecognizer *gr1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkEventStoreAccessForCalendar)];
    [draggableView.calImageView addGestureRecognizer:gr1];
    UIGestureRecognizer *gr2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkEventStoreAccessForCalendar)];
    [draggableView.calMonthLabel addGestureRecognizer:gr2];
    UIGestureRecognizer *gr3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkEventStoreAccessForCalendar)];
    [draggableView.calDayLabel addGestureRecognizer:gr3];
    UIGestureRecognizer *gr4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkEventStoreAccessForCalendar)];
    [draggableView.calDayOfWeekLabel addGestureRecognizer:gr4];
    UIGestureRecognizer *gr5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkEventStoreAccessForCalendar)];
    [draggableView.calTimeLabel addGestureRecognizer:gr5];
     */
    
    [draggableView loadCardWithData];
    
    [self sendSubviewToBack:dragView.cardBackground];
    
    self.dragView.friendScrollView.delegate = self;
    
    draggableView.delegate = self;
    
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    
    //[finalQuery countObjectsInBackgroundWithBlock:^(int eventCount, NSError *error) {
    
    int eventCount = evCount;
    
        NSLog(@"%lu cards loaded",(unsigned long)eventCount);
        
        if(eventCount > 0) {
            NSInteger numLoadedCardsCap =((eventCount > MAX_BUFFER_SIZE)?MAX_BUFFER_SIZE:eventCount);
            //%%% if the buffer size is greater than the data size, there will be an array error, so this makes sure that doesn't happen
            
            //%%% loops through the exampleCardsLabels array to create a card for each label.  This should be customized by removing "exampleCardLabels" with your own array of data
            for (int i = 0; i<eventCount; i++) {
                DraggableView* newCard = [self createDraggableViewWithDataAtIndex:i];
                [allCards addObject:newCard];
                
                
                if (i<numLoadedCardsCap) {
                    //%%% adds a small number of cards to be loaded
                    [loadedCards addObject:newCard];
                }
            }
            
            //%%% displays the small number of loaded cards dictated by MAX_BUFFER_SIZE so that not all the cards
            // are showing at once and clogging a ton of data
            for (int i = 0; i<[loadedCards count]; i++) {
                if (i>0) {
                    [self insertSubview:[loadedCards objectAtIndex:i] belowSubview:[loadedCards objectAtIndex:i-1]];
                } else {
                    [self addSubview:[loadedCards objectAtIndex:i]];
                }
                cardsLoadedIndex++; //%%% we loaded a card into loaded cards, so we have to increment
            }
            
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"noMoreEvents"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //if (!error) {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // time-consuming task
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                });
            //}
            
        } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"noMoreEvents"] ) { // run one more time without limits
            
            NSLog(@"Uno mas");
            
            [self.myViewController refreshData];
            [self.myViewController updateTopLabel];
            
        } else { // there really are no more events
            
            NSLog(@"no more events :(");
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreEvents"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            //[self.myViewController refreshData];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                // time-consuming task
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:@"No more Happenings.\nTry changing search criteria." maskType:SVProgressHUDMaskTypeGradient];
                    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self
                                                   selector:@selector(dismissHUD) userInfo:nil repeats:NO];
                });
            });
            
            [self removeFromSuperview];
            [self.myViewController dropdownPressed];
            
        }
        
        if (loadedCards.count > 0) {
            dragView = [loadedCards objectAtIndex:0]; // Make dragView the current card
            [dragView.cardBackground removeFromSuperview];
        }

    //}];//end of PFQuery
    
    //[self.myViewController updateMainTixButton];
    
}

- (void)dismissHUD {
    [SVProgressHUD dismiss];
}

//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card fromExpandedView:(BOOL)expandedBool
{
    Rdio *rdio = [AppDelegate sharedRdio];
    [rdio.player stop];
    
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
                
                if (loadedCards.count == 0) {
                    
                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded) {
                            
                            if (!shouldLimit || events.count != 10) {
                                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreEvents"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }
                            [self.myViewController refreshData];
                        }
                        
                    }];
                    
                } else {
                    
                    [object saveInBackground];

                }
                
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
         
            if (loadedCards.count == 0) {
                
                [swipesObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        if (!shouldLimit || events.count != 10) {
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreEvents"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        [self.myViewController refreshData];
                    }
                    
                }];
                
            } else {
                [swipesObject saveInBackground];
            }
            
        }
        
    }];

    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }

    if (expandedBool == YES) {
        self.myViewController.userSwipedFromExpandedView = YES;
        [self.myViewController expandCurrentView];
    } else
        self.myViewController.userSwipedFromExpandedView = NO;
    
    dragView = [loadedCards firstObject]; // Make dragView the current card
    [dragView.cardBackground removeFromSuperview];
    
    //[self.myViewController updateMainTixButton];
}

//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card fromExpandedView:(BOOL)expandedBool isGoing:(BOOL)isGoing
{
    Rdio *rdio = [AppDelegate sharedRdio];
    [rdio.player stop];
    
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

                                            //NSLog(@"%@", result);
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
            object[@"swipedAgain"] = @NO;
            object[@"swipedRight"] = @YES;
            object[@"isGoing"] = @(isGoing);
            
            if (loadedCards.count == 0) {
                
                [object saveEventually:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        if (!shouldLimit || events.count != 10) {
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreEvents"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        [self.myViewController refreshData];
                    }
                    
                }];
                
            } else {
                
                [object saveEventually];

            }
        
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
            [swipesObject pinInBackground];
            
            if (shouldLimit) {
                swipesObject[@"swipedAgain"] = @YES;
            }
            
            if ([[PFUser currentUser][@"socialMode"] isEqualToNumber:@YES] && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
                swipesObject[@"FBObjectID"] = user[@"FBObjectID"];
            }
            
            if (loadedCards.count == 0) {
                
                [swipesObject saveEventually:^(BOOL succeeded, NSError *error) {
                    
                    if (succeeded) {
                        
                        if (!shouldLimit || events.count != 10) {
                            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreEvents"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        [self.myViewController refreshData];
                    }
                    
                }];
                
            } else {
                [swipesObject pinInBackground];
                [swipesObject saveEventually];
            }
        }
    
    }];
        
    if (isGoing) {
        [self swipeDownForWhat:c];
    }

    
    if ([[PFUser currentUser][@"hasSwipedRight"] isEqualToNumber:@NO] ) {
        NSLog(@"First swipe right");
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        RKSwipeBetweenViewControllers *rk = appDelegate.rk;
        [rk showCallout];
        
        [PFUser currentUser][@"hasSwipedRight"] = @YES;
        [user saveEventually];
    }
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
    dragView = [loadedCards firstObject]; // Make dragView the current card
    [dragView.cardBackground removeFromSuperview];
    
    if (expandedBool == YES) {
        self.myViewController.userSwipedFromExpandedView = YES;
        [self.myViewController expandCurrentView];
    } else
        self.myViewController.userSwipedFromExpandedView = NO;
    
    //[self.myViewController updateMainTixButton];
    
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    dragView.overlayView.mode = GGOverlayViewModeRight;
    //[UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    //}];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    //[UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    //}];
    [dragView leftClickAction];
}

// Use this method if I ever add a down button!!
-(void)swipeDown
{
    dragView.overlayView.mode = GGOverlayViewModeDown;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    
}

-(void)swipeDownForWhat:(UIView *)card {
    
    DraggableView *c = (DraggableView *)card;
    PFUser *currentUser = [PFUser currentUser];
    
    PFObject *checklist = [PFObject objectWithClassName:@"Checklist"];
    checklist[@"userId"] = currentUser.objectId;
    checklist[@"eventId"] = c.objectID;
    checklist[@"tix"] = @NO;
    checklist[@"cal"] = @NO;
    checklist[@"invite"] = @NO;
    checklist[@"share"] = @NO;
    
    [self.myViewController swipeDown:c];

}

-(void)cardTap
{
    NSLog(@"Card tapped");
    
    PFGeoPoint *loc = self.dragView.geoPoint;
    self.mapLocation = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
    
    self.myViewController.mapLocation = self.mapLocation;
    self.myViewController.eventID = self.dragView.objectID;
    self.myViewController.eventTitle = self.dragView.title.text;
    self.myViewController.locationTitle = self.dragView.location.text;
    
    [self.myViewController expandCurrentView];
    
    [dragView cardExpanded:self.myViewController.isCardExpanded];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //if (CGRectContainsPoint(self.dragView.bounds, [touch locationInView:self.dragView]))
    if (self.myViewController.isCardExpanded)
        return NO;
    
    return YES;
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    PFObject *object = [query getObjectWithId:dragView.objectID];
    
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    
    event.title = dragView.title.text;
    
    NSDate *startDate = object[@"Date"];
    NSDate *endDate = object[@"EndTime"];
    
    event.startDate = startDate;
    event.endDate = endDate;

    //get address REMINDER 76597869876
    PFGeoPoint *geoPoint = object[@"GeoLoc"];
    CLLocation *eventLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    NSString *ticketLink = object[@"TicketLink"];
    NSString *description = dragView.subtitle.text;
    
    if ((description == nil || [description isEqualToString:@""]) && (ticketLink == nil || [ticketLink isEqualToString:@""])) {
        event.notes = [NSString stringWithFormat:@"Venue name: %@", dragView.location.text];
    } else if (ticketLink == nil || [ticketLink isEqualToString:@""]) {
        event.notes = [NSString stringWithFormat:@"Venue name: %@ // %@", dragView.location.text, description];
    } else if (description == nil || [description isEqualToString:@""]) {
        event.notes = [NSString stringWithFormat:@"Venue name: %@ // Get tickets at: %@", dragView.location.text, ticketLink];
    } else {
        event.notes = [NSString stringWithFormat:@"Venue name: %@ // Get tickets at: %@ // %@", dragView.location.text, ticketLink, description];
    }
    
    
    NSString *url = object[@"URL"];
    NSURL *urlFromString = [NSURL URLWithString:url];

    if (urlFromString != nil)
        event.URL = urlFromString;
    else
        event.URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.happening.city/events/%@", object.objectId]];
    
    
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
            event.location = dragView.location.text;
        
        
        //[RKDropdownAlert title:@"Event added to your main calendar!" backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        //NSError *err;
        //[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        //NSLog(@"Added %@ to calendar. Object ID: %@", dragView.title.text, dragView.objectID);
        
        [self.myViewController showEditEventVCWithEvent:event eventStore:eventStore];
    }];

}

#pragma delegate methods for draggableview

- (void)shareButtonTap:(id)sender {
    [self.myViewController shareAction:sender];
}

- (void)createdByTap {
    [self.myViewController showCreatedByProfile];
}

- (void)subtitleTap {
    [self.myViewController showMoreDetail];
}

- (void)moreButtonTap {
    [self.myViewController showMoreDetail];
}

-(void)inviteButtonTap {
    [self.myViewController inviteHomies];
}

-(void)mapViewTap {
    NSLog(@"Made it");
    [self.myViewController mapViewTap];
}

-(void)ticketsButtonTap:(id)sender {
    [self.myViewController ticketsButtonTapped:sender];
}

-(void)friendProfileTap:(id)sender {
    
    UIView *view = (UIView *)sender;
    //self.myViewController.friendObjectID = view.accessibilityIdentifier;
    [self.myViewController showFriendProfile:view.accessibilityIdentifier];
    
}


- (NSMutableArray *) setCategories {
    
    NSMutableArray *categories = [[NSMutableArray alloc]init];
    categories = [NSMutableArray arrayWithArray:[PFUser currentUser][@"categories"]];
    return categories;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.tag == 33) {
        
        if (scrollView.contentOffset.x >= (scrollView.contentSize.width - scrollView.frame.size.width)) {
            
            dragView.friendArrow.alpha = 0;
            
        } else {
            
            dragView.friendArrow.alpha = 1;

        }
        
    }
    
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

/*

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
           withColor:(UIColor*)  color
            withFont:(UIFont *)  font
{
    
    //UIFont *font = [UIFont fontWithName:@"LetterGothicStd" size:12.0]; // fixed-width font
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [color set];
    //UILabel *label;
    //label.text = text;
    //[label drawTextInRect:rect];
    //[text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
 
 */

@end
