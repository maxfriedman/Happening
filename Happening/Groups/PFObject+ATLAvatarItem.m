//
//  PFObject+ATLAvatarItem.m
//  Happening
//
//  Created by Max on 6/14/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "PFObject+ATLAvatarItem.h"

@implementation PFObject (ATLAvatarItem)

- (NSString *)participantIdentifier
{
    return self.objectId;
}

- (UIImage *)avatarImage
{
    PFFile *file = self[@"avatar"];
    //[file getDataInBackgroundWithBlock:^(NSData *data NSError *error) {
        //return [UIImage imageWithData:data];
    //}];
    
    return [UIImage imageWithData:[file getData]];
    //return [UIImage imageNamed:@"checked6green"];
}

- (NSString *)avatarInitials
{
    return nil; //[NSString stringWithFormat:@"%@%@", [[self.lastName substringToIndex:1] uppercaseString], [[self.firstName substringToIndex:1] uppercaseString]];
}

-(NSURL *)avatarImageURL {
    
    return nil;
    
}

@end
