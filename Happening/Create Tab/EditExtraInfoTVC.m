//
//  EditExtraInfoTVC.m
//  Happening
//
//  Created by Max on 1/3/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "EditExtraInfoTVC.h"

@interface EditExtraInfoTVC ()

@property (strong, nonatomic) IBOutlet UISwitch *freeEventSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *ticketsSwitch;

@end

@implementation EditExtraInfoTVC {
    
    PFUser *user;
    int repeats;
    NSString *url;
    NSString *email;
    BOOL tickets;
    BOOL free;
    
}

@synthesize passedEvent, urlField, nameField, emailField, repeatsLabel, urlString, emailString, delegate, freeEventSwitch, ticketsSwitch, ticketsBOOL, freeBOOL;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    NSLog(@"%@", passedEvent);
    
    url = urlString;
    email = emailString;
    tickets = ticketsBOOL;
    free = freeBOOL;
    

    if (![url isEqualToString:@"www.gethappeningapp.com"]) {
        urlField.text = url;
    }
    
    if (![email isEqualToString:@""]) {
        emailField.text = email;
    }

    nameField.text = passedEvent[@"CreatedByName"];
    repeatsLabel.text = passedEvent[@"Repeats"];
    
    [delegate setUrl:url tickets:tickets free:free email:email];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    if (![email isEqualToString:@""]) {
        UITableViewCell *emailCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        emailCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    if (![url isEqualToString:@""]) {
        UITableViewCell *urlCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        urlCell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        UITableViewCell *urlCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        urlCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *nameCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    nameCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)emailField:(id)sender {
    
    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    
    if ([self doesString:emailField.text contain:@"@"] && [self doesString:emailField.text contain:@"."]) {
        
        passedEvent[@"ContactEmail"] = emailField.text;
        
        currentCell.accessoryType =UITableViewCellAccessoryCheckmark;
        
        email = emailField.text;
        [delegate setUrl:url tickets:tickets free:free email:email];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Not a valid email address" message:@"" delegate:self cancelButtonTitle:@"Roger that" otherButtonTitles:nil, nil];
        [alert show];
        
        currentCell.accessoryType = UITableViewCellAccessoryNone;
        
        email = @"";
        [delegate setUrl:url tickets:tickets free:free email:email];
    }
    
}

-(BOOL)doesString:(NSString *)first contain:(NSString*)other {
    NSRange range = [first rangeOfString:other];
    return range.length != 0;
}

- (IBAction)ticketSwitchPressed:(id)sender {
    
    tickets = ticketsSwitch.on;
    //passedEvent[@"isTicketedEvent"] = @(tickets);
    [delegate setUrl:url tickets:tickets free:free email:email];
    passedEvent[@"isTicketedEvent"] = @(tickets);

}
- (IBAction)freeSwitchPressed:(id)sender {
    
    free = freeEventSwitch.on;
    //passedEvent[@"isFreeEvent"] = @(free);
    [delegate setUrl:url tickets:tickets free:free email:email];
    passedEvent[@"isFreeEvent"] = @(free);
}

- (IBAction)clearAccessory:(id)sender {
    
    UITableViewCell *currentCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    currentCell.accessoryType =UITableViewCellAccessoryNone;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Clear any prior accessory marks
    
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
            
        } else if (indexPath.row == 1) {
            
            passedEvent[@"Repeats"] = @"Weekly";
            repeats = 1;
            [self performSegueWithIdentifier:@"toFrequency" sender:self];
            
        } else if (indexPath.row == 2) {
            
            passedEvent[@"Repeats"] = @"Biweekly";
            repeats = 2;
            [self performSegueWithIdentifier:@"toFrequency" sender:self];
            
        } else if (indexPath.row == 3) {
            
            passedEvent[@"Repeats"] = @"Monthly";
            repeats = 3;
            [self performSegueWithIdentifier:@"toFrequency" sender:self];
            
        }
        
        [delegate setUrl:url description:description email:email];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
*/

/*
-(void)passFrequencyData:(int)freq {
    
    frequency = freq;
    [delegate setUrl:url description:description email:email];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[NewEventFrequencyTVC class]]) {
        NewEventFrequencyTVC *vc = (NewEventFrequencyTVC *)segue.destinationViewController;
        vc.repeats = repeats;
        vc.delegate = self;
    }
    
}
*/

@end
