//
//  CreateHappeningVC.m
//  Happening
//
//  Created by Max on 7/30/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "CreateHappeningVC.h"
#import "UIImage+ImageEffects.h"

@interface CreateHappeningVC ()

@end

@implementation CreateHappeningVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    for (UILabel *label in self.orLabels) {
        label.clipsToBounds = YES;
        label.layer.cornerRadius = label.frame.size.width / 2;
    }
    
    for (UIImageView *imv in self.imageViews) {
        
        //UIImage *im = [[UIImage imageNamed:@"party"] applyBlurWithRadius:10.0 tintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.2] saturationDeltaFactor:1.6 maskImage:nil];
        imv.image =  [imv.image applyBlurWithRadius:10.0 tintColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5] saturationDeltaFactor:3.0 maskImage:nil];  //[imv.image applyLightEffect];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)xButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
