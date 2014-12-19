//
//  DraggableViewBackground.m
//
//  Created by Max Friedman.
//  Copyright (c) 2014 Happening, LLC. All rights reserved.
//

#import "DraggableViewBackground.h"
#import "NSDate+CupertinoYankee.h"

@interface DraggableViewBackground()

@property (nonatomic, strong) EKEventStore *eventStore;

@end

@implementation DraggableViewBackground{
    NSInteger cardsLoadedIndex; //%%% the index of the card you have loaded into the loadedCards array last
    NSMutableArray *loadedCards; //%%% the array of card loaded (change max_buffer_size to increase or decrease the number of cards this holds)
    
    UIButton* menuButton;
    UIButton* messageButton;
    UIButton* checkButton;
    UIButton* xButton;
    
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 320; //%%% height of the draggable card
static const float CARD_WIDTH = 290; //%%% width of the draggable card

@synthesize exampleCardLabels; //%%% all the labels I'm using as example data at the moment
@synthesize allCards;//%%% all the cards

@synthesize titleArray;
@synthesize subtitleArray;
@synthesize locationArray;
@synthesize dateArray;
@synthesize timeArray;
@synthesize hashtagArray;
@synthesize someArray;
@synthesize geoLocArray;
@synthesize locManager;
@synthesize objectIDs;
@synthesize swipesRightArray;
@synthesize swipes;
@synthesize imageArray;
@synthesize createdByArray;
@synthesize storedIndex;

@synthesize dragView; //CURRENT CARD!
@synthesize eventStore;


- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [super layoutSubviews];
        [self setupView];
        
        eventStore = [[EKEventStore alloc] init];
        
        self.myViewController = nil;
        
        PFUser *user = [PFUser currentUser];
        
        if(locManager && [CLLocationManager locationServicesEnabled]) {
            [self.locManager startUpdatingLocation];
            CLLocation *currentLocation = locManager.location;
            user[@"userLoc"] = [PFGeoPoint geoPointWithLocation:currentLocation];
            NSLog(@"Current Location is: %@", currentLocation);
            [user saveInBackground];
        }
        
        
        exampleCardLabels = [[NSMutableArray alloc]initWithObjects: nil];
        someArray = [[NSArray alloc]init];
        titleArray = [[NSMutableArray alloc]init];
        subtitleArray = [[NSMutableArray alloc]init];
        locationArray = [[NSMutableArray alloc]init];
        dateArray = [[NSMutableArray alloc]init];
        //timeArray = [[NSMutableArray alloc]init];
        hashtagArray = [[NSMutableArray alloc]init];
        geoLocArray = [[NSMutableArray alloc]init];
        objectIDs = [[NSMutableArray alloc]init];
        swipesRightArray = [[NSMutableArray alloc]init];
        imageArray = [[NSMutableArray alloc]init];
        swipes = [[NSMutableArray alloc]init];
        createdByArray = [[NSMutableArray alloc]init];
        
        PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
        // Sorts the query by most recent event and only shows those after today's date
        [eventQuery orderByAscending:@"Date"];
        [eventQuery whereKey:@"Date" greaterThan:[NSDate date]]; // ADD DATE MINUS 2 HOURS TO SHOW EVENTS
        
        PFQuery *didUserSwipe = [PFQuery queryWithClassName:@"Swipes"];
        [didUserSwipe whereKey:@"UserID" containsString:user.username];
        NSLog(@"current user: %@", user.username);
        
        [eventQuery whereKey:@"objectId" doesNotMatchKey:@"EventID" inQuery:didUserSwipe];
        PFGeoPoint *userLoc = user[@"userLoc"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger radius = [defaults integerForKey:@"sliderValue"];
        [eventQuery whereKey:@"GeoLoc" nearGeoPoint:userLoc withinMiles:radius];
        
        
        //NSLog(@"events: %@", [eventQuery findObjects]);
        [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *eventObjects, NSError *error) {
            
            for (int i = 0; i < eventObjects.count; i++) {
                
                PFObject *eventObject = eventObjects[i];
                [objectIDs addObject:eventObject.objectId];
                
                [titleArray addObject:eventObject[@"Title"]];
                [subtitleArray addObject:eventObject[@"Subtitle"]];
                [locationArray addObject:eventObject[@"Location"]];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"EEE, MMM d"];
                NSDate *eventDate = [[NSDate alloc]init];
                eventDate = eventObject[@"Date"];
                
                if ([eventDate beginningOfDay] == [[NSDate date]beginningOfDay]) {  // TODAY
                    
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    NSString *finalString = [NSString stringWithFormat:@"Today at %@", timeString];
                    [dateArray addObject:finalString];
                    
                } else if ([eventDate beginningOfDay] == [[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]) { // TOMORROW
                    
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    NSString *finalString = [NSString stringWithFormat:@"Tomorrow at %@", timeString];
                    [dateArray addObject:finalString];
                    
                } else if ([eventDate endOfWeek] == [[NSDate date]endOfWeek]) { // SAME WEEK
                    
                    [formatter setDateFormat:@"EEEE"];
                    NSString *dayOfWeekString = [formatter stringFromDate:eventDate];
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    NSString *finalString = [NSString stringWithFormat:@"%@ at %@", dayOfWeekString, timeString];
                    [dateArray addObject:finalString];
                    
                } else {
                
                NSString *dateString = [formatter stringFromDate:eventDate];
                [formatter setDateFormat:@"h:mma"];
                NSString *timeString = [formatter stringFromDate:eventDate];
                NSString *finalString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];

                [dateArray addObject:finalString];
                    
                }
                
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
                //NSLog(@"%@ to %@", startTimeString, endTimeString);
                //[timeArray addObject:@"Delete this"];
                NSString *tagString = [NSString stringWithFormat:@"tags: %@", eventObject[@"Hashtag"]];
                [hashtagArray addObject:tagString];
                [geoLocArray addObject:eventObject[@"GeoLoc"]];
                
                NSNumber *swipe = eventObject[@"swipesRight"];
                NSString *swipeString = [NSString stringWithFormat:@"%@ interested", [swipe stringValue]];
                
                [swipesRightArray addObject:swipeString];
                
                [imageArray addObject:eventObject[@"Image"]];
                
                NSString *name = eventObject[@"CreatedByName"];
                NSString *fullName = [NSString stringWithFormat:@"Created by: %@", name];
                [createdByArray addObject:fullName];
                
            }
            
        }];
        
        loadedCards = [[NSMutableArray alloc] init];
        allCards = [[NSMutableArray alloc] init];
        cardsLoadedIndex = 0;
        [self loadCards];
    }
    return self;
}

//%%% sets up the extra buttons on the screen
-(void)setupView
{
#warning customize all of this.  These are just place holders to make it look pretty
    //self.backgroundColor = [UIColor colorWithRed:.92 green:.93 blue:.95 alpha:1]; //the gray background colors
    
    /*
     menuButton = [[UIButton alloc]initWithFrame:CGRectMake(17, 15, 45, 45)];
     [menuButton setImage:[UIImage imageNamed:@"Settings"] forState:UIControlStateNormal];
     messageButton = [[UIButton alloc]initWithFrame:CGRectMake(260, 15, 45, 45)];
     [messageButton setImage:[UIImage imageNamed:@"Share"] forState:UIControlStateNormal];
     
     happening = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, self.frame.size.width, 100)];
     [happening setTextAlignment:NSTextAlignmentCenter];
     happening.textColor = [UIColor blackColor];
     happening.text = @"Happening";
     
     
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


#warning include own card customization here!
//%%% creates a card and returns it.  This should be customized to fit your needs.
// use "index" to indicate where the information should be pulled.  If this doesn't apply to you, feel free
// to get rid of it (eg: if you are building cards from data from the internet)
-(DraggableView *)createDraggableViewWithDataAtIndex:(NSInteger)index
{
    DraggableView *draggableView = [[DraggableView alloc]initWithFrame:CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT)];
    [draggableView.activityView startAnimating];
    draggableView.userInteractionEnabled = NO;
    // &&& Adds image cards from array
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //NSLog(@"%@", objects[index]);
        //NSLog(objectIDs[index]);
        draggableView.objectID = objectIDs[index];
        draggableView.title.text = titleArray[index];
        draggableView.subtitle.text = subtitleArray[index];
        draggableView.location.text = locationArray[index];
        draggableView.date.text = dateArray[index];
        //draggableView.time.text = timeArray[index];
        draggableView.hashtag.text = hashtagArray[index];
        draggableView.swipesRight.text = swipesRightArray[index];
        //draggableView.createdBy.text = createdByArray[index];
        
        PFGeoPoint *loc = geoLocArray[index];
        draggableView.geoPoint = loc;
        if (loc.latitude == 0) {
            draggableView.geoLoc.text = @"";
            draggableView.locImage.image = nil;
        } else {
            PFUser *user = [PFUser currentUser];
            PFGeoPoint *userLoc = user[@"userLoc"];
            NSNumber *miles = [NSNumber numberWithDouble:([loc distanceInMilesTo:userLoc])];
            if (miles > [NSNumber numberWithInt:10]) {
                NSString *distance = [NSString stringWithFormat:(@"%.1f mi"), miles.floatValue];
                draggableView.geoLoc.text = distance;
            } else {
            NSString *distance = [NSString stringWithFormat:(@"%.2f mi"), miles.floatValue];
            draggableView.geoLoc.text = distance;
            }
            
            draggableView.locImage.image = [UIImage imageNamed:@"locationPinThickOutline"];
        }
        
        /*
         @"#Nightlife",@"#Sports",@"#Music", @"#Shopping", @"#Freebies", @"#HappyHour", @"#Dining", @"#Entertainment", @"#Fundraiser", @"#Other", @"#Meetup"
         NSString *img = [NSString stringWithFormat:(hashtagArray[index])];
         img = [img stringByAppendingString:@".jpg"];
         draggableView.eventImage.image = [UIImage imageNamed:img];
         */
        PFFile *imageFile = imageArray[index];
        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                draggableView.eventImage.image = [UIImage imageWithData:imageData];
            }
            
            storedIndex = index;
        }];
        
        draggableView.userImage.image = [UIImage imageNamed:@"userImage"];
        
        //draggableView.transpBackground.backgroundColor = [UIColor blackColor];
        //draggableView.transpBackground.backgroundColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:0 alpha:0.5];
        
        // Only allow interaction once all data is loaded
        draggableView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTap)];
        [draggableView addGestureRecognizer:tapGestureRecognizer];
        [draggableView.activityView stopAnimating];
    }];
    
    draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    PFUser *user = [PFUser currentUser];
    // PFQuery to get number of objects so I know how many cards to make
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"Date" greaterThan:[NSDate date]];
    
    
    PFQuery *didUserSwipe = [PFQuery queryWithClassName:@"Swipes"];
    [didUserSwipe whereKey:@"UserID" containsString:user.username];
    
    
    [query whereKey:@"objectId" doesNotMatchKey:@"EventID" inQuery:didUserSwipe];
    
    PFGeoPoint *userLoc = user[@"userLoc"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger radius = [defaults integerForKey:@"sliderValue"];
    [query whereKey:@"GeoLoc" nearGeoPoint:userLoc withinMiles:radius];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *eventObjects, NSError *error) {
        
        NSInteger eventCount = [eventObjects count];
        
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
        }
        
        if (loadedCards.count > 0)
            dragView = [loadedCards objectAtIndex:0]; // Make dragView the current card
        
    }];//end of PFQuery
    
    
}

#warning include own action here!
//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card;
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:c.objectID block:^(PFObject *object, NSError *error) {
        
        NSNumber *swipesNum = object[@"swipesLeft"];
        NSInteger swipesPlusOne = ([swipesNum integerValue] + 1);
        swipesNum = [NSNumber numberWithInt:swipesPlusOne];
        
        object[@"swipesLeft"] = swipesNum;
        [object saveInBackground];
        
    }];
    
    PFObject *swipesObject = [PFObject objectWithClassName:@"Swipes"];
    PFUser *user = [PFUser currentUser];
    swipesObject[@"UserID"] = user.username;
    swipesObject[@"EventID"] = c.objectID;
    swipesObject[@"swipedRight"] = @NO;
    swipesObject[@"swipedLeft"] = @YES;
    [swipesObject saveInBackground];
    
    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
 
    dragView = [loadedCards firstObject]; // Make dragView the current card

}

#warning include own action here!
//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    
    PFUser *user = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:c.objectID block:^(PFObject *object, NSError *error) {
        
        NSNumber *swipesNum = object[@"swipesRight"];
        NSInteger swipesPlusOne = ([swipesNum integerValue] + 1);
        swipesNum = [NSNumber numberWithInteger:swipesPlusOne];
        
        object[@"swipesRight"] = swipesNum;
        [object saveInBackground];
        
        NSString *tag = [NSString stringWithFormat:@"%@", object[@"Hashtag"]];
        NSNumber *tagNum= user[tag];
        NSInteger tagPlusOne = ([tagNum integerValue] + 1);
        tagNum = [NSNumber numberWithInteger:tagPlusOne];
        
        user[tag] = tagNum;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // The currentUser saved successfully.
            } else {
                // There was an error saving the currentUser.
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"Parse error: %@", errorString);
            }
        }];
    }];
    
    PFObject *swipesObject = [PFObject objectWithClassName:@"Swipes"];
    swipesObject[@"UserID"] = user.username;
    swipesObject[@"EventID"] = c.objectID;
    swipesObject[@"swipedRight"] = @YES;
    swipesObject[@"swipedLeft"] = @NO;
    [swipesObject saveInBackground];

    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
    //[self checkEventStoreAccessForCalendar];
    
    dragView = [loadedCards firstObject]; // Make dragView the current card

    
}

//%%% when you hit the right button, this is called and substitutes the swipe
-(void)swipeRight
{
    dragView.overlayView.mode = GGOverlayViewModeRight;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
    [dragView rightClickAction];
}

//%%% when you hit the left button, this is called and substitutes the swipe
-(void)swipeLeft
{
    dragView.overlayView.mode = GGOverlayViewModeLeft;
    [UIView animateWithDuration:0.2 animations:^{
        dragView.overlayView.alpha = 1;
    }];
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

-(void)cardTap
{
    NSLog(@"Card tapped");
    
    PFGeoPoint *loc = self.dragView.geoPoint;
    self.mapLocation = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
    
    self.myViewController.mapLocation = self.mapLocation;
    self.myViewController.eventID = self.dragView.objectID;
    self.myViewController.eventTitle = self.dragView.title.text;
    self.myViewController.locationTitle = self.dragView.location.text;
    
    [self.myViewController flipCurrentView];
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
                                                  cancelButtonTitle:@"OK"
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

    event.startDate = object[@"Date"];
    event.endDate = object[@"EndTime"];

    //get address REMINDER 76597869876
    PFGeoPoint *geoPoint = object[@"GeoLoc"];
    CLLocation *eventLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    
    NSString *subtitle = dragView.subtitle.text;
    NSString *description = object[@"Description"];
    
    if (description == nil)
        event.notes = [NSString stringWithFormat:@"%@ // %@", dragView.location.text, subtitle];
    else
        event.notes = [NSString stringWithFormat:@"%@ // %@ // %@", dragView.location.text, subtitle, description];
    
    
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
        
        if (zipCode) {
            event.location = [NSString stringWithFormat:@"%@, %@ %@, %@", streetName, cityName, stateName, zipCode];
        }
        else if (cityName) {
            event.location = [NSString stringWithFormat:@"%@, %@, %@", streetName, cityName, stateName];
        } else
            event.location = dragView.location.text;
        
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Event added to your main calendar!" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        NSLog(@"Added %@ to calendar. Object ID: %@", dragView.title.text, dragView.objectID);
        
    }];

}

@end
