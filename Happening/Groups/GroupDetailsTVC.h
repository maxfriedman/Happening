//
//  GroupDetailsTVC.h
//  Happening
//
//  Created by Max on 6/15/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Atlas/Atlas.h>

@protocol GroupDetailsTVCDelegate <NSObject>

- (void)groupChanged;

@end

@interface GroupDetailsTVC : UITableViewController

@property (weak) id <GroupDetailsTVCDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editItem;
@property PFObject *group;
@property (strong, nonatomic) IBOutlet UIImageView *groupImageView;
@property (strong, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *notiButton;
@property (assign) NSString *groupNameString;
@property LYRConversation *convo;

@property (nonatomic, strong) NSArray *fbIds;
@property (nonatomic, strong) NSArray *parseIds;
@property (nonatomic, strong) NSArray *names;

@end
