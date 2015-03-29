//
//  ProfileSettingsTVC.m
//  Happening
//
//  Created by Max on 3/19/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "ProfileSettingsTVC.h"
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>
#import "RKDropdownAlert.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "webViewController.h"

@interface ProfileSettingsTVC () <MFMailComposeViewControllerDelegate>

@end

@implementation ProfileSettingsTVC

@synthesize bottomView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;

    FBSDKLikeControl *likeButton = [[FBSDKLikeControl alloc] init];
    likeButton.frame = CGRectMake(15, bottomView.center.y - 10, likeButton.frame.size.width, likeButton.frame.size.height);
    likeButton.objectID = @"https://www.facebook.com/happeningllc/";
    [bottomView addSubview:likeButton];

    //likeButton.likeControlAuxiliaryPosition = FBLikeControlAuxiliaryPositionBottom;

    
    
}

- (IBAction)dismissButtonTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self.profileVC showNavTitle];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            NSLog(@"Contact Us Tapped");
            [self contactUsButtonTapped];
            
        } else if (indexPath.row == 1) {
            
            NSLog(@"Share Happening Tapped");
            [self shareAction];
            
        } else if (indexPath.row == 2) {
            
            NSLog(@"Rate in App Store tapped");
            [self appStoreAction];
            
        }
        
    }
}

- (void)contactUsButtonTapped {
    
    NSLog(@"Contact Us Tapped");
    // Email Subject
    NSString *emailTitle = @"";
    // Email Content
    NSString *messageBody = [NSString stringWithFormat: @"User ID: %@ \n\n", [PFUser currentUser].objectId];
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"max@gethappeningapp.com"];
    
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

- (void)shareAction {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
    cell.selected = NO;
    
    ProfActivityProvider *ActivityProvider = [[ProfActivityProvider alloc] init];
    
    NSURL *myWebsite = [NSURL URLWithString:@"http://www.happening.city"]; //Make this custom when Liran makes unique pages
    
    
    NSArray *itemsToShare = @[ActivityProvider, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:itemsToShare applicationActivities:nil];
    
    activityVC.excludedActivityTypes = @[UIActivityTypeAirDrop,
                                         UIActivityTypePrint,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToWeibo,
                                         UIActivityTypeCopyToPasteboard,
                                         ];
    
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    [activityVC setCompletionHandler:^(NSString *act, BOOL done)
     {
         NSString *ServiceMsg = @"Done!";
         BOOL calendarAction = NO;
         
         if ( [act isEqualToString:UIActivityTypeMail] ) {
             ServiceMsg = @"Mail sent!";
         }
         else if ( [act isEqualToString:UIActivityTypePostToTwitter] ) {
             ServiceMsg = @"Your tweet has been posted!";
         }
         else if ( [act isEqualToString:UIActivityTypePostToFacebook] ){
             ServiceMsg = @"Your Facebook status has been updated!";
         }
         else if ( [act isEqualToString:UIActivityTypeMessage] ) {
             ServiceMsg = @"Message sent!";
         } else {
             calendarAction = YES;
         }
         if ( done && (calendarAction == NO) )
         {
             
             // Custom action for other activity types...
             [RKDropdownAlert title:ServiceMsg backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
             
         }
     }];
    
}

- (void)appStoreAction {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    cell.selected = NO;
    
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
*/
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"toTerms"]) {
        
        webViewController *vc = (webViewController *)[segue.destinationViewController topViewController];
        vc.urlString = @"http://www.happening.city/terms";
        vc.titleString = @"Terms of Service";
        vc.shouldHideToolbar = YES;
        
    }
    
}


@end

@implementation ProfActivityProvider

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    
    NSString *shareText = [[NSString alloc]init];
    shareText = [NSString stringWithFormat:@"Check out this new app called Happening. It's the easiest way to find cool events to go to with friends."];
    
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypeMessage] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypeMail] ) {
        return shareText;
    } else
        return shareText;
    //if ( [activityType isEqualToString:@"it.albertopasca.myApp"] )
    //return @"OpenMyapp custom text";
    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @"Testing"; }
@end




