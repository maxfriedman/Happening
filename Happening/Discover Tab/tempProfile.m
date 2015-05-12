//
//  tempProfile.m
//  Happening
//
//  Created by Max on 4/12/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "tempProfile.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>


@interface tempProfile ()

@end

@implementation tempProfile {
    
    PFUser *user;
    PFUser *currentUser;
    NSString *eventTitle;
}

@synthesize profilePicImageView, nameLabel, detailLabel, subLabel, userID, eventID, notifyButton, explanationLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    notifyButton.userInteractionEnabled = NO;
    
    user = [PFQuery getUserObjectWithId:userID];
    currentUser = [PFUser currentUser];
    
    nameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
    detailLabel.text = [NSString stringWithFormat:@"%@", user[@"city"]];
    
    
    FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(120, 55, 80, 80)]; // initWithProfileID:user[@"FBObjectID"] pictureCropping:FBSDKProfilePictureModeSquare];
    profPicView.profileID = user[@"FBObjectID"];
    profPicView.pictureMode = FBSDKProfilePictureModeSquare;
    profPicView.layer.cornerRadius = 10;
    profPicView.layer.masksToBounds = YES;
    profPicView.layer.borderColor = [UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0].CGColor;
    profPicView.layer.borderWidth = 3.0;
    [self.view addSubview:profPicView];
    
    
    // Instantiate event dictionary--- this is where all event info is stored
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery getObjectInBackgroundWithId:eventID block:^( PFObject *event, NSError *error){
    
        if (!error) {
        
            NSString *gender = user[@"gender"];
            NSString *genderString = @"";
            
            if ([gender isEqualToString:@"male"]) {
                genderString = @"with him";
            } else if ([gender isEqualToString:@"female"]) {
                genderString = @"with her";
            } else {
                genderString = @"together";
            }
        
            eventTitle = event[@"Title"];
        
            subLabel.text = [NSString stringWithFormat:@"Let %@ know you want to go to %@ %@!", user[@"firstName"], eventTitle, genderString];
        
            NSString *pushMessage = [NSString stringWithFormat:@"%@ %@ wants to go to %@ with you!", currentUser[@"firstName"], currentUser[@"lastName"], eventTitle];
            
            explanationLabel.text = [NSString stringWithFormat: @"Tapping this button will send %@ a push notification that says: \"%@\"", user[@"firstName"], pushMessage];
            
            notifyButton.userInteractionEnabled = YES;
        }
    }];
    


    profilePicImageView.layer.cornerRadius = 10;
    profilePicImageView.layer.masksToBounds = YES;
    profilePicImageView.layer.borderColor =  [UIColor colorWithRed:232.0/255 green:232.0/255 blue:232.0/255 alpha:1.0].CGColor;
    profilePicImageView.layer.borderWidth = 3.0;

    notifyButton.layer.cornerRadius = 75;

}
- (IBAction)notifyUserButtonTapped:(id)sender {
    
    [notifyButton setUserInteractionEnabled:NO];
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"userID" equalTo:userID];
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    NSString *pushMessage = [NSString stringWithFormat:@"%@ %@ wants to go to %@ with you!", currentUser[@"firstName"], currentUser[@"lastName"], eventTitle];
    
    NSDictionary *data = @{
                           @"alert" : pushMessage,
                           @"badge" : @"Increment",
                           @"eventID" : self.eventID,
                           @"senderID" : currentUser.objectId,
                           };
    
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * __nullable error) {
        
        if (succeeded) {
            [notifyButton setTitle:@"Boom." forState:UIControlStateNormal];
            subLabel.text = [NSString stringWithFormat:@"We just notified %@!", user[@"firstName"]];
        } else {
            [notifyButton setTitle:@"Uh-oh." forState:UIControlStateNormal];
            subLabel.text = [NSString stringWithFormat:@"We were unable to notify %@!", user[@"firstName"]];
        }
        
        explanationLabel.alpha = 0;

    }];
    
    NSLog(@"SENT PUSH: %@", pushMessage);
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //code
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
