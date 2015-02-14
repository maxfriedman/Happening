//
//  dropdownSettingsView.h
//  Happening
//
//  Created by Max on 1/26/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol dropdownSettingsViewDelegate

-(void)refreshData;
-(void)dropdownPressed;

@end

@interface dropdownSettingsView : UIView <UITableViewDataSource, UITableViewDelegate>

-(BOOL)didPreferencesChange;

@property (weak) id <dropdownSettingsViewDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITextField *locationField;
@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) IBOutlet UIButton *todayButton;
@property (nonatomic, strong) IBOutlet UIButton *tomorrowButton;
@property (nonatomic, strong) IBOutlet UIButton *weekendButton;

@property (nonatomic, strong) IBOutlet UIImageView *dropdownImageView;

@property (nonatomic, strong) IBOutlet UISlider *slider;

@property (nonatomic, strong) IBOutlet UITableView *categoryTableView;

@property (nonatomic, strong) IBOutlet UIButton *dropdownButton;

@property (nonatomic, strong) IBOutlet UIImageView *cogImageView;

@property (nonatomic, strong) IBOutlet UILabel *topLabel;

@property (nonatomic, strong) IBOutlet UIView *dropdownView;

@end
