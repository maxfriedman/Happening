//
//  groupManager.h
//  Happening
//
//  Created by Max on 6/14/15.
//  Copyright (c) 2015 Happening. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFObject;
@class LYRConversation;

@interface groupManager : NSObject

+ (instancetype)sharedManager;

///-------------------------
/// @name Querying for Users
///-------------------------

- (void)queryForGroupWithName:(NSString *)searchText completion:(void (^)(NSArray *groups, NSError *error))completion;

- (void)queryForAllGroupsWithCompletion:(void (^)(NSArray *groups, NSError *error))completion;

///---------------------------
/// @name Accessing User Cache
///---------------------------

- (void)queryAndCacheGroupsWithIDs:(NSArray *)groupIDs completion:(void (^)(NSArray *groups, NSError *error))completion;

- (PFObject *)cachedGroupForUserID:(NSString *)groupID;

- (void)cacheGroupIfNeeded:(PFObject *)group;

- (NSArray *)unCachedGroupIDsFromGroups:(NSArray *)groups;

- (NSArray *)resolvedGroupNamesFromGroups:(NSArray *)groups;

@end
