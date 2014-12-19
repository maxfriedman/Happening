//
//  buttonOverride.m
//  Happening
//
//  Created by Max on 12/5/14.
//  Copyright (c) 2014 Happening LLC. All rights reserved.
//

#import "buttonOverride.h"

@implementation buttonOverride

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {

        self.backgroundColor = [UIColor lightGrayColor];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void) setSelected:(BOOL)selected {
    
    if (selected) {
        
        self.backgroundColor = [UIColor lightGrayColor];
    }
    else {
        self.backgroundColor = [UIColor clearColor];
    }

    
}

@end
