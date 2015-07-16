//
//  NotificationsTVC.m
//  Happening
//
//  Created by Max on 3/19/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "NotificationsTVC.h"
#import <Parse/Parse.h>

@interface NotificationsTVC () 

@end

@implementation NotificationsTVC {
    
    PFInstallation *currentInstallation;
}

@synthesize matchesOffOnLabel, popular, reminders, friendJoined, allGroups;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    currentInstallation = [PFInstallation currentInstallation];
    
    NSArray *channels = currentInstallation.channels;
    
    if ([channels containsObject:@"matches"])
        matchesOffOnLabel.text = @"On";
    else
        matchesOffOnLabel.text = @"Off";
    
    popular.on = [channels containsObject:@"popularEvents"];
    friendJoined.on = [channels containsObject:@"friendJoined"];
    reminders.on = [channels containsObject:@"reminders"];
    allGroups.on = [channels containsObject:@"allGroups"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushPopularSwitch:(UISwitch *)sender {
    
    if (sender.on) {
        [currentInstallation addObject:@"popularEvents" forKey:@"channels"];
    } else {
        [currentInstallation removeObject:@"popularEvents" forKey:@"channels"];
    }
    
    [currentInstallation saveEventually];
    
}

- (IBAction)pushFriendJoinedSwitch:(UISwitch *)sender {
    
    if (sender.on) {
        [currentInstallation addObject:@"friendJoined" forKey:@"channels"];
    } else {
        [currentInstallation removeObject:@"friendJoined" forKey:@"channels"];
    }
    
    [currentInstallation saveEventually];
    
}

- (IBAction)pushRemindersSwitch:(UISwitch *)sender {
    
    if (sender.on) {
        [currentInstallation addObject:@"reminders" forKey:@"channels"];
    } else {
        [currentInstallation removeObject:@"reminders" forKey:@"channels"];
    }
    
    [currentInstallation saveEventually];
    
}

- (IBAction)allGroupsSwitch:(UISwitch *)sender {
    
    if (sender.on) {
        [currentInstallation addObject:@"allGroups" forKey:@"channels"];
    } else {
        [currentInstallation removeObject:@"allGroups" forKey:@"channels"];
    }
    
    [currentInstallation saveEventually];
    
}

/*
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}


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
