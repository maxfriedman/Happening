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
    
    PFQuery *eventQuery;
    
}
//this makes it so only two cards are loaded at a time to
//avoid performance and memory costs
static const int MAX_BUFFER_SIZE = 2; //%%% max number of cards loaded at any given time, must be greater than 1
static const float CARD_HEIGHT = 310; //%%% height of the draggable card
static const float CARD_WIDTH = 284; //%%% width of the draggable card

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
@synthesize URLArray;
@synthesize calDayArray, calDayOfWeekArray, calMonthArray, calTimeArray;

@synthesize dragView; //CURRENT CARD!
@synthesize eventStore;
@synthesize blurView;


- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%");
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [super layoutSubviews];
        [self setupView];
        
        //self.superview.superview.userInteractionEnabled = YES;
        //self.myViewController.view.userInteractionEnabled = YES;
        
        self.myViewController.frontViewIsVisible = YES; // Cards start off with front view visible
        
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
        URLArray = [[NSMutableArray alloc]init];
        calTimeArray = [[NSMutableArray alloc]init];
        calMonthArray = [[NSMutableArray alloc]init];
        calDayOfWeekArray = [[NSMutableArray alloc]init];
        calDayArray = [[NSMutableArray alloc]init];
        
        eventQuery = [PFQuery queryWithClassName:@"Event"];
        
        // Sorts the query by categories chosen in settings... Default = ALL categories (set on first launch)
        NSArray *categories = [[NSArray alloc]init];
        categories = [self setCategories]; //set from User Defaults ... Should I just pull from Parse??
        [eventQuery whereKey:@"Hashtag" containedIn:categories];
        
        // Sorts the query by most recent event and only shows those after today's date
        
        BOOL shouldLimit =! [[NSUserDefaults standardUserDefaults] boolForKey:@"noMoreEvents"];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"today"]) {
            
            NSLog(@"today");
            
            [eventQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]]; // show today's events, must be at least 30 minutes left in the event (END)
             if (shouldLimit) [eventQuery whereKey:@"Date" lessThan:[[NSDate date]endOfDay]];
            
        } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"tomorrow"]) {
            
            NSLog(@"tomorrow");

            NSDate *tomorrowDate = [[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay];
            [eventQuery whereKey:@"Date" greaterThan:tomorrowDate]; // show tomorrow's events -- must START after beginning of tomorrow or later
            if (shouldLimit) [eventQuery whereKey:@"Date" lessThan:[tomorrowDate endOfDay]];
            
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
                if (shouldLimit) [eventQuery whereKey:@"Date" lessThan:[sundayDate endOfDay]];
                
            } else if ([[NSDate date] beginningOfDay] == [sundayDate dateByAddingTimeInterval:-86400]) {
            
                NSLog(@"saturday middle of day");
                
                [eventQuery whereKey:@"EndTime" greaterThan:[NSDate dateWithTimeIntervalSinceNow:1800]]; // show ONLY events from now (Saturday) to Sunday
                if (shouldLimit) [eventQuery whereKey:@"Date" lessThan:[sundayDate endOfDay]];
            
            } else {
                
                NSLog(@"weekday");
                
                [eventQuery whereKey:@"Date" greaterThan:[sundayDate dateByAddingTimeInterval:-86400]]; // show ALL events that start after this SATURDAY
                if (shouldLimit) [eventQuery whereKey:@"Date" lessThan:[sundayDate endOfDay]];
            
            }
            
            //NSLog(@"Beg of week: %@", [sundayDate dateByAddingTimeInterval:-86400]);
            
        }
        
        [eventQuery orderByAscending:@"Date"];
        
        PFQuery *didUserSwipe = [PFQuery queryWithClassName:@"Swipes"];
        [didUserSwipe whereKey:@"UserID" containsString:user.objectId];
        NSLog(@"current user: %@", user.username);
        
        [eventQuery whereKey:@"objectId" doesNotMatchKey:@"EventID" inQuery:didUserSwipe];
        PFGeoPoint *userLoc = user[@"userLoc"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSInteger radius = [defaults integerForKey:@"sliderValue"];
        [eventQuery whereKey:@"GeoLoc" nearGeoPoint:userLoc withinMiles:radius];
                
        //NSLog(@"events: %@", [eventQuery findObjects]);
        [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *eventObjects, NSError *error) {
            
            if (eventObjects.count == 0) {
                // Do something?
                NSLog(@"~~~~~~~~~~~~ NO EVENTS ~~~~~~~~~~~~~~~~~");
            }
            
            for (int i = 0; i < eventObjects.count; i++) {

                PFObject *eventObject = eventObjects[i];
                [objectIDs addObject:eventObject.objectId];

                [titleArray addObject:eventObject[@"Title"]];
                [subtitleArray addObject:eventObject[@"Description"]];
                [locationArray addObject:eventObject[@"Location"]];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"EEE, MMM d"];
                NSDate *eventDate = [[NSDate alloc]init];
                eventDate = eventObject[@"Date"];
                
                NSString *finalString;
                
                // FORMAT FOR MULTI-DAY EVENT
                NSDate *endDate = eventObject[@"EndTime"];
                
                
                if ([eventDate beginningOfDay] == [[NSDate date]beginningOfDay]) {  // TODAY
                    
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    finalString = [NSString stringWithFormat:@"Today at %@", timeString];
                    
                    [calDayOfWeekArray addObject:@"Today"];
                    
                } else if ([eventDate beginningOfDay] == [[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]) { // TOMORROW
                    
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    finalString = [NSString stringWithFormat:@"Tomorrow at %@", timeString];
                    
                    [calDayOfWeekArray addObject:@"Tomorrow"];
                    
                } else if ([eventDate endOfWeek] == [[NSDate date]endOfWeek]) { // SAME WEEK
                    
                    [formatter setDateFormat:@"EEEE"];
                    NSString *dayOfWeekString = [formatter stringFromDate:eventDate];
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    finalString = [NSString stringWithFormat:@"%@ at %@", dayOfWeekString, timeString];
                    
                    [formatter setDateFormat:@"EEEE"];
                    [calDayOfWeekArray addObject:[formatter stringFromDate:eventDate]];
                    
                } else if ([eventDate beginningOfDay] != [endDate beginningOfDay]) { //MULTI-DAY EVENT
                    
                    [formatter setDateFormat:@"MMM d"];
                    NSString *dateString = [formatter stringFromDate:eventDate];
                    NSString *endDateString = [formatter stringFromDate:endDate];
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    NSString *endTimeString = [formatter stringFromDate:endDate];
                    
                    finalString = [NSString stringWithFormat:@"%@ at %@ to %@ at %@", dateString, timeString, endDateString, endTimeString];
                    
                    [formatter setDateFormat:@"EEEE"];
                    [calDayOfWeekArray addObject:[formatter stringFromDate:eventDate]];
                
                } else { // Past this week- uses abbreviated date format
                
                    NSString *dateString = [formatter stringFromDate:eventDate];
                    [formatter setDateFormat:@"h:mma"];
                    NSString *timeString = [formatter stringFromDate:eventDate];
                    finalString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
                    
                    [formatter setDateFormat:@"EEEE"];
                    [calDayOfWeekArray addObject:[formatter stringFromDate:eventDate]];
                    
                }
                
                [formatter setDateFormat:@"MMM"];
                [calMonthArray addObject:[formatter stringFromDate:eventDate]];
                [formatter setDateFormat:@"d"];
                [calDayArray addObject:[formatter stringFromDate:eventDate]];
                
                [formatter setDateFormat:@"h:mma"];
                NSString *calTimeString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:eventDate], [formatter stringFromDate:endDate]];
                
                if ([calTimeString containsString:@":00"]) {
                    
                    calTimeString = [calTimeString stringByReplacingOccurrencesOfString:@":00" withString:@" "];
                    
                }
                
                [calTimeArray addObject:calTimeString];
                
                
                if ([finalString containsString:@":00"]) {
                    
                    finalString = [finalString stringByReplacingOccurrencesOfString:@":00" withString:@" "];
                    
                }
               
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
                NSString *fullName = [NSString stringWithFormat:@"%@", name];
                [createdByArray addObject:name];
                
                NSString *urlString = eventObject[@"URL"];
                if (urlString == nil || [urlString isEqualToString:@""])
                    [URLArray addObject:@""];
                else
                    [URLArray addObject:urlString];

            }
            
            if (!error) {
                loadedCards = [[NSMutableArray alloc] init];
                allCards = [[NSMutableArray alloc] init];
                cardsLoadedIndex = 0;
                [self loadCards];
            } else {
                NSLog(@"Error--- perform action");
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // time-consuming task
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:@"Houston, we have a problem." maskType:SVProgressHUDMaskTypeGradient];
                    });
                });
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
    //[draggableView.activityView startAnimating];
    draggableView.userInteractionEnabled = NO;
    // &&& Adds image cards from array
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //NSLog(@"%@", objects[index]);
        //NSLog(objectIDs[index]);

        draggableView.objectID = objectIDs[index];
        draggableView.title.text = titleArray[index];
        draggableView.subtitle.text = subtitleArray[index];
        [draggableView.subtitle sizeToFit];
        draggableView.location.text = locationArray[index];
        draggableView.date.text = dateArray[index];
        //draggableView.time.text = timeArray[index];
        //draggableView.hashtag.text = hashtagArray[index];
        draggableView.swipesRight.text = swipesRightArray[index];
        draggableView.URL = URLArray[index];

        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:createdByArray[index]];
        [attString addAttribute:(NSString*)kCTUnderlineStyleAttributeName
                          value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]
                          range:(NSRange){0,[attString length]}];
        draggableView.createdBy.attributedText = attString;
        [draggableView.createdBy sizeToFit];
        if (draggableView.createdBy.frame.size.width > 160) {
            draggableView.createdBy.frame = CGRectMake(draggableView.createdBy.frame.origin.x, draggableView.createdBy.frame.origin.y, 160, draggableView.createdBy.frame.size.height);
        }

        PFGeoPoint *loc = geoLocArray[index];
        draggableView.geoPoint = loc;
        if (loc.latitude == 0) {
            draggableView.geoLoc.text = @"";
            draggableView.locImage.image = nil;
        } else {
            PFUser *user = [PFUser currentUser];
            PFGeoPoint *userLoc = user[@"userLoc"];
            NSNumber *miles = [NSNumber numberWithDouble:([loc distanceInMilesTo:userLoc])];
            if ([miles integerValue] > 10) {
                NSString *distance = [NSString stringWithFormat:(@"%ld mi"), (long)miles.integerValue];
                draggableView.geoLoc.text = distance;
            } else {
            NSString *distance = [NSString stringWithFormat:(@"%.1f mi"), miles.floatValue];
            draggableView.geoLoc.text = distance;
            }
            
            draggableView.locImage.image = [UIImage imageNamed:@"location"];
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
                
                blurView = [[FXBlurView alloc]initWithFrame:draggableView.blurEffectView.frame];
                [draggableView.eventImage addSubview:blurView];
                blurView.dynamic = NO;
                blurView.blurRadius = 50;

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
                
            }
            
            storedIndex = index;
        }];

        draggableView.userImage.image = [UIImage imageNamed:@"interested_face"];
                
        //draggableView.transpBackground.backgroundColor = [UIColor blackColor];
        //draggableView.transpBackground.backgroundColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:0 alpha:0.5];
        
        // Only allow interaction once all data is loaded
        draggableView.userInteractionEnabled = YES;
        
        UIImage *calImage = [UIImage imageNamed:@"calendar light grey"]; //[DraggableViewBackground drawText:calMonthArray[index] inImage:[UIImage imageNamed:@"calendar light grey"] atPoint:CGPointMake(20, 20) withColor:[UIColor blackColor] withFont:[UIFont fontWithName:@"OpenSans" size:10.0]];
        // calImage = [DraggableViewBackground drawText:calDayArray[index] inImage:[UIImage imageNamed:@"calendar light grey"] atPoint:CGPointMake(40, 40) withColor:[UIColor blackColor] withFont:[UIFont fontWithName:@"OpenSans" size:12.0]];
        
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
        
        
        //draggableView.calImageView.frame = CGRectMake(0, 0, calImage.size.width, calImage.size.height);
        
        NSLog(@"DATE: ==> %@, %@, %@, %@", calMonthArray[index], calDayArray[index], calDayOfWeekArray[index], calTimeArray[index]);
        
        
        [draggableView.shareButton addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
        
        UITapGestureRecognizer *createdByTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createdByTap)];
        [draggableView.createdBy addGestureRecognizer:createdByTapRecognizer];
        
        [self sendSubviewToBack:dragView.cardBackground];
        //[draggableView.activityView stopAnimating];
        
    }];
    
    draggableView.delegate = self;
    return draggableView;
}

//%%% loads all the cards and puts the first x in the "loaded cards" array
-(void)loadCards
{
    
    [eventQuery countObjectsInBackgroundWithBlock:^(int eventCount, NSError *error) {
        
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
            
            if (!error) {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // time-consuming task
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD dismiss];
                    });
                });
            }
            
        } else {
            
            NSLog(@"no more events :(");
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreEvents"];
            [self.myViewController refreshData];
        }
        
        if (loadedCards.count > 0) {
            dragView = [loadedCards objectAtIndex:0]; // Make dragView the current card
            [dragView.cardBackground removeFromSuperview];
        }

    }];//end of PFQuery
    
    
}

//%%% action called when the card goes to the left.
// This should be customized with your own action
-(void)cardSwipedLeft:(UIView *)card fromFlippedView:(BOOL)flippedBool
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:c.objectID block:^(PFObject *object, NSError *error) {
        
        [object incrementKey:@"swipesLeft"];
        [object saveInBackground];
        
        if (!error) {
            NSLog(@"Swipe saved successfully!");
        } else {
            NSLog(@"Parse error: %@", error);
        }
        
    }];
    
    PFObject *swipesObject = [PFObject objectWithClassName:@"Swipes"];
    PFUser *user = [PFUser currentUser];
    swipesObject[@"UserID"] = user.objectId;
    swipesObject[@"username"] = user.username;
    swipesObject[@"EventID"] = c.objectID;
    swipesObject[@"swipedRight"] = @NO;
    swipesObject[@"swipedLeft"] = @YES;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"socialMode"]) {
        swipesObject[@"FBObjectID"] = user[@"FBObjectID"];
    }

    
    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
 
    dragView = [loadedCards firstObject]; // Make dragView the current card
    [dragView.cardBackground removeFromSuperview];

    if (flippedBool == YES) {
        self.myViewController.userSwipedFromFlippedView = YES;
        [self.myViewController flipCurrentView];
    } else
        self.myViewController.userSwipedFromFlippedView = NO;
    
    if (loadedCards.count == 0) {
        
        [swipesObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreEvents"];
                [self.myViewController refreshData];
            }
            
        }];
    
    } else {
        [swipesObject saveInBackground];
    }
    
}

//%%% action called when the card goes to the right.
// This should be customized with your own action
-(void)cardSwipedRight:(UIView *)card fromFlippedView:(BOOL)flippedBool
{
    //do whatever you want with the card that was swiped
    DraggableView *c = (DraggableView *)card;
    
    PFUser *user = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:c.objectID block:^(PFObject *object, NSError *error) {
        
        [object incrementKey:@"swipesRight"];
        [object saveInBackground];
        
        NSString *tag = [NSString stringWithFormat:@"%@", object[@"Hashtag"]];
        [user incrementKey:tag];
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // The currentUser saved successfully.
            } else {
                // There was an error saving the currentUser.
                NSString *errorString = [error userInfo][@"error"];
                NSLog(@"Parse error: %@", errorString);
            }
        }];
        
        if (!error) {
            NSLog(@"Swipe saved successfully!");
        } else {
            NSLog(@"Parse error: %@", error);
              }
    }];
    
    PFObject *swipesObject = [PFObject objectWithClassName:@"Swipes"];
    swipesObject[@"UserID"] = user.objectId;
    swipesObject[@"username"] = user.username;
    swipesObject[@"EventID"] = c.objectID;
    swipesObject[@"swipedRight"] = @YES;
    swipesObject[@"swipedLeft"] = @NO;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"socialMode"]) {
        swipesObject[@"FBObjectID"] = user[@"FBObjectID"];
    }

    
    //PFObject *analyticsObject = [PFObject objectWithClassName:@"Analytics"];
    //analyticsObject[@"Age"] = user[@"]


    [loadedCards removeObjectAtIndex:0]; //%%% card was swiped, so it's no longer a "loaded card"
    
    if (cardsLoadedIndex < [allCards count]) { //%%% if we haven't reached the end of all cards, put another into the loaded cards
        [loadedCards addObject:[allCards objectAtIndex:cardsLoadedIndex]];
        cardsLoadedIndex++;//%%% loaded a card, so have to increment count
        [self insertSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-1)] belowSubview:[loadedCards objectAtIndex:(MAX_BUFFER_SIZE-2)]];
    }
    
    dragView = [loadedCards firstObject]; // Make dragView the current card
    [dragView.cardBackground removeFromSuperview];
    
    if (loadedCards.count > 1) {
        DraggableView *secondDragView = [loadedCards objectAtIndex:1];
        [secondDragView sendSubviewToBack:secondDragView.cardBackground];
    }
    
    if (flippedBool == YES) {
        self.myViewController.userSwipedFromFlippedView = YES;
        [self.myViewController flipCurrentView];
    } else
        self.myViewController.userSwipedFromFlippedView = NO;
    
    if (loadedCards.count == 0) {
        
        [swipesObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    // time-consuming task
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *message = [[NSString alloc] init];
                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                        if ([defaults boolForKey:@"today"]) {
                            
                            message = @"No more events today.\nLoading future events...";
                            
                        } else if ([defaults boolForKey:@"tomorrow"]) {
                            
                            message = @"No more events tomorrow.\nLoading future events...";
                            
                        } else {

                            message = @"No more events this weekend.\nLoading future events...";
                            
                        }
                        
                        [SVProgressHUD showWithStatus:message maskType:SVProgressHUDMaskTypeGradient];
                        [SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:14.0]];
                    });
                });
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noMoreEvents"];
                [self.myViewController refreshData];
            }
            
        }];
        
    } else {
        [swipesObject saveInBackground];
    }

    
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
    
    [dragView cardExpanded:!self.myViewController.frontViewIsVisible];
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //if (CGRectContainsPoint(self.dragView.bounds, [touch locationInView:self.dragView]))
    if (self.myViewController.frontViewIsVisible)
        return YES;
    
    return NO;
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
    PFObject *object = [query getObjectWithId:dragView.objectID];
    
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    EKEventViewController *evc = [[EKEventViewController alloc] init];
    
    event.title = dragView.title.text;

    event.startDate = object[@"Date"];
    event.endDate = object[@"EndTime"];

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
            event.location = dragView.location.text;
        
        
        //[RKDropdownAlert title:@"Event added to your main calendar!" backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        //[eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        //NSLog(@"Added %@ to calendar. Object ID: %@", dragView.title.text, dragView.objectID);
        
        [self.myViewController showEditEventVCWithEvent:event eventStore:eventStore];
    }];

}

- (void)shareAction {
    [self.myViewController shareAction];
}

- (void)createdByTap {
    [self.myViewController showCreatedByProfile];
}

- (NSMutableArray *) setCategories {
    
    NSMutableArray *categories = [[NSMutableArray alloc]init];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"nightlife"]) {
        [categories addObject:@"Nightlife"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"entertainment"]) {
        [categories addObject:@"Entertainment"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"music"]) {
        [categories addObject:@"Music"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dining"]) {
        [categories addObject:@"Dining"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"happyHour"]) {
        [categories addObject:@"Happy Hour"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"sports"]) {
        [categories addObject:@"Sports"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"shopping"]) {
        [categories addObject:@"Shopping"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"fundraiser"]) {
        [categories addObject:@"Fundraiser"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"meetup"]) {
        [categories addObject:@"Meetup"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"freebies"]) {
        [categories addObject:@"Freebies"];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"other"]) {
        [categories addObject:@"Other"];
    }
    
    
    
    return categories;
}

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
    UILabel *label;
    //label.text = text;
    //[label drawTextInRect:rect];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
