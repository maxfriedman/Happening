//
//  LocationConstants.m
//  Happening
//
//  Created by Max on 7/27/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "LocationConstants.h"

@implementation LocationConstants

- (NSArray *)getCityNamesArray {
    
    return @[@"Washington, DC", @"Boston, MA", @"Nashville, TN", @"Philadelphia, PA", @"San Francisco, CA"];
}

-(NSArray *)getCityImagesArray {
 
    return @[[UIImage new], [UIImage new], [UIImage new], [UIImage new], [UIImage new]]; //@[[UIImage imageNamed:@"cities icon dc"], [UIImage imageNamed:@"cities icon boston"], [UIImage new], [UIImage new], [UIImage new]];
}

- (CLLocation *)getLocForCity:(NSString *)cityString {
    
    if ([cityString isEqualToString:@"Washington, DC"]) return [self getDCLoc];
    else if ([cityString isEqualToString:@"Boston, MA"]) return [self getBostonLoc];
    else if ([cityString isEqualToString:@"Nashville, TN"]) return [self getNashvilleLoc];
    else if ([cityString isEqualToString:@"Philadelphia, PA"]) return [self getPhillyLoc];
    else if ([cityString isEqualToString:@"San Francisco, CA"]) return [self getSanFranLoc];

    return nil;
}

- (CLLocation *)getBostonLoc {
 
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:42.358431 longitude:-71.059773];
    return loc;
}

- (CLLocation *)getDCLoc {
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:38.907192 longitude:-77.036871];
    return loc;
}

- (CLLocation *)getNashvilleLoc {
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:36.162664 longitude:-86.781602];
    return loc;
}

- (CLLocation *)getPhillyLoc {
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:39.952584 longitude:-75.165222];
    return loc;
}

- (CLLocation *)getSanFranLoc {
    
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:37.774929 longitude:-122.419416];
    return loc;
}

- (BOOL)isUserLocInBoxForCity:(NSString *)cityString withRadius:(float)radius{
    
    CLLocation *CLLoc = [self getLocForCity:cityString];
    CLLocationCoordinate2D loc = CLLoc.coordinate;
    
    float milesToLat = 69;
    //float milesToLong = 45;
    
    //Position, decimal degrees
    
    //Earth’s radius, sphere
    float earthRadius = 6378137.0;
    
    //offsets in meters
    float dn = radius * 1609.344;
    float de = radius * 1609.344;
    
    //Coordinate offsets in radians
    float dLat = dn/earthRadius;
    float dLon = de/(earthRadius*cosf(M_PI*loc.latitude/180));
    
    //OffsetPosition, decimal degrees
    float lat1 = loc.latitude - dLat * 180/M_PI;
    float lon1 = loc.longitude - dLon * 180/M_PI;
    
    float lat2 = loc.latitude + dLat * 180/M_PI;
    float lon2 = loc.longitude + dLon * 180/M_PI;
    
    float blah = cosf(loc.latitude) * 69;
    
    //PFGeoPoint *swc = [PFGeoPoint geoPointWithLatitude:lat1 longitude:lon1];
    //PFGeoPoint *nwc = [PFGeoPoint geoPointWithLatitude:lat2 longitude:lon2];
    
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
    
    CLLocation *theUserLoc = [[CLLocation alloc] initWithLatitude:loc.latitude longitude:loc.longitude];
    
    CLLocationDistance distance1 = [locA distanceFromLocation:theUserLoc];
    CLLocationDistance distance2 = [locB distanceFromLocation:theUserLoc];
    
    NSLog(@"%f", distance1);
    NSLog(@"%f", distance2);
    
    
    return NO;
}

@end
