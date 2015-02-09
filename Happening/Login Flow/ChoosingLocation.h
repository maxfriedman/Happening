//
//  ChoosingLocation.h
//  HappeningParse
//
//  Created by Max on 11/7/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"

@protocol ChoosingLocationDelegate <NSObject>

-(void) refreshData;

@end


@interface ChoosingLocation : UIViewController <CLLocationManagerDelegate, UIAlertViewDelegate>

@property (weak) id <ChoosingLocationDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIButton *currentLocButton;
@property (strong, nonatomic) IBOutlet UIButton *choosingLocButton;

@property (strong, nonatomic)CLLocationManager* locManager;

@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UILabel *sliderLabel;

@end
