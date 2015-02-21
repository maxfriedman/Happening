//
//  SettingsChoosingLoc.h
//  Happening
//
//  Created by Max on 11/10/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@class SettingsChoosingLoc;

@protocol SettingsChoosingLocDelegate <NSObject>

- (void)refreshSettings;

@end

@interface SettingsChoosingLoc : UIViewController

@property (nonatomic, weak) id <SettingsChoosingLocDelegate> delegate;

@property (strong, nonatomic) CLLocationManager *locManager;

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) PFUser *user;

@end
