//
//  HOKDeeplink.h
//  Hoko
//
//  Created by Hoko, S.A. on 23/07/14.
//  Copyright (c) 2015 Hoko, S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Hoko+Nullability.h"

typedef NS_ENUM(NSUInteger, HOKDeeplinkPlatform) {
    HOKDeeplinkPlatformiPhone,
    HOKDeeplinkPlatformiPad,
    HOKDeeplinkPlatformiOSUniversal,
    HOKDeeplinkPlatformAndroid,
    HOKDeeplinkPlatformWeb,
};

@interface HOKDeeplink : NSObject

+ (hok_nonnull instancetype)deeplinkWithRoute:(hok_nullable NSString *)route
                  routeParameters:(hok_nullable NSDictionary *)routeParameters
                  queryParameters:(hok_nullable NSDictionary *)queryParameters;

- (hok_nonnull instancetype)initWithRoute:(hok_nullable NSString *)route
              routeParameters:(hok_nullable NSDictionary *)routeParameters
              queryParameters:(hok_nullable NSDictionary *)queryParameters;

- (void)addURL:(hok_nonnull NSString *)url forPlatform:(HOKDeeplinkPlatform)platform;

@property (nonatomic, strong, readonly, hok_nullable) NSString *route;
@property (nonatomic, strong, readonly, hok_nullable) NSDictionary *queryParameters;
@property (nonatomic, strong, readonly, hok_nullable) NSDictionary *routeParameters;
@property (nonatomic, strong, readonly, hok_nonnull) NSDictionary *json;

@end

