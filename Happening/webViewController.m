//
//  webViewController.m
//  Happening
//
//  Created by Max on 2/17/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "webViewController.h"
#import "RKDropdownAlert.h"

@interface webViewController ()

@end

@implementation webViewController

@synthesize webView, urlString, titleString, shouldHideToolbar;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    webView.delegate = self;
    
    if (shouldHideToolbar) {
        [self hideToolbar];
    }
    
    self.navigationController.navigationBar.barTintColor = [UIColor clearColor]; //%%% bartint
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBar"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.topItem.title = titleString;
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideToolbar {
    
    //NSLayoutConstraint *constraint = webView.constraints[3];
    //constraint.constant = cardView.frame.size.height + height;
    
    //NSLog(@"webview constraints: %@", webView.constraints);
    
    //self.toolbar.hidden = YES;
    //webView.scrollView.contentSize =  self.view.frame.size; //CGSizeMake(<#CGFloat width#>, <#CGFloat height#>)
    //webView.frame = self.view.frame;
    //[webView sizeToFit];

    self.forward.enabled = NO;
    self.back.enabled = NO;
    self.share.enabled = NO;
    
    
}

- (void)updateButtons
{
    self.forward.enabled = self.webView.canGoForward;
    self.back.enabled = self.webView.canGoBack;
    //self.share.enabled =! self.webView.isLoading;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}


- (IBAction)xButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        //code
    }];
}

- (IBAction)shareAction:(id)sender {
    
    APActivityProvider3 *ActivityProvider = [[APActivityProvider3 alloc] init];
    ActivityProvider.title = titleString;
    
    NSString *eventUrlString = urlString;
    NSURL *myWebsite = [NSURL URLWithString:eventUrlString];
    ActivityProvider.url = myWebsite;
    ActivityProvider.urlString = urlString;
    
    NSArray *itemsToShare = @[ActivityProvider, myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:itemsToShare applicationActivities:nil];
    
    activityVC.excludedActivityTypes = @[UIActivityTypePrint,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToWeibo,
                                         ];
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    [activityVC setCompletionHandler:^(NSString *act, BOOL done)
     {
         NSString *ServiceMsg = @"Done!";
         BOOL calendarAction = NO;
         
         if ( [act isEqualToString:UIActivityTypeMail] ) {
             ServiceMsg = @"Mail sent!";
         }
         else if ( [act isEqualToString:UIActivityTypePostToTwitter] ) {
             ServiceMsg = @"Your tweet has been posted!";
         }
         else if ( [act isEqualToString:UIActivityTypePostToFacebook] ){
             ServiceMsg = @"Your Facebook status has been updated!";
         }
         else if ( [act isEqualToString:UIActivityTypeMessage] ) {
             ServiceMsg = @"Message sent!";
         } else {
             calendarAction = YES;
         }
         if ( done && (calendarAction == NO) )
         {
             
             // Custom action for other activity types...
             [RKDropdownAlert title:ServiceMsg backgroundColor:[UIColor colorWithRed:.05 green:.29 blue:.49 alpha:1.0] textColor:[UIColor whiteColor]];
             
         }
     }];
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

@implementation APActivityProvider3

@synthesize title, url, urlString;

- (id) activityViewController:(UIActivityViewController *)activityViewController
          itemForActivityType:(NSString *)activityType
{
    
    NSString *shareText = [NSString stringWithFormat:@"%@", title];
    /*
     } else {
     shareText = [NSString stringWithFormat:@"Check out this awesome event: %@, %@ at %@ on %@ %@", title, description, loc, dateString, eventTimeString];
     } */
    
    if ( [activityType isEqualToString:UIActivityTypePostToTwitter] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypePostToFacebook] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypeMessage] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypeMail] ) {
        return shareText;
    }
    if ( [activityType isEqualToString:UIActivityTypeAddToReadingList]) {
        return url;
    }
    if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
        return urlString;
    }
    else
        return nil;

    return nil;
}
- (id) activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController { return @"Testing"; }
@end


