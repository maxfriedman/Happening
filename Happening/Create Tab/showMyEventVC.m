//
//  showMyEventVC.m
//  Happening
//
//  Created by Max on 12/2/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "showMyEventVC.h"
#import "FXBlurView.h"
#import "webViewController.h"

@interface showMyEventVC ()

@end

@implementation showMyEventVC {
    DraggableView *dragView;
    FlippedDVB *flippedView;
    NSString *urlString;
    NSString *urlTitleString;
}

@synthesize segControl, notInterestedLabel, interestedLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.eventIDLabel.text = self.eventID;
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [dragView removeFromSuperview];
    [flippedView removeFromSuperview];
    
    dragView = [[DraggableView alloc] initWithFrame:CGRectMake(0, 0, 284, 310)];
    dragView.center = CGPointMake(160, 173);
    dragView.swipeDownMargin = 10000;
    dragView.actionMargin = 10000;
    [self loadDragView];
    [self.view addSubview:dragView];
    
    UIButton *eventURLButton = [[UIButton alloc] init];
    NSString *myUrlString = [NSString stringWithFormat: @"www.happening.city/events/%@", self.eventID];
    [eventURLButton setTitle:myUrlString forState:UIControlStateNormal];
    [eventURLButton sizeToFit];
    eventURLButton.center = CGPointMake(160, 340);
    eventURLButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:12.0];
    [eventURLButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    eventURLButton.reversesTitleShadowWhenHighlighted = YES;
    [eventURLButton addTarget:self action:@selector(eventURLPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:eventURLButton];
    [self.view sendSubviewToBack:eventURLButton];
    
}

-(void)eventURLPressed {
    
    // IN APP EXPERIENCE
    
    /*
     UIWebView *webView = [[UIWebView alloc] init];
     [webView setFrame:CGRectMake(0, 0, 320, 460)];
     [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gethappeningapp.com"]]];
     [[self view] addSubview:webView];
     */
    
    // OPENS IN SAFARI
    
    urlString = [NSString stringWithFormat: @"http://www.happening.city/events/%@", self.eventID];
    urlTitleString = dragView.title.text;
    [self performSegueWithIdentifier:@"toWebVC" sender:self];
    
    //NSURL *url = [[NSURL alloc] initWithString:urlString];
    //[[UIApplication sharedApplication] openURL:url];
    
}

- (void)loadDragView {
    
    dragView.userInteractionEnabled = NO;
    dragView.cardBackground.hidden = YES;
    dragView.overlayView.hidden = YES;
    
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
        
        dragView.subtitle.text = event[@"Description"];
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
                
                FXBlurView *blurView = [[FXBlurView alloc]initWithFrame:dragView.blurEffectView.frame];
                [dragView.eventImage addSubview:blurView];
                blurView.dynamic = NO;
                blurView.blurRadius = 50;
            }
            
        }];
        
        dragView.userImage.image = [UIImage imageNamed:@"interested_face"];
        
        dragView.userInteractionEnabled = YES;
        
        if (!error) {
             NSLog(@"Successfully loaded user's event. ID: %@ || NAME: %@", self.eventID, dragView.title.text);
            
            [self loadFlippedView];
            
        } else {
            NSLog(@"ERROR SHOWING EVENT: %@", error);
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Something went wrong :(" message:@"Event cannot be viewed, please check your internet connection and try again." delegate:self cancelButtonTitle:@"That's odd" otherButtonTitles:nil, nil];
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
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Something went wrong :(" message:@"Event cannot be viewed, please check your internet connection and try again." delegate:self cancelButtonTitle:@"That's odd" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }];
    
}

- (IBAction)websiteButtonTapped:(id)sender {
    
    urlString = @"http://www.happening.city";
    urlTitleString = @"Happening";
    [self performSegueWithIdentifier:@"toWebVC" sender:self];
    
    // IN APP EXPERIENCE
    
    /*
    UIWebView *webView = [[UIWebView alloc] init];
    [webView setFrame:CGRectMake(0, 0, 320, 460)];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://gethappeningapp.com"]]];
    [[self view] addSubview:webView];
     */
    
    
}
- (IBAction)xButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self.profileVC showNavTitle];
    }];
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
     
     } else if ([segue.identifier isEqualToString:@"toWebVC"]) {
         
         webViewController* vc = (webViewController *)[[segue destinationViewController] topViewController];
         vc.urlString = urlString;
         vc.titleString = urlTitleString;
     }
 }

@end
