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
    if ([self[@"memberCount"] intValue] == 2) {
        
        NSDictionary *dict = [self getOtherUserDict];
        
        NSString *name = [dict valueForKey:@"name"];
        if ([self doesString:name contain:[PFUser currentUser][@"firstName"]]) {
            name = [name stringByReplacingOccurrencesOfString:[PFUser currentUser][@"firstName"] withString:@""];
        
            if ([self doesString:name contain:@"and"]) {
                name = [name stringByReplacingOccurrencesOfString:@"and" withString:@""];
        
                if ([self doesString:name contain:@" "]) {
                    name = [name stringByReplacingOccurrencesOfString:@" " withString:@""];
                
                }
            }
        }
        
        return name;

    }

    return self[@"name"];;
}

-(BOOL)doesString:(NSString *)first contain:(NSString*)other {
    NSRange range = [first rangeOfString:other];
    return range.length != 0;
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
    
    if ([self isPersonalGroup]) {

        NSDictionary *dict = [self getOtherUserDict];
        
        return [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [dict objectForKey:@"id"]]];

    }
    
    PFFile *file = self[@"avatar"];
    
    if (file)
        return [NSURL URLWithString:file.url];
    
    return  nil;
    
    
}


- (BOOL)isPersonalGroup {
    
    NSNumber *memCount = self[@"memberCount"];
    if ([memCount intValue] == 2 && [self[@"isDefaultImage"] boolValue] == YES) {
        return YES;
    }
    
    return NO;
}

-(NSDictionary *)getOtherUserDict {
    
    // THE OTHER USER
    
    NSArray *userDicts = self[@"user_dicts"];
    for (NSDictionary *dict in userDicts) {
        if (![[dict valueForKey:@"parseId"] isEqualToString:[PFUser currentUser].objectId])
            return dict;
    }
    
    return nil;
}

@end
