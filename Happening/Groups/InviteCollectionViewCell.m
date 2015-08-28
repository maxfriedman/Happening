//
//  InviteCollectionViewCell.m
//  Happening
//
//  Created by Max on 6/16/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "InviteCollectionViewCell.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CupertinoYankee.h"

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

@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) LYRConversation *conversation;

@property (strong, nonatomic) NSMutableDictionary *extraSections;
@property (strong, nonatomic) NSMutableArray *rsvpYesArray;
@property (strong, nonatomic) NSMutableArray *rsvpNoArray;
@property (strong, nonatomic) NSMutableArray *rsvpMaybeArray;

@property (strong, nonatomic) UIView *borderView;
@property (strong, nonatomic) UIImageView *rsvpImageView;

@property (strong, nonatomic) UIImageView *cornerImageView;

@end

@implementation InviteCollectionViewCell {

}

@synthesize title, yesButton, noButton, location, calDayLabel, calDayOfWeekLabel, calImageView, calMonthLabel, calTimeLabel, eventImageView, borderColor, currentUser, groupEvent, event, activityView, conversation, extraSections, rsvpMaybeArray, rsvpNoArray, rsvpYesArray, borderView, cornerImageView, rsvpImageView;

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
        
        borderView = [[UIView alloc] initWithFrame:CGRectMake(20, 10, 320-40, frame.size.height - 10)];
        borderView.backgroundColor = [UIColor clearColor];
        borderView.layer.borderColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0].CGColor;
        borderView.layer.borderColor = borderColor.CGColor;
        borderView.layer.borderWidth = 1.0;
        borderView.layer.cornerRadius = 5.0;
        borderView.layer.masksToBounds = YES;
        [self addSubview:borderView];
        
        borderView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toEvent:)];
        gr.cancelsTouchesInView = NO;
        [borderView addGestureRecognizer:gr];
        
        eventImageView = [[UIImageView alloc] initWithFrame:borderView.bounds];
        eventImageView.image = [UIImage imageNamed:@"Nightlife"];
        //eventImageView.alpha = 0.1;
        [borderView addSubview:eventImageView];
        
        [self.eventImageView setContentMode:UIViewContentModeScaleAspectFill];
        self.eventImageView.autoresizingMask =
        ( UIViewAutoresizingFlexibleBottomMargin
         | UIViewAutoresizingFlexibleHeight
         | UIViewAutoresizingFlexibleLeftMargin
         | UIViewAutoresizingFlexibleRightMargin
         | UIViewAutoresizingFlexibleTopMargin
         | UIViewAutoresizingFlexibleWidth );
        
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        
        maskLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:0.8].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:0.6].CGColor, /*(id)[UIColor colorWithWhite:1.0 alpha:0.7].CGColor,*/ (id)[UIColor colorWithWhite:1.0 alpha:0.8].CGColor, nil];
        
        maskLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0],
                               [NSNumber numberWithFloat:0.55],
                               //[NSNumber numberWithFloat:0.7],
                               //[NSNumber numberWithFloat:0.9],
                               [NSNumber numberWithFloat:1.0], nil];
        
        maskLayer.bounds = self.eventImageView.bounds;
        maskLayer.anchorPoint = CGPointZero;
        [self.eventImageView.layer addSublayer:maskLayer];
        
        // Configure Label
        title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, borderView.frame.size.width - 30, 30)];
        //[title setTextAlignment:NSTextAlignmentCenter];
        title.font = [UIFont fontWithName:@"OpenSans-Semibold" size:17.0];
        title.textColor = [UIColor whiteColor];
        title.minimumScaleFactor = 0.7;
        [borderView addSubview:title];
        
        location = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, borderView.frame.size.width - 30, 30)];
        //[location setTextAlignment:NSTextAlignmentCenter];
        location.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        location.textColor = [UIColor whiteColor];
        location.minimumScaleFactor = 0.7;
        [borderView addSubview:location];
        
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

        calImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 70, 50, 50)];
        calImageView.userInteractionEnabled = YES;
        calImageView.image = [UIImage imageNamed:@"calendar light grey"];
        calImageView.alpha = 0;
        [borderView addSubview:calImageView];
        
        UIColor *grayColor = [UIColor colorWithRed:(70.0/255.0) green:(70.0/255.0) blue:(70.0/255.0) alpha:1.0];
        UIColor *lightGrayColor = [UIColor colorWithRed:(164.0/255.0) green:(163.0/255.0) blue:(163.0/255.0) alpha:1.0];
        
        //calMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 230, 20, 20)];
        calMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 40, 40)];
        calMonthLabel.textAlignment = NSTextAlignmentCenter;
        calMonthLabel.font = [UIFont fontWithName:@"OpenSans" size:14.0];
        calMonthLabel.textColor = [UIColor whiteColor];
        calMonthLabel.userInteractionEnabled = YES;
        [borderView addSubview:calMonthLabel];
        
        //calMonthLabel.text = @"JUN";
        
        //calDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(17.5, 238, 20, 20)];
        calDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 86, 40, 40)];
        calDayLabel.textAlignment = NSTextAlignmentCenter;
        calDayLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16.0];
        calDayLabel.textColor = [UIColor whiteColor];
        calDayLabel.minimumScaleFactor = 0.75;
        calDayLabel.adjustsFontSizeToFitWidth = YES;
        calDayLabel.userInteractionEnabled = YES;
        [borderView addSubview:calDayLabel];
        
        //calDayLabel.text = @"23";
        
        
        //calDayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 231, 100, 20)];
        calDayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 71-5, 150, 40)];
        calDayOfWeekLabel.textAlignment = NSTextAlignmentLeft;
        calDayOfWeekLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
        calDayOfWeekLabel.textColor = [UIColor whiteColor];
        calDayOfWeekLabel.userInteractionEnabled = YES;
        [borderView addSubview:calDayOfWeekLabel];
        
        //calDayOfWeekLabel.text = @"Today";
        
        //calTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, 242, 62, 20)];
        calTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 90-5, 150, 40)];
        calTimeLabel.textAlignment = NSTextAlignmentLeft;
        calTimeLabel.font = [UIFont fontWithName:@"OpenSans" size:15.0];
        calTimeLabel.textColor = [UIColor whiteColor];
        calTimeLabel.minimumScaleFactor = 0.75;
        calTimeLabel.adjustsFontSizeToFitWidth = YES;
        calTimeLabel.userInteractionEnabled = YES;
        [borderView addSubview:calTimeLabel];
        
        //calTimeLabel.text = @"8:00PM";
        
         
        yesButton = [[UIButton alloc] initWithFrame: CGRectMake(50, 150 - 10 - 5, 100, 30)];
        yesButton.frame = CGRectMake(1, borderView.frame.size.height - 40, borderView.frame.size.width/2-1, 40);
        [yesButton addTarget:self action:@selector(yesButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //[yesButton setImage:[UIImage imageNamed:@"checked6"] forState:UIControlStateNormal];
        [yesButton setTitle:@"I'm in" forState:UIControlStateNormal];
        //[yesButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
        [yesButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
        yesButton.tag = 0;
        yesButton.enabled = NO;
        
        yesButton.backgroundColor =  [UIColor whiteColor];
        //yesButton.layer.cornerRadius = 15.0;
        //yesButton.layer.borderWidth = 1.0;
        //yesButton.layer.borderColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0].CGColor;
        //yesButton.layer.borderColor = borderColor.CGColor;
        
        noButton = [[UIButton alloc] initWithFrame: CGRectMake(160, 150 - 10 - 5, 100, 30)];
        noButton.frame = CGRectMake(borderView.frame.size.width/2, borderView.frame.size.height - 40, borderView.frame.size.width/2-1, 40);
        [noButton addTarget:self action:@selector(noButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        //[noButton setImage:[UIImage imageNamed:@"close7"] forState:UIControlStateNormal];
        [noButton setTitle:@"I'm out" forState:UIControlStateNormal];
        //[noButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [noButton setTitleColor:borderColor forState:UIControlStateNormal];
        [noButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans" size:15.0]];
        noButton.tag = 0;
        noButton.enabled = NO;
        
        noButton.backgroundColor =  [UIColor whiteColor];
        //noButton.layer.cornerRadius = 15.0;
        //noButton.layer.borderWidth = 1.0;
        //noButton.layer.borderColor = [UIColor colorWithRed:204.0/255 green:204.0/255 blue:204.0/255 alpha:1.0].CGColor;
        //noButton.layer.borderColor = borderColor.CGColor;
        
        [borderView addSubview:yesButton];
        [borderView addSubview:noButton];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, yesButton.frame.size.height)];
        lineView.center = CGPointMake(eventImageView.center.x, yesButton.center.y);
        lineView.backgroundColor = borderColor;
        [borderView addSubview:lineView];
    
                
        UIView *picViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        FBSDKProfilePictureView *ppView = [[FBSDKProfilePictureView alloc] initWithFrame:picViewContainer.bounds];
        ppView.clipsToBounds = YES;
        ppView.layer.cornerRadius = picViewContainer.frame.size.height/2;
        
        [picViewContainer addSubview:ppView];
        picViewContainer.tag = 9;
        
        cornerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 0, 15, 15)];
        cornerImageView.image = [UIImage imageNamed:@"question"];
        cornerImageView.layer.cornerRadius = 7.5;
        cornerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cornerImageView.layer.borderWidth = 1.0;
        [picViewContainer addSubview:cornerImageView];
        
        picViewContainer.center = CGPointMake(230, calImageView.center.y);
        [borderView addSubview:picViewContainer];
        
        /*
        rsvpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [rsvpButton setImage:[UIImage imageNamed:@"Show_more_button_with_three_dots_64"] forState:UIControlStateNormal];
        rsvpButton.center = CGPointMake(picViewContainer.center.x + 25 + 25, picViewContainer.center.y);
        //[borderView addSubview:moreButton];
        rsvpButton.gestureRecognizers = @[];*/
        
        rsvpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        rsvpImageView.image = [UIImage imageNamed:@"Show_more_button_with_three_dots_64"];
        rsvpImageView.center = CGPointMake(picViewContainer.center.x + 25 + 25, picViewContainer.center.y);
        //[borderView addSubview:rsvpImageView];
        
        //[moreButton addTarget:self action:@selector(moreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        /*
        UIView *buttonBorderView = [[UIView alloc] initWithFrame:CGRectMake(0, borderView.frame.size.height - 49, borderView.frame.size.width, 49)];
        buttonBorderView.layer.borderColor = borderColor.CGColor;
        buttonBorderView.layer.borderWidth = 1.0;
        buttonBorderView.clipsToBounds = YES;
        [borderView insertSubview:buttonBorderView aboveSubview:eventImageView];
        */
        //[self shouldDisplayAvatarItem:YES];
    }
    return self;
}

- (void)moreButtonTapped {
    

}

- (void)toEvent:(UITapGestureRecognizer *)gr {
    
    NSLog(@"made it");
    
    CGPoint point = [gr locationInView:rsvpImageView];
    NSLog(@"%f %f", point.x, point.y);
    
    CGRect buttonRect = rsvpImageView.frame;
    
    BOOL didTouchRSVPButton = [rsvpImageView pointInside:point withEvent:nil];
    
    if (!didTouchRSVPButton) {
        
        self.segueType = @"event";
        
    } else {
        
        self.segueType = @"rsvp";
        
    }
    
    if (event != nil) {
        
        
        
    }
    
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
    
}

- (void)loadDataFromParse {
    
    LYRMessagePart *part = self.message.parts[0];
    NSData *data = part.data;
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&error];

    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query fromLocalDatastore];
    [query getObjectInBackgroundWithId:[json objectForKey:@"eventId"] block:^(PFObject *object, NSError *error){

        if (!error) {
            event = object;
            title.text = event[@"Title"];
            location.text = [NSString stringWithFormat:@"at %@", event[@"Location"]];
            
            PFFile *file = event[@"Image"];
            if (file != nil) {
                [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                
                    eventImageView.image = [UIImage imageWithData:data];
                    [activityView stopAnimating];
                }];
            } else {
                [activityView stopAnimating];
            }
            
            [self setDateText];
            
        } else {
            
            PFQuery *query = [PFQuery queryWithClassName:@"Event"];
            [query getObjectInBackgroundWithId:[json objectForKey:@"eventId"] block:^(PFObject *object, NSError *error){
                
                if (!error) {
                    
                    [object pinInBackground];
                    
                    event = object;
                    title.text = event[@"Title"];
                    location.text = [NSString stringWithFormat:@"at %@", event[@"Location"]];
                    
                    PFFile *file = event[@"Image"];
                    if (file != nil) {
                        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                            
                            eventImageView.image = [UIImage imageWithData:data];
                            [activityView stopAnimating];
                        }];
                    } else {
                        [activityView stopAnimating];
                    }
                    
                    [self setDateText];
                    
                } else {
                    
                    
                    
                }
                
            }];
            
        }
        
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
            
            self.rsvpObject = object;
            
            NSString *goingType = object[@"GoingType"];
            if ([goingType isEqualToString:@"yes"]) {
                
                cornerImageView.image = [UIImage imageNamed:@"check75"];
                
                [yesButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                yesButton.backgroundColor = borderColor;
                yesButton.tag = 1;
                
                noButton.backgroundColor = [UIColor whiteColor];
                [noButton setTitleColor:borderColor forState:UIControlStateNormal];
                noButton.tag = 0;
                
            } else if ([goingType isEqualToString:@"no"]) {
                
                cornerImageView.image = [UIImage imageNamed:@"X"];
                
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
        cornerImageView.image = [UIImage imageNamed:@"check75"];
        yesButton.backgroundColor = borderColor;
        yesButton.tag = 1;
        
        noButton.backgroundColor = [UIColor whiteColor];
        [noButton setTitleColor:borderColor forState:UIControlStateNormal];
        noButton.tag = 0;
        
    } else {
        
        yesButton.backgroundColor = [UIColor whiteColor];
        cornerImageView.image = [UIImage imageNamed:@"question"];
        [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
        yesButton.tag = 0;
        
    }
    
    [self reloadRSVPs];
    
}

- (void)noButtonTapped:(UIGestureRecognizer *)gr {
    
    if (noButton.tag == 0) {
        
        [noButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cornerImageView.image = [UIImage imageNamed:@"X"];
        noButton.backgroundColor = borderColor;
        noButton.tag = 1;
        
        yesButton.backgroundColor = [UIColor whiteColor];
        [yesButton setTitleColor:borderColor forState:UIControlStateNormal];
        yesButton.tag = 0;
        
    } else {
        
        noButton.backgroundColor = [UIColor whiteColor];
        cornerImageView.image = [UIImage imageNamed:@"question"];
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
                
                
                NSLog(@"&& Height for cell: %f", actualLineSize);
                
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

- (void)setDateText {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"EEE, MMM d"];
    NSDate *eventDate = [[NSDate alloc]init];
    
    eventDate = self.event[@"Date"];
    
    NSString *finalString;
    BOOL funkyDates = NO;
    NSString *calTimeString = @"";
    
    // FORMAT FOR MULTI-DAY EVENT
    NSDate *endDate = self.event[@"EndTime"];
    
    if ([eventDate compare:[NSDate date]] == NSOrderedAscending && endDate != nil) {
        
        calDayOfWeekLabel.text = @"Happening now!";
        funkyDates = YES;
        [formatter setDateFormat:@"h:mma"];
        calTimeString = [NSString stringWithFormat:@"Now - %@", [formatter stringFromDate:endDate]];
        
    } else if ([[eventDate beginningOfDay] isEqualToDate:[[NSDate date]beginningOfDay]]) {  // TODAY
        
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"Today at %@", timeString];
        calDayOfWeekLabel.text = @"Today";
        calTimeString = timeString;
        
    } else if ([[eventDate beginningOfDay] isEqualToDate:[[NSDate dateWithTimeIntervalSinceNow:86400] beginningOfDay]]) { // TOMORROW
        
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"Tomorrow at %@", timeString];
        
        calDayOfWeekLabel.text = @"Tomorrow";
        
    } else if ([[eventDate endOfWeek] isEqualToDate:[[NSDate date]endOfWeek]]) { // SAME WEEK
        
        [formatter setDateFormat:@"EEEE"];
        NSString *dayOfWeekString = [formatter stringFromDate:eventDate];
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"%@ at %@", dayOfWeekString, timeString];
        
        [formatter setDateFormat:@"EEEE"];
        calDayOfWeekLabel.text = [formatter stringFromDate:eventDate];
        
    } else if (![[eventDate beginningOfDay] isEqualToDate:[endDate beginningOfDay]] && endDate != nil) { //MULTI-DAY EVENT
        
        [formatter setDateFormat:@"MMM d"];
        NSString *dateString = [formatter stringFromDate:eventDate];
        NSString *endDateString = [formatter stringFromDate:endDate];
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        NSString *endTimeString = [formatter stringFromDate:endDate];
        
        finalString = [NSString stringWithFormat:@"%@ at %@ to %@ at %@", dateString, timeString, endDateString, endTimeString];
        
        [formatter setDateFormat:@"EEE"];
        if (endDate != nil) {
            calDayOfWeekLabel.text = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:eventDate], [formatter stringFromDate:endDate]];
        } else {
            calDayOfWeekLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:eventDate]];
        }
        
        //funkyDates = YES;
        //calTimeString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:eventDate], [formatter stringFromDate:endDate]];
        
    } else { // Past this week- uses abbreviated date format
        
        NSString *dateString = [formatter stringFromDate:eventDate];
        [formatter setDateFormat:@"h:mma"];
        NSString *timeString = [formatter stringFromDate:eventDate];
        finalString = [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
        
        [formatter setDateFormat:@"EEEE"];
        calDayOfWeekLabel.text = [formatter stringFromDate:eventDate];
        
    }
    
    if (funkyDates) {
        
        [formatter setDateFormat:@"MMM"];
        calMonthLabel.text = [formatter stringFromDate:eventDate];
        
        [formatter setDateFormat:@"d"];
        NSString *dateSpan = @"";
        
        NSString *startDay =[formatter stringFromDate:eventDate];
        NSString *endDay = [formatter stringFromDate:endDate];
        
        if (![startDay isEqualToString:endDay]) {
            dateSpan = [NSString stringWithFormat:@"%@-%@",startDay,endDay];
        } else {
            dateSpan = startDay;
        }
        
        calDayLabel.text = dateSpan;
        
    } else {
        
        [formatter setDateFormat:@"MMM"];
        calMonthLabel.text = [formatter stringFromDate:eventDate];
        [formatter setDateFormat:@"d"];
        calDayLabel.text = [formatter stringFromDate:eventDate];
        [formatter setDateFormat:@"h:mma"];
        
        if (endDate != nil)
            calTimeString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:eventDate], [formatter stringFromDate:endDate]];
        else
           calTimeString = [NSString stringWithFormat:@"%@", [formatter stringFromDate:eventDate]];
    }
    
    if (endDate == nil) {
        
    }
    
    calTimeString = [calTimeString stringByReplacingOccurrencesOfString:@":00" withString:@" "];
    
    calTimeLabel.text = calTimeString;
    
    finalString = [finalString stringByReplacingOccurrencesOfString:@":00" withString:@" "];
    
    //[dateArray addObject:finalString];
    
    [self checkIfEnded];
}


- (void)checkIfEnded {
    
    NSDate *startDate = self.event[@"Date"];
    NSDate *endDate = self.event[@"EndTime"];
    
    BOOL hasEnded = NO;
    
    [[borderView viewWithTag:90] removeFromSuperview];
    yesButton.enabled = YES;
    noButton.enabled = YES;
    yesButton.userInteractionEnabled = YES;
    noButton.userInteractionEnabled = YES;
    
    if (endDate == nil && [[startDate beginningOfDay] compare:[[NSDate date] beginningOfDay]] == NSOrderedAscending) {
        hasEnded = YES;
    } else if (endDate != nil && [endDate compare:[NSDate date]] == NSOrderedAscending) {
        hasEnded = YES;
    }
    
    if (hasEnded) {
        
        calDayOfWeekLabel.text = @"Event ended";
        
        UIImageView *endedImageView = [[UIImageView alloc] initWithFrame:borderView.bounds];
        endedImageView.tag = 90;
        endedImageView.image = [UIImage imageNamed:@"event ended"];
        [borderView addSubview:endedImageView];
        //self.userInteractionEnabled = NO;
        yesButton.enabled = NO;
        noButton.enabled = NO;
        yesButton.userInteractionEnabled = NO;
        noButton.userInteractionEnabled = NO;
        //[ticketsButton setTitle:@"Tickets no longer available" forState:UIControlStateNormal];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mma"];
        NSString *startTimeString = [formatter stringFromDate:startDate];
        calTimeLabel.text = startTimeString;
        [formatter setDateFormat:@"MMM d"];
        NSString *dateString = [formatter stringFromDate:startDate];
        
        //date.text = [NSString stringWithFormat:@"Started at %@ on %@", startTimeString, dateString];
    }
    
}


@end
