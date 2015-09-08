//
//  LocationSearching.m
//  Happening
//
//  Created by Max on 10/6/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "LocationSearching.h"
#import "AppDelegate.h"

@interface LocationSearching () <UISearchDisplayDelegate, UISearchBarDelegate, /*UISearchResultsUpdating,*/ UISearchControllerDelegate, CLLocationManagerDelegate>

@end

@implementation LocationSearching {
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
}

@synthesize Event;
@synthesize delegate;
@synthesize locManager;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.searchDisplayController setDelegate:self];
    [self.searchBar setDelegate:self];
    Event = [PFObject objectWithClassName:@"Event"];
    
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
    
    cell.textLabel.text = item.name;
    NSString *cityName = item.placemark.addressDictionary[@"City"];
    NSString *stateName = item.placemark.addressDictionary[@"State"];
    NSString *zipCode = item.placemark.addressDictionary[@"ZIP"];
    NSString *country = item.placemark.addressDictionary[@"Country"];
    if (zipCode)
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ %@, %@", cityName, stateName, zipCode, country];
    else cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@", cityName, stateName, country];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchDisplayController setActive:NO animated:YES];
    
    NSLog(@"Location was selected");
    /*
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.item = results.mapItems[indexPath.row];
    Event[@"LocTitle"] = appDelegate.item.name;
    NSString *cityName = appDelegate.item.placemark.addressDictionary[@"City"];
    NSString *stateName = appDelegate.item.placemark.addressDictionary[@"State"];
    NSString *zipCode = appDelegate.item.placemark.addressDictionary[@"ZIP"];
    NSString *country = appDelegate.item.placemark.addressDictionary[@"Country"];
    if (zipCode)
        appDelegate.locSubtitle = [NSString stringWithFormat:@"%@, %@ %@, %@", cityName, stateName, zipCode, country];
    else appDelegate.locSubtitle = [NSString stringWithFormat:@"%@, %@, %@", cityName, stateName, country];

    PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:appDelegate.item.placemark.location];
    Event[@"GeoLoc"] = loc;
     */
    
    [self.delegate addItemViewController:self didFinishEnteringItem:results.mapItems[indexPath.row]];
    
    [self dismissViewControllerAnimated:YES completion:nil];

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
