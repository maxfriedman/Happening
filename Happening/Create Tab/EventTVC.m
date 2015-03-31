//
//  EventTVC.m
//  Happening
//
//  Created by Max on 9/15/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "EventTVC.h"
#import "RKDropdownAlert.h"

@interface EventTVC () <UITextViewDelegate>

@property (assign) NSInteger datePickerHeight;
@property (assign) NSInteger endTimePickerHeight;
@property (assign) NSInteger hashtagPickerHeight;

@property (assign) BOOL isDatePickerShown;
@property (assign) BOOL isEndTimePickerShown;
@property (assign) BOOL isHashtagPickerShown;

@property (strong, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) IBOutlet UIButton *endTimeButton;
@property (strong, nonatomic) IBOutlet UIButton *hashtagButton;

@property (strong, nonatomic) IBOutlet UILabel *dateDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *endTimeDetailLabel;
@property (strong, nonatomic) IBOutlet UILabel *hashtagDetailLabel;

@end

@implementation EventTVC {
    NSDateFormatter *dateFormatter;
    int intervalInSeconds;
    MKMapItem *item;
    
    int repeatsInt;
    NSString *urlString;
    NSString *descriptionString;
    NSString *emailString;
    NSString *createdByNameString;
    int frequencyInt;
    
    BOOL ticks;
    BOOL isFree;
}

@synthesize imageView, button;
@synthesize cancelButton;

@synthesize Event;

@synthesize titleField, locationField;

@synthesize endTimePicker, datePicker;

@synthesize hashtagPicker, hashtagData;

@synthesize mapView = _mapView;

@synthesize locSubtitle, locTitle;

@synthesize imageButton;

@synthesize dateButton, endTimeButton, hashtagButton;

@synthesize dateDetailLabel, endTimeDetailLabel, hashtagDetailLabel;

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    intervalInSeconds = 3600;
    
    locTitle.text = @"";
    locSubtitle.font = [locSubtitle.font fontWithSize:17.0];
    locSubtitle.alpha = 0.2;
    
    datePicker.alpha = 0;
    endTimePicker.alpha = 0;
    hashtagPicker.alpha = 0;
    
    self.datePickerHeight = 0;
    self.endTimePickerHeight = 0;
    self.hashtagPickerHeight = 0;
    
    self.isDatePickerShown = NO;
    self.isEndTimePickerShown = NO;
    self.isHashtagPickerShown = NO;
    
    dateButton.tintColor = [UIColor whiteColor];
    endTimeButton.tintColor = [UIColor whiteColor];
    hashtagButton.tintColor = [UIColor whiteColor];
    
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE, MMM d    h:mm a"];
    
    NSLog(@"Event being created...");
    
    PFUser *user = [PFUser currentUser];
    Event = [PFObject objectWithClassName:@"Event"];
    
    NSString *firstName = user[@"firstName"];
    NSString *lastName = user[@"lastName"];
    createdByNameString = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    
    urlString = @"";
    repeatsInt = 0;
    frequencyInt = 1;
    descriptionString = @"";
    isFree = NO;
    ticks = NO;
    
    if (user.email != nil) {
        emailString = user.email;
    } else {
        emailString = @"";
    }
    
    Event[@"Hashtag"] = @"Nightlife";
    Event[@"Repeats"] = @"Never";
    Event[@"CreatedBy"] = user.objectId;
    Event[@"CreatedByName"] = createdByNameString;
}

- (IBAction)dateButtonAction:(id)sender {
    
    if (!self.isDatePickerShown) { // Picker hidden, let's show it!
        self.datePickerHeight = 162;
        datePicker.alpha = 1;
        self.endTimePickerHeight = 0;
        endTimePicker.alpha = 0;
        self.hashtagPickerHeight = 0;
        hashtagPicker.alpha = 0;
        [self.tableView reloadData];
        
        self.isDatePickerShown = YES;
        self.isEndTimePickerShown = NO;
        self.isHashtagPickerShown = NO;
        
        dateDetailLabel.textColor = [UIColor redColor];
        endTimeDetailLabel.textColor = [UIColor blackColor];
        if (![hashtagDetailLabel.text isEqualToString:@"Nightlife"])
            hashtagDetailLabel.textColor = [UIColor blackColor];

    } else { // Picker shown, let's hide it
        self.datePickerHeight = 0;
        datePicker.alpha = 0;
        [self.tableView reloadData];
        self.isDatePickerShown = NO;
        dateDetailLabel.textColor = [UIColor blackColor];
    }
    
}

- (IBAction)endTimeButtonAction:(id)sender {
    
    if (!self.isEndTimePickerShown) { // Picker hidden, let's show it!
        
        self.endTimePickerHeight = 162;
        endTimePicker.alpha = 1;
        self.datePickerHeight = 0;
        datePicker.alpha = 0;
        self.hashtagPickerHeight = 0;
        hashtagPicker.alpha = 0;
        [self.tableView reloadData];
        
        self.isEndTimePickerShown = YES;
        self.isDatePickerShown = NO;
        self.isHashtagPickerShown = NO;
        
        endTimeDetailLabel.textColor = [UIColor redColor];
        dateDetailLabel.textColor = [UIColor blackColor];
        if (![hashtagDetailLabel.text isEqualToString:@"Nightlife"])
            hashtagDetailLabel.textColor = [UIColor blackColor];

    } else { // Picker shown, let's hide it
        self.endTimePickerHeight = 0;
        endTimePicker.alpha = 0;
        [self.tableView reloadData];
        self.isEndTimePickerShown = NO;
        endTimeDetailLabel.textColor = [UIColor blackColor];
    }
    
}

- (IBAction)hashtagButtonAction:(id)sender {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hashtagDetailLabel.text = @"Nightlife";
    });
    
    if (!self.isHashtagPickerShown) { // Picker hidden, let's show it!
        
        self.hashtagPickerHeight = 162;
        hashtagPicker.alpha = 1;
        self.endTimePickerHeight = 0;
        endTimePicker.alpha = 0;
        self.datePickerHeight = 0;
        datePicker.alpha = 0;
        [self.tableView reloadData];
        
        self.isHashtagPickerShown = YES;
        self.isEndTimePickerShown = NO;
        self.isDatePickerShown = NO;
        
        hashtagDetailLabel.textColor = [UIColor redColor];
        endTimeDetailLabel.textColor = [UIColor blackColor];
        dateDetailLabel.textColor = [UIColor blackColor];
        
    } else { // Picker shown, let's hide it
        self.hashtagPickerHeight = 0;
        hashtagPicker.alpha = 0;
        [self.tableView reloadData];
        self.isHashtagPickerShown = NO;
        hashtagDetailLabel.textColor = [UIColor blackColor];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1)
        return 103;
    else if (indexPath.section == 2 && indexPath.row == 1)
        return self.datePickerHeight;
    else if (indexPath.section == 2 && indexPath.row == 3)
        return self.endTimePickerHeight;
    else if (indexPath.section == 3 && indexPath.row == 1)
        return self.hashtagPickerHeight;
    else if (indexPath.section == 4)
        return 202;
    
    return 44;
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    datePicker.minimumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:-86400]; //24 hours ago
    datePicker.maximumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:17280000]; //200 days
    
    self.hashtagData  = [[NSArray alloc]initWithObjects:@"Nightlife",@"Sports",@"Music", @"Shopping", @"Freebies", @"Happy Hour", @"Dining", @"Entertainment", @"Fundraiser", @"Meetup", @"Other", nil];
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    //NSLog(@"%@", appDelegate.item);
    
    if (appDelegate.item != nil) {
        item = appDelegate.item;
        locSubtitle.font = [locSubtitle.font fontWithSize:11.0];
        locSubtitle.alpha = 1;
        locTitle.text = item.name;
        locSubtitle.text = appDelegate.locSubtitle;
        NSIndexPath *path = [[NSIndexPath alloc]init];
        path = [NSIndexPath indexPathForRow:1 inSection:1];
        UITableViewCell *locCell = [self.tableView cellForRowAtIndexPath:path];
        locCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    NSLog(@"Event creation cancelled :(");
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.item = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self.profileVC showNavTitle];
    }];
    
}

- (IBAction)titleTextInput:(UITextField *)sender {
    
    Event[@"Title"] = self.titleField.text;
    NSIndexPath *path = [[NSIndexPath alloc]init];
    path = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *locCell = [self.tableView cellForRowAtIndexPath:path];
    
    if (self.titleField.text.length > 3) {
        locCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else
        locCell.accessoryType = UITableViewCellAccessoryNone;
}

- (IBAction)locationTextInput:(UITextField *)sender {
    
    Event[@"Location"] = self.locationField.text;
    NSIndexPath *path = [[NSIndexPath alloc]init];
    path = [NSIndexPath indexPathForRow:0 inSection:1];
    UITableViewCell *locCell = [self.tableView cellForRowAtIndexPath:path];
    
    if (self.locationField.text.length > 3) {
        locCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else
        locCell.accessoryType = UITableViewCellAccessoryNone;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@"Description"]) {
        textView.text = @"";
    }
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont systemFontOfSize:14.0];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    
    if ([textView.text isEqualToString:@""]) {
        
        textView.text = @"Description";
        textView.textColor = [UIColor lightGrayColor];
        textView.font = [UIFont systemFontOfSize:17.0];
        currentCell.accessoryType = UITableViewCellAccessoryNone;
        
    } else {
        //passedEvent[@"Description"] = textView.text;
        Event[@"Description"] = textView.text;
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
}


- (IBAction)doneButton:(UIBarButtonItem *)sender {
        
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    for (int i=0;i<1;i++)
    {
        // Title check
        if (self.titleField.text.length < 3)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Title must be at least 3 characters long" delegate:self cancelButtonTitle:@"I'm on it" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        
        // Location check
        
        if (self.locationField.text.length < 3)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"What is the name of the event's location? Must be at least 3 characters long." delegate:self cancelButtonTitle:@"Hmmm..." otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        
        if (datePicker.date.timeIntervalSinceNow < 0) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"The event can't take place in the past! Please change the date." delegate:self cancelButtonTitle:@"Well that makes sense." otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        
        // Did user choose a loc?
        if (!item.placemark.location.coordinate.longitude)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Please select a location for this event. If you cannot find or do not know the exact location, just use the city name (i.e. Washington, DC)." delegate:self cancelButtonTitle:@"You got it" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        
        // Did user choose a tag?
        if ([hashtagDetailLabel.text isEqualToString:@"Tap to set"])
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Please select a tag for this event." delegate:self cancelButtonTitle:@"Roger that" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        
        //%%%%%
        
        if (self.titleField.text.length > 24 && self.locationField.text.length > 30)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You may want to shorten the length of the title and location name fields, as they could be cut off upon display (i.e. \"Event locati...\")" delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Continue", nil];
            [alert show];
            break;
        }
        
        if (self.titleField.text.length > 24)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Since your event title is greater than 24 characters long, it may be cut off. (i.e. \"Event na...\")" delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Continue", nil];
            [alert show];
            break;
        }
        
        if (self.locationField.text.length > 30)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Since the name of your event's location is greater than 30 characters long, it may be cut off. (i.e. \"Event locati...\")" delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Continue", nil];
            [alert show];
            break;
        }
        
        Event[@"Frequency"] = @(frequencyInt);
        Event[@"URL"] = urlString;
        Event[@"ContactEmail"] = emailString;
        Event[@"isTicketedEvent"] = @(ticks);
        Event[@"isFreeEvent"] = @(isFree);
        
        Event[@"weight"] = @3;
        
        PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:item.placemark.location];
        Event[@"GeoLoc"] = loc;
        
        NSNumber *one = [NSNumber numberWithInt:1];
        Event[@"swipesRight"] = one;
        NSNumber *zero = [NSNumber numberWithInt:0];
        Event[@"swipesLeft"] = zero;
        
        
        // If all conditions are met, Event saves in background
        
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2));
        [activityView startAnimating];
        [self.view addSubview:activityView];
        [activityView startAnimating];
        self.view.userInteractionEnabled = NO;
        
        
        [RKDropdownAlert title:@"Event created!" message:@"Please wait a few seconds for your event \n to be uploaded" backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
        
        [Event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Event Created!");
                self.view.userInteractionEnabled = YES;
                
                if (repeatsInt > 0) {
                    [self repeatEvent];
                }
                [delegate refreshMyEvents];
                
                 // dismiss when event is saved
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    [self.profileVC showNavTitle];
                }];
                
            } else {
                NSLog(@"ERROR CREATING EVENT: %@", error);
                
                [RKDropdownAlert title:@"Something went wrong :(" message:@"Event was not created, please check your internet connection and try again." backgroundColor:[UIColor redColor] textColor:[UIColor whiteColor]];
                
                self.view.userInteractionEnabled = YES;
            }
        }];
        
        appDelegate.item = nil;
    }
}


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (buttonIndex == [alertView cancelButtonIndex]){
        NSLog(@"Alert shown- user clicked Edit/OK");
        
    } else {
        NSLog(@"Alert shown- user clicked Continue");
        
        Event[@"Frequency"] = @(frequencyInt);
        Event[@"URL"] = urlString;
        Event[@"ContactEmail"] = emailString;
        Event[@"Description"] = descriptionString;
        
        PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:item.placemark.location];
        Event[@"GeoLoc"] = loc;
        
        NSNumber *one = [NSNumber numberWithInt:1];
        Event[@"swipesRight"] = one;
        NSNumber *zero = [NSNumber numberWithInt:0];
        Event[@"swipesLeft"] = zero;
        
        // If all conditions are met, Event saves in background
        
        /*
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2));
        [activityView startAnimating];
        [self.view addSubview:activityView];
        [activityView startAnimating];
        self.view.userInteractionEnabled = NO;
        */

        [RKDropdownAlert title:@"Event created!" message:@"Please wait a few seconds for your event \n to be uploaded" backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
        
        [Event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Event created!");
                self.view.userInteractionEnabled = YES;
                //[self dismissViewControllerAnimated:YES completion:nil];
                
                if (repeatsInt > 0) {
                    [self repeatEvent];
                }
                [delegate refreshMyEvents];
                
                // dismiss when event is saved
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    [self.profileVC showNavTitle];
                }];

            } else {
                NSLog(@"ERROR CREATING EVENT: %@", error);
                
                [RKDropdownAlert title:@"Something went wrong :(" message:@"Event was not created, please check your internet connection and try again." backgroundColor:[UIColor redColor] textColor:[UIColor whiteColor]];
                
                self.view.userInteractionEnabled = YES;
            }
        }];
        
        appDelegate.item = nil;
        
    }
}

- (IBAction)dateChanged:(UIDatePicker *)sender {
    
    Event[@"Date"] = self.datePicker.date;
    
    //NSDate *endDate = [NSDate dateWithTimeInterval:1800 sinceDate:self.datePicker.date];
    //endTimePicker.minimumDate = endDate;
    endTimePicker.date = [NSDate dateWithTimeInterval:intervalInSeconds sinceDate:datePicker.date];
    
    dateDetailLabel.text = [dateFormatter stringFromDate:datePicker.date];
        
    [self performSelector:@selector(didEndTimeChange:) withObject:endTimePicker];
    
    NSLog(@"Date changed");
    
    Event[@"EndTime"] = self.endTimePicker.date;
    
}

- (IBAction)didEndTimeChange:(UIDatePicker *)sender {
    
    Event[@"EndTime"] = self.endTimePicker.date;
    
    NSDictionary* attributes = @{
                                 NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
                                 };
    
    // IF LESS THAN TODAY MAKE STRIKETHROUGH
    if ([endTimePicker.date timeIntervalSinceDate:datePicker.date] < 0) {
        if ([endTimePicker.date beginningOfDay] == [datePicker.date beginningOfDay]) {
            NSDateFormatter *sameDayFormatter = [[NSDateFormatter alloc]init];
            [sameDayFormatter setDateFormat:@"h:mm a"];
            NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:[sameDayFormatter stringFromDate:endTimePicker.date] attributes:attributes];
            endTimeDetailLabel.attributedText = attrText;
        } else {
            NSAttributedString* attrText = [[NSAttributedString alloc] initWithString:[dateFormatter stringFromDate:endTimePicker.date] attributes:attributes];
            endTimeDetailLabel.text = [dateFormatter stringFromDate:endTimePicker.date];
            endTimeDetailLabel.attributedText = attrText;
        }
    } else {
        
        if ([endTimePicker.date beginningOfDay] == [datePicker.date beginningOfDay]) {
            NSDateFormatter *sameDayFormatter = [[NSDateFormatter alloc]init];
            [sameDayFormatter setDateFormat:@"h:mm a"];
            endTimeDetailLabel.text = [sameDayFormatter stringFromDate:endTimePicker.date];
        } else {
            endTimeDetailLabel.text = [dateFormatter stringFromDate:endTimePicker.date];
        }
    }
    
    intervalInSeconds = [endTimePicker.date timeIntervalSinceDate:datePicker.date];
    NSLog(@"End Time changed + saved");
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    
    return self.hashtagData.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [self.hashtagData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"Selected Row %ld: %@", (long)row, [self.hashtagData objectAtIndex:row]);

    Event[@"Hashtag"] = [self.hashtagData objectAtIndex:row];
    //NSString *img = [NSString stringWithFormat:([self.hashtagData objectAtIndex:row])];
    UIImage *image = [UIImage imageNamed:[self.hashtagData objectAtIndex:row]];
    imageView.image = image;
    
    hashtagDetailLabel.text = [self.hashtagData objectAtIndex:row];
    
    //Save Image
    NSData *imageData = UIImagePNGRepresentation(imageView.image);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    Event[@"Image"] = imageFile;
    
}

- (IBAction)imageButtonPressed:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeImage, nil];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSUInteger size = [UIImagePNGRepresentation(image) length];
        
        if (size > 10485760) {
        
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Uh-oh" message:@"Image size is too large. Please try another image." delegate:self cancelButtonTitle:@"Aww man!" otherButtonTitles:nil, nil];
            [alert show];
            
        } else {
            
            imageView.image = image;
            
            //Save Image
            NSData *imageData = UIImagePNGRepresentation(image);
            PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
            Event[@"Image"] = imageFile;
        }
    }
}

- (void)eventRepeats:(int)repeats tickets:(BOOL)tickets free:(BOOL)free url:(NSString *)url email:(NSString *)email frequency:(int)freq {
    
    repeatsInt = repeats;
    urlString = url;
    emailString = email;
    frequencyInt = freq;
    ticks = tickets;
    isFree = free;
    
    Event[@"ContactEmail"] = email;
    Event[@"Frequency"] = @(freq);
    Event[@"URL"] = urlString;
    Event[@"ContactEmail"] = email;
    Event[@"isTicketedEvent"] = @(ticks);
    Event[@"isFreeEvent"] = @(isFree);
    
    /*
    NSIndexPath *path = [[NSIndexPath alloc]init];
    path = [NSIndexPath indexPathForRow:0 inSection:5];
    UITableViewCell *locCell = [self.tableView cellForRowAtIndexPath:path];
    
    //locCell.detailTextLabel.text = @"Yes";
     */
    
}

- (void)repeatEvent {
    
    NSLog(@"Repeat event!");
    
    for (int i = 1; i < frequencyInt; i ++) {
    
        PFObject *repeatEvent = [PFObject objectWithClassName:@"Event"];
    
        repeatEvent[@"CreatedBy"] = Event[@"CreatedBy"];
        repeatEvent[@"CreatedByName"] = Event[@"CreatedByName"];
        repeatEvent[@"ContactEmail"] = Event[@"ContactEmail"];
        repeatEvent[@"GeoLoc"] = Event[@"GeoLoc"];
        repeatEvent[@"Hashtag"] = Event[@"Hashtag"];
        repeatEvent[@"Image"] = Event[@"Image"];
        repeatEvent[@"Location"] = Event[@"Location"];
        repeatEvent[@"Repeats"] = Event[@"Repeats"];
        repeatEvent[@"Description"] = Event[@"Description"];
        repeatEvent[@"Title"] = Event[@"Title"];
        repeatEvent[@"URL"] = Event[@"URL"];
        repeatEvent[@"swipesLeft"] = Event[@"swipesLeft"];
        repeatEvent[@"swipesRight"] = Event[@"swipesRight"];
        repeatEvent[@"Frequency"] = Event[@"Frequency"];
        repeatEvent[@"isTicketedEvent"] = Event[@"isTicketedEvent"];
        repeatEvent[@"isFreeEvent"] = Event[@"isFreeEvent"];
        
        repeatEvent[@"weight"] = @3;

        
        if (repeatsInt == 1) { // Weekly 604800 seconds
        
            NSLog(@"Repeats weekly");
            repeatEvent[@"Date"] = [self.datePicker.date dateByAddingTimeInterval:  (  i * 604800   ) ];
            repeatEvent[@"EndTime"] = [self.endTimePicker.date dateByAddingTimeInterval:  (  i * 604800  ) ];
        
        } else if (repeatsInt == 2) { // Biweekly 1209600 seconds
        
            NSLog(@"Repeats Biweekly");
            repeatEvent[@"Date"] = [self.datePicker.date dateByAddingTimeInterval: i * 1209600];
            repeatEvent[@"EndTime"] = [self.endTimePicker.date dateByAddingTimeInterval: i * 1209600];
        
        } else { //monthly
        
            NSLog(@"Repeats monthly");
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setMonth:i]; // Month set to i
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *startDate = [calendar dateByAddingComponents:dateComponents toDate:datePicker.date options:0];
            NSDate *endDate = [calendar dateByAddingComponents:dateComponents toDate:endTimePicker.date options:0];
        
            repeatEvent[@"Date"] = startDate;
            repeatEvent[@"EndTime"] = endDate;
        
        }
    
        [repeatEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Repeat event saved!");
            }
        }];
    }
    
}
- (IBAction)contactUsButtonTapped:(id)sender {
    
    NSLog(@"Contact Us Tapped");
    // Email Subject
    PFUser *user = [PFUser currentUser];
    NSString *emailTitle = [NSString stringWithFormat:@"A message from user: %@", user.objectId];
    // Email Content
    NSString *messageBody = @"How can we help?";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"hello@happening.city"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toMoreInfo"]) {
        // Pass along variables
        ExtraInfoTVC *vc = (ExtraInfoTVC *)[segue destinationViewController];
        vc.delegate = self;
        
        vc.urlString = urlString;
        vc.emailString = emailString;
        vc.createdByNameString = createdByNameString;
        vc.repeatsInt = repeatsInt;
        vc.frequency = frequencyInt;
        vc.freeBOOL = isFree;
        vc.ticketBOOL = ticks;
        
        [vc setPassedEvent:Event];
    }
}

@end
