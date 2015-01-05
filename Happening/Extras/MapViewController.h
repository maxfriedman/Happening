//
//  MapViewController.h
//  Happening
//
//  Created by Max on 9/17/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UISearchDisplayDelegate/*, UISearchResultsUpdating*/>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocationManager *locManager;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;


@end
