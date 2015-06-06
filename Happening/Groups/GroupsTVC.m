//
//  GroupsTVC.m
//  Happening
//
//  Created by Max on 6/1/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupsTVC.h"
#import "GroupsCell.h"
#import "GroupPageTVC.h"
#import <Parse/Parse.h>

@interface GroupsTVC ()

@end

@implementation GroupsTVC {
    
    NSMutableArray *groupNamesArray;
    NSMutableArray *groupMembersArray;
    NSMutableArray *groupMemCountArray;
    NSMutableArray *groupIDsArray;
    NSArray *groupsArray;
    PFUser *currentUser;
    
    NSString *selectedGroupId;
    NSString *selectedName;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    groupNamesArray = [NSMutableArray array];
    groupMembersArray = [NSMutableArray array];
    groupMemCountArray = [NSMutableArray array];
    groupIDsArray = [NSMutableArray array];
    groupsArray = [NSArray array];
    
    currentUser = [PFUser currentUser];

    PFQuery *groupsUserQuery = [PFQuery queryWithClassName:@"Group_User"];
    [groupsUserQuery whereKey:@"user_id" equalTo:currentUser.objectId];
    
    PFQuery *groupsQuery = [PFQuery queryWithClassName:@"Group"];
    [groupsQuery whereKey:@"objectId" matchesKey:@"group_id" inQuery:groupsUserQuery];
    [groupsQuery includeKey:@"user_objects"];
    
    [groupsQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
       
        if (!error) {
            
            groupsArray = array;
            
            for (PFObject *group in array) {
                
                NSArray *users = group[@"user_objects"];
                NSString *groupName = group[@"name"];
                
                if ([groupName isEqualToString:@"_indy_"]) {
                    for (PFUser *user in users) {
                        if (![user.objectId isEqualToString: currentUser.objectId]) {
                            [groupNamesArray addObject:[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]]];
                        }
                    }
                    
                    [groupMembersArray addObject: @"No new notifications."];
                
                } else {
                    
                    [groupNamesArray addObject:groupName];
                
                    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                    
                    for (PFUser *user in users) {
                        if (![user.objectId isEqualToString: currentUser.objectId]) {
                            [tempArray addObject:[NSString stringWithFormat:@"%@", user[@"firstName"]]];
                        }
                    }
                    
                    NSString *memberString = [NSString stringWithFormat:@"With %@", tempArray[0]];
                    
                    for (int i = 1; i < tempArray.count - 1; i++) {
                        memberString = [memberString stringByAppendingString:[NSString stringWithFormat:@", %@", tempArray[i]]];
                    }
                    
                    PFUser *user = users[users.count-1];
                    if (tempArray.count > 1)
                        memberString = [memberString stringByAppendingString:[NSString stringWithFormat:@" and %@", user[@"firstName"]]];
                    
                    [groupMembersArray addObject:memberString];
                    
                }
                
                NSNumber *memCount = group[@"memberCount"];
                [groupMemCountArray addObject:memCount];
                [groupIDsArray addObject:group.objectId];
            
                [self.tableView reloadData];
            }
            
        }
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [groupsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GroupsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"group" forIndexPath:indexPath];
    
    // Configure the cell...
    
    cell.nameLabel.text = groupNamesArray[indexPath.row];
    cell.membersLabel.text = groupMembersArray[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
    selectedGroupId = groupIDsArray[indexPath.row];
    selectedName = groupNamesArray[indexPath.row];
    [self performSegueWithIdentifier:@"toGroupPage" sender:self];
}


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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"toGroupPage"]) {
        
        GroupPageTVC *vc = (GroupPageTVC *)[[segue destinationViewController] topViewController];
        vc.groupId = selectedGroupId;
        vc.groupName = selectedName;
    }
    
}


@end
