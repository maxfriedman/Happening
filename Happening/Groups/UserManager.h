//
//  UserManager.h
//  
//
//  Created by Max on 6/9/15.
//
//

#import <Foundation/Foundation.h>

@class PFUser;
@class LYRConversation;

@interface UserManager : NSObject

+ (instancetype)sharedManager;

///-------------------------
/// @name Querying for Users
///-------------------------

- (void)queryForUserWithName:(NSString *)searchText completion:(void (^)(NSArray *participants, NSError *error))completion;

- (void)queryForAllUsersWithCompletion:(void (^)(NSArray *users, NSError *error))completion;

///---------------------------
/// @name Accessing User Cache
///---------------------------

- (void)queryAndCacheUsersWithIDs:(NSArray *)userIDs completion:(void (^)(NSArray *participants, NSError *error))completion;

- (PFUser *)cachedUserForUserID:(NSString *)userID;

- (void)cacheUserIfNeeded:(PFUser *)user;

- (NSArray *)unCachedUserIDsFromParticipants:(NSArray *)participants;

- (NSArray *)resolvedNamesFromParticipants:(NSArray *)participants;

@end