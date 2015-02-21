//
//  ExtraInfoTVC.m
//  Happening
//
//  Created by Max on 12/8/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "ExtraInfoTVC.h"
#import "EventTVC.h"

@interface ExtraInfoTVC () {
    
    PFUser *user;
    int repeats;
    NSString *url;
    NSString *description;
    NSString *email;
    
}

@end

@implementation ExtraInfoTVC

@synthesize passedEvent, urlField, descriptionScrollField, nameField, emailField, delegate, frequency, urlString, descriptionString, emailString, createdByNameString, repeatsInt;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    url = urlString;
    description = descriptionString;
    email = emailString;
    repeats = repeatsInt;
    
    if (![description isEqualToString:@""]) {
        descriptionScrollField.textColor = [UIColor blackColor];
        descriptionScrollField.font = [UIFont systemFontOfSize:14.0];
        descriptionScrollField.text = description;
    }
    if (![url isEqualToString:@"www.gethappeningapp.com"]) {
        urlField.text = url;
    }
    
    nameField.text = createdByNameString;
    
    if (![email isEqualToString:@""]) {
        emailField.text = email;
    }
    
    [delegate eventRepeats:repeats url:url description:description email:email frequency:frequency];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    UITableViewCell *nameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    nameCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (![email isEqualToString:@""]) {
        UITableViewCell *emailCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        emailCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    if (![description isEqualToString:@""]) {
        UITableViewCell *descCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        descCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    if (![url isEqualToString:@"www.gethappeningapp.com"]) {
        UITableViewCell *urlCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        urlCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
    UITableViewCell *repeatCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:repeats inSection:2]];
    repeatCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)urlField:(id)sender {
    
    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    NSURL *candidateURL = [NSURL URLWithString:urlField.text];
    // WARNING > "test" is an URL according to RFCs, being just a path
    // so you still should check scheme and all other NSURL attributes you need
    if (candidateURL && [urlField.text containsString:@"."] /* && candidateURL.scheme && candidateURL.host */) {
        // candidate is a well-formed url with:
        //  - a scheme (like http://)
        //  - a host (like stackoverflow.com)
        //passedEvent[@"URL"] = urlField.text;

        currentCell.accessoryType =UITableViewCellAccessoryCheckmark;
        
        url = urlField.text;
        [delegate eventRepeats:repeats url:url description:description email:email frequency:frequency];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Not a valid web address" message:@"" delegate:self cancelButtonTitle:@"Roger that" otherButtonTitles:nil, nil];
        [alert show];
        
        currentCell.accessoryType = UITableViewCellAccessoryNone;
        
        url = @"";
        [delegate eventRepeats:repeats url:url description:description email:email frequency:frequency];
    }
}

- (IBAction)emailField:(id)sender {
    
    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    
    if ([emailField.text containsString:@"@"] && [emailField.text containsString:@"."]) {
        
        passedEvent[@"ContactEmail"] = emailField.text;
    
        currentCell.accessoryType =UITableViewCellAccessoryCheckmark;
        
        email = emailField.text;
        [delegate eventRepeats:repeats url:url description:description email:email frequency:frequency];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Not a valid email address" message:@"" delegate:self cancelButtonTitle:@">.<" otherButtonTitles:nil, nil];
        [alert show];
        
        currentCell.accessoryType = UITableViewCellAccessoryNone;
        
        email = @"";
        [delegate eventRepeats:repeats url:url description:description email:email frequency:frequency];
    }
    
}


- (IBAction)clearAccessory:(id)sender {
    
    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    currentCell.accessoryType =UITableViewCellAccessoryNone;
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
        description = textView.text;
        [delegate eventRepeats:repeats url:url description:description email:email frequency:frequency];
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Clear any prior accessory marks
    NSLog(@"Repeat cell selected");
    
    if (indexPath.section == 2) {
    
    UITableViewCell *cellOne = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
    cellOne.accessoryType = UITableViewCellAccessoryNone;
    UITableViewCell *cellTwo = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
    cellTwo.accessoryType = UITableViewCellAccessoryNone;
    UITableViewCell *cellThree = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]];
    cellThree.accessoryType = UITableViewCellAccessoryNone;
    UITableViewCell *cellFour = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:2]];
    cellFour.accessoryType = UITableViewCellAccessoryNone;

    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath != [NSIndexPath indexPathForRow:0 inSection:1]) {
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
    if (indexPath.row == 0) {
        
        passedEvent[@"Repeats"] = @"Never";
        repeats = 0;
        frequency = 1;
        
    } else if (indexPath.row == 1) {
        
        passedEvent[@"Repeats"] = @"Weekly";
        
        if (repeats != indexPath.row) {
            frequency = 3;
        }
        
        repeats = 1;
        [self performSegueWithIdentifier:@"toFrequency" sender:self];
        
    } else if (indexPath.row == 2) {
        
        passedEvent[@"Repeats"] = @"Biweekly";
        
        if (repeats != indexPath.row) {
            frequency = 3;
        }
        
        repeats = 2;
        [self performSegueWithIdentifier:@"toFrequency" sender:self];
        
    } else if (indexPath.row == 3) {
        
        passedEvent[@"Repeats"] = @"Monthly";
        
        if (repeats != indexPath.row) {
            frequency = 3;
        }
        
        repeats = 3;
        [self performSegueWithIdentifier:@"toFrequency" sender:self];
        
    }
        
        [delegate eventRepeats:repeats url:url description:description email:email frequency:frequency];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)passFrequencyData:(int)freq {
    
    frequency = freq;
    [delegate eventRepeats:repeats url:url description:description email:email frequency:frequency];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[NewEventFrequencyTVC class]]) {
        NewEventFrequencyTVC *vc = (NewEventFrequencyTVC *)segue.destinationViewController;
        vc.repeats = repeats;
        vc.frequencyInt = frequency;
        vc.delegate = self;
    }
    
}


@end
