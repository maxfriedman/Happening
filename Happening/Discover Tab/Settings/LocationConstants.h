//
//  LocationConstants.h
//  Happening
//
//  Created by Max on 7/27/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationConstants : NSObject

- (CLLocation *)getLocForCity:(NSString *)cityString;

- (CLLocation *)getBostonLoc;
- (CLLocation *)getDCLoc;
- (CLLocation *)getNashvilleLoc;
- (CLLocation *)getSanFranLoc;
- (CLLocation *)getPhillyLoc;

- (NSArray *)getCityNamesArray;
- (NSArray *)getCityImagesArray;

@end
