//
//  showMyEventVC.m
//  Happening
//
//  Created by Max on 12/2/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "showMyEventVC.h"

@interface showMyEventVC ()

@end

@implementation showMyEventVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.eventIDLabel.text = self.eventID;
    NSLog(@"%@", self.eventID);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if ([segue.identifier isEqualToString:@"toEditEvent"]) {
         
         // Pass along variables
         //self.editEventTVC.eventID = self.eventID;
         
         EditEventTVC* vc = (EditEventTVC *)[[segue destinationViewController] topViewController];
         [vc setEventID:self.eventID];
     
     }
 }

@end
