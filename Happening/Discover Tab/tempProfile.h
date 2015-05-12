//
//  tempProfile.h
//  Happening
//
//  Created by Max on 4/12/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tempProfile : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@property (strong, nonatomic) IBOutlet UILabel *subLabel;

@property (strong, nonatomic) IBOutlet UIButton *notifyButton;

@property (strong, nonatomic) IBOutlet UILabel *explanationLabel;

@property (assign) NSString *eventID;
@property (assign) NSString *userID;

@end
