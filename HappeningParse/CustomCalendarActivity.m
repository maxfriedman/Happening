//
//  CustomCalendarActivity.m
//  HappeningParse
//
//  Created by Max on 12/18/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "CustomCalendarActivity.h"

@implementation CustomCalendarActivity

@synthesize eventStore, draggableView;

- (NSString *)activityType
{
    return @"AddToCalendar";
}

- (NSString *)activityTitle
{
    return @"Add Event to Calendar";
}

- (UIImage *)activityImage
{
    // Note: These images need to have a transparent background and I recommend these sizes:
    // iPadShare@2x should be 126 px, iPadShare should be 53 px, iPhoneShare@2x should be 100
    // px, and iPhoneShare should be 50 px. I found these sizes to work for what I was making.
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return [UIImage imageNamed:@"calendar"];
    }
    else
    {
        return [UIImage imageNamed:@"calendar"];
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s", __FUNCTION__);
    return YES;
}


- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s",__FUNCTION__);
}

- (UIViewController *)activityViewController
{
    NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void)performActivity
{
    // This is where you can do anything you want, and is the whole reason for creating a custom UIActivity
    
    eventStore = [[EKEventStore alloc] init];
    
    [self checkEventStoreAccessForCalendar];
    
    [self activityDidFinish:YES];
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
    PFObject *object = [query getObjectWithId:draggableView.objectID];
    
    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
    
    event.title = draggableView.title.text;
    NSLog(@"Added %@ to calendar. Object ID: %@", draggableView.title.text, draggableView.objectID);
    
    event.startDate = object[@"Date"];
    event.endDate = object[@"EndTime"];
    
    //get address REMINDER 76597869876
    PFGeoPoint *geoPoint = object[@"GeoLoc"];
    CLLocation *eventLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    
    NSString *subtitle = draggableView.subtitle.text;
    NSString *description = object[@"Description"];
    
    if (description == nil)
        event.notes = [NSString stringWithFormat:@"%@ // %@", draggableView.location.text, subtitle];
    else
        event.notes = [NSString stringWithFormat:@"%@ // %@ // %@", draggableView.location.text, subtitle, description];
    
    
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
            event.location = draggableView.location.text;
        
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Event added to your main calendar!" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        NSLog(@"Event added to calendar!");
        
    }];
    
}

@end
