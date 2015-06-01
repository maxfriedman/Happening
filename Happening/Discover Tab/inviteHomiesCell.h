//
//  inviteHomiesCell.h
//  Happening
//
//  Created by Max on 5/28/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface inviteHomiesCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet FBSDKProfilePictureView *fbProfPicView;
@property (strong, nonatomic) IBOutlet UIImageView *checkButton;
@property (assign) BOOL pictureLoaded;


@end
