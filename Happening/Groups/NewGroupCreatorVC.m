//
//  NewGroupCreatorVC.m
//  Happening
//
//  Created by Max on 6/4/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "NewGroupCreatorVC.h"
#import <QuartzCore/QuartzCore.h>
#import <Atlas/Atlas.h>
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "CustomConstants.h"
#import <FastttCamera.h>
#import "UIButton+Extensions.h"

@import MobileCoreServices;

@interface NewGroupCreatorVC () <UIActionSheetDelegate, FastttCameraDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *snapshotView;
@property (nonatomic, strong) FastttCamera *fastCamera;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *switchCameraButton;

@end

@implementation NewGroupCreatorVC {
    
    UIButton *takePictureButton;
    UIActivityIndicatorView *activityView;
    UIImage *groupImage;
    UIButton *chooseImageButton;
    UIButton *changeButton;
    
    BOOL isDefaultImage;

}

@synthesize avatarContainerView, bigProfPicView, smallTopProfPicView,smallBottomProfPicView, eventId, userIdArray, numberLabel, textField, createButton, memCount, snapshotView, flashButton, switchCameraButton, event, fromGroupsTab;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isDefaultImage = YES;
    
    avatarContainerView.layer.cornerRadius = 90;
    avatarContainerView.layer.masksToBounds = YES;
    avatarContainerView.layer.borderWidth = 2.0;
    avatarContainerView.layer.borderColor = [UIColor clearColor].CGColor;

    bigProfPicView.profileID = userIdArray[0];
    
    smallBottomProfPicView.profileID = userIdArray[1];
    
    smallTopProfPicView.profileID = userIdArray[2];
    
    [avatarContainerView sendSubviewToBack:smallBottomProfPicView];
    [avatarContainerView sendSubviewToBack:smallTopProfPicView];
    [avatarContainerView sendSubviewToBack:bigProfPicView];
    
    numberLabel.text = [NSString stringWithFormat:@"%d", memCount];
    numberLabel.layer.cornerRadius = 35;
    numberLabel.layer.masksToBounds = YES;
    numberLabel.backgroundColor = [UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:0.9];
    createButton.enabled = NO;
    
    UIImageView *imv = [[UIImageView alloc] initWithFrame:avatarContainerView.bounds];
    imv.backgroundColor = [UIColor whiteColor];
    imv.image = [UIImage imageNamed:@"userImage"];
    imv.alpha = 0.2;
    
    UIView *overlayView = [[UIView alloc] initWithFrame:imv.bounds];
    overlayView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    //overlayView.alpha = 0.6;
    //[overlayView addSubview:imv];
    
    [avatarContainerView addSubview:overlayView];
    
    changeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    changeButton.center = avatarContainerView.center;
    [changeButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeImage:) forControlEvents:UIControlEventTouchUpInside];
    
    [avatarContainerView addSubview:changeButton];
    
    groupImage = [UIImage imageNamed:@"userImage"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [textField becomeFirstResponder];
}

- (void)changeImage: (UIGestureRecognizer *) gr {
    
    [self.view endEditing:YES];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", @"Use Default", nil];
    [sheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"index: %lu", buttonIndex);
    

    switch (buttonIndex) {
        case 0: { // Take Photo
            
            _fastCamera = [FastttCamera new];
            self.fastCamera.delegate = self;
            
            [self.fastCamera removeFromParentViewController];
            [self fastttAddChildViewController:self.fastCamera];
            self.fastCamera.view.frame = snapshotView.frame;
            
            self.fastCamera.view.layer.masksToBounds = YES;
            self.fastCamera.view.layer.cornerRadius = self.fastCamera.view.frame.size.width / 2;
            
            if (!takePictureButton) {
                takePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 330, 160, 50)];
                [takePictureButton setTitleColor:[UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0] forState:UIControlStateNormal];
                takePictureButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
                takePictureButton.layer.cornerRadius = 4.0;
                takePictureButton.layer.masksToBounds = YES;
                takePictureButton.layer.borderWidth = 1.0;
                takePictureButton.layer.borderColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
                [self.view addSubview:takePictureButton];
                [takePictureButton addTarget:self action:@selector(snapDopePic) forControlEvents:UIControlEventTouchUpInside];
            }
            takePictureButton.alpha = 1;
            [takePictureButton setTitle:@"Take Picture" forState:UIControlStateNormal];
            
            if (!flashButton) {
            flashButton = [[UIButton alloc] initWithFrame:CGRectMake(119, 400, 20.8, 30)];
            [flashButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
            [self.view addSubview:flashButton];
            [flashButton addTarget:self action:@selector(flashButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            }
            [flashButton setImage:[UIImage imageNamed:@"flash_transp"] forState:UIControlStateNormal];
            flashButton.alpha = 1;
            flashButton.enabled = YES;
            
            if (!switchCameraButton) {
            switchCameraButton = [[UIButton alloc] initWithFrame:CGRectMake(170, 400, 30, 30)];
            [switchCameraButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
            [switchCameraButton addTarget:self action:@selector(switchCameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:switchCameraButton];
            }
            [switchCameraButton setImage:[UIImage imageNamed:@"flip"] forState:UIControlStateNormal];
            switchCameraButton.enabled = YES;
            switchCameraButton.alpha = 1;

            
            if (!chooseImageButton) {
                chooseImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
                chooseImageButton.center = CGPointMake(160, 480);
                [chooseImageButton setTitle:@"Choose Image" forState:UIControlStateNormal];
                chooseImageButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:11.0];
                [chooseImageButton setTitleColor:[UIColor colorWithRed:0.0 green:80.0/255 blue:230.0/255 alpha:1.0] forState:UIControlStateNormal];
                [self.view addSubview:chooseImageButton];
                [chooseImageButton addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
            }
            chooseImageButton.alpha = 1;
            
            break;
        }
        case 1: { // Choose Photo
            
            [self chooseImage];
            
            break;
        }
            
        case 2: { // Default
            
            changeButton.alpha = 0;
            
            UIImageView *imv = [[UIImageView alloc] initWithFrame:snapshotView.bounds];
            imv.tag = 99;
            imv.image = [UIImage imageNamed:@"userImage"];
            imv.backgroundColor = [UIColor groupTableViewBackgroundColor];
            imv.layer.masksToBounds = YES;
            imv.layer.frame = snapshotView.frame;
            imv.layer.cornerRadius = imv.frame.size.width / 2;
            imv.userInteractionEnabled = YES;
            [imv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)]];
            [self.view addSubview:imv];
            groupImage = imv.image;
            isDefaultImage = YES;

            [textField becomeFirstResponder];
            
        }
            
        default:
            break;
    }
    
}

- (void)snapDopePic {
    
    [self.fastCamera takePicture];
    
    [takePictureButton setTitle:@"" forState:UIControlStateNormal];
    takePictureButton.enabled = NO;
    flashButton.enabled = NO;
    switchCameraButton.enabled = NO;
    
    activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = takePictureButton.center;
    [self.view addSubview:activityView];
    [activityView startAnimating];
    
    [takePictureButton removeTarget:self action:@selector(snapDopePic) forControlEvents:UIControlEventTouchUpInside];
    [takePictureButton addTarget:self action:@selector(retakePicture) forControlEvents:UIControlEventTouchUpInside];
}

- (void)retakePicture {
    
    [takePictureButton setTitle:@"Take Picture" forState:UIControlStateNormal];
    [takePictureButton removeTarget:self action:@selector(retakePicture) forControlEvents:UIControlEventTouchUpInside];
    [takePictureButton addTarget:self action:@selector(snapDopePic) forControlEvents:UIControlEventTouchUpInside];
    
    flashButton.enabled = YES;
    switchCameraButton.enabled = YES;
    
    for (int i = 0; i < self.view.subviews.count; i ++) {
        UIView *view = self.view.subviews[i];
        if (view.tag == 99) {
            [view removeFromSuperview];
        }
    }
    [self.fastCamera startRunning];
}

- (void)flashButtonPressed
{
    NSLog(@"flash button pressed");
    
    FastttCameraFlashMode flashMode;
    NSString *flashTitle;
    switch (self.fastCamera.cameraFlashMode) {
        case FastttCameraFlashModeOn:
            flashMode = FastttCameraFlashModeOff;
            flashTitle = @"Flash Off";
            [flashButton setImage:[UIImage imageNamed:@"flash_transp"] forState:UIControlStateNormal];
            break;
        case FastttCameraFlashModeOff:
        default:
            flashMode = FastttCameraFlashModeOn;
            flashTitle = @"Flash On";
            [flashButton setImage:[UIImage imageNamed:@"flash_filled"] forState:UIControlStateNormal];
            break;
    }
    if ([self.fastCamera isFlashAvailableForCurrentDevice]) {
        [self.fastCamera setCameraFlashMode:flashMode];
        [self.flashButton setTitle:flashTitle forState:UIControlStateNormal];
    }
}

- (void)switchCameraButtonPressed
{
    NSLog(@"switch camera button pressed");
    
    FastttCameraDevice cameraDevice;
    switch (self.fastCamera.cameraDevice) {
        case FastttCameraDeviceFront:
            cameraDevice = FastttCameraDeviceRear;
            break;
        case FastttCameraDeviceRear:
        default:
            cameraDevice = FastttCameraDeviceFront;
            break;
    }
    if ([FastttCamera isCameraDeviceAvailable:cameraDevice]) {
        [self.fastCamera setCameraDevice:cameraDevice];
        if (![self.fastCamera isFlashAvailableForCurrentDevice]) {
            [self.flashButton setTitle:@"Flash Off" forState:UIControlStateNormal];
            flashButton.enabled = NO;
            [flashButton setImage:[UIImage imageNamed:@"flash_transp"] forState:UIControlStateNormal];
        } else {
            flashButton.enabled = YES;
        }
    }
}

#pragma mark - IFTTTFastttCameraDelegate

- (void)cameraController:(FastttCamera *)cameraController
 didFinishCapturingImage:(FastttCapturedImage *)capturedImage
{
    /**
     *  Here, capturedImage.fullImage contains the full-resolution captured
     *  image, while capturedImage.rotatedPreviewImage contains the full-resolution
     *  image with its rotation adjusted to match the orientation in which the
     *  image was captured.
     */
}

- (void)cameraController:(FastttCamera *)cameraController
didFinishScalingCapturedImage:(FastttCapturedImage *)capturedImage
{
    /**
     *  Here, capturedImage.scaledImage contains the scaled-down version
     *  of the image.
     */
    NSLog(@"Scaled image snagged.");
    
    [self.fastCamera stopRunning];
    [activityView stopAnimating];
    [takePictureButton setTitle:@"Re-take" forState:UIControlStateNormal];
    takePictureButton.enabled = YES;
    
    UIImageView *imv = [[UIImageView alloc] initWithFrame:snapshotView.bounds];
    imv.tag = 99;
    imv.image = capturedImage.scaledImage;
    imv.layer.masksToBounds = YES;
    imv.layer.frame = snapshotView.frame;
    imv.layer.cornerRadius = imv.frame.size.width / 2;
    imv.userInteractionEnabled = YES;
    [imv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)]];
    [self.view addSubview:imv];
    
    groupImage = capturedImage.scaledImage;
    isDefaultImage = NO;
    
    if ([textField.text isEqualToString:@""]) {
        [textField becomeFirstResponder];
    }
}

- (void)cameraController:(FastttCamera *)cameraController
didFinishNormalizingCapturedImage:(FastttCapturedImage *)capturedImage
{
    /**
     *  Here, capturedImage.fullImage and capturedImage.scaledImage have
     *  been rotated so that they have image orientations equal to
     *  UIImageOrientationUp. These images are ready for saving and uploading,
     *  as they should be rendered more consistently across different web
     *  services than images with non-standard orientations.
     */
    
    NSLog(@"Image Acquired.");
    groupImage = capturedImage.fullImage;
    
}

- (void)chooseImage {
    
    [self.fastCamera stopRunning];
    flashButton.alpha = 0;
    switchCameraButton.alpha = 0;
    takePictureButton.alpha = 0;
    chooseImageButton.alpha = 0;
    [self startMediaBrowserFromViewController:self usingDelegate:(self)];
    
}

- (IBAction)textFieldChanged:(UITextField *)sender {
    
    if ([textField.text isEqualToString:@""]) {
        createButton.tintColor = [UIColor lightTextColor];
        createButton.style = UIBarButtonItemStylePlain;
        createButton.enabled = NO;
    } else {
        createButton.tintColor = [UIColor whiteColor];
        createButton.style = UIBarButtonItemStyleDone;
        createButton.enabled = YES;
    }
}

- (IBAction)createButtonTapped:(id)sender {
    [self createGroup];
}

- (void)createGroup {
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -60)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show]; //WithMaskType:SVProgressHUDMaskTypeGradient];
            //[SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
            //[SVProgressHUD setStatus:@"Loading Happenings"];
        });
    });
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSLog(@"%@", userIdArray);
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"FBObjectID" containedIn:userIdArray];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
        
        if (!error) {
            
            PFObject *group = [PFObject objectWithClassName:@"Group"];
            group[@"user_objects"] = users;
            group[@"name"] = textField.text;
            group[@"memberCount"] = [NSNumber numberWithInt:memCount];
            
            NSMutableArray *userDictsArray = [NSMutableArray array];
            NSMutableArray *parseArray = [NSMutableArray array];
            NSMutableArray *fbArray = [NSMutableArray array];
            for (PFUser *user in users) {
                [parseArray addObject:user.objectId];
                [fbArray addObject:user[@"FBObjectID"]];
                
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                
                [dict setObject:user.objectId forKey:@"parseId"];
                [dict setObject:[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]] forKey:@"name"];
                [dict setObject:user[@"FBObjectID"] forKey:@"id"];
                [userDictsArray addObject:dict];
            }
            
            group[@"user_parse_ids"]= parseArray;
            group[@"user_dicts"] = userDictsArray;
            
            NSData *imageData = UIImagePNGRepresentation(groupImage);
            PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
            group[@"avatar"] = imageFile;
            group[@"isDefaultImage"] = @(isDefaultImage);
            
            [group saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                
                if (success) {
                    
                    /*
                    NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"groupDict"] mutableCopy];
                    if (!dict) {
                        dict = [NSMutableDictionary dictionary];
                    }
                    NSDictionary *groupDict = [group dictionaryWithValuesForKeys:[NSArray arrayWithObjects:@"avatar", @"name", @"memberCount", @"objectId", nil]];
                    [dict setObject:groupDict forKey:group.objectId];
                    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"groupDict"];
                    [[NSUserDefaults standardUserDefaults] synchronize]; */
                    
                    [group pinInBackground];
                    
                    if (!fromGroupsTab) {
                    
                        PFObject *groupEvent = [PFObject objectWithClassName:@"Group_Event"];
                        groupEvent[@"EventID"] = event.objectId;
                        groupEvent[@"GroupID"] = group.objectId;
                        groupEvent[@"invitedByName"] = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstName"], currentUser[@"lastName"]];
                        groupEvent[@"invitedByID"] = currentUser.objectId;
                        
                        [event pinInBackground];

                        [groupEvent saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
                            
                            [groupEvent pinInBackground];
                            
                            PFObject *rsvpObject = [PFObject objectWithClassName:@"Group_RSVP"];
                            rsvpObject[@"EventID"] = event.objectId;
                            rsvpObject[@"GroupID"] = group.objectId;
                            rsvpObject[@"Group_Event_ID"] = groupEvent.objectId;
                            rsvpObject[@"UserID"] = currentUser.objectId;
                            rsvpObject[@"User_Object"] = currentUser;
                            rsvpObject[@"UserFBID"] = currentUser[@"FBObjectID"];
                            rsvpObject[@"GoingType"] = @"yes";
                            [rsvpObject saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                                [rsvpObject pinInBackground];
                            }];
                        }];
                        
                        PFQuery *swipesQuery = [PFQuery queryWithClassName:@"Swipes"];
                        [swipesQuery whereKey:@"EventID" equalTo:self.event.objectId];
                        [swipesQuery whereKey:@"UserID" equalTo:currentUser.objectId];
                        [swipesQuery fromLocalDatastore];
                        [swipesQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
                            
                            if (!error) {
                                
                                object[@"isGoing"] = @(YES);
                                [object saveEventually];
                                
                            } else {
                                
                                PFObject *swipesObject = [PFObject objectWithClassName:@"Swipes"];
                                swipesObject[@"UserID"] = currentUser.objectId;
                                swipesObject[@"username"] = currentUser.username;
                                swipesObject[@"EventID"] = event.objectId;
                                swipesObject[@"swipedRight"] = @YES;
                                swipesObject[@"swipedLeft"] = @NO;
                                swipesObject[@"isGoing"] = @(YES);
                                if ([[PFUser currentUser][@"socialMode"] isEqualToNumber:@YES] && ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]]) {
                                    swipesObject[@"FBObjectID"] = currentUser[@"FBObjectID"];
                                }
                                [swipesObject saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
                                    if (success) [swipesObject pinInBackground];
                                }];
                                
                                PFObject *timelineObject = [PFObject objectWithClassName:@"Timeline"];
                                timelineObject[@"type"] = @"eventInvite";
                                timelineObject[@"userId"] = currentUser.objectId;
                                timelineObject[@"eventId"] = event.objectId;
                                timelineObject[@"createdDate"] = [NSDate date];
                                timelineObject[@"eventTitle"] = event[@"Title"];
                                [timelineObject pinInBackground];
                                [timelineObject saveEventually];
                                
                                [currentUser incrementKey:@"score" byAmount:@20];
                                [currentUser saveEventually];
                                
                            }
                        }];
                        
                        [currentUser incrementKey:@"score" byAmount:@5];
                        [currentUser saveEventually];
                    
                    }
                    
                    PFObject *groupCreateTimelineObject = [PFObject objectWithClassName:@"Timeline"];
                    groupCreateTimelineObject[@"type"] = @"groupCreate";
                    groupCreateTimelineObject[@"userId"] = currentUser.objectId;
                    groupCreateTimelineObject[@"createdDate"] = [NSDate date];
                    [groupCreateTimelineObject pinInBackground];
                    [groupCreateTimelineObject saveEventually];
                    
                    [currentUser incrementKey:@"score" byAmount:@15];
                    [currentUser saveEventually];

                    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                    for (NSDictionary *dict in userDictsArray) {
                        if (![[dict objectForKey:@"parseId"] isEqualToString:currentUser.objectId]) {
                            NSString *name = [dict valueForKey:@"name"];
                            [tempArray addObject:[NSString stringWithFormat:@"%@", [[name componentsSeparatedByString:@" "] objectAtIndex:0]]];
                        }
                    }
                    
                    NSString *memberString = [NSString stringWithFormat:@"%@", tempArray[0]];
                    
                    for (int i = 1; i < tempArray.count - 1; i++) {
                        memberString = [memberString stringByAppendingString:[NSString stringWithFormat:@", %@", tempArray[i]]];
                    }
                    
                    if (tempArray.count > 1) {
                        NSString *name = [tempArray lastObject];
                        memberString = [memberString stringByAppendingString:[NSString stringWithFormat:@" and %@", name]];
                    }
                    
                    NSString *pushMessage = @"";
                    
                    if (!fromGroupsTab) {
                        
                        if (memCount == 3) {
                            pushMessage = [NSString stringWithFormat:@"%@ %@ added you and one other to the group \"%@\" and invited you both to an event - check it out!", currentUser[@"firstName"], currentUser[@"lastName"], group[@"name"]];
                        } else {
                            pushMessage = [NSString stringWithFormat:@"%@ %@ added you and %d others to the group \"%@\" and invited you all to an event - check it out!", currentUser[@"firstName"], currentUser[@"lastName"],  memCount - 2, group[@"name"]];
                        }
                        
                        [self setupConversationWithMessage:[NSString stringWithFormat:@"%@ %@ created \"%@\" with %@ and invited the group to an event.", currentUser[@"firstName"], currentUser[@"lastName"], group[@"name"], memberString] forGroup:group];
                        
                    } else {
                        
                        if (memCount == 3) {
                            pushMessage = [NSString stringWithFormat:@"%@ %@ added you and one other to the group \"%@.\"", currentUser[@"firstName"], currentUser[@"lastName"], group[@"name"]];
                        } else {
                            pushMessage = [NSString stringWithFormat:@"%@ %@ added you and %d others to the group \"%@.\"", currentUser[@"firstName"], currentUser[@"lastName"],  memCount - 2, group[@"name"]];
                        }
                        
                        [self setupConversationWithMessage:[NSString stringWithFormat:@"%@ %@ created \"%@\" with %@.", currentUser[@"firstName"], currentUser[@"lastName"], group[@"name"], memberString] forGroup:group];
                        
                    }
                    
                    /*
                    PFObject *notification = [PFObject objectWithClassName:@"Notifications"];
                    notification[@"Type"] = @"group";
                    notification[@"Subtype"] = @"new_group";
                    notification[@"EventID"] = self.eventId;
                    notification[@"UserID"] = currentUser.objectId;  // THIS IS THE DIFFERENCE
                    notification[@"GroupID"] = group.objectId;
                    notification[@"InviterID"] = currentUser.objectId;
                    notification[@"Seen"] = @NO;
                    notification[@"Message"] = pushMessage;
                    //notification[@"AllUserObjects"] = users;
                    [notification saveInBackground];
                    */
                    
                    PFObject *groupUser = [PFObject objectWithClassName:@"Group_User"];
                    groupUser[@"user_id"] = currentUser.objectId;
                    groupUser[@"group_id"] = group.objectId;
                    [groupUser saveInBackground];
                    
                    for (PFObject *user in users) {
                        
                        [user pinInBackground];
                        
                        if (![user.objectId isEqualToString:currentUser.objectId]) {
                        
                            PFObject *groupUser = [PFObject objectWithClassName:@"Group_User"];
                            groupUser[@"user_id"] = user.objectId;
                            groupUser[@"group_id"] = group.objectId;
                            [groupUser saveInBackground];
                            
                        }
                    }
                
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                        if (self.fromGroupsTab) [self.inviteHomiesToGroup.delegate showBoom];
                        else [self.inviteHomies.delegate showBoom];
                        
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                        [appDelegate.mh.groupHub increment];
                    }];
                
                } else {
                    [SVProgressHUD showErrorWithStatus:@"Group creation failed :("];
                    self.navigationItem.rightBarButtonItem.enabled = YES;
                    self.navigationItem.leftBarButtonItem.enabled = YES;
                }

            }];
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"Group creation failed :("];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            self.navigationItem.leftBarButtonItem.enabled = YES;
        }
    }];

    
}

- (void)setupConversationWithMessage:(NSString *)messageText forGroup:(PFObject *)group {
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
    
    LYRConversation *conversation = nil;
    BOOL shouldCreateNewConvo = YES;
    
    NSError *error = nil;
    NSOrderedSet *conversations = [appDelegate.layerClient executeQuery:query error:&error];
    if (!error) {
        
        NSLog(@"%tu conversations", conversations.count);
        
        for (LYRConversation *convo in conversations) {
            
            if ([[convo.metadata valueForKey:@"groupId"] isEqualToString:group.objectId]) {
                
                NSLog(@"group convo exists");
                conversation = convo;
                shouldCreateNewConvo = NO;
                break;
            }
        }
    }
    
    if (shouldCreateNewConvo) {
        
        NSArray *userObjects = group[@"user_objects"];
        NSMutableArray *idArray = [NSMutableArray new];
        for (PFUser *user in userObjects) {
            [idArray addObject:user.objectId];
        }
        
        conversation = [appDelegate.layerClient newConversationWithParticipants:[NSSet setWithArray:idArray] options:nil error:&error];
        [conversation setValue:group[@"name"] forMetadataAtKeyPath:@"title"];
        [conversation setValue:group.objectId forMetadataAtKeyPath:@"groupId"];
        
        group[@"chatId"] = conversation.identifier.absoluteString;
        [group saveEventually];
        
    }
    
    
    //Send messages w data
    
    /* %%%%%%%%%%%%%%% System notification message %%%%%%%%%%%%%%%%%% */
    NSDictionary *dataDictionary = @{@"message":messageText,
                                     @"type":@"invite",
                                     @"groupId":group.objectId,
                                     };
    NSError *JSONSerializerError;
    NSData *dataDictionaryJSON = [NSJSONSerialization dataWithJSONObject:dataDictionary options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
    LYRMessagePart *dataMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemObject data:dataDictionaryJSON];
    // Create messagepart with info about cell
    float actualLineSize = [messageText boundingRectWithSize:CGSizeMake(270, CGFLOAT_MAX)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:[UIFont fontWithName:@"OpenSans" size:10.0]}
                                                     context:nil].size.height;
    NSDictionary *cellInfoDictionary = @{@"height": [NSString stringWithFormat:@"%f", actualLineSize]};
    NSData *cellInfoDictionaryJSON = [NSJSONSerialization dataWithJSONObject:cellInfoDictionary options:
                                            NSJSONWritingPrettyPrinted error:&JSONSerializerError];
    LYRMessagePart *cellInfoMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemCellInfo data:cellInfoDictionaryJSON];
    // Add message to ordered set.  This ordered set messages will get sent to the participants
    LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart,cellInfoMessagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:&error];
    // Sends the specified message
    
    BOOL success = [conversation sendMessage:message error:&error];
    if (success) {
        //NSLog(@"Message queued to be sent: %@", message);
    } else {
        NSLog(@"Message send failed: %@", error);
        
        [self dismissViewControllerAnimated:YES completion:^{
            [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    
    if (!fromGroupsTab) {
    
        /* %%%%%%%%%%%%%%% Embedded RSVP Invite %%%%%%%%%%%%%%%%%% */
        NSDictionary *dataDictionary2 = @{@"message":messageText,
                                          @"eventId":event.objectId,
                                          @"groupId":group.objectId,
                                          };
        NSError *JSONSerializerError2;
        NSData *dataDictionaryJSON2 = [NSJSONSerialization dataWithJSONObject:dataDictionary2 options:NSJSONWritingPrettyPrinted error:&JSONSerializerError2];
        LYRMessagePart *dataMessagePart2 = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeCustomObject data:dataDictionaryJSON2];
        // Create messagepart with info about cell
        NSDictionary *cellInfoDictionary2 = @{@"height":@"180"};
        NSData *cellInfoDictionaryJSON2 = [NSJSONSerialization dataWithJSONObject:cellInfoDictionary2 options:NSJSONWritingPrettyPrinted error:&JSONSerializerError2];
        LYRMessagePart *cellInfoMessagePart2 = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeCustomCellInfo data:cellInfoDictionaryJSON2];
        // Add message to ordered set.  This ordered set messages will get sent to the participants
        LYRMessage *message2 = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart2,cellInfoMessagePart2] options:nil error:&error];
        
        // Sends the specified message
        NSLog(@"%@", conversation);
        BOOL success2 = [conversation sendMessage:message2 error:&error];
        if (success2) {
            NSLog(@"Message queued to be sent: %@", message);
        } else {
            NSLog(@"Message send failed: %@", error);
            
            [self dismissViewControllerAnimated:YES completion:^{
                [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"refreshGroups"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }];
        }
    }
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeImage, nil];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    
    mediaUI.delegate = delegate;
    
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        //originalImage = (UIImage *) [info objectForKey:
                                     //UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        groupImage = imageToUse;
        isDefaultImage = NO;
        
        UIImageView *imv = [[UIImageView alloc] initWithFrame:snapshotView.bounds];
        imv.tag = 99;
        imv.image = groupImage;
        imv.layer.masksToBounds = YES;
        imv.layer.frame = snapshotView.frame;
        imv.layer.cornerRadius = imv.frame.size.width / 2;
        [self.view addSubview:imv];
        imv.userInteractionEnabled = YES;
        [imv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)]];
         
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [textField becomeFirstResponder];

}

-(BOOL) textFieldShouldReturn:(UITextField *)tf{
    
    [tf resignFirstResponder];
    return YES;
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
