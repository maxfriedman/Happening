//
//  EventTVC.h
//  Happening
//
//  Created by Max on 9/15/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "CupertinoYankee.h"
#import "ExtraInfoTVC.h"

@protocol EventTVCDelegate <NSObject>

-(void)refreshMyEvents;

@end

@interface EventTVC: UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate, ExtraInfoTVCDelegate>

@property (nonatomic, weak) id<EventTVCDelegate> delegate;

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

//@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;

@property (strong, nonatomic) IBOutlet UITextField *urlField;

@property (strong, nonatomic) IBOutlet UITextField *descriptionField;

@property (strong, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (strong, nonatomic) IBOutlet UIButton *contactUsButton;

@end
