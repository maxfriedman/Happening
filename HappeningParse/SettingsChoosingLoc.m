//
//  SettingsChoosingLoc.m
//  HappeningParse
//
//  Created by Max on 11/10/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "SettingsChoosingLoc.h"

@interface SettingsChoosingLoc () <UISearchDisplayDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, CLLocationManagerDelegate>

@end

@implementation SettingsChoosingLoc {
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}

@synthesize user;
@synthesize delegate;
@synthesize locManager;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchDisplayController setDelegate:self];
    [self.searchBar setDelegate:self];
    user = [PFUser currentUser];
    
    if(self.locManager==nil){
        locManager = [[CLLocationManager alloc] init];
        locManager.delegate=self;
        //[locManager requestAlwaysAuthorization];
        locManager.desiredAccuracy=kCLLocationAccuracyBest;
        locManager.distanceFilter=50;
        
    }
    
    // Might want to delete this-- If I do, if someone decides to turn location services off, they will continue to get a message every time they launch the app...
    if([CLLocationManager locationServicesEnabled]){
        [self.locManager startUpdatingLocation];
        CLLocation *currentLocation = locManager.location;
        NSLog(@"Current Location is: %@", currentLocation);
    }
    
}

#pragma mark - Search Methods
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    
    // Cancel any previous searches.
    [localSearch cancel];
    
    // Perform a new search.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = MKCoordinateRegionMakeWithDistance(locManager.location.coordinate, 15000.0, 15000.0);
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        /*
         if (error != nil) {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Map Error",nil)
         message:[error localizedDescription]
         delegate:nil
         cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
         return;
         }
         
         if ([response.mapItems count] == 0) {
         [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results",nil)
         message:nil
         delegate:nil
         cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
         return;
         } */
        
        results = response;
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *IDENTIFIER = @"SearchResultsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:IDENTIFIER];
    }
    
    MKMapItem *item = results.mapItems[indexPath.row];
    user[@"userLocTitle"] = item.name;
    cell.textLabel.text = item.name;
    
    NSString *cityName = item.placemark.addressDictionary[@"City"];
    NSString *stateName = item.placemark.addressDictionary[@"State"];
    NSString *zipCode = item.placemark.addressDictionary[@"ZIP"];
    NSString *country = item.placemark.addressDictionary[@"Country"];
    
    if (zipCode) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ %@, %@", cityName, stateName, zipCode, country];
        user[@"userLocSubtitle"] = cell.detailTextLabel.text;
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@", cityName, stateName, country];
        user[@"userLocSubtitle"] = cell.detailTextLabel.text;
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController setActive:NO animated:YES];
    
    NSLog(@"Location was selected");
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.userLocation = results.mapItems[indexPath.row];
    PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:appDelegate.userLocation.placemark.location];
    user[@"userLoc"] = loc;
    [user saveInBackground];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    /*
     MKMapItem *item = results.mapItems[indexPath.row];
     [self.ibMapView addAnnotation:item.placemark];
     [self.ibMapView selectAnnotation:item.placemark animated:YES];
     
     [self.ibMapView setCenterCoordinate:item.placemark.location.coordinate animated:YES];
     
     [self.ibMapView setUserTrackingMode:MKUserTrackingModeNone];
     */
}

- (IBAction)didClick:(UIBarButtonItem *)sender {
    /*
     [self.delegate addItemViewController:self didFinishEnteringItem:item];
     LocationSearching *locationSearching = [[LocationSearching alloc]initWithNibName:@"LocationSearching" bundle:nil];
     locationSearching.delegate = self;
     */
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
