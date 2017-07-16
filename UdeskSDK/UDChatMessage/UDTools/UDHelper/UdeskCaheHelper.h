//
//  UdeskCaheHelper.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "Udesk_YYCache.h"

@interface UdeskCaheHelper : Udesk_YYCache

+ (instancetype)sharedManager;

- (void)storeVideo:(NSData *)videoData videoId:(NSString *)videoId;

- (BOOL)containsObjectForKey:(NSString *)key;

- (NSString *)filePathForkey:(NSString *)key;

- (NSString *)filePath;

@end
