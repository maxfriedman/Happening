//
//  EditEventTVC.h
//  HappeningParse
//
//  Created by Max on 12/3/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"
#import "NSDate+CupertinoYankee.h"

@interface EditEventTVC : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property NSString *eventID;

@property (strong, nonatomic) IBOutlet UIButton *button;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@property (strong, nonatomic) IBOutlet UITextField *titleField;

@property (strong, nonatomic) IBOutlet UITextField *subtitleField;

@property (strong, nonatomic) IBOutlet UITextField *locationField;

@property (strong, nonatomic) PFObject *Event;

@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (strong, nonatomic) IBOutlet UIDatePicker *endTimePicker;

@property (strong, nonatomic) IBOutlet UIPickerView *hashtagPicker;

@property (strong, nonatomic) NSArray *hashtagData;

@property (strong, nonatomic) MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UILabel *locTitle;

@property (strong, nonatomic) IBOutlet UILabel *locSubtitle;

@property (strong, nonatomic) IBOutlet UIButton *imageButton;



@end
