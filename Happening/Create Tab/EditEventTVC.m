//
//  EditEventTVC.m
//  Happening
//
//  Created by Max on 12/3/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "EditEventTVC.h"

@interface EditEventTVC ()

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

@implementation EditEventTVC {
    NSDateFormatter *dateFormatter;
    int intervalInSeconds;
}

@synthesize imageView, button;
@synthesize cancelButton;

@synthesize Event;

@synthesize titleField, subtitleField, locationField;

@synthesize datePicker, endTimePicker;

@synthesize hashtagPicker, hashtagData;

@synthesize mapView = _mapView;

@synthesize locSubtitle, locTitle;

@synthesize imageButton;

@synthesize dateButton, endTimeButton, hashtagButton;

@synthesize dateDetailLabel, endTimeDetailLabel, hashtagDetailLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    intervalInSeconds = 3600;
    
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

    NSLog(@"Event being Edited...");
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    Event = [query getObjectWithId:self.eventID];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@", Event[@"Title"]];
    
    titleField.text = Event[@"Title"];
    subtitleField.text = Event[@"Subtitle"];
    locationField.text = Event[@"Location"];
    
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE, MMM d    h:mm a"];
    
    datePicker.date = Event[@"Date"];
    dateDetailLabel.text = [dateFormatter stringFromDate:datePicker.date];
    
    if (Event[@"EndTime"]) {
        endTimePicker.date = Event[@"EndTime"];
        endTimeDetailLabel.text = [dateFormatter stringFromDate:endTimePicker.date];
    }
    
    PFFile *imageFile = Event[@"Image"];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            imageView.image = [UIImage imageWithData:data];
        }
    }];
    
    hashtagData  = [[NSArray alloc]initWithObjects:@"Nightlife",@"Sports",@"Music", @"Shopping", @"Freebies", @"Happy Hour", @"Dining", @"Entertainment", @"Fundraiser", @"Meetup", @"Other", nil];
    
    NSString *tagString = Event[@"Hashtag"];
    
    if ([tagString isEqualToString:@"Nightlife"])
        [hashtagPicker selectRow:0 inComponent:0 animated:NO];
    else if ([tagString isEqualToString:@"Sports"])
        [hashtagPicker selectRow:1 inComponent:0 animated:NO];
    else if ([tagString isEqualToString:@"Music"])
        [hashtagPicker selectRow:2 inComponent:0 animated:NO];
    else if ([tagString isEqualToString:@"Shopping"])
        [hashtagPicker selectRow:3 inComponent:0 animated:NO];
    else if ([tagString isEqualToString:@"Freebies"])
        [hashtagPicker selectRow:4 inComponent:0 animated:NO];
    else if ([tagString isEqualToString:@"Happy Hour"])
        [hashtagPicker selectRow:5 inComponent:0 animated:NO];
    else if ([tagString isEqualToString:@"Dining"])
        [hashtagPicker selectRow:6 inComponent:0 animated:NO];
    else if ([tagString isEqualToString:@"Entertainment"])
        [hashtagPicker selectRow:7 inComponent:0 animated:NO];
    else if ([tagString isEqualToString:@"Fundraiser"])
        [hashtagPicker selectRow:8 inComponent:0 animated:NO];
    else if ([tagString isEqualToString:@"Meetup"])
        [hashtagPicker selectRow:9 inComponent:0 animated:NO];
    else if ([tagString isEqualToString:@"Other"])
        [hashtagPicker selectRow:10 inComponent:0 animated:NO];
    hashtagDetailLabel.text = tagString;

    PFGeoPoint *geoPoint = Event[@"GeoLoc"];
    CLLocation *eventLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    [[[CLGeocoder alloc]init] reverseGeocodeLocation:eventLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks[0];
        
        NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
        NSString *addressString = [lines componentsJoinedByString:@" "];
        NSLog(@"Address: %@", addressString);
        
        NSString *name = placemark.addressDictionary[@"Name"];
        NSString *streetName = placemark.addressDictionary[@"Street"];
        NSString *cityName = placemark.addressDictionary[@"City"];
        NSString *stateName = placemark.addressDictionary[@"State"];
        NSString *zipCode = placemark.addressDictionary[@"ZIP"];
        NSString *country = placemark.addressDictionary[@"Country"];
        
        locTitle.text = [NSString stringWithFormat:@"%@", name];
        
        if (zipCode) {
            locSubtitle.font = [locSubtitle.font fontWithSize:11.0];
            locSubtitle.alpha = 1.0;
            locSubtitle.text = [NSString stringWithFormat:@"%@, %@ %@, %@", cityName, stateName, zipCode, country];
        }
        else if (cityName) {
            locSubtitle.font = [locSubtitle.font fontWithSize:11.0];
            locSubtitle.alpha = 1.0;
            locSubtitle.text = [NSString stringWithFormat:@"%@, %@, %@", cityName, stateName, country];
        }
        
    }];
    
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
    if (indexPath.section == 2 && indexPath.row == 1)
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
    
    
    datePicker.minimumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:-86400]; //24 hours ago
    datePicker.maximumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:17280000]; //200 days
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    //NSLog(@"%@", appDelegate.item);
    
    if (appDelegate.item != nil) {
        locTitle.text = appDelegate.item.name;
        locSubtitle.text = appDelegate.locSubtitle;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    NSLog(@"Cancel button pressed- Discard any edits");
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.item = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)titleTextInput:(UITextField *)sender {
    
    Event[@"Title"] = self.titleField.text;
    Event[@"CreatedByName"] = @"";
}

- (IBAction)subtitleTextInput:(UITextField *)sender {

    Event[@"Subtitle"] = self.subtitleField.text;
}

- (IBAction)locationTextInput:(UITextField *)sender {

    Event[@"Location"] = self.locationField.text;
}

- (IBAction)doneButton:(UIBarButtonItem *)sender {
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    for (int i=0;i<1;i++)
    {
        // Title check
        if (self.titleField.text.length < 3)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Title must be at least 3 characters long" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        
        // Location check
        
        if (self.locationField.text.length < 3)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"What is the name of the event's location? Must be at least 3 characters long." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        
        if (datePicker.date.timeIntervalSinceNow < 0) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"The event can't take place in the past! Please change the date." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        
        // Did user choose a loc?
        if (!appDelegate.item.placemark.location.coordinate.longitude)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Please select a location for this event. If you cannot find or do not know the exact location, just use the city name (i.e. Washington, DC)." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            break;
        }
        
        //%%%%%
        if (self.titleField.text.length > 24 && self.subtitleField.text.length > 31 && self.locationField.text.length > 30)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You may want to shorten the length of the title, subtitle and location name fields, as they could be cut off upon display (i.e. \"Event locatio...\")" delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Continue", nil];
            [alert show];
            break;
        }
        
        if (self.titleField.text.length > 24 && self.subtitleField.text.length > 31)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You may want to shorten the length of the title and subtitle fields, as they could be cut off upon display (i.e. \"Check out this eve...\")" delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Continue", nil];
            [alert show];
            break;
        }
        
        if (self.titleField.text.length > 24 && self.locationField.text.length > 30)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You may want to shorten the length of the title and location name fields, as they could be cut off upon display (i.e. \"Event locati...\")" delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Continue", nil];
            [alert show];
            break;
        }
        
        if (self.subtitleField.text.length > 31 && self.locationField.text.length > 30)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"You may want to shorten the length of the subtitle and location name fields, as they could be cut off upon display (i.e. \"Event locatio...\")" delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Continue", nil];
            [alert show];
            break;
        }
        
        if (self.titleField.text.length > 24)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Since your event title is greater than 24 characters long, it may be cut off. (i.e. \"Event na...\")" delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Continue", nil];
            [alert show];
            break;
        }
        
        if (self.subtitleField.text.length > 31)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Since your event's subtitle is greater than 30 characters long, it may be cut off. (i.e. \"Event subti...\")" delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Continue", nil];
            [alert show];
            break;
        }
        
        if (self.locationField.text.length > 30)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warning" message:@"Since the name of your event's location is greater than 30 characters long, it may be cut off. (i.e. \"Event locati...\")" delegate:self cancelButtonTitle:@"Edit" otherButtonTitles:@"Continue", nil];
            [alert show];
            break;
        }
        
        Event[@"Title"] = self.titleField.text;
        Event[@"Subtitle"] = self.subtitleField.text;
        Event[@"Location"] = self.locationField.text;
        
        //Save Image
        NSData *imageData = UIImagePNGRepresentation(imageView.image);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        Event[@"Image"] = imageFile;
        
        PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:appDelegate.item.placemark.location];
        Event[@"GeoLoc"] = loc;
        
        NSNumber *one = [NSNumber numberWithInt:1];
        Event[@"swipesRight"] = one;
        
        Event[@"Date"] = self.datePicker.date;
        
        PFUser *user = [PFUser currentUser];
        Event[@"CreatedBy"] = user.username;
        NSString *firstName = user[@"firstName"];
        NSString *lastName = user[@"lastName"];
        NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        Event[@"CreatedByName"] = name;
        
        // If all conditions are met, Event saves in background
        
        [Event saveInBackground];
        appDelegate.item = nil;
        
        NSLog(@"Event created!");
        
        // Peace out!
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (buttonIndex == [alertView cancelButtonIndex]){
        NSLog(@"Alert shown- user clicked Edit/OK");
        
        
    } else {
        NSLog(@"Alert shown- user clicked Continue");
        
        Event[@"Title"] = self.titleField.text;
        Event[@"Subtitle"] = self.subtitleField.text;
        Event[@"Location"] = self.locationField.text;
        
        //Save Image
        NSData *imageData = UIImagePNGRepresentation(imageView.image);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        Event[@"Image"] = imageFile;
        
        PFGeoPoint *loc = [PFGeoPoint geoPointWithLocation:appDelegate.item.placemark.location];
        Event[@"GeoLoc"] = loc;
        
        NSNumber *one = [NSNumber numberWithInt:1];
        Event[@"swipesRight"] = one;
        
        Event[@"Date"] = self.datePicker.date;
        
        PFUser *user = [PFUser currentUser];
        Event[@"CreatedBy"] = user.username;
        NSString *firstName = user[@"firstName"];
        NSString *lastName = user[@"lastName"];
        NSString *name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
        Event[@"CreatedByName"] = name;
        
        // If all conditions are met, Event saves in background
        
        [Event saveInBackground];
        appDelegate.item = nil;
        
        NSLog(@"Event created!");
        
        // Peace out!
        [self dismissViewControllerAnimated:YES completion:nil];
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

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

    return self.hashtagData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    return [self.hashtagData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSLog(@"Selected Row %ld: %@", (long)row, [self.hashtagData objectAtIndex:row]);
    
    Event[@"Hashtag"] = [self.hashtagData objectAtIndex:row];
    //NSString *img = [NSString stringWithFormat:([self.hashtagData objectAtIndex:row])];
    UIImage *image = [UIImage imageNamed:[self.hashtagData objectAtIndex:row]];
    imageView.image = image;
    
    hashtagDetailLabel.text = [self.hashtagData objectAtIndex:row];
    NSLog(@"%@", [UIFont familyNames]);
    hashtagDetailLabel.font = [UIFont fontWithName:@"Open Sans" size:17.0];
    
    
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
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Image size is too large. Please try another image." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        } else {
            
            imageView.image = image;
        }
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
