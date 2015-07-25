//
//  MatchesWithFriendsTVC.m
//  Happening
//
//  Created by Max on 7/10/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "MatchesWithFriendsTVC.h"
#import <Parse/Parse.h>

@interface MatchesWithFriendsTVC () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) IBOutlet UISwitch *matchesWithFriendsSwitch;
@property (strong, nonatomic) IBOutlet UIPickerView *friendsPicker;
@property (strong, nonatomic) IBOutlet UILabel *friendNumberLabel;

@end

@implementation MatchesWithFriendsTVC {
    
    NSArray *pickerArray;
    PFUser *currentUser;
    PFInstallation *currentInstallation;
}

@synthesize matchesWithFriendsSwitch, friendsPicker, friendNumberLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    currentUser = [PFUser currentUser];
    currentInstallation = [PFInstallation currentInstallation];
    
    NSArray *channels = currentInstallation.channels;
    
    matchesWithFriendsSwitch.on = [channels containsObject:@"matches"];
    
    if (!matchesWithFriendsSwitch.on) {
        
        UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        for (UIView *view in cell1.subviews) {
            view.alpha = 0;
        }
        
        UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        for (UIView *view in cell2.subviews) {
            view.alpha = 0;
        }
        
    }
    
    pickerArray = [NSArray arrayWithObjects:@"1 friend", @"2 friends", @"3 friends", @"4 friends", @"5 friends", @"6 friends", @"7 friends", @"8 friends", @"9 friends", @"10 friends", nil];
    /*
    UIFont *font = [UIFont fontWithName:@"OpenSans-Bold" size:15.0];
    NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithObject:font
                                                                              forKey:NSFontAttributeName];
    int matchCount = [currentInstallation[@"matchCount"] intValue];
    [attrsDictionary setObject:[UIColor colorWithRed:47.0/255 green:76.0/255 blue:142.0/255 alpha:1.0] forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", pickerArray[matchCount-1]] attributes:attrsDictionary];
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@" swipe right on the same event as me."];
    if (matchCount == 1)
        aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@" swipes right on the same event as me."];
    
    [aAttrString1 appendAttributedString:aAttrString2];
    friendNumberLabel.attributedText = aAttrString1;
    [friendNumberLabel sizeToFit];
    */
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    int matchCount = [currentInstallation[@"matchCount"] intValue];
    if (matchCount <= 0) {
        matchCount = 5;
    }
    [friendsPicker selectRow:matchCount-1 inComponent:0 animated:YES];
    [self pickerView:friendsPicker didSelectRow:matchCount-1 inComponent:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 1 && matchesWithFriendsSwitch.on) {
        return @"Notify me when...";
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
        return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    if (section == 1)
        return 2;
        
    return 0;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return 10;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return pickerArray[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    UIFont *font = [UIFont fontWithName:@"OpenSans-Bold" size:15.0];
    NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithObject:font
                                                                              forKey:NSFontAttributeName];
    [attrsDictionary setObject:[UIColor colorWithRed:47.0/255 green:76.0/255 blue:142.0/255 alpha:1.0] forKey:NSForegroundColorAttributeName];
    NSMutableAttributedString *aAttrString1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", pickerArray[row]] attributes:attrsDictionary];
    NSMutableAttributedString *aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@" swipe right on the same event as me."];
    if (row == 0)
        aAttrString2 = [[NSMutableAttributedString alloc] initWithString:@" swipes right on the same event as me."];
    
    [aAttrString1 appendAttributedString:aAttrString2];
    friendNumberLabel.attributedText = aAttrString1;
    [friendNumberLabel sizeToFit];
    
    currentInstallation[@"matchCount"] = [NSNumber numberWithInteger:(row+1)];
    [currentInstallation saveEventually];
}

- (IBAction)pushMatchesSwitch:(UISwitch *)sender {
    
    if (sender.on) {
        [currentInstallation addObject:@"matches" forKey:@"channels"];
        
        UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        for (UIView *view in cell1.subviews) {
            view.alpha = 1;
        }
        
        UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        for (UIView *view in cell2.subviews) {
            view.alpha = 1;
        }
        
    } else {
        [currentInstallation removeObject:@"matches" forKey:@"channels"];

        UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        for (UIView *view in cell1.subviews) {
            view.alpha = 0;
        }
        
        UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        for (UIView *view in cell2.subviews) {
            view.alpha = 0;
        }
        
    }
    
    [currentInstallation saveEventually];
    [self.tableView reloadData];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0)
        return 44;
    
    if (matchesWithFriendsSwitch.on) {
    
        if (indexPath.row == 0)
            return 44;
        return 158;
    }
    
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tag" forIndexPath:indexPath];
    
    return cell;
} */


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
