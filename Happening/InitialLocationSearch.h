//
//  InitialLocationSearch.h
//  HappeningParse
//
//  Created by Max on 11/7/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"

@interface InitialLocationSearch : UIViewController

//@property (nonatomic, weak) id <InitialLocationSearch> delegate;

@property (strong, nonatomic) CLLocationManager *locManager;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) PFObject *Event;

@end
