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
    if ([self isPersonalGroup]) {
        
        NSArray *users = self[@"user_objects"];
        PFUser *otherUser = nil;
        for (PFUser *user in users) {
            if (![user isEqual:[PFUser currentUser]]) {
                otherUser = user;
            }
        }
        
        NSArray *friends = [[PFUser currentUser] objectForKey:@"friends"];
        NSMutableArray *idsArray = [NSMutableArray new];
        for (NSDictionary *dict in friends) {
            if ([[dict valueForKey:@"parseId"] isEqualToString:otherUser.objectId])
                return [dict valueForKey:@"name"];
        }

    }

    return self[@"name"];;
}

- (UIImage *)avatarImage
{
    PFFile *file = self[@"avatar"];
    //[file getDataInBackgroundWithBlock:^(NSData *data NSError *error) {
        //return [UIImage imageWithData:data];
    //}];
    
    if (file || [self isPersonalGroup])
        return nil;
    
    return  [UIImage imageNamed:@"userImage"];
    
    //return [UIImage imageWithData:[file getData]];
    //return [UIImage imageNamed:@"checked6green"];
}

- (NSString *)avatarInitials
{
    
    if ([self isPersonalGroup]) {
        
        NSDictionary *dict = [self getOtherUserDict];
        
        NSString *fullName = [dict objectForKey:@"name"];
        NSRange range = [fullName rangeOfString:@" "];
        NSString *fname = [fullName substringToIndex:range.location];
        NSString *lname = [fullName substringFromIndex:range.location+1];
        
        return [NSString stringWithFormat:@"%@%@", [[fname substringToIndex:1] uppercaseString], [[lname substringToIndex:1] uppercaseString]];
    }
    
    return nil; //[NSString stringWithFormat:@"%@%@", [[self.lastName substringToIndex:1] uppercaseString], [[self.firstName substringToIndex:1] uppercaseString]];
}

-(NSURL *)avatarImageURL {
    
    PFFile *file = self[@"avatar"];
    
    if ([self isPersonalGroup]) {

        NSDictionary *dict = [self getOtherUserDict];
        
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [dict objectForKey:@"id"]]];

    }
    
    if (file)
        return [NSURL URLWithString:file.url];
    
    return  nil;
    
    
}


- (BOOL)isPersonalGroup {
    
    NSNumber *memCount = self[@"memberCount"];
    if ([memCount intValue] == 2) {
        return YES;
    }
    
    return NO;
}

-(PFUser *)getOtherParseUser {
    
    // THE OTHER USER
    NSArray *users = self[@"user_objects"];
    for (PFUser *user in users) {
        if (![user isEqual:[PFUser currentUser]]) {
            
            NSArray *friends = [[PFUser currentUser] objectForKey:@"friends"];
            for (NSDictionary *dict in friends) {

                if ([[dict valueForKey:@"parseId"] isEqualToString:user.objectId]) {
                    
                    return user;
                    
                }
            }
        }
    }
    
    return nil;
}

-(NSDictionary *)getOtherUserDict {
    
    // THE OTHER USER
    NSArray *users = self[@"user_objects"];
    for (PFUser *user in users) {
        if (![user isEqual:[PFUser currentUser]]) {
            
            NSArray *friends = [[PFUser currentUser] objectForKey:@"friends"];
            for (NSDictionary *dict in friends) {

                if ([[dict valueForKey:@"parseId"] isEqualToString:user.objectId]) {
                    
                    return dict;
                    
                }
            }
        }
    }
    
    return nil;
}

@end
