//
//  TableViewController.m
//  HappeningParse
//
//  Created by Max on 9/15/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "EventTVC.h"



@implementation EventTVC {

    MKLocalSearch *localSearch;
    MKLocalSearchResponse *results;

}

@synthesize imageView, button;
@synthesize cancelButton;

@synthesize Event;

@synthesize titleField, subtitleField, locationField;

@synthesize endTimePicker, datePicker;

@synthesize hashtagPicker, hashtagData;

@synthesize mapView = _mapView;

@synthesize locSubtitle, locTitle;

@synthesize imageButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Event being created...");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

// I want this to only run once.......
-(void)viewWillAppear:(BOOL)animated {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.tabBarController.selectedIndex = 1;
    });
    
    
    datePicker.minimumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:-86400]; //24 hours ago
    datePicker.maximumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:17280000]; //200 days
    
    
    self.hashtagData  = [[NSArray alloc]initWithObjects:@"Nightlife",@"Sports",@"Music", @"Shopping", @"Freebies", @"Happy Hour", @"Dining", @"Entertainment", @"Fundraiser", @"Meetup", @"Other", nil];
    
    Event = [PFObject objectWithClassName:@"Event"];
    //Default, in case picker is not changed:
    Event[@"Hashtag"] = @"Nightlife";
    
    
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    //NSLog(@"%@", appDelegate.item);
    
    locTitle.text = appDelegate.item.name;
    locSubtitle.font = [locSubtitle.font fontWithSize:17.0];
    locSubtitle.alpha = 0.2;
    
    NSString *cityName = appDelegate.item.placemark.addressDictionary[@"City"];
    NSString *stateName = appDelegate.item.placemark.addressDictionary[@"State"];
    NSString *zipCode = appDelegate.item.placemark.addressDictionary[@"ZIP"];
    NSString *country = appDelegate.item.placemark.addressDictionary[@"Country"];
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
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    NSLog(@"Event creation cancelled :(");
    AppDelegate *appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.item = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)eventTextInput:(UITextField *)sender {
    
    
    Event[@"Title"] = self.titleField.text;
    Event[@"Subtitle"] = self.subtitleField.text;
    //Event[@"Location"] = self.locationField.text;
    Event[@"Date"] = self.datePicker.date;
    //Event[@"EndTime"] = self.endTimePicker.date;
    Event[@"CreatedByName"] = @"";

    
    
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


/*
 -(void)imageWasAdded:(EventTVC *)image {
 
 EventTVC *eventImage = (EventTVC *)image;
 //if (eventImage.imageView.image != nil) {
 NSData *imageData = UIImagePNGRepresentation(eventImage.imageView.image);
 PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
 Event[@"Image"] = imageFile;
 //}
 
 }
 */
- (IBAction)dateChanged:(UIDatePicker *)sender {
    
    // I don't think this code actually does anything. EndTime gets set no matter what
    
    Event[@"Date"] = self.datePicker.date;
    
    //sets end time picker to one hour later than start time
    //self.endTimePicker.date = [[NSDate alloc]initWithTimeInterval:3600 sinceDate:self.datePicker.date];
    
    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
    self.endTimePicker.date = self.datePicker.date;
    //});
    NSLog(@"Date changed");
    
}

- (IBAction)didEndTimeChange:(UIDatePicker *)sender {
    
    Event[@"EndTime"] = self.endTimePicker.date;
    
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


#pragma mark - Table view data source

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
