//
//  NSDictionary+UDMessage.m
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import "NSDictionary+UDMessage.h"

@implementation NSDictionary(UDMessage)

- (void)ud_each:(void (^)(id key, id obj))block
{
    NSParameterAssert(block != nil);
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}


- (NSNumber *)numberForKey:(NSString *)key
{
    return [[self objectForKey:key] isKindOfClass:[NSNull class]] ? nil : (NSNumber *)[self objectForKey:key];
}

- (NSString *)stringForKey:(NSString *)key
{
    return [[self objectForKey:key] isKindOfClass:[NSNull class]] ? nil : (NSString *)[self objectForKey:key];
}

- (NSArray *)arrayForKey:(NSString *)key
{
    return [[self objectForKey:key] isKindOfClass:[NSNull class]] ? nil : (NSArray *)[self objectForKey:key];
}

- (NSDictionary *)dictionaryForKey:(NSString *)key
{
    return [[self objectForKey:key] isKindOfClass:[NSNull class]] ? nil : (NSDictionary *)[self objectForKey:key];
}

- (BOOL)boolForKey:(NSString *)key
{
    return [[self objectForKey:key] isKindOfClass:[NSNull class]] ? 0 : [[self objectForKey:key] boolValue];
}

- (id)jsonObjectForKey:(id)aKey {
    id object = [self objectForKey:aKey];
    if ([object isKindOfClass:[NSNull class]]) {
        object = nil;
    }
    
    return object;
}


@end
