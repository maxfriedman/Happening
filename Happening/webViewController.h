//
//  webViewController.h
//  Happening
//
//  Created by Max on 2/17/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface webViewController : UIViewController <UIWebViewDelegate>

-(void)hideToolbar;

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (assign) NSString *urlString;
@property (assign) NSString *titleString;
@property (assign) BOOL shouldHideToolbar;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refresh;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *share;


@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

@end


@interface APActivityProvider3 : UIActivityItemProvider <UIActivityItemSource>
@property (assign) NSString *title;
@property (assign) NSString *urlString;
@property (assign) NSURL *url;
@end

@interface APActivityIcon3 : UIActivity
@end

