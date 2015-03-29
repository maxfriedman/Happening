//
//  showMyEventVC.h
//  Happening
//
//  Created by Max on 12/2/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditEventTVC.h"
#import "DraggableView.h"
#import "FlippedDVB.h"
#import "UICountingLabel.h"
#import "ProfileTVC.h"

@interface showMyEventVC : UIViewController

@property (assign) NSString *eventID;

@property (strong, nonatomic) IBOutlet UILabel *eventIDLabel;

@property (strong, nonatomic) IBOutlet UISegmentedControl *segControl;

@property (strong, nonatomic) IBOutlet UICountingLabel *notInterestedLabel;

@property (strong, nonatomic) IBOutlet UICountingLabel *interestedLabel;

@property (strong, nonatomic) IBOutlet UIButton *websiteButton;

@property (strong, nonatomic)ProfileTVC *profileVC;

@end

@interface APActivityProvider4 : UIActivityItemProvider <UIActivityItemSource>
@property (nonatomic, strong)DraggableView *APdragView;
@end

@interface APActivityIcon4 : UIActivity
@end
