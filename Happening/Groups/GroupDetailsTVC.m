//
//  GroupDetailsTVC.m
//  Happening
//
//  Created by Max on 6/15/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "GroupDetailsTVC.h"
#import <QuartzCore/QuartzCore.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import "CustomConstants.h"
#import "GroupAddFriendsTVC.h"
#import <FastttCamera.h>
#import "UIButton+Extensions.h"
#import "SVProgressHUD.h"

@import MobileCoreServices;

@interface GroupDetailsTVC () <UIAlertViewDelegate, UIActionSheetDelegate, FastttCameraDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GroupAddFriendsTVCDelegate>

@property (nonatomic, strong) FastttCamera *fastCamera;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *switchCameraButton;

@end

@implementation GroupDetailsTVC {
    
    NSMutableArray *picsArray;
    
    UIButton *takePictureButton;
    UIActivityIndicatorView *activityView;
    UIImage *groupImage;
    UIButton *chooseImageButton;
    UIButton *changeButton;
    UIView *borderView;
    UITextField *textField;
    
    BOOL isDefault;
}

@synthesize group, groupImageView, groupNameLabel, parseIds, fbIds, names, flashButton, switchCameraButton, editItem;

- (void)viewDidLoad {
    
    borderView = [[UIView alloc] initWithFrame:CGRectMake(groupImageView.frame.origin.x - 2, groupImageView.frame.origin.y - 2, groupImageView.frame.size.width + 4, groupImageView.frame.size.height + 4)];
    borderView.backgroundColor = [UIColor clearColor];
    borderView.layer.cornerRadius = 52;
    borderView.layer.borderColor = [UIColor whiteColor].CGColor;
    borderView.layer.borderWidth = 3.0;
    [self.view addSubview:borderView];
    
    //groupImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    //groupImageView.layer.borderWidth = 3.0f;
    groupImageView.layer.cornerRadius = 50.0f;
    groupImageView.clipsToBounds = YES;
    
    borderView.userInteractionEnabled = YES;
    [borderView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage:)]];
    
    isDefault = [group[@"isDefaultImage"] boolValue];
    
    self.groupNameLabel.text = group[@"name"];
    
    groupNameLabel.userInteractionEnabled = YES;
    [groupNameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editName)]];
    
    changeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    changeButton.center = CGPointMake(borderView.bounds.size.width / 2, borderView.bounds.size.height / 2);
    [changeButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(changeImage:) forControlEvents:UIControlEventTouchDown];
    
    if (isDefault) {
        
        groupImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [borderView addSubview:changeButton];

        if (self.names.count > 2) {
            groupImageView.image = [UIImage imageNamed:@"userImage"];
        }
        
    } else {
     
        PFFile *file = group[@"avatar"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            if (!error)
                groupImageView.image = [UIImage imageWithData:data];
        }];
        
    }
    
    picsArray = [NSMutableArray new];
    for (int i = 0; i < fbIds.count; i++) {
        //[namesArray addObject:[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]]];

        NSString *fbId = fbIds[i];
        NSString *pfId = parseIds[i];
        
        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10, 7, 36, 36)];
        profPicView.layer.cornerRadius = 18;
        profPicView.layer.masksToBounds = YES;
        profPicView.profileID = fbId;
        profPicView.tag = 9;
        profPicView.accessibilityIdentifier = pfId;
        [picsArray addObject:profPicView];
    }
        
}

- (void)editName {
    
    groupNameLabel.alpha = 0;
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(8, 145, 304, 24)];
    textField.delegate = self;
    textField.text = groupNameLabel.text;
    textField.alpha = 1.0;
    textField.font = [UIFont fontWithName:@"OpenSans-Semibold" size:18.0];
    textField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:textField];
    
    /*
    [UIView animateWithDuration:0.2 animations:^{
        groupNameLabel.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            textField.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }]; */
    
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField becomeFirstResponder];
    [self userIsEditing:YES];
    
}

- (void)textFieldDidEndEditing:(UITextField *)tf {
    [self userIsEditing:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
    [self userIsEditing:NO];
    return YES;
}

- (void)userIsEditing:(BOOL)isEditing {
 
    if (isEditing) {
        
        editItem.title = @"Done";
        editItem.style = UIBarButtonItemStyleDone;
        editItem.tag = 2;
        
    } else {
        
        [textField endEditing:YES];
        editItem.title = @"Edit";
        editItem.style = UIBarButtonItemStylePlain;
        [[groupImageView viewWithTag:765] removeFromSuperview];
        if (!isDefault) {
            [changeButton removeFromSuperview];
        }
        [textField resignFirstResponder];
        editItem.tag = 1;
        [self didNameChange];
        groupNameLabel.alpha = 1;
        [textField removeFromSuperview];

    }
    
}

- (void)didNameChange {
    
    if (![groupNameLabel.text isEqualToString:textField.text] && ![textField.text isEqualToString:@""]) {
        
        NSLog(@"name changed!");
        group[@"name"] = textField.text;
        [group saveEventually];
        
        [self sendMessage:[NSString stringWithFormat:@"%@ %@ renamed the group to \"%@\".", [PFUser currentUser][@"firstName"], [PFUser currentUser][@"lastName"], textField.text] type:@"settings"];
        
        [self.convo.metadata setValue:textField.text forKeyPath:@"title"];
        
        groupNameLabel.text = textField.text;
    }
    
}

- (IBAction)editButtonPressed:(UIBarButtonItem *)sender {
    
    if (sender.tag == 1) {
        [self userIsEditing:YES];
        [self editName];

        if (!isDefault) {
            UIView *maskView = [[UIView alloc] initWithFrame:groupImageView.bounds];
            maskView.backgroundColor = [UIColor lightGrayColor];
            maskView.alpha = 0.5;
            maskView.tag = 765;
            [groupImageView addSubview:maskView];
            [borderView addSubview:changeButton];
        }
        
    } else {
        [self userIsEditing:NO];
    
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    else if (section == 1)
        return [group[@"memberCount"] integerValue];
    else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"add" forIndexPath:indexPath];
        return cell;
        
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"peeps" forIndexPath:indexPath];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:5];
        nameLabel.text = names[indexPath.row];
        
        [[cell viewWithTag:9] removeFromSuperview];
        [cell addSubview:[picsArray objectAtIndex:indexPath.row]];
        
        return cell;
        
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leave" forIndexPath:indexPath];
        return cell;
    }
    
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ((int)indexPath.section == 0) {
     
        NSLog(@"Add participants selected - show friend picker");
        
    } else if (indexPath.section == 1) {
        
        NSLog(@"User selected - Do nothing");

        
    } else if (indexPath.section == 2) {
        
        NSLog(@"Leave group selected - show alert view");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"This action is permanent, and cannot be undone." delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Leave Group", nil];
        alert.delegate = self;
        [alert show];

    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        
        NSLog(@"Nevermind");
        
    } else if (buttonIndex == 1) {
        
        NSLog(@"Leave group - Peace!");
        
        PFUser *currentUser = [PFUser currentUser];
        /*
        [self.convo removeParticipants:[NSSet setWithObject:currentUser.objectId] error:nil];
        
        //NSMutableArray *users = group[@"user_objects"];
        
        for (int i = 0; i < users.count; i++) {
            
            PFUser *user = users[i];
            
            if ([user.objectId isEqualToString:currentUser.objectId]) {
                NSLog(@"Made it!");
                [users removeObjectAtIndex:i];
                break;
            }
        }
        
        NSLog(@"users = %@", users);
        
        group[@"user_objects"] = [NSArray arrayWithArray:users];
        [group incrementKey:@"memberCount" byAmount:@(-1)];
        [group saveInBackground];
        
        
        PFQuery *groupUserQuery = [PFQuery queryWithClassName:@"Group_User"];
        [groupUserQuery whereKey:@"user_id" equalTo:currentUser.objectId];
        [groupUserQuery whereKey:@"group_id" equalTo:group.objectId];
        
        [groupUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
           
            [object deleteInBackground];
            
        }]; */
        
        [self sendMessage:[NSString stringWithFormat:@"%@ %@ has left the group.", currentUser[@"firstName"], currentUser[@"lastName"]] type:@"leave"];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] animated:YES];
    
}

- (void)sendMessage:(NSString *)messageText type:(NSString *)type {
    
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    //Send message w data
    NSDictionary *dataDictionary = @{@"message":messageText,
                                     @"type":type,
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
    NSData *cellInfoDictionaryJSON = [NSJSONSerialization dataWithJSONObject:cellInfoDictionary options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
    LYRMessagePart *cellInfoMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemCellInfo data:cellInfoDictionaryJSON];
    // Add message to ordered set.  This ordered set messages will get sent to the participants
    NSError *error = nil;
    LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart,cellInfoMessagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:&error];
    
    // Creates and returns a new message object with the given conversation and array of message parts
    //LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[messagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:nil];
    
    // Sends the specified message
    BOOL success = [self.convo sendMessage:message error:&error];
    if (success) {
        NSLog(@"Message queued to be sent: %@", message);
    } else {
        NSLog(@"Message send failed: %@", error);
    }
}

- (void)changeImage: (UIGestureRecognizer *) gr {
    
    NSLog(@"Change image!");
    
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
            self.fastCamera.view.frame = groupImageView.frame;
            
            self.fastCamera.view.layer.masksToBounds = YES;
            self.fastCamera.view.layer.cornerRadius = self.fastCamera.view.frame.size.width / 2;
            
            takePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(groupImageView.frame.origin.x + groupImageView.frame.size.width + 15, groupImageView.center.y + 10, 80, 30)];
            [takePictureButton setTitleColor:[UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0] forState:UIControlStateNormal];
            takePictureButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
            takePictureButton.layer.cornerRadius = 4.0;
            takePictureButton.layer.masksToBounds = YES;
            takePictureButton.layer.borderWidth = 1.0;
            takePictureButton.layer.borderColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
            [self.view addSubview:takePictureButton];
            [takePictureButton addTarget:self action:@selector(snapDopePic) forControlEvents:UIControlEventTouchUpInside];
            
            takePictureButton.alpha = 1;
            [takePictureButton setTitle:@"Snap pic" forState:UIControlStateNormal];
            
            flashButton = [[UIButton alloc] initWithFrame:CGRectMake(takePictureButton.frame.origin.x + 10, takePictureButton.frame.origin.y + 30 + 8, 15, 21.6)];
            [flashButton setHitTestEdgeInsets:UIEdgeInsetsMake(-5, -5, -5, -5)];
            [self.view addSubview:flashButton];
            [flashButton addTarget:self action:@selector(flashButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            
            [flashButton setImage:[UIImage imageNamed:@"flash_transp"] forState:UIControlStateNormal];
            flashButton.alpha = 1;
            flashButton.enabled = YES;
            
            switchCameraButton = [[UIButton alloc] initWithFrame:CGRectMake(takePictureButton.frame.origin.x + takePictureButton.frame.size.width - 20 - 10, takePictureButton.frame.origin.y + 30 + 9, 20, 20)];
            [switchCameraButton setHitTestEdgeInsets:UIEdgeInsetsMake(-5, -5, -5, -5)];
            [switchCameraButton addTarget:self action:@selector(switchCameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:switchCameraButton];
            
            [switchCameraButton setImage:[UIImage imageNamed:@"flip"] forState:UIControlStateNormal];
            switchCameraButton.enabled = YES;
            switchCameraButton.alpha = 1;
            
            /*
            if (!chooseImageButton) {
                chooseImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
                chooseImageButton.center = CGPointMake(160, 480);
                [chooseImageButton setTitle:@"Choose Image" forState:UIControlStateNormal];
                chooseImageButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:11.0];
                [chooseImageButton setTitleColor:[UIColor colorWithRed:0.0 green:80.0/255 blue:230.0/255 alpha:1.0] forState:UIControlStateNormal];
                [self.view addSubview:chooseImageButton];
                [chooseImageButton addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
            }
            chooseImageButton.alpha = 1;*/
            
            break;
        }
        case 1: { // Choose Photo
            
            [self chooseImage];
            
            break;
        }
            
        case 2: { // Default
            
            changeButton.alpha = 0;
            
            groupImage = [UIImage imageNamed:@"userImage"];
            groupImageView.image = [UIImage imageNamed:@"userImage"];
            [changeButton removeFromSuperview];
            [self saveImage:groupImage isDefault:YES];
            //[textField becomeFirstResponder];
            
        }
            
        default:
            break;
    }
    
}

- (void)saveImage:(UIImage *)image isDefault:(BOOL)isDefault {
    
    UIView *maskView = [[UIView alloc] initWithFrame:groupImageView.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.0;
    [groupImageView addSubview:maskView];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    indicatorView.center = CGPointMake(groupImageView.bounds.size.width/2, groupImageView.bounds.size.height/2);
    [groupImageView addSubview:indicatorView];
    [indicatorView startAnimating];
    
    [UIView animateWithDuration:0.1 animations:^{
        maskView.alpha = 0.4;
    } completion:^(BOOL finished) {
        [indicatorView startAnimating];
    }];
    
    NSData *imageData = UIImagePNGRepresentation(groupImage);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    
    [group fetchInBackgroundWithBlock:^(PFObject *ob, NSError *error) {
        
        if (!error) {
        
            ob[@"avatar"] = imageFile;
            ob[@"isDefaultImage"] = @(isDefault);
            
            [ob saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
               
                if (success) {
                    
                    [ob pinInBackground];
                    [self sendMessage:[NSString stringWithFormat:@"%@ %@ changed the group's image.", [PFUser currentUser][@"firstName"], [PFUser currentUser][@"lastName"]] type:@"settings"];
                    
                    //[self ]
                    
                    [UIView animateWithDuration:0.1 animations:^{
                    } completion:^(BOOL finished) {
                        [indicatorView stopAnimating];
                        
                        UIImageView *checkImv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
                        checkImv.center = indicatorView.center;
                        checkImv.alpha = 0;
                        checkImv.image = [UIImage imageNamed:@"white_check"];
                        [groupImageView addSubview:checkImv];
                        
                        [UIView animateWithDuration:0.1 animations:^{
                            checkImv.alpha = 1.0;
                        } completion:^(BOOL finished) {
                            
                            [UIView animateWithDuration:0.3 delay:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                checkImv.alpha = 0.0;
                                maskView.alpha = 0.0;
                            } completion:^(BOOL finished) {
                                [checkImv removeFromSuperview];
                                [maskView removeFromSuperview];
                                [indicatorView removeFromSuperview];
                            }];
                        }];
                        
                    }];
                    
                } else {
                    
                    
                }
                
            }];
            
        }

    }];
    
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
    
    //[takePictureButton removeTarget:self action:@selector(snapDopePic) forControlEvents:UIControlEventTouchUpInside];
    //[takePictureButton addTarget:self action:@selector(retakePicture) forControlEvents:UIControlEventTouchUpInside];
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
    [self fastttRemoveChildViewController:self.fastCamera];
    [activityView stopAnimating];
    takePictureButton.enabled = YES;
    
    [takePictureButton removeFromSuperview];
    [flashButton removeFromSuperview];
    [switchCameraButton removeFromSuperview];
    
    groupImage = capturedImage.scaledImage;
    groupImageView.image = groupImage;
    [changeButton removeFromSuperview];

    /*
    if ([textField.text isEqualToString:@""]) {
        [textField becomeFirstResponder];
    }*/
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
    [self saveImage:groupImage isDefault:NO];

    
}

- (void)chooseImage {
    
    [self.fastCamera stopRunning];
    flashButton.alpha = 0;
    switchCameraButton.alpha = 0;
    takePictureButton.alpha = 0;
    chooseImageButton.alpha = 0;
    [self startMediaBrowserFromViewController:self usingDelegate:(self)];
    
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
        groupImageView.image = groupImage;
        [changeButton removeFromSuperview];
        [self saveImage:groupImage isDefault:NO];

    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //[textField becomeFirstResponder];
    
}

-(void)showBoom {
    
    NSLog(@"Boom");
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -66)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
            [SVProgressHUD showSuccessWithStatus:@"Boom"];
            [SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
        });
    });

    names = [NSArray new];
    fbIds = [NSArray new];
    parseIds = [NSArray new];
    
    for (NSDictionary *dict in group[@"user_dicts"]) {
        
        names = [names arrayByAddingObject:[dict valueForKey:@"name"]];
        fbIds = [fbIds arrayByAddingObject:[dict valueForKey:@"id"]];
        parseIds = [parseIds arrayByAddingObject:[dict valueForKey:@"parseId"]];
        
    }
    
    picsArray = [NSMutableArray new];
    for (int i = 0; i < fbIds.count; i++) {
        //[namesArray addObject:[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]]];
        
        NSString *fbId = fbIds[i];
        NSString *pfId = parseIds[i];
        
        FBSDKProfilePictureView *profPicView = [[FBSDKProfilePictureView alloc] initWithFrame:CGRectMake(10, 7, 36, 36)];
        profPicView.layer.cornerRadius = 18;
        profPicView.layer.masksToBounds = YES;
        profPicView.profileID = fbId;
        profPicView.tag = 9;
        profPicView.accessibilityIdentifier = pfId;
        [picsArray addObject:profPicView];
    }
    
    self.groupNameLabel.text = group[@"name"];
    
    [self.tableView reloadData];
    [self.delegate groupChanged];
    
}

-(void)showError:(NSString *)message {
    
    NSLog(@"Error");
    
    [SVProgressHUD setViewForExtension:self.view];
    [SVProgressHUD setOffsetFromCenter:UIOffsetMake(0, -66)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD show];
            [SVProgressHUD showErrorWithStatus:message];
            [SVProgressHUD setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
        });
    });
    
    [self.tableView reloadData];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    
    if ([segue.identifier isEqualToString:@"toAddFriends"]) {
        
        NSLog(@"%@", group);
        GroupAddFriendsTVC *vc = (GroupAddFriendsTVC *)[[segue destinationViewController] topViewController];
        vc.convo = self.convo;
        vc.group = self.group;
        vc.delegate = self;
    }
    
}


@end
