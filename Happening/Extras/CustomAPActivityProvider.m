//
//  CustomAPActivityProvider.m
//  Happening
//
//  Created by Max on 7/9/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "CustomAPActivityProvider.h"

@implementation CustomAPActivityProvider

@synthesize eventObject;

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    
    PFUser *user = [PFUser currentUser];
    
    NSString *title = eventObject[@"Title"];
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
    
    eventTimeString = [NSString stringWithFormat:@"at %@", startTimeString];
    
    
    NSString *shareText = [[NSString alloc]init];
    //if ([description isEqualToString:@""] || description == nil) {
    shareText = [NSString stringWithFormat:@"Check out this awesome event: %@ at %@ on %@ %@ // ", title, loc, dateString, eventTimeString];
    /*
     } else {
     shareText = [NSString stringWithFormat:@"Check out this awesome event: %@, %@ at %@ on %@ %@", title, description, loc, dateString, eventTimeString];
     } */
    
    NSLog(@"%@", shareText);
    
    [user addObject:eventObject.objectId forKey:@"sharedEvents"];
    [user saveEventually];
    
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


@end
