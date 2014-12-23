//
//  TabBarViewController.m
//  Happening
//
//  Created by Max on 10/10/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //UIColor *normalColor = [UIColor lightTextColor];
    //UIColor *selectedColor = [UIColor whiteColor];
    
    //[self.tabBar setTintColor:selectedColor];
    
    // repeat for every tab, but increment the index each time
    UITabBarItem *firstTab = [self.tabBar.items objectAtIndex:0];
    
    UIImage *createImage = [UIImage imageNamed:@"create"];
    //addImage = [TabBarViewController filledImageFrom:addImage withColor:normalColor];
    
    // also repeat for every tab
    firstTab.selectedImage = [createImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //firstTab.selectedImage = [[UIImage imageNamed:@"add"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *secondTab = [self.tabBar.items objectAtIndex:1];
    UIImage *discoverImage = [UIImage imageNamed:@"discover"];
    //binocularsImage = [TabBarViewController filledImageFrom:binocularsImage withColor:normalColor];

    secondTab.selectedImage = [discoverImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //secondTab.selectedImage = [[UIImage imageNamed:@"addTab"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
   
    UITabBarItem *thirdTab = [self.tabBar.items objectAtIndex:2];
    UIImage *attendImage = [UIImage imageNamed:@"attend"];
    //binocularsImage = [TabBarViewController filledImageFrom:binocularsImage withColor:normalColor];
    
    thirdTab.selectedImage = [attendImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    /*   This burned a string into a calendar image to show today's date
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"d"];
    NSString *dateString = [formatter stringFromDate:date];
    
    UIImage *calImage = [UIImage imageNamed:@"BlankCalTab"];
    UIImage *cal = [TabBarViewController filledImageFrom:calImage withColor:normalColor];
    UIImage *calWithText;
    
    if (dateString.length == 1) {
        calWithText = [TabBarViewController drawText:dateString inImage:cal atPoint:CGPointMake(8, 7) withColor:normalColor];        calImage = [TabBarViewController drawText:dateString inImage:calImage atPoint:CGPointMake(8, 7) withColor:selectedColor];
    } else {
        calWithText = [TabBarViewController drawText:dateString inImage:cal atPoint:CGPointMake(5, 7) withColor:normalColor];
        calImage = [TabBarViewController drawText:dateString inImage:calImage atPoint:CGPointMake(5, 7) withColor:selectedColor];
    }
    thirdTab.image = [calWithText imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    thirdTab.selectedImage = [calImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
    
    */
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans-Semibold" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor darkTextColor]
                                                        } forState:UIControlStateSelected];
 
    
    // doing this results in an easier to read unselected state then the default iOS 7 one
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans-Light" size:10.0f],
                                                        NSForegroundColorAttributeName : [UIColor grayColor]
                                                        } forState:UIControlStateNormal];
    //[[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(40, -15)];
    
}

+ (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color{
    
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
           withColor:(UIColor*)  color
{
    
    UIFont *font = [UIFont fontWithName:@"LetterGothicStd" size:12.0]; // fixed-width font
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [color set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end