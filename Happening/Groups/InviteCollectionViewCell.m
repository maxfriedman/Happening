//
//  InviteCollectionViewCell.m
//  Happening
//
//  Created by Max on 6/16/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "InviteCollectionViewCell.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface InviteCollectionViewCell ()

@property (strong,nonatomic) UILabel *title;
@property (strong,nonatomic) UILabel *location;
@property (strong,nonatomic) UIButton *yesButton;
@property (strong,nonatomic) UIButton *noButton;
@property (strong,nonatomic) LYRMessage *message;
@property (strong,nonatomic) UIImageView *calImageView;
@property (strong,nonatomic) UILabel *calTimeLabel;
@property (strong,nonatomic) UILabel *calDayOfWeekLabel;
@property (strong,nonatomic) UILabel *calDayLabel;
@property (strong,nonatomic) UILabel *calMonthLabel;
@property (strong,nonatomic) UIImageView *eventImageView;

@end

@implementation InviteCollectionViewCell {
    UIColor *borderColor;
    PFUser *currentUser;
    PFObject *groupEvent;
    PFObject *event;
    UIActivityIndicatorView *activityView;
    LYRConversation *conversation;
    
    NSMutableDictionary *extraSections;
    NSMutableArray *rsvpYesArray;
    NSMutableArray *rsvpNoArray;
    NSMutableArray *rsvpMaybeArray;
}

@synthesize title, yesButton, noButton, location, calDayLabel, calDayOfWeekLabel, calImageView, calMonthLabel, calTimeLabel, eventImageView;

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self)
    {
        currentUser = [PFUser currentUser];
        
        borderColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0];
        
        activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((320/2)-25, (180/2)-25, 50, 50)];
        [activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self addSubview:activityView];
        [activityView startAnimating];
        
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(20, 10, 320-40, frame.size.height - 10)];
        borderView.backgroundColor = [UIColor clearColor];
        //borderView.layer.borderColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0].CGColor;
        borderView.layer.borderColor = borderColor.CGColor;
        borderView.layer.borderWidth = 1.0;
        borderView.layer.cornerRadius = 5.0;
        borderView.layer.masksToBounds = YES;
        [self addSubview:borderView];
        
        eventImageView = [[UIImageView alloc] initWithFrame:borderView.bounds];
        eventImageView.image = [UIImage imageNamed:@"Nightlife"];
        eventImageView.alpha = 0.1;
        [borderView addSubview:eventImageView];
        
        // Configure Label
        title = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 260, 40)];
        [title setTextAlignment:NSTextAlignmentCenter];
        title.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17.0];
        [self addSubview:title];
        
        location = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, 290, 40)];
        [location setTextAlignment:NSTextAlignmentCenter];
        location.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        [self addSubview:location];
        
        self.backgroundColor = [UIColor whiteColor];
        
        // Configure Button
        /*
        _button = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [_button addTarget:self
                    action:@selector(buttonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
        _button.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_button];
        */
        
        
        //calImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 230, 25, 25)];

        calImageView = [[UIImageView alloc] initWithFrame:CGRectMake(65, 70 + 5, 50, 50)];
        calImageView.userInteractionEnabled = YES;
        calImageView.image = [UIImage imageNamed:@"calendar light grey"];
        calImageView.alpha = 0;
        [self addSubview:calImageView];
        
        UIColor *grayColor = [UIColor colorWithRed:(70.0/255.0) green:(70.0/255.0) blue:(70.0/255.0) alpha:1.0];
        UIColor *lightGrayColor = [UIColor colorWithRed:(164.0/255.0) green:(163.0/255.0) blue:(163.0/255.0) alpha:1.0];
        
        //calMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 230, 20, 20)];
        calMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 70 + 5, 40, 40)];
        calMonthLabel.textAlignment = NSTextAlignmentCenter;
        calMonthLabel.font = [UIFont fontWithName:@"OpenSans" size:14.0];
        calMonthLabel.textColor = grayColor;
        calMonthLabel.userInteractionEnabled = YES;
        [self addSubview:calMonthLabel];
        
        calMonthLabel.text = @"JUN";
        
        //calDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 238, 20, 20)];
        calDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 86 + 5, 40, 40)];
        calDayLabel.textAlignment = NSTextAlignmentCenter;
        calDayLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16.0];
        calDayLabel.textColor = grayColor;
        calDayLabel.minimumScaleFactor = 0.75;
        calDayLabel.adjustsFontSizeToFitWidth = YES;
        calDayLabel.userInteractionEnabled = YES;
        [self addSubview:calDayLabel];
        
        calDayLabel.text = @"23";
        
        
        //calDayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 231, 100, 20)];
        calDayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 71, 150, 40)];
        calDayOfWeekLabel.textAlignment = NSTextAlignmentLeft;
        calDayOfWeekLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
        calDayOfWeekLabel.textColor = grayColor;
        calDayOfWeekLabel.userInteractionEnabled = YES;
        [self addSubview:calDayOfWeekLabel];
        
        calDayOfWeekLabel.text = @"Today";
        
        //calTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 242, 62, 20)];
        calTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 90, 150, 40)];
        calTimeLabel.textAlignment = NSTextAlignmentLeft;
        calTimeLabel.font = [UIFont fontWithName:@"OpenSans" size:13.0];
        calTimeLabel.textColor = grayColor;
        calTimeLabel.minimumScaleFactor = 0.75;
        calTimeLabel.adjustsFontSizeToFitWidth = YES;
        calTimeLabel.userInteractionEnabled = YES;
        [self addSubview:calTimeLabel];
        
        calTimeLabel.text = @"8:00PM - 11:00PM";
        
         
        yesButton = [[UIButton alloc] initWithFrame: CGRectMake(50, 150 - 10 - 5, 100, 30)];
        [yesButton addTarget:self action:@selector(yesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //[yesButton setImage:[UIImage imageNamed:@"checked6"] forState:UIControlStateNormal];
        [yesButton setTitle:@"Going" forState:UIControlStateNormal];
        //[yesButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
        [yesButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:13.0]];
        yesButton.tag = 0;
        yesButton.enabled = NO;
        
        yesButton.backgroundColor =  [UIColor whiteColor];
        yesButton.layer.cornerRadius = 15.0;
        yesButton.layer.borderWidth = 1.0;
        //yesButton.layer.borderColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0].CGColor;
        yesButton.layer.borderColor = borderColor.CGColor;
        
        noButton = [[UIButton alloc] initWithFrame: CGRectMake(160, 150 - 10 - 5, 100, 30)];
        [noButton addTarget:self action:@selector(noButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //[noButton setImage:[UIImage imageNamed:@"close7"] forState:UIControlStateNormal];
        [noButton setTitle:@"Can't make it" forState:UIControlStateNormal];
        //[noButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [noButton setTitleColor:borderColor forState:UIControlStateNormal];
        [noButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:12.0]];
        noButton.tag = 0;
        noButton.enabled = NO;
        
        noButton.backgroundColor =  [UIColor whiteColor];
        noButton.layer.cornerRadius = 15.0;
        noButton.layer.borderWidth = 1.0;
        //noButton.layer.borderColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0].CGColor;
        noButton.layer.borderColor = borderColor.CGColor;
        
        [self addSubview:yesButton];
        [self addSubview:noButton];
        
        //[self shouldDisplayAvatarItem:YES];
        
    }
    return self;
}

- (void)buttonTapped:(id)sender {
    // Show message identifer in Alert Dialog
    NSString *alertText = self.message.identifier.description;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello!" message:alertText delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alert addButtonWithTitle:@"Ok"];
    [alert show];
}

- (void)presentMessage:(LYRMessage *)message {
    self.message = message;
    LYRMessagePart *part = message.parts[0];
    
    // if message contains custom mime type then get the text from the MessagePart JSON
    if([part.MIMEType isEqual: ATLMimeTypeCustomObject])
    {
        NSData *data = part.data;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        //title.text = [json objectForKey:@"message"];
        //location.text = @"at Location Name";
        //[title sizeToFit];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
        NSOrderedSet *conversations = [appDelegate.layerClient executeQuery:query error:&error];
        if (!error) {
            
            for (LYRConversation *convo in conversations) {
                
                if ([[convo.metadata valueForKey:@"groupId"] isEqualToString:[json objectForKey:@"groupId"]]) {
                    
                    conversation = convo;
                    break;
                }
            }
        }
        
        [self loadDataFromParse];
        
    }
}

- (void)updateWithSender:(id<ATLParticipant>)sender{
    
    sender = nil;
    return;
}


- (void)shouldDisplayAvatarItem:(BOOL)shouldDisplayAvatarItem{
    
    LYRMessagePart *part = self.message.parts[0];
    
    // if message contains custom mime type then get the text from the MessagePart JSON
    if([part.MIMEType isEqual: ATLMimeTypeCustomObject])
    {
        NSData *data = part.data;
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
        //self.title.text = [json objectForKey:@"message"];
    
        //return YES;
    }
    
}

- (void)loadDataFromParse {
    
    LYRMessagePart *part = self.message.parts[0];
    NSData *data = part.data;
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];

    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:[json objectForKey:@"eventId"] block:^(PFObject *object, NSError *error){

        event = object;
        title.text = event[@"Title"];
        location.text = [NSString stringWithFormat:@"at %@", event[@"Location"]];
        
        PFFile *file = event[@"Image"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        
            eventImageView.image = [UIImage imageWithData:data];
            [activityView stopAnimating];
        }];
        
    }];
    
    
    rsvpMaybeArray = [NSMutableArray array];
    rsvpNoArray = [NSMutableArray array];
    rsvpYesArray = [NSMutableArray array];
    extraSections = [NSMutableDictionary dictionary];

    PFQuery *groupRSVPQuery = [PFQuery queryWithClassName:@"Group_RSVP"];
    [groupRSVPQuery fromLocalDatastore];
    [groupRSVPQuery whereKey:@"EventID" equalTo:[json objectForKey:@"eventId"]];
    [groupRSVPQuery whereKey:@"GroupID" equalTo:[json objectForKey:@"groupId"]];
    [groupRSVPQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        calImageView.alpha = 1.0;
        yesButton.enabled = YES;
        noButton.enabled = YES;
        
        if (!error) {
            
            NSString *goingType = object[@"GoingType"];
            if ([goingType isEqualToString:@"yes"]) {
                
                [yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                yesButton.backgroundColor = borderColor;
                yesButton.tag = 1;
                
                noButton.backgroundColor = [UIColor whiteColor];
                [noButton setTitleColor:borderColor forState:UIControlStateNormal];
                noButton.tag = 0;
                
            } else if ([goingType isEqualToString:@"no"]) {
                
                [noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                noButton.backgroundColor = borderColor;
                noButton.tag = 1;
                
                yesButton.backgroundColor = [UIColor whiteColor];
                [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
                yesButton.tag = 0;
                
            } else {
                
                //maybe
                
            }
            
        } else {
            
            //maybe
            
            
            
        }
        
    }];

    
}


- (void)yesButtonTapped:(UIGestureRecognizer *)gr {
    
    if (yesButton.tag == 0) {
        
        [yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        yesButton.backgroundColor = borderColor;
        yesButton.tag = 1;
        
        noButton.backgroundColor = [UIColor whiteColor];
        [noButton setTitleColor:borderColor forState:UIControlStateNormal];
        noButton.tag = 0;
        
    } else {
        
        yesButton.backgroundColor = [UIColor whiteColor];
        [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
        yesButton.tag = 0;
        
    }
    
    [self reloadRSVPs];
    
}

- (void)noButtonTapped:(UIGestureRecognizer *)gr {
    
    if (noButton.tag == 0) {
        
        [noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        noButton.backgroundColor = borderColor;
        noButton.tag = 1;
        
        yesButton.backgroundColor = [UIColor whiteColor];
        [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
        yesButton.tag = 0;
        
    } else {
        
        noButton.backgroundColor = [UIColor whiteColor];
        [noButton setTitleColor:borderColor forState:UIControlStateNormal];
        noButton.tag = 0;
        
    }
    
    [self reloadRSVPs];

}

- (void)reloadRSVPs {
    
    LYRMessagePart *part = self.message.parts[0];
    NSData *data = part.data;
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];
    
    PFQuery *groupRSVPQuery = [PFQuery queryWithClassName:@"Group_RSVP"];
    [groupRSVPQuery fromLocalDatastore];
    [groupRSVPQuery whereKey:@"EventID" equalTo:[json objectForKey:@"eventId"]];
    [groupRSVPQuery whereKey:@"GroupID" equalTo:[json objectForKey:@"groupId"]];
    [groupRSVPQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        
        PFObject *rsvpObject = [PFObject objectWithClassName:@"Group_RSVP"];
        
        if (!error) {
            
            rsvpObject = object;
            
        } else {
            
            rsvpObject[@"EventID"] = [json objectForKey:@"eventId"];
            rsvpObject[@"GroupID"] = [json objectForKey:@"groupId"];
            //rsvpObject[@"Group_Event_ID"] = groupEventObject.objectId;
            rsvpObject[@"UserID"] = currentUser.objectId;
            rsvpObject[@"UserFBID"] = currentUser[@"FBObjectID"];
            rsvpObject[@"User_Object"] = currentUser;
            //rsvpObject[@"GoingType"] = @"yes"; SET BELOW
            [rsvpObject pinInBackground];
            
        }
        
        if (yesButton.tag == 1) {
            rsvpObject[@"GoingType"] = @"yes";
        } else if (noButton.tag == 1) {
            rsvpObject[@"GoingType"] = @"no";
        } else {
            rsvpObject[@"GoingType"] = @"maybe";
        }
        
        [rsvpObject saveEventually:^(BOOL success, NSError *error){
            
            if (!error && (noButton.tag == 1 || yesButton.tag == 1)) {
                
                NSString *messageText = @"";
                if (yesButton.tag == 1) {
                    messageText = [NSString stringWithFormat:@"%@ %@ is going to '%@'", currentUser[@"firstName"], currentUser[@"lastName"], self.title.text];
                } else if (noButton.tag == 1) {
                    messageText = [NSString stringWithFormat:@"%@ %@ is not going to '%@'", currentUser[@"firstName"], currentUser[@"lastName"], self.title.text];
                }
                
                NSDictionary *dataDictionary = @{@"message":messageText,
                                                 @"type":@"RSVP",
                                                 @"groupId":[json objectForKey:@"groupId"],
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
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                LYRMessage *message = [appDelegate.layerClient newMessageWithParts:@[dataMessagePart,cellInfoMessagePart] options:@{LYRMessageOptionsPushNotificationAlertKey: messageText} error:&error];
                
                // Sends the specified message
                BOOL success = [conversation sendMessage:message error:&error];
                if (success) {
                    //NSLog(@"Message queued to be sent: %@", message);
                } else {
                    NSLog(@"Message send failed: %@", error);
                }
            }
            
        }];
        
    }];
    
    //[self loadPics];
}



@end
