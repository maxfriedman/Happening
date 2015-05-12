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

@implementation NotificationsTVC

@synthesize inAppMatches, popular, pushMatches, reminders, friendJoined, friendPush;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    NSArray *channels = currentInstallation.channels;
    
    inAppMatches.on = [channels containsObject:@"matchesInApp"];
    popular.on = [channels containsObject:@"popularEvents"];
    pushMatches.on = [channels containsObject:@"matches"];
    friendJoined.on = [channels containsObject:@"friendJoined"];
    reminders.on = [channels containsObject:@"reminders"];
    friendPush.on = [channels containsObject:@"friendPush"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)inAppMatchesSwitch:(UISwitch *)sender {
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (sender.on) {
        [currentInstallation addObject:@"matchesInApp" forKey:@"channels"];
    } else {
        [currentInstallation removeObject:@"matchesInApp" forKey:@"channels"];
    }
    
    [currentInstallation saveInBackground];
    
}

- (IBAction)pushMatchesSwitch:(UISwitch *)sender {
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (sender.on) {
        [currentInstallation addObject:@"matches" forKey:@"channels"];
    } else {
        [currentInstallation removeObject:@"matches" forKey:@"channels"];
    }
    
    [currentInstallation saveInBackground];
    
}

- (IBAction)pushPopularSwitch:(UISwitch *)sender {
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (sender.on) {
        [currentInstallation addObject:@"popularEvents" forKey:@"channels"];
    } else {
        [currentInstallation removeObject:@"popularEvents" forKey:@"channels"];
    }
    
    [currentInstallation saveInBackground];
    
}

- (IBAction)pushFriendJoinedSwitch:(UISwitch *)sender {
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (sender.on) {
        [currentInstallation addObject:@"friendJoined" forKey:@"channels"];
    } else {
        [currentInstallation removeObject:@"friendJoined" forKey:@"channels"];
    }
    
    [currentInstallation saveInBackground];
    
}

- (IBAction)pushRemindersSwitch:(UISwitch *)sender {
    
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (sender.on) {
        [currentInstallation addObject:@"reminders" forKey:@"channels"];
    } else {
        [currentInstallation removeObject:@"reminders" forKey:@"channels"];
    }
    
    [currentInstallation saveInBackground];
    
}

- (IBAction)friendPushSwitch:(UISwitch *)sender {
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    
    if (sender.on) {
        [currentInstallation addObject:@"friendPush" forKey:@"channels"];
    } else {
        [currentInstallation removeObject:@"friendPush" forKey:@"channels"];
    }
    
    [currentInstallation saveInBackground];
    
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
