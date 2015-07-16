//
//  CategoryBubbleView.m
//  Happening
//
//  Created by Max on 7/8/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "CategoryBubbleView.h"

@implementation CategoryBubbleView

- (id)initWithText:(NSString *)text type:(NSString *)type {
    
    self = [super init];
    if (self) {
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];

        if ([type isEqualToString:@"repeat"]) {
            self.backgroundColor = [UIColor colorWithRed:51.0/255 green:204.0/255 blue:102.0/255 alpha:1.0];

            textLabel.text = text;
            textLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:11.0];
            textLabel.textColor = [UIColor whiteColor];
            [textLabel sizeToFit];
            
            self.frame = CGRectMake(15, 15, textLabel.frame.size.width + 20, 20);
            self.layer.cornerRadius = 10;
            self.layer.masksToBounds = YES;
            
        } else {
            self.backgroundColor = [UIColor colorWithRed:0 green:176.0/255 blue:242.0/255 alpha:1.0];
            
            textLabel.text = text;
            textLabel.font = [UIFont fontWithName:@"OpenSans" size:10.0];
            textLabel.textColor = [UIColor whiteColor];
            [textLabel sizeToFit];
            
            self.frame = CGRectMake(15, 15, textLabel.frame.size.width + 20, 20);
            self.layer.cornerRadius = 10;
            self.layer.masksToBounds = YES;
        }
        
        self.bubbleType = type;
        
        textLabel.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        
        self.tag = 123;
        
        [self addSubview:textLabel];
        
    }
    
    return self;
}

@end
