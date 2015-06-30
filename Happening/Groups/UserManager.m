//
//  UserManager.m
//  
//
//  Created by Max on 6/9/15.
//
//

#import "UserManager.h"
#import <Parse/Parse.h>
//#import "PFUser+ATLParticipant.h"
#import <Bolts/Bolts.h>

@interface UserManager ()

@property (nonatomic) NSCache *userCache;

@end

@implementation UserManager

#pragma mark - Public Methods

+ (instancetype)sharedManager
{
    static UserManager *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[UserManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userCache = [NSCache new];
    }
    return self;
}

#pragma mark Query Methods

- (void)queryForUserWithName:(NSString *)searchText completion:(void (^)(NSArray *, NSError *))completion
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

- (void)queryForAllUsersWithCompletion:(void (^)(NSArray *, NSError *))completion
{
    PFQuery *query = [PFUser query];
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

- (void)queryAndCacheUsersWithIDs:(NSArray *)userIDs completion:(void (^)(NSArray *, NSError *))completion
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" containedIn:userIDs];
    query.limit = 1000;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (PFUser *user in objects) {
                [self cacheUserIfNeeded:user];
            }
            if (completion) objects.count > 0 ? completion(objects, nil) : completion(nil, nil);
        } else {
            if (completion) completion(nil, error);
        }
    }];
}

- (PFUser *)cachedUserForUserID:(NSString *)userID
{
    if ([self.userCache objectForKey:userID]) {
        return [self.userCache objectForKey:userID];
    }
    return nil;
}

- (void)cacheUserIfNeeded:(PFUser *)user
{
    if (![self.userCache objectForKey:user.objectId]) {
        [self.userCache setObject:user forKey:user.objectId];
    }
}

- (NSArray *)unCachedUserIDsFromParticipants:(NSArray *)participants
{
    NSMutableArray *array = [NSMutableArray new];
    
    for (NSString *userID in participants) {
        if ([userID isEqualToString:[PFUser currentUser].objectId]) continue;
        if (![self.userCache objectForKey:userID]) {
            [array addObject:userID];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

- (NSArray *)resolvedNamesFromParticipants:(NSArray *)participants
{
    NSMutableArray *array = [NSMutableArray new];
    for (NSString *userID in participants) {
        if ([userID isEqualToString:[PFUser currentUser].objectId]) continue;
        if ([self.userCache objectForKey:userID]) {
            PFUser *user = [self.userCache objectForKey:userID];
            [array addObject:user[@"firstName"]];
        }
    }
    return [NSArray arrayWithArray:array];
}

@end
