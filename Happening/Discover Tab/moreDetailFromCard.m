//
//  moreDetail.m
//  Happening
//
//  Created by Max on 12/1/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "moreDetailFromCard.h"

@interface moreDetailFromCard ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UILabel *locationLabel;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation moreDetailFromCard

@synthesize titleLabel, subtitleLabel, locationLabel, scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    scrollView.scrollEnabled = YES;
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 200)];
    titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:15.0];
    titleLabel.text = self.titleText;
    titleLabel.numberOfLines = 0;
    [titleLabel sizeToFit];
    [scrollView addSubview:titleLabel];
    
    [self layoutLocationLabel];
    
}

- (void)layoutLocationLabel {
    
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, titleLabel.frame.origin.y + titleLabel.frame.size.height + 15, 280, 200)];
    locationLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:14.0];
    locationLabel.text = self.locationText;
    locationLabel.numberOfLines = 0;
    [locationLabel sizeToFit];
    [scrollView addSubview:locationLabel];
    
    [self layoutSubtitleLabel];
}

- (void)layoutSubtitleLabel {
    
    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, locationLabel.frame.origin.y + locationLabel.frame.size.height + 20, 280, 2000)];
    subtitleLabel.font = [UIFont fontWithName:@"OpenSans" size:12.0];
    subtitleLabel.text = self.subtitleText;
    subtitleLabel.numberOfLines = 0;
    [subtitleLabel sizeToFit];
    [scrollView addSubview:subtitleLabel];
    
    if (subtitleLabel.frame.size.height + subtitleLabel.frame.origin.y + 50 > self.view.frame.size.height) {
        scrollView.contentSize = CGSizeMake(self.view.frame.size.width, subtitleLabel.frame.size.height + subtitleLabel.frame.origin.y + 50);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
