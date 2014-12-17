//
//  FlippedDVB.m
//  HappeningParse
//
//  Created by Max on 12/1/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "FlippedDVB.h"
#import <AddressBook/AddressBook.h>

@interface FlippedDVB ()

@property (nonatomic,strong) UIButton *wikipediaButton;

@end

@implementation FlippedDVB

-(void)didMoveToSuperview {
    
    for (id viewToRemove in [self subviews]){
        [viewToRemove removeFromSuperview];
    }
    
    UILabel *transpBackground = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 50)];
    transpBackground.backgroundColor = [UIColor blackColor];
    transpBackground.backgroundColor = [UIColor colorWithHue:1.0 saturation:0.0 brightness:0 alpha:0.5];
    [self addSubview:transpBackground];
    
    NSLog(@"Event ID: %@", self.eventID);
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 290, 50)];
    self.titleLabel.text = [NSString stringWithFormat:@"%@", self.eventTitle];
    
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:22];
    
    [self addSubview:self.titleLabel];

    NSArray *array = [[NSArray alloc]initWithObjects:@"Details", @"Map View", @"Tickets", nil];
    UISegmentedControl *segcontrol = [[UISegmentedControl alloc]initWithItems:array];
    segcontrol.frame = CGRectMake(0, 55, 290, 40);
    segcontrol.selectedSegmentIndex = 0;
    
    [segcontrol addTarget:self action:@selector(segAction:) forControlEvents: UIControlEventValueChanged];
    [self performSelector:@selector(segAction:) withObject:segcontrol];
    segcontrol.alpha = 0;
    [self addSubview:segcontrol];
    segcontrol.alpha = 1;

}

- (void)segAction:(UISegmentedControl *)segment {
    
    NSLog(@"Swithced to segment %ld", (long)segment.selectedSegmentIndex);
    
    if (segment.selectedSegmentIndex == 0)
    {
        //self.titleLabel.text = @"One";
        
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, 290, 220)];
        scrollView.contentSize = CGSizeMake(290, 700);
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:scrollView];
        
    } else if (segment.selectedSegmentIndex == 1)
    {
        //self.titleLabel.text = @"Two";
        
        MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 100, 290, 220)];
        mapView.delegate = self;
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
        [annotation setCoordinate:self.mapLocation.coordinate];
        [annotation setTitle:self.eventLocationTitle];
        
        [[[CLGeocoder alloc]init] reverseGeocodeLocation:self.mapLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = placemarks[0];
            
            NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
            NSString *addressString = [lines componentsJoinedByString:@" "];
            NSLog(@"Address: %@", addressString);
            
            NSString *streetName = placemark.addressDictionary[@"Street"];
            NSString *cityName = placemark.addressDictionary[@"City"];
            NSString *stateName = placemark.addressDictionary[@"State"];
            NSString *zipCode = placemark.addressDictionary[@"ZIP"];
            if (zipCode)
                annotation.subtitle = [NSString stringWithFormat:@"%@, %@ %@, %@", streetName, cityName, stateName, zipCode];
            else annotation.subtitle = [NSString stringWithFormat:@"%@, %@, %@", streetName, cityName, stateName];

        }];
        
        [mapView addAnnotation:annotation];
        [mapView viewForAnnotation:annotation];
        [mapView selectAnnotation:annotation animated:YES];
        
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapLocation.coordinate, 750, 750);
        [mapView setRegion:region animated:NO];
        [mapView setUserTrackingMode:MKUserTrackingModeNone];
        [mapView regionThatFits:region];
        
        [self addSubview:mapView];
        
    } else if (segment.selectedSegmentIndex == 2)
    {
        //self.titleLabel.text = @"Three";
        
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 100, 290, 220)];
        scrollView.contentSize = CGSizeMake(290, 700);
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:scrollView];
    }
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
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
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
}

- (void)setupUserInterface {
    
    self.viewController = nil;
    
    self.layer.cornerRadius = 4;
    self.layer.shadowRadius = 3;
    self.layer.shadowOpacity = 0.2;
    self.layer.shadowOffset = CGSizeMake(1, 1);
    
    CGRect buttonFrame = CGRectMake(10.0, 209.0, 234.0, 37.0);
    
    // create the button
    self.wikipediaButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.wikipediaButton.frame=buttonFrame;
    
    [self.wikipediaButton setTitle:@"Tickets on Eventbrite" forState:UIControlStateNormal];
    
    // Center the text on the button, considering the button's shadow
    self.wikipediaButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.wikipediaButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [self.wikipediaButton addTarget:self action:@selector(jumpToWikipedia:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.wikipediaButton];
}

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setAutoresizesSubviews:YES];
        [self setupUserInterface];
        
        // set the background color of the view to clearn
        self.backgroundColor=[UIColor groupTableViewBackgroundColor];
        
        // attach a tap gesture recognizer to this view so it can flip
        UITapGestureRecognizer *tapGestureRecognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)jumpToWikipedia:(id)sender {
    
    
}

- (void)drawRect:(CGRect)rect {
    
    //UIImage *backgroundImage = [UIImage imageNamed:@"Nightlife"];
    //CGRect elementSymbolRectangle = CGRectMake(50, 100, [backgroundImage size].width, [backgroundImage size].height);
    //[backgroundImage drawInRect:elementSymbolRectangle];

    
}

- (void)tapAction:(UIGestureRecognizer *)gestureRecognizer {
    
    // when a tap gesture occurs tell the view controller to flip this view to the
    // back and show the AtomicElementFlippedView instead
    [self.viewController flipCurrentView];
}


@end
