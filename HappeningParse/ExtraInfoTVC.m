//
//  ExtraInfoTVC.m
//  Happening
//
//  Created by Max on 12/8/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "ExtraInfoTVC.h"

@interface ExtraInfoTVC () {
    
    PFUser *user;
}

@end

@implementation ExtraInfoTVC

@synthesize passedEvent, urlField, descriptionScrollField, nameField, emailField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    user = [PFUser currentUser];
    NSString *firstName = user[@"firstName"];
    NSString *lastName = user[@"lastName"];
    nameField.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    emailField.text = user.username;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)urlField:(id)sender {
    
    NSURL *candidateURL = [NSURL URLWithString:urlField.text];
    // WARNING > "test" is an URL according to RFCs, being just a path
    // so you still should check scheme and all other NSURL attributes you need
    if (candidateURL /* && candidateURL.scheme*/ && candidateURL.host) {
        // candidate is a well-formed url with:
        //  - a scheme (like http://)
        //  - a host (like stackoverflow.com)
        passedEvent[@"URL"] = urlField.text;
        UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        currentCell.accessoryType =UITableViewCellAccessoryCheckmark;
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Not a valid web address" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)clearAccessory:(id)sender {
    
    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    currentCell.accessoryType =UITableViewCellAccessoryNone;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    textView.text = @"";
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont systemFontOfSize:14.0];
    
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@""]) {
        
        textView.text = @"Description";
        textView.textColor = [UIColor lightGrayColor];
        textView.font = [UIFont systemFontOfSize:17.0];
    } else {
        passedEvent[@"Description"] = textView.text;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Clear any prior accessory marks
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
        
    } else if (indexPath.row == 1) {
        
        passedEvent[@"Repeats"] = @"Weekly";
        
    } else if (indexPath.row == 2) {
        
        passedEvent[@"Repeats"] = @"Biweekly";
        
    } else if (indexPath.row == 3) {
        
        passedEvent[@"Repeats"] = @"Monthly";
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
