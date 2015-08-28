//
//  CreateHappeningView.m
//  Happening
//
//  Created by Max on 8/2/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "CreateHappeningView.h"
#import "DraggableView.h"
#import "UIButton+Extensions.h"
#import "SVProgressHUD.h"
#import "RKDropdownAlert.h"
#import "CupertinoYankee.h"
#import "LocationConstants.h"
#import "ModalPopup.h"
#import "ProfilePictureView.h"
#import "CustomConstants.h"

@interface CreateHappeningView () <UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FastttCameraDelegate, DraggableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *switchCameraButton;

@end

@implementation CreateHappeningView {
    
    DraggableView *dragView;
    UIView *stepsView;
    UITextField *titleTextField;
    UITextField *locationTextField;
    UITextField *dateTextField;
    UITextField *descriptionTextField;
    
    UIButton *takePictureButton;
    UILabel *changeImageLabel;
    UIActivityIndicatorView *activityView;
    UIImage *eventImage;
    UIButton *chooseImageButton;
    UIButton *changeButton;
    UIView *containerView;
    
    UILabel *inviteLabel;
    UILabel *subInviteLabel;
    
    BOOL addedImage;
    NSDate *eventDate;
    
    UIView *pickerContainerView;
    UIPickerView *catPicker;
    UIDatePicker *datePicker;
    NSArray *pickerRows;
    
    NSArray *selectedIds;
    NSArray *selectedImages;
    NSMutableArray *finalGroupIdArray;
    NSMutableArray *finalUserIdArray;

}

@synthesize flashButton, switchCameraButton;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

        addedImage = NO;
        
    }
    return self;
}

- (void)addDragView {

    if (!dragView) {
        
        dragView = [[DraggableView alloc] initWithFrame:CGRectMake(9, 3, 284, 390)];
        dragView.delegate = self;
        [dragView setEditableCard];
        [dragView.shareButton removeFromSuperview];
        dragView.overlayView.isCreateCard = YES;
        NSMutableArray *sublayers = [NSMutableArray arrayWithArray:dragView.eventImage.layer.sublayers];
        [sublayers removeObjectAtIndex:0];
        dragView.eventImage.layer.sublayers = sublayers;
        
        /* %%%%%%%%%  DragView formatting  %%%%%%%%%%% */
        
        dragView.cardView.layer.borderColor = [UIColor colorWithRed:0 green:185.0/255.0 blue:245.0/255 alpha:1.0].CGColor;
        dragView.eventImage.layer.borderColor = [UIColor colorWithRed:0.0 green:185.0/255.0 blue:245.0/255 alpha:1.0].CGColor;
        [dragView.cardBackground removeFromSuperview];
        
        /* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */

        
        /* %%%%%%%%%  Replacing elements with text views  %%%%%%%%%%% */
        
        
        titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 137, dragView.frame.size.width - 30, 32)];
        titleTextField.font = dragView.title.font;
        titleTextField.textColor = [UIColor darkGrayColor];
        titleTextField.placeholder = @"Title";
        titleTextField.delegate = self;
        [titleTextField setReturnKeyType:UIReturnKeyNext];
        titleTextField.tag = 1;
        [titleTextField clearsOnInsertion];
        [titleTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [dragView.cardView insertSubview:titleTextField belowSubview:dragView.overlayView];
        
        
        locationTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 189.5, dragView.frame.size.width - 30, 21)];
        locationTextField.textColor = dragView.location.textColor;
        locationTextField.font = dragView.location.font;
        locationTextField.placeholder = @"Set a location"; //@"Set a location (optional)";
        locationTextField.delegate = self;
        [locationTextField setReturnKeyType:UIReturnKeyNext];
        locationTextField.tag = 2;
        [locationTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [locationTextField clearsOnInsertion];
        [dragView.cardView addSubview:locationTextField];
        
        
        dateTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 213.5, dragView.frame.size.width - 30, 17)];
        dateTextField.textColor = dragView.date.textColor;
        dateTextField.font = dragView.date.font;
        dateTextField.placeholder = @"Set a date";
        dateTextField.delegate = self;
        [dateTextField setReturnKeyType:UIReturnKeyDone];
        dateTextField.tag = 3;
        [dateTextField clearsOnInsertion];
        
        dateTextField.inputView = [UIView new]; // hides keyboard
        
        [dateTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [dragView.cardView addSubview:dateTextField];
        
        
        changeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        changeButton.center = CGPointMake(dragView.eventImage.bounds.size.width / 2, dragView.eventImage.bounds.size.height / 2 - 20);
        [changeButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [changeButton addTarget:self action:@selector(changeImage) forControlEvents:UIControlEventTouchDown];
        [dragView.cardView addSubview:changeButton];
        
        changeImageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, dragView.frame.size.width, 30)];
        changeImageLabel.font = [UIFont fontWithName:@"OpenSans" size:12.0];
        changeImageLabel.textColor = [UIColor darkGrayColor];
        changeImageLabel.textAlignment = NSTextAlignmentCenter;
        changeImageLabel.text = @"Add an image";
        [dragView.cardView addSubview:changeImageLabel];
        
        
        inviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(dragView.hapLogoButton.frame.size.width + 10 + 15, dragView.hapLogoButton.frame.origin.y,dragView.frame.size.width - dragView.hapLogoButton.frame.size.width - 45, 30)];
        inviteLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:11.0];
        inviteLabel.textColor = [UIColor darkGrayColor];
        inviteLabel.text = @"All nearby friends will see this event";
        [dragView.cardView addSubview:inviteLabel];
        
        subInviteLabel = [[UILabel alloc] initWithFrame:CGRectMake(dragView.hapLogoButton.frame.size.width + 10 + 15, dragView.hapLogoButton.center.y, dragView.frame.size.width - dragView.hapLogoButton.frame.size.width - 40, 30)];
        subInviteLabel.center = CGPointMake(subInviteLabel.center.x, dragView.hapLogoButton.center.y + 7);
        subInviteLabel.font = [UIFont fontWithName:@"OpenSans" size:9.0];
        subInviteLabel.textColor = [UIColor darkGrayColor];
        subInviteLabel.text = @"unless you tap to invite specific friends/groups.";
        [dragView.cardView addSubview:subInviteLabel];
        
        
        
        [dragView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cardTap)]];
        [self addSubview:dragView];
    
        dragView.eventImage.userInteractionEnabled = YES;
        [dragView.eventImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeImage)]];
        

        pickerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, 320, 200)]; //(0, self.frame.size.height - 200, 320, 200)];
        pickerContainerView.alpha = 0;
        pickerContainerView.backgroundColor = [UIColor whiteColor];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 2)];
        lineView.backgroundColor = [UIColor grayColor];
        [pickerContainerView addSubview:lineView];
        
        datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 20, 320, 162)];
        datePicker.alpha = 0;
        [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
        //datePicker.minimumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:-86400]; //24 hours ago
        datePicker.minimumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:0];
        datePicker.maximumDate = [[NSDate alloc]initWithTimeIntervalSinceNow:17280000]; //200 days
        [datePicker setMinuteInterval:15];
        [pickerContainerView addSubview:datePicker];
        
        catPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 38, 320, 162)];
        catPicker.delegate = self;
        catPicker.dataSource  = self;
        catPicker.alpha = 0;
        [pickerContainerView addSubview:catPicker];
        
        UIButton *doneButton = [[UIButton alloc] initWithFrame: CGRectMake(250, 0, 50, 50)];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        doneButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17.0];
        [doneButton setTitleColor:[UIColor colorWithRed:0 green:150.0/255 blue:245.0/255 alpha:1.0] forState:UIControlStateNormal];
        [doneButton addTarget:self action:@selector(makePickerViewDisappear) forControlEvents:UIControlEventTouchUpInside];
        [pickerContainerView addSubview:doneButton];
        
        [self addSubview:pickerContainerView];
        
        
        
        UILabel *swipeWhenDoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 390, 320, 60)];
        swipeWhenDoneLabel.textColor = [UIColor colorWithRed:50.0/255 green:50.0/255 blue:50.0/255 alpha:1.0];
        swipeWhenDoneLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:18.0];
        swipeWhenDoneLabel.textAlignment = NSTextAlignmentCenter;
        swipeWhenDoneLabel.text = @"Swipe down when you're done!";
        [self insertSubview:swipeWhenDoneLabel belowSubview:dragView];
        
        pickerRows = [[NSArray alloc] initWithObjects:@"Nightlife",@"Sports",@"Music", @"Shopping", @"Freebies", @"Happy Hour", @"Dining", @"Entertainment", @"Fundraiser", @"Meetup", @"Other", nil];
    }
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    return pickerRows.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    return pickerRows[row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    return 1;
}

- (void)animatePickerType:(NSString *)type {
    
    pickerContainerView.alpha = 1.0;
    [titleTextField resignFirstResponder];
    [locationTextField resignFirstResponder];
    
    if ([type isEqualToString:@"date"]) {
        
        catPicker.alpha = 0.0;
        datePicker.alpha = 1.0;
        
        [UIView animateWithDuration:0.4 animations:^{
            
            pickerContainerView.frame = CGRectMake(0, self.frame.size.height - 200, 320, 200);

        }];
        
    } else {
        
        datePicker.alpha = 0.0;
        catPicker.alpha = 1.0;
        
        [changeImageLabel removeFromSuperview];
        titleTextField.textColor = [UIColor whiteColor];
        titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.82 alpha:1]}];
        
        UIImage *image = [UIImage imageNamed:[pickerRows objectAtIndex:[catPicker selectedRowInComponent:0]]];
        dragView.eventImage.image = image;
        eventImage = image;
        addedImage = YES;
        
        [self saveImage:image isDefault:YES];
        
        [UIView animateWithDuration:0.4 animations:^{
            
            pickerContainerView.frame = CGRectMake(0, self.frame.size.height - 200, 320, 200);
            
        }];
        
    }
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    UIImage *image = [UIImage imageNamed:[pickerRows objectAtIndex:row]];
    dragView.eventImage.image = image;
    eventImage = image;
    addedImage = YES;
    [self saveImage:image isDefault:YES];
    
    //hashtagDetailLabel.text = [self.hashtagData objectAtIndex:row];
    
}

- (void)dateChanged {
    
    eventDate = datePicker.date;
    NSLog(@"%@", eventDate);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"EEE, MMM d"];
    
    NSString *finalString;
    BOOL funkyDates = NO;
    
    if ([eventDate compare:[NSDate date]] == NSOrderedAscending) {
        
        finalString = [NSString stringWithFormat:@"Happening NOW!"];
        funkyDates = YES;
        [formatter setDateFormat:@"h:mma"];
        
    } else if ([[eventDate beginningOfDay] isEqualToDate:[[NSDate date]beginningOfDay]]) {  // TODAY
        
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"Today at %@", timeString];
        
    } else if ([[eventDate beginningOfDay] isEqualToDate:[[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]]) { // TOMORROW
        
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"Tomorrow at %@", timeString];
        
    } else if ([[eventDate endOfWeek] isEqualToDate:[[NSDate date]endOfWeek]]) { // SAME WEEK
        
        [formatter setDateFormat:@"EEEE"];
        NSString *dayOfWeekString = [formatter stringFromDate:eventDate];
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"%@ at %@", dayOfWeekString, timeString];
        
    } else { // Past this week- uses abbreviated date format
        
        NSString *dateString = [formatter stringFromDate:eventDate];
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
        
    }
    
    finalString = [finalString stringByReplacingOccurrencesOfString:@":00" withString:@" "];
    
    dateTextField.text = finalString;
    
}

- (void)makePickerViewDisappear {

    [dateTextField endEditing:YES];

    [UIView animateWithDuration:0.2 animations:^{
        
        pickerContainerView.frame = CGRectMake(0, self.frame.size.height, 320, 200);
        
    } completion:^(BOOL finished) {
        
        pickerContainerView.alpha = 0;
    }];
    
}

- (void)cardTap {
    
    [titleTextField resignFirstResponder];
    [locationTextField resignFirstResponder];
    [dateTextField resignFirstResponder];
}

- (void)animatingDidStop {
    [titleTextField becomeFirstResponder];
}


- (void)textFieldDidChange:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField.tag == 1 && [titleTextField.text isEqualToString:@""]) {
        //textField.text = @"Title (required)";
    } else if (textField.tag == 2 && [locationTextField.text isEqualToString:@""]) {
        //textField.text = @"Set a location";
    } else if (textField.tag == 3 && [dateTextField.text isEqualToString:@""]) {
        //textField.text = @"Set a date";
    } else if (textField.tag == 3) {
        [textField resignFirstResponder];
    }
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField.tag == 3) {
        [self animatePickerType:@"date"];
    } else {
        [self makePickerViewDisappear];
    }
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)tf {
    
    if (tf.tag == 1) {
        
        if ([titleTextField.text isEqualToString:@""]) {
            
            [self showErrorForTextField:tf];
            
        } else {
            
            [locationTextField becomeFirstResponder];
        
        }
        
        
    } else if (tf.tag == 2) {
        
        [dateTextField becomeFirstResponder];
        
    } else if (tf.tag == 3) {
        
        [tf endEditing:YES];
        
    }
    
    return YES;
}

- (void) showErrorForTextField:(UITextField *)textField {
    
    if (textField.tag == 1) {
        
        [UIView transitionWithView:titleTextField duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}];
            
        } completion:^(BOOL finished) {
            
            if (!addedImage) {
                [UIView transitionWithView:titleTextField duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.75 alpha:1]}];
                } completion:nil];
            } else {
                [UIView transitionWithView:titleTextField duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.83 alpha:1]}];
                } completion:nil];
            }
            
        }];
        
    } else if (textField.tag == 3) {
        
        [UIView transitionWithView:dateTextField duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
            textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Set a date" attributes:@{NSForegroundColorAttributeName: [UIColor redColor]}];
            
        } completion:^(BOOL finished) {
            [UIView transitionWithView:dateTextField duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Set a date" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.75 alpha:1]}];
                } completion:nil];
        }];
        
    }
    
}



- (void)changeImage {
    
    NSLog(@"Change image!");
    
    [self endEditing:YES];
    [self makePickerViewDisappear];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose Photo", @"Use Default", nil];
    [sheet showInView:self];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"index: %lu", buttonIndex);
    
    
    switch (buttonIndex) {
        case 0: { // Take Photo
            
            _fastCamera = [FastttCamera new];
            self.fastCamera.delegate = self;
            
            [self.fastCamera removeFromParentViewController];
            [self.vc fastttAddChildViewController:self.fastCamera];
            self.fastCamera.view.frame = CGRectMake(19, 7, dragView.eventImage.frame.size.width - 2, dragView.eventImage.frame.size.height - 2);
            UIBezierPath *maskPath;
            maskPath = [UIBezierPath bezierPathWithRoundedRect:self.fastCamera.view.bounds
                                             byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                   cornerRadii:CGSizeMake(10.0, 10.0)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.bounds;
            maskLayer.path = maskPath.CGPath;
            self.fastCamera.view.layer.mask = maskLayer;
            
            /*
            UIBezierPath *maskPath;
            maskPath = [UIBezierPath bezierPathWithRoundedRect:dragView.eventImage.bounds
                                             byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                   cornerRadii:CGSizeMake(10.0, 10.0)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.bounds;
            maskLayer.path = maskPath.CGPath;
            eventImage.layer.mask = maskLayer;
            */
             
            //self.fastCamera.view.layer.masksToBounds = YES;
            //self.fastCamera.view.layer.cornerRadius = self.fastCamera.view.frame.size.width / 2;
            
            if (!containerView) {
                containerView = [[UIView alloc] initWithFrame:CGRectMake(19, 7 + dragView.eventImage.frame.size.height + 2, dragView.eventImage.frame.size.width - 2, dragView.frame.size.height - dragView.eventImage.frame.size.height - 4)];
                containerView.backgroundColor = [UIColor whiteColor];
                UIBezierPath *maskPath2;
                maskPath2 = [UIBezierPath bezierPathWithRoundedRect:containerView.bounds
                                                 byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                       cornerRadii:CGSizeMake(10.0, 10.0)];
                CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
                maskLayer2.frame = self.bounds;
                maskLayer2.path = maskPath2.CGPath;
                containerView.layer.mask = maskLayer2;
            }
            [self addSubview:containerView];
            
            if (!takePictureButton) {
                takePictureButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 230, 160, 50)];
                [takePictureButton setTitleColor:[UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0] forState:UIControlStateNormal];
                takePictureButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:17.0];
                takePictureButton.layer.cornerRadius = 4.0;
                takePictureButton.layer.masksToBounds = YES;
                takePictureButton.layer.borderWidth = 1.0;
                takePictureButton.layer.borderColor = [UIColor colorWithRed:0.0 green:176.0/255 blue:242.0/255 alpha:1.0].CGColor;
                [self addSubview:takePictureButton];
                [takePictureButton addTarget:self action:@selector(snapDopePic) forControlEvents:UIControlEventTouchUpInside];
            }
            takePictureButton.alpha = 1;
            [takePictureButton setTitle:@"Snap pic" forState:UIControlStateNormal];
            
            if (!flashButton) {
                flashButton = [[UIButton alloc] initWithFrame:CGRectMake(119, 300, 20.8, 30)];
                [flashButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
                [self addSubview:flashButton];
                [flashButton addTarget:self action:@selector(flashButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            }
            [flashButton setImage:[UIImage imageNamed:@"flash_transp"] forState:UIControlStateNormal];
            flashButton.alpha = 1;
            flashButton.enabled = YES;
            
            if (!switchCameraButton) {
                switchCameraButton = [[UIButton alloc] initWithFrame:CGRectMake(170, 300, 30, 30)];
                [switchCameraButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
                [switchCameraButton addTarget:self action:@selector(switchCameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
                [self addSubview:switchCameraButton];
            }
            [switchCameraButton setImage:[UIImage imageNamed:@"flip"] forState:UIControlStateNormal];
            switchCameraButton.enabled = YES;
            switchCameraButton.alpha = 1;
            
            
            if (!chooseImageButton) {
                chooseImageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
                chooseImageButton.center = CGPointMake(160, 380);
                [chooseImageButton setTitle:@"Choose Image" forState:UIControlStateNormal];
                chooseImageButton.titleLabel.font = [UIFont fontWithName:@"OpenSans" size:11.0];
                [chooseImageButton setTitleColor:[UIColor colorWithRed:0.0 green:80.0/255 blue:230.0/255 alpha:1.0] forState:UIControlStateNormal];
                [self addSubview:chooseImageButton];
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
            
            [self animatePickerType:@"cat"];
            
            /*
            groupImage = [UIImage imageNamed:@"userImage"];
            dragView.eventImage.image = [UIImage imageNamed:@"userImage"];
            [changeButton removeFromSuperview];
            [self saveImage:groupImage isDefault:YES];
            //[textField becomeFirstResponder];
            */
        }
            
        default:
            break;
    }
    
}

- (void)saveImage:(UIImage *)image isDefault:(BOOL)isDefault {
    
    [activityView stopAnimating];
    
    if (!addedImage) {
    
        titleTextField.textColor = [UIColor whiteColor];
        titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.82 alpha:1]}];
        
        CAGradientLayer *l = [CAGradientLayer layer];
        l.frame = dragView.eventImage.bounds;
        l.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9] CGColor], nil];
        
        //l.startPoint = CGPointMake(0.0, 0.7f);
        //l.endPoint = CGPointMake(0.0f, 1.0f);
        l.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.2],
                       [NSNumber numberWithFloat:0.5],
                       //[NSNumber numberWithFloat:0.9],
                       [NSNumber numberWithFloat:1.0], nil];
        
        [dragView.eventImage.layer insertSublayer:l atIndex:0];
        chooseImageButton.alpha = 0;
        
        /*
        UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(9.5, 9.5, 41, 41)];
        whiteView.backgroundColor = [UIColor whiteColor];
        whiteView.layer.cornerRadius = whiteView.frame.size.height/2;
        whiteView.layer.masksToBounds = YES;
        [dragView.cardView addSubview:whiteView];
        */
        
        /*
        UILabel *createdByLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 17, 80, 26)];
        createdByLabel.textColor = [UIColor whiteColor];
        createdByLabel.backgroundColor = [UIColor colorWithRed:30.0/255 green:30.0/255 blue:30.0/255 alpha:1.0];
        createdByLabel.layer.cornerRadius = 3.0;
        createdByLabel.layer.borderWidth = 0.5;
        createdByLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        createdByLabel.clipsToBounds = YES;
        createdByLabel.numberOfLines = 2;
        createdByLabel.text = [NSString stringWithFormat:@"Created by\n%@ %@", [PFUser currentUser][@"firstName"], [PFUser currentUser][@"lastName"]];
        //createdByLabel.textAlignment = NSTextAlignmentRight;
        createdByLabel.font = [UIFont fontWithName:@"OpenSans" size:9.0];
        [dragView.cardView addSubview:createdByLabel];
         */
        
        addedImage = YES;
    }
    
    [changeImageLabel removeFromSuperview];
    [containerView removeFromSuperview];
    ProfilePictureView *ppview = [[ProfilePictureView alloc] initWithFrame:CGRectMake(10, 10, 40, 40) type:@"create" fbid:[PFUser currentUser][@"FBObjectID"]];
    ppview.layer.borderColor = [UIColor whiteColor].CGColor;
    [dragView.cardView addSubview:ppview];
    
    /*
    UIView *maskView = [[UIView alloc] initWithFrame:dragView.eventImage.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.0;
    [dragView.eventImage addSubview:maskView];
    
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    indicatorView.center = CGPointMake(dragView.eventImage.bounds.size.width/2, dragView.eventImage.bounds.size.height/2);
    [dragView.eventImage addSubview:indicatorView];
    
    [UIView animateWithDuration:0.1 animations:^{
        maskView.alpha = 0.4;
    } completion:^(BOOL finished) {
        [indicatorView startAnimating];
    }];
    
    NSData *imageData = UIImagePNGRepresentation(groupImage);
    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    */
    
    /*
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
        
    }]; */
    
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
    [self addSubview:activityView];
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
    [self.vc fastttRemoveChildViewController:self.fastCamera];
    [activityView stopAnimating];
    takePictureButton.enabled = YES;
    
    [takePictureButton removeFromSuperview];
    [flashButton removeFromSuperview];
    [switchCameraButton removeFromSuperview];
    
    eventImage = capturedImage.scaledImage;
    dragView.eventImage.image = eventImage;
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
    eventImage = capturedImage.fullImage;
    [self saveImage:eventImage isDefault:NO];
    
    
}

- (void)chooseImage {
    
    [self.fastCamera stopRunning];
    [changeImageLabel removeFromSuperview];
    [containerView removeFromSuperview];
    flashButton.alpha = 0;
    switchCameraButton.alpha = 0;
    takePictureButton.alpha = 0;
    chooseImageButton.alpha = 0;
    [self startMediaBrowserFromViewController:self.vc usingDelegate:(self)];
    
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
        
        eventImage = imageToUse;
        dragView.eventImage.image = eventImage;
        [changeButton removeFromSuperview];
        [self saveImage:eventImage isDefault:NO];
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //[textField becomeFirstResponder];
    
}

- (void)resignAllResponders {
    
    [titleTextField resignFirstResponder];
    [locationTextField resignFirstResponder];
    
}


- (void)cardSwipedRight:(UIView *)card fromExpandedView:(BOOL)expandedBool isGoing:(BOOL)isGoing {
    
    NSLog(@"MADE IT");
    
    if (titleTextField.text.length == 0) {
        
        [RKDropdownAlert title:@"Don't forget a title!" message:@"Just tap \"Title\" to edit." backgroundColor:[UIColor redColor] textColor:[UIColor whiteColor]];
        
        double delayInSeconds = 0.4;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on the main queue after delay
            
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
                [self insertSubview:dragView belowSubview:pickerContainerView];
                dragView.overlayView.alpha = 0;
                dragView.cardView.center = dragView.originalPoint;
                dragView.cardView.transform = CGAffineTransformMakeRotation(0);
            
            } completion:^(BOOL finished) {
                
                [self showErrorForTextField:titleTextField];
                
            }];
            
        });
        
    } else if (!addedImage) {
        
        [RKDropdownAlert title:@"Nice try!" message:@"Don't forget to add an image." backgroundColor:[UIColor redColor] textColor:[UIColor whiteColor]];
        
        double delayInSeconds = 0.4;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on the main queue after delay
            
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                [self insertSubview:dragView belowSubview:pickerContainerView];
                dragView.overlayView.alpha = 0;
                dragView.cardView.center = dragView.originalPoint;
                dragView.cardView.transform = CGAffineTransformMakeRotation(0);
                
            } completion:^(BOOL finished) {
                
                [self showErrorForTextField:dateTextField];

            }];
            
        });
        
    } else if (locationTextField.text.length == 0) {
        
        [RKDropdownAlert title:@"Where is it?" message:@"Don't forget to set a location." backgroundColor:[UIColor redColor] textColor:[UIColor whiteColor]];
        
        double delayInSeconds = 0.4;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on the main queue after delay
            
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                [self insertSubview:dragView belowSubview:pickerContainerView];
                dragView.overlayView.alpha = 0;
                dragView.cardView.center = dragView.originalPoint;
                dragView.cardView.transform = CGAffineTransformMakeRotation(0);
                
            } completion:^(BOOL finished) {
                
            }];
            
        });
        
    } else if (dateTextField.text.length == 0) {
        
        [RKDropdownAlert title:@"One more thing..." message:@"You gotta set the date!" backgroundColor:[UIColor redColor] textColor:[UIColor whiteColor]];
        
        double delayInSeconds = 0.4;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on the main queue after delay
            
            [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                
                [self insertSubview:dragView belowSubview:pickerContainerView];
                dragView.overlayView.alpha = 0;
                dragView.cardView.center = dragView.originalPoint;
                dragView.cardView.transform = CGAffineTransformMakeRotation(0);
                
            } completion:^(BOOL finished) {
                
            }];
            
        });
        
    } else {
    
    
        NSLog(@"Successfully added fields to create an event! Creating...");
        
        [SVProgressHUD setViewForExtension:self];
        [SVProgressHUD showWithStatus:@"Just a sec..."];
        
        PFUser *currentUser = [PFUser currentUser];
        
        PFObject *event = [PFObject objectWithClassName:@"Event"];
        event[@"Title"] = titleTextField.text;
        NSData *imageData = UIImagePNGRepresentation(eventImage);
        PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
        event[@"Image"] = imageFile;
        
        if (locationTextField.text.length > 0)
            event[@"Location"] = locationTextField.text;
        
        if (dateTextField.text.length > 0)
            event[@"Date"] = eventDate;
        
        event[@"weight"] = @3;
        event[@"globalWeight"] = @1;
        
        
        /*
        if (selectedIds.count > 0) {
            event[@"private"] = @YES;
        } else {
            event[@"private"] = @NO;
        }*/
        
        event[@"private"] = @YES;
        

        PFGeoPoint *userLoc = currentUser[@"userLoc"];
        NSInteger radius = [currentUser[@"radius"] integerValue];
        
        LocationConstants *locConstants = [[LocationConstants alloc] init];
        
        NSString *selectedCity = currentUser[@"userLocTitle"];
        CLLocation *theCityLoc = [locConstants getLocForCity:selectedCity];
        CLLocation *theUserLoc = [[CLLocation alloc] initWithLatitude:userLoc.latitude longitude:userLoc.longitude];
        
        CLLocationDistance distance = [theUserLoc distanceFromLocation:theCityLoc];
        
        //NSLog(@"%f", distance);
        
        CLLocationCoordinate2D finalLoc;
        
        if (distance > 20 * 1609.344 || distance == 0) { // User's current location is > 20 miles outside of the city, use default
            
            NSLog(@"User's current location is > 20 miles outside of the city, use default");
            finalLoc = theCityLoc.coordinate;
            
        } else {
            
            NSLog(@"Use the user's current location!");
            finalLoc = theUserLoc.coordinate;
        }
        
        event[@"GeoLoc"] = [PFGeoPoint geoPointWithLatitude:finalLoc.latitude longitude:finalLoc.longitude];
        event[@"CreatedByName"] = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstName"], currentUser[@"lastName"] ];
        event[@"CreatedByFBID"] = currentUser[@"FBObjectID"];
        event[@"CreatedBy"] = currentUser.objectId;
        if (currentUser.email != nil)
            event[@"ContactEmail"] = currentUser.email;
        
        event[@"swipesLeft"] = @0;
        event[@"swipesRight"] = @1;
        
        NSMutableArray *userIds = [[NSMutableArray alloc] initWithObjects:currentUser[@"FBObjectID"], nil];
        finalUserIdArray = [NSMutableArray new];
        finalGroupIdArray = [NSMutableArray new];
        
        if (selectedIds.count == 0) {
            
            NSArray *friends = currentUser[@"friends"];
            for (NSDictionary *friend in friends) {
                [userIds addObject:[friend valueForKey:@"id"]];
            }
            
            event[@"invitedIds"] = userIds;
            
            [self saveEvent:event];
            
        } else {
            
            __block int count = 0;
            
            for (int i = 0; i < selectedImages.count; i++) {
                
                UIView *view = selectedImages[i];
                NSString *theId = selectedIds[i];
                
                if ([view isKindOfClass:[FBSDKProfilePictureView class]]) {
                    
                    [userIds addObject:theId];
                    [finalUserIdArray addObject:theId];
                    count++;
                    if (count == selectedIds.count) {
                        event[@"invitedIds"] = userIds;
                        [self saveEvent:event];
                    }
                } else {
                    
                    PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
                    [groupQuery fromLocalDatastore];
                    [groupQuery getObjectInBackgroundWithId:theId block:^(PFObject *group, NSError *error) {
                        
                        if (!error) {
                            
                            NSArray *userDicts = group[@"user_dicts"];
                            NSMutableArray *friendIds = [NSMutableArray array];
                            for (NSDictionary *friend in userDicts) {
                                [friendIds addObject:[friend valueForKey:@"id"]];
                            }
                            
                            [userIds addObjectsFromArray:friendIds];
                            [finalGroupIdArray addObject:theId];
                            
                            count++;
                            if (count == selectedIds.count) {
                                event[@"invitedIds"] = userIds;
                                [self saveEvent:event];
                            }
                        }
                        
                    }];
                    
                }
            
                /*
                NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
                if ([theId rangeOfCharacterFromSet:notDigits].location == NSNotFound && theId.length > 12)
                {
                    // newString consists only of the digits 0 through 9 ------ FBID
                    [finalUserIdArray addObject:theId];
                    count++;
                    if (count == selectedIds.count) [self saveEvent:event];
                    
                } else { // group id */
            }
        }
    }
}

- (void)saveEvent:(PFObject *)event {
        
    PFUser *currentUser = [PFUser currentUser];
    
    [event saveInBackgroundWithBlock:^(BOOL success, NSError *error) {
       
        if (success) {
            
            [event pinInBackground];
            
            NSLog(@"USER EVENT CREATED!");
            
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
            [swipesObject pinInBackground];
            [swipesObject saveEventually];
            
            NSString *name = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstName"], currentUser[@"lastName"]];
            
            NSString *locString = locationTextField.text; //[locationTextField.text stringByReplacingOccurrencesOfString:@"at " withString:@""];
            if (locationTextField.text == nil) locString = @"";
            
            
            if (selectedIds.count == 0) {
            
                [PFCloud callFunctionInBackground:@"newUserEvent"
                                   withParameters:@{@"user":currentUser.objectId, @"event":event.objectId, @"fbID":currentUser[@"FBObjectID"], @"fbToken":[FBSDKAccessToken currentAccessToken].tokenString, @"title":event[@"Title"], @"name":name, @"loc":locString, @"eventDate":event[@"Date"]}
                                            block:^(NSString *result, NSError *error) {
                                                if (!error) {
                                                    
                                                    //NSLog(@"%@", result);
                                                }
                                            }];
                
            } else {
                
                __block int saveCount = 0;
                
                PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
                [groupQuery whereKey:@"objectId" containedIn:finalGroupIdArray];
                [groupQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    if (!error) {
                        
                        for (PFObject *group in objects) {
                                    
                            PFObject *groupEvent = [PFObject objectWithClassName:@"Group_Event"];
                            groupEvent[@"EventID"] = event.objectId;
                            groupEvent[@"GroupID"] = group.objectId;
                            groupEvent[@"invitedByName"] = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstName"], currentUser[@"lastName"]];
                            groupEvent[@"invitedByID"] = currentUser.objectId;
                            groupEvent[@"eventObject"] = event;
                            [event pinInBackground];
                            [groupEvent pinInBackground];
                            [groupEvent saveEventually:^(BOOL success, NSError *error) {
                                
                                PFObject *rsvpObject = [PFObject objectWithClassName:@"Group_RSVP"];
                                rsvpObject[@"EventID"] = event.objectId;
                                rsvpObject[@"GroupID"] = group.objectId;
                                rsvpObject[@"Group_Event_ID"] = groupEvent.objectId;
                                rsvpObject[@"UserID"] = currentUser.objectId;
                                rsvpObject[@"User_Object"] = currentUser;
                                rsvpObject[@"UserFBID"] = currentUser[@"FBObjectID"];
                                rsvpObject[@"GoingType"] = @"yes";
                                [rsvpObject pinInBackground];
                                [rsvpObject saveEventually];
                                
                            }];
                            
                            PFObject *timelineObject = [PFObject objectWithClassName:@"Timeline"];
                            timelineObject[@"type"] = @"eventInvite";
                            timelineObject[@"userId"] = currentUser.objectId;
                            timelineObject[@"eventId"] = event.objectId;
                            timelineObject[@"createdDate"] = [NSDate date];
                            timelineObject[@"eventTitle"] = event[@"Title"];
                            [timelineObject pinInBackground];
                            [timelineObject saveEventually];
                            
                            [currentUser incrementKey:@"score" byAmount:@5];
                            [currentUser saveEventually];
                            
                            [self setupConversationWithMessage:[NSString stringWithFormat:@"%@ %@ created a Happening and invited \"%@\" to %@", currentUser[@"firstName"], currentUser[@"lastName"], group[@"name"], event[@"Title"]] forGroup:group event:event];
                            
                            saveCount++;
                            
                        }
                        
                    } else {
                        
                        [SVProgressHUD showErrorWithStatus:@"Group invite failed :("];
                    }
                    
                }];

                
                PFUser *currentUser = [PFUser currentUser];
                PFQuery *userQuery = [PFUser query];
                __block int saveCount2 = 0;
                [userQuery whereKey:@"FBObjectID" containedIn:finalUserIdArray];
                [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error){
                        
                    if (!error) {
                        
                        for (int i = 0; i < users.count; i++) {
                            
                            PFObject *user = (PFObject *)users[i];
                            
                            PFObject *cu = (PFObject *)currentUser;
                            
                            NSMutableArray *usersForGroup = [[NSMutableArray alloc] initWithObjects:user, cu, nil];
                            NSMutableArray *userIds = [NSMutableArray array];
                            for (PFUser *user in usersForGroup) {
                                [userIds addObject:user.objectId];
                            }
                            
                            PFQuery *groupUserQuery1 = [PFQuery queryWithClassName:@"Group_User"];
                            [groupUserQuery1 whereKey:@"user_id" equalTo:currentUser.objectId];
                            
                            NSLog(@"%@", userIds);
                            
                            PFQuery *groupQuery = [PFQuery queryWithClassName:@"Group"];
                            [groupQuery fromLocalDatastore];
                            [groupQuery whereKey:@"user_parse_ids" containsAllObjectsInArray:userIds];
                            [groupQuery whereKey:@"memberCount" equalTo:@2];
                            
                            [groupQuery getFirstObjectInBackgroundWithBlock:^(PFObject *group, NSError *error){
                                
                                BOOL newGroupNewEvent = YES;
                                
                                if (!error) {
                                    
                                    NSLog(@"1-1 group exists!");
                                    newGroupNewEvent = NO;
                                    
                                    NSLog(@"Event in group does NOT exist!");
                                    
                                    PFObject *groupEvent = [PFObject objectWithClassName:@"Group_Event"];
                                    groupEvent[@"EventID"] = event.objectId;
                                    groupEvent[@"GroupID"] = group.objectId;
                                    groupEvent[@"invitedByName"] = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstName"], currentUser[@"lastName"]];
                                    groupEvent[@"invitedByID"] = currentUser.objectId;
                                    groupEvent[@"eventObject"] = event;
                                    [event pinInBackground];
                                    [groupEvent pinInBackground];
                                    [groupEvent saveEventually:^(BOOL success, NSError *error) {
                                        
                                        PFObject *rsvpObject = [PFObject objectWithClassName:@"Group_RSVP"];
                                        rsvpObject[@"EventID"] = event.objectId;
                                        rsvpObject[@"GroupID"] = group.objectId;
                                        rsvpObject[@"Group_Event_ID"] = groupEvent.objectId;
                                        rsvpObject[@"UserID"] = currentUser.objectId;
                                        rsvpObject[@"User_Object"] = currentUser;
                                        rsvpObject[@"UserFBID"] = currentUser[@"FBObjectID"];
                                        rsvpObject[@"GoingType"] = @"yes";
                                        [rsvpObject pinInBackground];
                                        [rsvpObject saveEventually];
                                        
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
                                    
                                    [self setupConversationWithMessage:[NSString stringWithFormat:@"%@ %@ created a Happening and invited you to %@", currentUser[@"firstName"], currentUser[@"lastName"], event[@"Title"]] forGroup:group event:event];
                                    
                                    saveCount++;
                                    
                                }
                                
                                if (newGroupNewEvent) {
                                    
                                    NSLog(@"users do not have a 1-1 group. Create new group and event!");
                                    
                                    PFObject *group = [PFObject objectWithClassName:@"Group"];
                                    group[@"name"] =  [NSString stringWithFormat:@"%@ and %@", currentUser[@"firstName"], user[@"firstName"]]; //[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
                                    group[@"memberCount"] = @2;
                                    group[@"avatar"] = [PFFile fileWithName:@"image.png" data:UIImagePNGRepresentation([UIImage imageNamed:@"userImage"])];
                                    group[@"isDefaultImage"] = @YES;
                                    group[@"isDefaultName"] = @YES;
                                    
                                    NSMutableArray *userDictsArray = [NSMutableArray array];
                                    NSMutableArray *parseArray = [NSMutableArray array];
                                    NSMutableArray *fbArray = [NSMutableArray array];
                                    for (PFUser *user in usersForGroup) {
                                        [parseArray addObject:user.objectId];
                                        [fbArray addObject:user[@"FBObjectID"]];
                                        
                                        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                        
                                        [dict setObject:user.objectId forKey:@"parseId"];
                                        [dict setObject:[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]] forKey:@"name"];
                                        [dict setObject:user[@"FBObjectID"] forKey:@"id"];
                                        [userDictsArray addObject:dict];
                                    }
                                    
                                    group[@"user_parse_ids"] = parseArray;
                                    group[@"user_dicts"] = userDictsArray;
                                    
                                    NSLog(@"%@", group);
                                    
                                    [group saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                                        
                                        NSLog(@"Made it");
                                        
                                        if (success) {
                                            
                                            [group pinInBackground];
                                            
                                            PFObject *groupUser1 = [PFObject objectWithClassName:@"Group_User"];
                                            groupUser1[@"user_id"] = currentUser.objectId;
                                            groupUser1[@"group_id"] = group.objectId;
                                            [groupUser1 saveInBackground];
                                            
                                            PFObject *groupUser2 = [PFObject objectWithClassName:@"Group_User"];
                                            groupUser2[@"user_id"] = user.objectId;
                                            groupUser2[@"group_id"] = group.objectId;
                                            [groupUser2 saveInBackground];
 
                                            PFObject *groupEvent = [PFObject objectWithClassName:@"Group_Event"];
                                            groupEvent[@"EventID"] = event.objectId;
                                            groupEvent[@"GroupID"] = group.objectId;
                                            groupEvent[@"invitedByName"] = [NSString stringWithFormat:@"%@ %@", currentUser[@"firstName"], currentUser[@"lastName"]];
                                            groupEvent[@"invitedByID"] = currentUser.objectId;
                                            groupEvent[@"eventObject"] = event;
                                            [groupEvent pinInBackground];
                                            [event pinInBackground];
                                            [groupEvent saveEventually:^(BOOL success, NSError *error) {
                                                
                                                PFObject *rsvpObject = [PFObject objectWithClassName:@"Group_RSVP"];
                                                rsvpObject[@"EventID"] = event.objectId;
                                                rsvpObject[@"GroupID"] = group.objectId;
                                                rsvpObject[@"Group_Event_ID"] = groupEvent.objectId;
                                                rsvpObject[@"UserID"] = currentUser.objectId;
                                                rsvpObject[@"User_Object"] = currentUser;
                                                rsvpObject[@"UserFBID"] = currentUser[@"FBObjectID"];
                                                rsvpObject[@"GoingType"] = @"yes";
                                                [rsvpObject pinInBackground];
                                                [rsvpObject saveEventually];
                                                
                                            }];
                                            
                                            PFObject *groupCreateTimelineObject = [PFObject objectWithClassName:@"Timeline"];
                                            groupCreateTimelineObject[@"type"] = @"groupCreate";
                                            groupCreateTimelineObject[@"userId"] = currentUser.objectId;
                                            groupCreateTimelineObject[@"createdDate"] = [NSDate date];
                                            [groupCreateTimelineObject pinInBackground];
                                            [groupCreateTimelineObject saveEventually];
                                            
                                            PFObject *eventInviteTimelineObject = [PFObject objectWithClassName:@"Timeline"];
                                            eventInviteTimelineObject[@"type"] = @"eventInvite";
                                            eventInviteTimelineObject[@"userId"] = currentUser.objectId;
                                            eventInviteTimelineObject[@"eventId"] = event.objectId;
                                            eventInviteTimelineObject[@"createdDate"] = [NSDate date];
                                            eventInviteTimelineObject[@"eventTitle"] = event[@"Title"];
                                            [eventInviteTimelineObject pinInBackground];
                                            [eventInviteTimelineObject saveEventually];
                                            
                                            [currentUser incrementKey:@"score" byAmount:@20];
                                            [currentUser saveEventually];
                                            
                                            [self setupConversationWithMessage:[NSString stringWithFormat:@"%@ %@ created a Happening and invited you to %@", currentUser[@"firstName"], currentUser[@"lastName"], event[@"Title"]] forGroup:group event:event];
                                            
                                        } else {
                                            

                                        }
                                    }];
                                }
                            }];
                        }
                    }
                }];
                
            }
            
            
            
            [SVProgressHUD showSuccessWithStatus:@"Boom"];
            
            
            
            PFObject *timelineObject = [PFObject objectWithClassName:@"Timeline"];
            
            timelineObject[@"type"] = @"create";
            
            timelineObject[@"userId"] = [PFUser currentUser].objectId;
            timelineObject[@"eventId"] = event.objectId;
            timelineObject[@"createdDate"] = [NSDate date];
            timelineObject[@"eventTitle"] = event[@"Title"];
            [timelineObject pinInBackground];
            [timelineObject saveEventually];
            
            [currentUser incrementKey:@"score" byAmount:@20];
            [currentUser incrementKey:@"createdCount" byAmount:@1];

            [currentUser saveEventually];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ModalPopup *popup = [storyboard instantiateViewControllerWithIdentifier:@"ModalPopup"];
            popup.eventObject = event;
            popup.eventDateString = dateTextField.text;
            popup.eventImage = dragView.eventImage.image;
            popup.type = @"create";
            [self.vc showModalPopup:popup];
            
            //[self.vc createButtonPressed:nil];
            
            
        } else {
            
            NSLog(@"error: %@", error);
        }
        
    }];

    
}

- (void)setupConversationWithMessage:(NSString *)messageText forGroup:(PFObject *)group event:(PFObject *)event {
    
    
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
        
        NSArray *userObjects = group[@"user_dicts"];
        NSMutableArray *idArray = [NSMutableArray new];
        for (NSDictionary *user in userObjects) {
            [idArray addObject:[user valueForKey:@"parseId"]];
        }
        
        conversation = [appDelegate.layerClient newConversationWithParticipants:[NSSet setWithArray:idArray] options:nil error:&error];
        [conversation setValue:group[@"name"] forMetadataAtKeyPath:@"title"];
        [conversation setValue:group.objectId forMetadataAtKeyPath:@"groupId"];
        
        group[@"chatId"] = conversation.identifier.absoluteString;
        [group saveEventually];
        
    }
    
    if (!conversation || conversation == nil) {
        NSLog(@"New Conversation creation failed: %@", error);
        [SVProgressHUD showErrorWithStatus:@"Something went wrong :("];
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
    NSData *cellInfoDictionaryJSON = [NSJSONSerialization dataWithJSONObject:cellInfoDictionary options:NSJSONWritingPrettyPrinted error:&JSONSerializerError];
    LYRMessagePart *cellInfoMessagePart = [LYRMessagePart messagePartWithMIMEType:ATLMimeTypeSystemCellInfo data:cellInfoDictionaryJSON];
    // Add message to ordered set.  This ordered set messages will get sent to the participants
    LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart,cellInfoMessagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:&error];
    // Sends the specified message
    
    BOOL success = [conversation sendMessage:message error:&error];
    if (success) {
        //NSLog(@"Message queued to be sent: %@", message);
    } else {
        NSLog(@"Message send failed: %@", error);
    }
    
    
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
    BOOL success2 = [conversation sendMessage:message2 error:&error];
    if (success2) {
        NSLog(@"Message queued to be sent: %@", message);
    } else {
        NSLog(@"Message send failed: %@", error);
    }
    
}


/*
- (void)addStepsView {
 
    stepsView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 320, 25)];
    stepsView.backgroundColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0];
 
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 2)];
    lineView.center = CGPointMake(stepsView.frame.size.width / 2, stepsView.frame.size.height / 2);
    lineView.backgroundColor = [UIColor whiteColor];
    [stepsView addSubview:lineView];
 
    UILabel *stepOneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    stepOneLabel.center = CGPointMake(lineView.center.x / 2, lineView.center.y);
    stepOneLabel.layer.masksToBounds = YES;
    stepOneLabel.layer.cornerRadius = stepOneLabel.frame.size.height/2;
    stepOneLabel.backgroundColor = [UIColor whiteColor];
    stepOneLabel.textColor = stepsView.backgroundColor;
    stepOneLabel.font = [UIFont fontWithName:@"OpenSans" size:7.0];
    stepOneLabel.textAlignment = NSTextAlignmentCenter;
    stepOneLabel.text = @"1";
    [stepsView addSubview:stepOneLabel];
 
    UILabel *createLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 10)];
 
    UILabel *stepTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    stepTwoLabel.center = CGPointMake(lineView.center.x * 1.5, lineView.center.y);
    stepTwoLabel.layer.masksToBounds = YES;
    stepTwoLabel.layer.cornerRadius = stepTwoLabel.frame.size.height/2;
    stepTwoLabel.backgroundColor = [UIColor whiteColor];
    stepTwoLabel.textColor = stepsView.backgroundColor;
    stepTwoLabel.font = [UIFont fontWithName:@"OpenSans" size:8.0];
    stepTwoLabel.textAlignment = NSTextAlignmentCenter;
    stepTwoLabel.text = @"2";
    [stepsView addSubview:stepTwoLabel];
 
    [self addSubview:stepsView];
}
 */

- (void)didInviteHomiesWithPics:(NSArray *)pics ids:(NSArray *)ids {
    
    //ProfilePictureView *ppview = [[ProfilePictureView alloc] initWithFrame:CGRectMake(50 * friendCount, 0, 40, 40) type:type fbid:fbid];
    //ppview.parseId = object[@"UserID"];
    //[friendScrollView addSubview:ppview];
    
    NSLog(@"^^^^^^^^^^^^^^^^^^");
    NSLog(@"%@, %@", pics, ids);
    
    for (UIView *view in dragView.friendScrollView.subviews) {
        [view removeFromSuperview];
    }
    
    selectedIds = ids;
    selectedImages = pics;
    
    [subInviteLabel removeFromSuperview];
    
    for (int i = 0; i < pics.count; i++) {
        
        UIView *view = pics[i];
        
        for (UIView *subview in view.subviews) {
            if (subview.tag == 123) [subview removeFromSuperview];
        }
        
        for (UIGestureRecognizer *gr in view.gestureRecognizers) {
            [view removeGestureRecognizer:gr];
        }
        
        view.frame = CGRectMake(50 * i, 0, 40, 40);
        [dragView.friendScrollView addSubview:view];
        dragView.friendScrollView.contentSize = CGSizeMake((50 * i) + 40 + 5, 50);
        
        if (i > 4) {
            dragView.friendArrow.alpha = 1;
        }
        
    }
    
}

- (void)inviteButtonTap {
 
    [self.delegate inviteFromCreateViewTapped];
    
}

@end
