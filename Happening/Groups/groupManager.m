//
//  groupManager.m
//  Happening
//
//  Created by Max on 6/14/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import "groupManager.h"
#import <Parse/Parse.h>
//#import "PFUser+ATLParticipant.h"
#import <Bolts/Bolts.h>

@interface groupManager ()

@property (nonatomic) NSCache *groupCache;

@end

@implementation groupManager

#pragma mark - Public Methods

+ (instancetype)sharedManager
{
    static groupManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[groupManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.groupCache = [NSCache new];
    }
    return self;
}

#pragma mark Query Methods

- (void)queryForGroupWithName:(NSString *)searchText completion:(void (^)(NSArray *groups, NSError *error))completion
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    query.limit = 1000;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSMutableArray *contacts = [NSMutableArray new];
            for (PFUser *user in objects){
                if ([[NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]] rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [contacts addObject:user];
                }
            }
            if (completion) completion([NSArray arrayWithArray:contacts], nil);
        } else {
            if (completion) completion(nil, error);
        }
    }];
}

- (void)queryForAllGroupsWithCompletion:(void (^)(NSArray *groups, NSError *error))completion;
{
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    query.limit = 1000;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (completion) completion(objects, nil);
        } else {
            if (completion) completion(nil, error);
        }
    }];
}

- (void)queryAndCacheGroupsWithIDs:(NSArray *)groupIDs completion:(void (^)(NSArray *groups, NSError *error))completion;
{
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:@"objectId" containedIn:groupIDs];
    query.limit = 1000;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFObject *group in objects) {
                [self cacheGroupIfNeeded:group];
            }
            if (completion) objects.count > 0 ? completion(objects, nil) : completion(nil, nil);
        } else {
            if (completion) completion(nil, error);
        }
    }];
}

- (PFObject *)cachedGroupForUserID:(NSString *)groupID;
{
    if ([self.groupCache objectForKey:groupID]) {
        return [self.groupCache objectForKey:groupID];
    }
    return nil;
}

- (void)cacheGroupIfNeeded:(PFObject *)group;
{
    if (![self.groupCache objectForKey:group.objectId]) {
        [self.groupCache setObject:group forKey:group.objectId];
    }
}

/*
- (NSArray *)unCachedGroupIDsFromGroups:(NSArray *)groups;
{
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSString *groupID in groups) {
        if ([groupID isEqualToString:[PFUser currentUser].objectId]) continue;
        if (![self.groupCache objectForKey:groupID]) {
            [array addObject:groupID];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

- (NSArray *)resolvedGroupNamesFromGroups:(NSArray *)groups;
{
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *userID in participants) {
        if ([userID isEqualToString:[PFUser currentUser].objectId]) continue;
        if ([self.groupCache objectForKey:userID]) {
            PFUser *user = [self.groupCache objectForKey:userID];
            [array addObject:user[@"firstName"]];
        }
    }
    return [NSArray arrayWithArray:array];
}
*/

@end
