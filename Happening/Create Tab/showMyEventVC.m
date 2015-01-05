//
//  showMyEventVC.m
//  Happening
//
//  Created by Max on 12/2/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "showMyEventVC.h"

@interface showMyEventVC ()

@end

@implementation showMyEventVC {
    DraggableView *dragView;
    FlippedDVB *flippedView;
}

@synthesize segControl, notInterestedLabel, interestedLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.eventIDLabel.text = self.eventID;
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [dragView removeFromSuperview];
    [flippedView removeFromSuperview];
    
    dragView = [[DraggableView alloc] initWithFrame:CGRectMake(0, 0, 290, 320)];
    dragView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - 40);
    dragView.swipeDownMargin = 10000;
    dragView.actionMargin = 10000;
    [self loadDragView];
    [self.view addSubview:dragView];
    
    flippedView = [[FlippedDVB alloc]initWithFrame:CGRectMake(0, 0, 290, 320)];
    flippedView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 - 40);
    flippedView.actionMargin = 10000;
    flippedView.swipeDownMargin = 10000;
    
    flippedView.hidden = YES;
    
}


- (void)loadDragView {
    
    dragView.userInteractionEnabled = NO;
    dragView.cardBackground.hidden = YES;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *event, NSError *error) {
        
        notInterestedLabel.format = @"%d";
        interestedLabel.format = @"%d";
        
        float notInterestedFloat = [event[@"swipesLeft"] floatValue];
        float interestedFloat = [event[@"swipesRight"] floatValue];
        
        if (notInterestedFloat < 5 || interestedFloat < 5) {
            
            notInterestedLabel.animationDuration = 0.5;
            interestedLabel.animationDuration = 0.5;
        } else if (notInterestedFloat < 20 || interestedFloat < 20) {
            
            notInterestedLabel.animationDuration = 1.2;
            interestedLabel.animationDuration = 1.2;
        }
        
        
        [notInterestedLabel countFromZeroTo:notInterestedFloat];
        
        [interestedLabel countFromZeroTo:interestedFloat];
        
        dragView.title.text = event[@"Title"];
        self.navigationItem.title = dragView.title.text;
        
        dragView.subtitle.text = event[@"Subtitle"];
        dragView.location.text = event[@"Location"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEE, MMM d"];
        NSDate *eventDate = [[NSDate alloc]init];
        eventDate = event[@"Date"];
        
        if ([eventDate beginningOfDay] == [[NSDate date]beginningOfDay]) {  // TODAY
            
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            NSString *finalString = [NSString stringWithFormat:@"Today at %@", timeString];
            dragView.date.text = finalString;
            
        } else if ([eventDate beginningOfDay] == [[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]) { // TOMORROW
            
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            NSString *finalString = [NSString stringWithFormat:@"Tomorrow at %@", timeString];
            dragView.date.text = finalString;
            
        } else if ([eventDate endOfWeek] == [[NSDate date]endOfWeek]) { // SAME WEEK
            
            [formatter setDateFormat:@"EEEE"];
            NSString *dayOfWeekString = [formatter stringFromDate:eventDate];
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            NSString *finalString = [NSString stringWithFormat:@"%@ at %@", dayOfWeekString, timeString];
            dragView.date.text = finalString;
            
        } else {
            
            NSString *dateString = [formatter stringFromDate:eventDate];
            [formatter setDateFormat:@"h:mma"];
            NSString *timeString = [formatter stringFromDate:eventDate];
            NSString *finalString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
            dragView.date.text = finalString;
        }
        
        NSString *tagString = [NSString stringWithFormat:@"tags: %@", event[@"Hashtag"]];
        dragView.hashtag.text = tagString;
        
        PFGeoPoint *loc = event[@"GeoLoc"];
        PFUser *user = [PFUser currentUser];
        PFGeoPoint *userLoc = user[@"userLoc"];
        NSNumber *miles = [NSNumber numberWithDouble:([loc distanceInMilesTo:userLoc])];
        if ([miles integerValue] > 10) {
            NSString *distance = [NSString stringWithFormat:(@"%ld mi"), (long)miles.integerValue];
            dragView.geoLoc.text = distance;
        } else {
            NSString *distance = [NSString stringWithFormat:(@"%.1f mi"), miles.floatValue];
            dragView.geoLoc.text = distance;
        }
        
        NSNumber *swipe = event[@"swipesRight"];
        NSString *swipeString = [NSString stringWithFormat:@"%@ interested", [swipe stringValue]];
        
        dragView.swipesRight.text = swipeString;
        
        NSString *name = event[@"CreatedByName"];
        NSString *fullName = [NSString stringWithFormat:@"Created by: %@", name];
        dragView.createdBy.text = fullName;
        
        dragView.locImage.image = [UIImage imageNamed:@"locationPinThickOutline"];
        
        PFFile *imageFile = event[@"Image"];
        [imageFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                dragView.eventImage.image = [UIImage imageWithData:imageData];
            }
            
        }];
        
        dragView.userImage.image = [UIImage imageNamed:@"interested_face"];
        
        dragView.userInteractionEnabled = YES;
        
        if (!error) {
             NSLog(@"Successfully loaded user's event. ID: %@ || NAME: %@", self.eventID, dragView.title.text);
            
            [self loadFlippedView];
            
        } else {
            NSLog(@"ERROR SHOWING EVENT: %@", error);
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Something went wrong :(" message:@"Event cannot be viewed, please check your internet connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }

    }];
}



- (IBAction)segAction:(UISegmentedControl *)segment {
    
    NSLog(@"Switched to segment %ld", (long)segment.selectedSegmentIndex);
    
    if (segment.selectedSegmentIndex == 0)
    {
        flippedView.hidden = YES;
        dragView.hidden = NO;
        
    } else {
        
        dragView.hidden = YES;
        flippedView.hidden = NO;
        
    }
    
}
- (void)loadFlippedView {
    
    flippedView.userInteractionEnabled = NO;
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:self.eventID block:^(PFObject *event, NSError *error) {
        
        flippedView.eventTitle = dragView.title.text;
        PFGeoPoint *loc = event[@"GeoLoc"];
        flippedView.mapLocation = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
        flippedView.eventLocationTitle = dragView.location.text;
        flippedView.userInteractionEnabled = YES;
        
        if (!error) {
            NSLog(@"Successfully loaded Flipped View. ID: %@ || NAME: %@", self.eventID, dragView.title.text);
            [self.view addSubview:flippedView];
        } else {
            NSLog(@"ERROR SHOWING EVENT: %@", error);
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Something went wrong :(" message:@"Event cannot be viewed, please check your internet connection and try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }];
    
}

- (IBAction)websiteButtonTapped:(id)sender {
    
    // IN APP EXPERIENCE
    
    /*
    UIWebView *webView = [[UIWebView alloc] init];
    [webView setFrame:CGRectMake(0, 0, 320, 460)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gethappeningapp.com"]]];
    [[self view] addSubview:webView];
     */
    
    // OPENS IN SAFARI
    
    NSURL *url = [[NSURL alloc] initWithString:@"http://gethappeningapp.com"];
    [[UIApplication sharedApplication] openURL:url];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if ([segue.identifier isEqualToString:@"toEditEvent"]) {
         
         // Pass along variables
         //self.editEventTVC.eventID = self.eventID;
         
         EditEventTVC* vc = (EditEventTVC *)[[segue destinationViewController] topViewController];
         [vc setEventID:self.eventID];
     
     }
 }

@end
