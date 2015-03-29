//
//  DragMapViewController.m
//  Happening
//
//  Created by Max on 2/10/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "DragMapViewController.h"
#import <Parse/Parse.h>

@interface DragMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@end

@implementation DragMapViewController {
    MKPointAnnotation *annotation;
}

@synthesize mapView, directionsButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mapView.delegate = self;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:self.objectID block:^(PFObject *object, NSError *error) {
        
        PFGeoPoint *loc = object[@"GeoLoc"];
        CLLocation *mapLocation = [[CLLocation alloc]initWithLatitude:loc.latitude longitude:loc.longitude];
        
        annotation = [[MKPointAnnotation alloc]init];
        [annotation setCoordinate:mapLocation.coordinate];
        [annotation setTitle:self.locationTitle];
        [annotation setSubtitle:self.locationSubtitle];
        
        [mapView addAnnotation:annotation];
        [mapView viewForAnnotation:annotation];
        [mapView selectAnnotation:annotation animated:YES];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapLocation.coordinate, 1250, 1250);
        [mapView setRegion:region animated:NO];
        [mapView setUserTrackingMode:MKUserTrackingModeFollow];
        [mapView regionThatFits:region];
        
    }];
    

    directionsButton.layer.cornerRadius = 3.0;
    directionsButton.reversesTitleShadowWhenHighlighted = YES;
    directionsButton.layer.masksToBounds = YES;
    
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)anno
{
    NSLog(@"Made it 1");
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else  // use whatever annotation class you used when creating the annotation
    {
        NSLog(@"Made it 2");
        
        MKAnnotationView *annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"tag"];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:@"Annotation"];
        annotationView.centerOffset = CGPointMake(0, -18);
        //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
}

- (IBAction)redirectToMaps:(id)sender {
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    
    [[[CLGeocoder alloc]init] reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = placemarks[0];
        
        MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary: placemark.addressDictionary];
        
        MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
        destination.name = self.locationTitle;
        NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
        NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 MKLaunchOptionsDirectionsModeWalking,
                                 MKLaunchOptionsDirectionsModeKey, nil];
        [MKMapItem openMapsWithItems: items launchOptions: options];
    }];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)xButtonPress:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
