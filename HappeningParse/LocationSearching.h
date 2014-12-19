//
//  LocationSearching.h
//  Happening
//
//  Created by Max on 10/6/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@class LocationSearching;

@protocol LocationSearchingDelegate <NSObject>

- (void)addItemViewController:(LocationSearching *)controller didFinishEnteringItem:(MKMapItem *)item;

@end

@interface LocationSearching : UIViewController

@property (nonatomic, weak) id <LocationSearchingDelegate> delegate;

@property (strong, nonatomic) CLLocationManager *locManager;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) PFObject *Event;

@end
