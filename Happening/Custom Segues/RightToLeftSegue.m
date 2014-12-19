//
//  RightToLeftSegue.m
//  HappeningParse
//
//  Created by Max on 12/1/14.
//  Copyright (c) 2014 Happening. All rights reserved.
//

#import "RightToLeftSegue.h"

@implementation RightToLeftSegue

-(void)perform {
    
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromRight; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom

    [sourceViewController.view.window.layer addAnimation:transition
                                                  forKey:nil];
    
    [sourceViewController presentViewController:destinationController animated:NO completion:nil];
}

@end
