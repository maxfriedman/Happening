//
//  ViewController.m
//  HappeningParse
//
//  Created by Max on 9/6/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "ViewController.h"
#import "DraggableViewBackground.h"
#import <Parse/Parse.h>


@interface ViewController ()

@end

@implementation ViewController

@synthesize shareButton;

- (void)viewDidLoad {
    [super viewDidLoad];

}

-(void)viewWillAppear:(BOOL)animated {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Refresh only if there was a change in preferences or the app has loaded for the first time.
    if ([defaults boolForKey:@"refreshData"]) {

        UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.center=self.view.center;
        [activityView startAnimating];
        [self.view addSubview:activityView];
    
        DraggableViewBackground *draggableBackground = [[DraggableViewBackground alloc]initWithFrame:self.view.frame];
        
        [self.view addSubview:draggableBackground];
    
        [activityView stopAnimating];
        
        [defaults setBool:NO forKey:@"refreshData"];
        [defaults synchronize];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareAction:(id)sender {
    
    APActivityProvider *ActivityProvider = [[APActivityProvider alloc] init];
    
    NSURL *myWebsite = [NSURL URLWithString:@"http://www.gethappeningapp.com/"];
    NSArray *itemsToShare = @[ActivityProvider, myWebsite];
        
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:itemsToShare applicationActivities:nil];
    
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
             
             UIAlertView *Alert = [[UIAlertView alloc] initWithTitle:ServiceMsg message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [Alert show];
         }
     }];
    
}

@end

@implementation APActivityProvider

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    DraggableViewBackground *draggableView = [[DraggableViewBackground alloc]init];
    
    PFUser *user = [PFUser currentUser];
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    // Sorts the query by most recent event and only shows those after today's date
    [eventQuery orderByAscending:@"Date"];
    [eventQuery whereKey:@"Date" greaterThan:[NSDate date]];
    
    PFQuery *didUserSwipe = [PFQuery queryWithClassName:@"Swipes"];
    [didUserSwipe whereKey:@"UserID" containsString:user.username];
    
    [eventQuery whereKey:@"objectId" doesNotMatchKey:@"EventID" inQuery:didUserSwipe];
    
    NSArray *eventArray = [[NSArray alloc]init];
    eventArray = [eventQuery findObjects];
    PFObject *eventObject = eventArray[draggableView.storedIndex];
    
    NSString *title = eventObject[@"Title"];
    NSString *subtitle = eventObject[@"Subtitle"];
    NSString* loc = eventObject[@"Location"];
    
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
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @""; }
@end


