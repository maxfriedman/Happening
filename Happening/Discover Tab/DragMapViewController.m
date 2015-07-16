//
//  DragMapViewController.m
//  Happening
//
//  Created by Max on 2/10/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "DragMapViewController.h"
#import <Button/Button.h>

@interface DragMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@end

@implementation DragMapViewController {
    MKPointAnnotation *annotation;
}

@synthesize mapView, directionsButton, event;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mapView.delegate = self;
    
    PFGeoPoint *geoPoint = event[@"GeoLoc"];
    
    CLLocation *mapLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    annotation = [[MKPointAnnotation alloc]init];
    [annotation setCoordinate:mapLocation.coordinate];
    [annotation setTitle:self.locationTitle];
    [annotation setSubtitle:self.locationSubtitle];
    
    [mapView addAnnotation:annotation];
    [mapView viewForAnnotation:annotation];
    [mapView selectAnnotation:annotation animated:YES];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(mapLocation.coordinate, 1250, 1250);
    [mapView setRegion:region animated:NO];
    //[mapView setUserTrackingMode:MKUserTrackingModeFollow];
    [mapView regionThatFits:region];

    directionsButton.layer.cornerRadius = 3.0;
    directionsButton.reversesTitleShadowWhenHighlighted = YES;
    directionsButton.layer.masksToBounds = YES;
    
    BTNDropinButton *uberBTN =[[BTNDropinButton alloc] initWithButtonId:@"btn-0acf02149a673eb6"];
    
    NSString *locationText = [NSString stringWithString:self.locationTitle];
    locationText = [locationText stringByReplacingOccurrencesOfString:@"at " withString:@""];
    
    BTNVenue *venue = [BTNVenue venueWithId:@"abc123" venueName:locationText latitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    [uberBTN setFrame:CGRectMake(0, 0, 175, 30)];
    uberBTN.center = CGPointMake(self.view.center.x, directionsButton.center.y + 45);
    
    [[BTNDropinButton appearance] setBorderColor:[UIColor blackColor]];
    
    [uberBTN prepareForDisplayWithVenue:venue completion:^(BOOL isDisplayable) {
        if (isDisplayable) {
            [self.view addSubview:uberBTN];
        }
    }];
    
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
        annotationView.frame = CGRectMake(0, 0, 20, 25);
        annotationView.centerOffset = CGPointMake(0, -5);
        //annotationView.calloutOffset = CGPointMake(10, 0);
        //annotationView.layer.anchorPoint = CGPointMake(0.5f, 1.0f);

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

    [[BTNDropinButton appearance] setBorderColor:[UIColor clearColor]];

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
