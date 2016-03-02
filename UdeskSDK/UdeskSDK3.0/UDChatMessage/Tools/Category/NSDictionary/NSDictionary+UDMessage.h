//
//  NSDictionary+UDMessage.h
//  UdeskSDK
//
//  Created by xuchen on 16/1/18.
//  Copyright © 2016年 xuchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary(UDMessage)

- (NSNumber *)numberForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (NSDictionary *)dictionaryForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (id)jsonObjectForKey:(id)aKey;

- (void)ud_each:(void (^)(id key, id obj))block;

@end
