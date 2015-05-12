//
//  SettingsChoosingLoc.m
//  Happening
//
//  Created by Max on 11/10/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "SettingsChoosingLoc.h"
#import "RKDropdownAlert.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface SettingsChoosingLoc () <UISearchDisplayDelegate, UISearchBarDelegate, /*UISearchResultsUpdating,*/ UISearchControllerDelegate, CLLocationManagerDelegate>

@end

@implementation SettingsChoosingLoc {
    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;
    BOOL choseCurrentLoc;
}

@synthesize user;
@synthesize delegate;
@synthesize locManager;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    [super viewDidLoad];
    //[self.searchDisplayController setDelegate:self];
    [self.searchBar setDelegate:self];
    user = [PFUser currentUser];
    
    choseCurrentLoc = NO;
    
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
    
    /*
    NSIndexPath *ipzero = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cellzero = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:ipzero];
    cellzero.textLabel.text  = @"Current Location";
    */
    
    //self.searchDisplayController.searchResultsTableView.hidden = NO;
    //[self.searchDisplayController.searchResultsTableView.superview bringSubviewToFront:self.searchDisplayController.searchResultsTableView];
    //[self.searchDisplayController setActive:YES animated:YES];

    
}

-(void)viewDidLayoutSubviews{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
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
        
        results = response;
        
        [self.tableView reloadData];
        
        //[self.searchDisplayController.searchResultsTableView reloadData];
    }];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 3;
    }
    
    return [results.mapItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 1) {
    
        return 10;
    }
    
    return  0;
}


/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    

    return <#expression#>
}
 */


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"one"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"one"];
        }
        
        if (indexPath.row == 0) {
        
            cell.textLabel.text = @"Current Location";
            UIImage *im = [UIImage imageNamed:@"map pin"];
            //im.size = CGSizeMake(40, 40);
            cell.imageView.contentMode = UIViewContentModeCenter;
            //cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            cell.imageView.frame = CGRectMake(10, 10, cell.imageView.frame.size.width - 20, cell.imageView.frame.size.height - 20);
            cell.imageView.image = im;
            
        } else if (indexPath.row == 1) {
        
            cell.textLabel.text = @"Washington, DC";
            cell.imageView.image = [UIImage imageNamed:@"cities icon dc"];
            
        } else if (indexPath.row == 2) {
        
            cell.textLabel.text = @"Boston, MA";
            cell.imageView.image = [UIImage imageNamed:@"cities icon boston"];
        }

        CGSize itemSize = CGSizeMake(40, 40);
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"two"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"two"];
    }

    MKMapItem *item = results.mapItems[indexPath.row];
    cell.textLabel.text = item.name;
    
    NSString *cityName = item.placemark.addressDictionary[@"City"];
    NSString *stateName = item.placemark.addressDictionary[@"State"];
    NSString *zipCode = item.placemark.addressDictionary[@"ZIP"];
    NSString *country = item.placemark.addressDictionary[@"Country"];
    
    if (zipCode) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@ %@, %@", cityName, stateName, zipCode, country];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@", cityName, stateName, country];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //[self.searchBar. setActive:NO animated:YES];
    
    NSLog(@"Location was selected");

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            [self didChooseCurrentLoc];
            //[delegate refreshSettings];
            
        } else if (indexPath.row == 1) {
            
            user[@"userLocTitle"] = @"Washington, DC";
            [defaults setObject:@"Washington, DC" forKey:@"userLocTitle"];
            
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:38.907192 longitude:-77.036871];
            user[@"userLoc"] = geoPoint;

            [defaults synchronize];
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    NSLog(@"Saved user");
                    
                    
                    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                        
                        NSLog(@" ====== iOS 7 ====== ");
                        
                        [self dismissViewControllerAnimated:YES completion:^{
                            [delegate refreshSettings];
                            [delegate iOS7Touch];
                        }];

                    } else {
                        
                        [self dismissViewControllerAnimated:YES completion:^{
                            [delegate refreshSettings];
                        }];
                    }
                    
                }
            }];
            
        } else if (indexPath.row == 2) {
            
            user[@"userLocTitle"] = @"Boston, MA";
            [defaults setObject:@"Boston, MA" forKey:@"userLocTitle"];
            
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:42.358431 longitude:-71.059773];
            user[@"userLoc"] = geoPoint;
            
            [defaults synchronize];
            
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    NSLog(@"Saved user");
                    
                    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                        
                        NSLog(@" ====== iOS 7 ====== ");
                        
                        [self dismissViewControllerAnimated:YES completion:^{
                            [delegate refreshSettings];
                            [delegate iOS7Touch];
                        }];
                        
                    } else {
                        
                        [self dismissViewControllerAnimated:YES completion:^{
                            [delegate refreshSettings];
                        }];
                    }
                }
            }];
            
        }
        
        user[@"userLocSubtitle"] = @"";
        [defaults setObject:@"" forKey:@"userLocSubtitle"];
        
    } else {
    
        MKMapItem *item = results.mapItems[indexPath.row];
        user[@"userLocTitle"] = item.name;
        [defaults setObject:item.name forKey:@"userLocTitle"];
    
        NSString *cityName = item.placemark.addressDictionary[@"City"];
        NSString *stateName = item.placemark.addressDictionary[@"State"];
        NSString *zipCode = item.placemark.addressDictionary[@"ZIP"];
        NSString *country = item.placemark.addressDictionary[@"Country"];
    
        NSString *subtitle;
        if (zipCode) {
            subtitle = [NSString stringWithFormat:@"%@, %@ %@, %@", cityName, stateName, zipCode, country];
        } else {
            subtitle= [NSString stringWithFormat:@"%@, %@, %@", cityName, stateName, country];
        }

        user[@"userLocSubtitle"] = subtitle;
        [defaults setObject:subtitle forKey:@"userLocSubtitle"];
    
        MKMapItem *userLocation = results.mapItems[indexPath.row];
        PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:userLocation.placemark.location];
        user[@"userLoc"] = loc;
    
        [user saveInBackground];
        [defaults synchronize];
        [delegate refreshSettings];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)didChooseCurrentLoc {

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Uh-oh" message:@"You've disabled using your current location for Happening. To change this, please go to Settings -> Happening -> Location -> While Using the App" delegate:self cancelButtonTitle:@"I'm on it!" otherButtonTitles:nil, nil];
        [alert show];
        
    } else if (![CLLocationManager locationServicesEnabled]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Uh-oh" message:@"Please turn on your location services! Go to Settings -> Privacy -> Location Services -> On" delegate:self cancelButtonTitle:@"I'm on it!" otherButtonTitles:nil, nil];
        [alert show];
        
    } else if(self.locManager==nil){
        
        choseCurrentLoc = YES;
        locManager = [[CLLocationManager alloc] init];
        locManager.delegate=self;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            
            NSLog(@" ====== iOS 8 ====== ");
            [locManager requestWhenInUseAuthorization];
        }
        
        locManager.desiredAccuracy=kCLLocationAccuracyBest;
        locManager.distanceFilter=50;
        [locManager startUpdatingLocation];
        
    } else {
        
        NSLog(@"User already enabled current loc and location services are on");
        choseCurrentLoc = YES;
        locManager = [[CLLocationManager alloc] init];
        locManager.delegate = self;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            
            NSLog(@" ====== iOS 8 ====== ");
            [locManager requestWhenInUseAuthorization];
        }
        
        locManager.desiredAccuracy=kCLLocationAccuracyBest;
        locManager.distanceFilter=50;
        [locManager startUpdatingLocation];

        
        //[self dismissViewControllerAnimated:YES completion:nil];

        
        // peace out -- already authorized CL
        // Never show this again
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunched"];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        //[delegate setLocationSegue];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusAuthorizedAlways) {
        
        //[delegate setLocationSegue];
        NSLog(@"Location status changed");
        [self.locManager startUpdatingLocation];
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    if (choseCurrentLoc) {
        
        NSLog(@"Location updated");
        
        PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:locManager.location];
        user[@"userLoc"] = loc;
        user[@"userLocTitle"] = @"Current Location";
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                NSLog(@"Saved user");
                
                // Peace out!
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                //[defaults setBool:YES forKey:@"hasLaunched"];
                [defaults setObject:@"Current Location" forKey:@"userLocTitle"];
                [defaults setObject:@"" forKey:@"userLocSubtitle"];
                [defaults synchronize];
                
                
                if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
                    
                    NSLog(@" ====== iOS 7 ====== ");
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        [delegate refreshSettings];
                        [delegate iOS7Touch];
                    }];
                    
                } else {
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                        [delegate refreshSettings];
                    }];
                }
                
            }
        }];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
        
        return 54;
    }
    
    return 44;
    
}


- (IBAction)didClick:(UIBarButtonItem *)sender {
    /*
     [self.delegate addItemViewController:self didFinishEnteringItem:item];
     LocationSearching *locationSearching = [[LocationSearching alloc]initWithNibName:@"LocationSearching" bundle:nil];
     locationSearching.delegate = self;
     */
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunched"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    
    } else {
        [RKDropdownAlert title:@"Hey there" message:@"Please choose a location before continuing" backgroundColor:[UIColor redColor] textColor:[UIColor whiteColor]];
    }
    
}

@end
