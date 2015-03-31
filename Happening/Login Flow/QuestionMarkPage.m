//
//  QuestionMarkPage.m
//  Happening
//
//  Created by Max on 3/31/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "QuestionMarkPage.h"
#import "webViewController.h"
#import  <MessageUI/MessageUI.h>

@interface QuestionMarkPage ()

@end

@implementation QuestionMarkPage {
    
    
}

@synthesize scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    
    /*
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 280, 200)];
    titleLabel.center = CGPointMake(self.view.center.x, 75);
    titleLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:20.0];
    titleLabel.text = @"Your best friends,\nthe best events,\nall in one place.";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    //[titleLabel sizeToFit];
    [scrollView addSubview:titleLabel];
*/
    
    
    UILabel *title1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 280, 200)];
    title1.center = CGPointMake(self.view.center.x, 120);
    title1.font = [UIFont fontWithName:@"OpenSans-Semibold" size:18.0];
    title1.text = @"Why do I have to sign in with Facebook?";
    title1.textAlignment = NSTextAlignmentLeft;
    title1.numberOfLines = 0;
    [title1 sizeToFit];
    [scrollView addSubview:title1];
    
    UILabel *subtitle1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 280, 500)];
    subtitle1.center = CGPointMake(self.view.center.x, 160);
    subtitle1.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    subtitle1.text = @"Happening uses Facebook to connect you with your friends, and show you relevant events. We respect your privacy and will never post to Facebook without your permission. If you'd like to use Happening anonymously, you can go to the Settings menu inside of the app and disable \"Social Mode\" after you sign in. Also, we encourage you to look at our privacy policy (below) for more information.";
    subtitle1.textAlignment = NSTextAlignmentLeft;
    subtitle1.numberOfLines = 0;
    //[titleLabel sizeToFit];
    [scrollView addSubview:subtitle1];
    
    
    
    UILabel *title2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 400, 280, 200)];
    title2.center = CGPointMake(self.view.center.x, 380);
    title2.font = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    title2.text = @"Please note that Happening currently only supports Boston and Washington DC. If you'd like to bring Happening near you, let us know!";
    title2.textAlignment = NSTextAlignmentCenter;
    title2.numberOfLines = 0;
    [title2 sizeToFit];
    [scrollView addSubview:title2];
    
    UIButton *privacyButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 440, 100, 30)];
    privacyButton.center = CGPointMake(self.view.center.x / 2, 400);
    [privacyButton setTitle:@"Privacy" forState:UIControlStateNormal];
    privacyButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16.0];
    [privacyButton setTitleColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] forState:UIControlStateNormal];
    [privacyButton addTarget:self action:@selector(privacyAction) forControlEvents:UIControlEventTouchUpInside];
    privacyButton.reversesTitleShadowWhenHighlighted = YES;
    //privacyButton.layer.cornerRadius = 3.0;
    //privacyButton.layer.borderWidth = 2.0;
    //privacyButton.layer.borderColor = [UIColor blueColor].CGColor;
    [scrollView addSubview:privacyButton];
    
    
    UIButton *termsButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 440, 130, 30)];
    termsButton.center = CGPointMake((self.view.center.x * 3 / 2) - 30, 400);
    [termsButton setTitle:@"Terms of Service" forState:UIControlStateNormal];
    termsButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16.0];
    [termsButton setTitleColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] forState:UIControlStateNormal];
    [termsButton addTarget:self action:@selector(termsAction) forControlEvents:UIControlEventTouchUpInside];
    termsButton.reversesTitleShadowWhenHighlighted = YES;
    //privacyButton.layer.cornerRadius = 3.0;
    //privacyButton.layer.borderWidth = 2.0;
    //privacyButton.layer.borderColor = [UIColor blueColor].CGColor;
    [scrollView addSubview:termsButton];
    
    
    
    UIButton *contactButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 450, 100, 30)];
    contactButton.center = CGPointMake(self.view.center.x, 455);
    [contactButton setTitle:@"Contact Us" forState:UIControlStateNormal];
    contactButton.titleLabel.font = [UIFont fontWithName:@"OpenSans-Light" size:16.0];
    [contactButton setTitleColor:[UIColor colorWithRed:0.0 green:184.0/255.0 blue:245.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [contactButton addTarget:self action:@selector(contactUsButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    contactButton.reversesTitleShadowWhenHighlighted = YES;
    contactButton.layer.cornerRadius = 4.0;
    contactButton.layer.borderWidth = 1.0;
    contactButton.layer.borderColor = [UIColor colorWithRed:0.0 green:184.0/255.0 blue:245.0/255.0 alpha:1.0].CGColor;
    [scrollView addSubview:contactButton];
    

    
    //[privacyButton ]
    //[privacyButton setTitleColor:<#(UIColor *)#> forState:<#(UIControlState)#>]
    
    /*
    UILabel *subtitle2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 450, 280, 500)];
    subtitle2.center = CGPointMake(self.view.center.x, 580);
    subtitle2.font = [UIFont fontWithName:@"OpenSans" size:13.0];
    subtitle2.text = @"Your best friends,\nthe best events,\nall in one place.";
    subtitle2.textAlignment = NSTextAlignmentCenter;
    subtitle2.numberOfLines = 0;
    //[titleLabel sizeToFit];
    [scrollView addSubview:subtitle2];
     */
    
    //scrollView.contentSize = CGSizeMake(320, 1000);
    
}


- (void)contactUsButtonTapped {
    
    NSLog(@"Contact Us Tapped");

    // Email Content
    NSString *messageBody = @"How can we help?";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"hello@happening.city"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    //[mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:nil];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissVC:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        //code
    }];
    
}

-(void)privacyAction {
    [self performSegueWithIdentifier:@"toPP" sender:self];
}

-(void)termsAction {
    [self performSegueWithIdentifier:@"toT" sender:self];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"toPP"]) {
        
        webViewController *vc = (webViewController *)[segue.destinationViewController topViewController];
        vc.urlString = @"http://www.happening.city/privacy";
        vc.titleString = @"Privacy Policy";
        vc.shouldHideToolbar = YES;
        
    } else if ([segue.identifier isEqualToString:@"toT"]) {
        
        webViewController *vc = (webViewController *)[segue.destinationViewController topViewController];
        vc.urlString = @"http://www.happening.city/terms";
        vc.titleString = @"Terms of Service";
        vc.shouldHideToolbar = YES;
        
    }
    
}


@end
